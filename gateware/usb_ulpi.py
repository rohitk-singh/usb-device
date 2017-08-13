from migen import *
from migen.fhdl.specials import Tristate
from migen.fhdl import verilog
from migen.fhdl.decorators import ClockDomainsRenamer
from migen.genlib.fifo import AsyncFIFO, SyncFIFO

import subprocess


class USB_ULPI(Module):
    clk = Signal()  # USB 60MHz clock
    data = Signal(8)  # Bidirectional
    dir = Signal()  # Input
    nxt = Signal()  # Input
    stp = Signal(reset=1)  # Output
    reset = Signal()  # Output

    data_t = TSTriple(8).get_tristate(data)  # TriState

    axi_slave_layout = [
        ("awaddr", 32),  # , DIR_M_TO_S),
        ("awprot", 3),  # , DIR_M_TO_S),
        ("awvalid", 1),  # DIR_M_TO_S),
        ("awready", 1),  # , DIR_S_TO_M),
        ("wdata", 32),  # , DIR_M_TO_S),
        ("wstrb", 4),  # DIR_M_TO_S),
        ("wvalid", 1),  # DIR_M_TO_S),
        ("wready", 1),  # DIR_S_TO_M),
        ("bresp", 2),  # DIR_S_TO_M),
        ("bvalid", 1),  # DIR_S_TO_M),
        ("bready", 1),  # DIR_M_TO_S),
        ("araddr", 32),  # DIR_M_TO_S),
        ("arprot", 3),  # DIR_M_TO_S),
        ("arvalid", 1),  # DIR_M_TO_S),
        ("arready", 1),  # DIR_S_TO_M),
        ("rdata", 32),  # DIR_S_TO_M),
        ("rresp", 2),  # DIR_S_TO_M),
        ("rvalid", 1),  # DIR_S_TO_M),
        ("rready", 1),  # DIR_M_TO_S),
    ]

    axi_reg_layout = [
        ("data_w", 32),
        ("data_r", 32),
        ("we", 1),
        ("re", 1),
        ("writable", 1),
        ("readable", 1)
    ]

    def __init__(self):
        self.specials += self.data_t

        self.isRxCmd = Signal()
        self.rx_data = Signal(8)
        rx_fifo_we = Signal()
        self.debug = Signal(8)

        past_rx_cmd = Signal(8)
        current_rx_cmd = Signal(8)


        # ULPI Register Write signals. USB clock domain
        ulpi_reg_wr_addr = Signal(6)
        ulpi_reg_wr_data = Signal(8)
        ulpi_reg_wr_trig = Signal()
        ulpi_reg_wr_busy = Signal()
        ulpi_reg_wr_done = Signal()
        ulpi_reg_wr_queue = Signal()

        # ULPI Register Read signals. USB clock domain
        ulpi_reg_rd_addr = Signal(6)
        ulpi_reg_rd_data = Signal(8)
        ulpi_reg_rd_trig = Signal()
        ulpi_reg_rd_busy = Signal()
        ulpi_reg_rd_done = Signal()
        ulpi_reg_rd_queue = Signal()

        self.sync.usb += [
            If(ulpi_reg_wr_trig, ulpi_reg_wr_queue.eq(1)),
            If(ulpi_reg_rd_trig, ulpi_reg_rd_queue.eq(1)),
        ]

        fsm = self.fsm = ClockDomainsRenamer("usb")(FSM(reset_state="RESET"))
        self.submodules += fsm

        fsm.act("RESET",
            If(~self.dir,
                NextValue(self.data_t.o, 0x00),
                NextState("IDLE"),
            )
        )

        fsm.act("IDLE",
            If(self.dir,  # & self.nxt,
                NextState("RX")
            ).Elif(ulpi_reg_wr_queue,
                NextState("REG_WR_CMD"),
                NextValue(self.data_t.o, Cat(ulpi_reg_wr_addr, Constant(value=2, bits_sign=2))),
                NextValue(ulpi_reg_wr_queue, 0),
                NextValue(ulpi_reg_wr_busy, 1),
                NextValue(ulpi_reg_wr_done, 0),
            ).Elif(ulpi_reg_rd_queue,
                NextState("REG_RD_CMD"),
                NextValue(self.data_t.o, Cat(ulpi_reg_rd_addr, Constant(value=3, bits_sign=2))),
                NextValue(ulpi_reg_rd_queue, 0),
                NextValue(ulpi_reg_rd_busy, 1),
                NextValue(ulpi_reg_rd_done, 0),

            )
        )

        fsm.act("RX",
            NextValue(self.isRxCmd, 0x0),
            If(self.dir & ~self.nxt,
                NextValue(self.rx_data, self.data_t.i),
                NextValue(self.isRxCmd, 0x1),
            ).Elif(self.dir & self.nxt,
                NextValue(self.rx_data, self.data_t.i)
            ).Elif(~self.dir & ~self.nxt,
                NextState("IDLE"),
            )
        )

        fsm.act("REG_WR_CMD",
            If(~self.dir & self.nxt,
               NextState("REG_WR_DATA"),
               NextValue(self.data_t.o, ulpi_reg_wr_data),
            ).Elif(self.dir,  # & self.nxt,
                NextState("RX"),  # Reg write aborted during Reg Write TXCMD cycle
                NextValue(self.data_t.o, 0x00),
            )
        )

        fsm.act("REG_WR_DATA",
            If(~self.dir & self.nxt,
                NextState("REG_WR_STP"),
                NextValue(self.stp, 1),
            ).Elif(self.dir & self.nxt,
                NextState("RX"),  # Reg write aborted during write data cycle
            ),
            NextValue(self.data_t.o, 0x00),
        )

        fsm.act("REG_WR_STP",
            If(~self.dir & ~self.nxt,
                NextState("IDLE"),
            ).Elif(self.dir & self.nxt,
                NextState("RX"),  # Register write followed immediately by a USB receive during stp assertion
            ),
            NextValue(self.data_t.o, 0x00),
            NextValue(ulpi_reg_wr_busy, 0),
            NextValue(ulpi_reg_wr_done, 1),
        )

        fsm.act("REG_RD_CMD",
            If(self.nxt & ~self.dir,
                NextState("REG_RD_TURNAROUND"),
            ).Elif(self.nxt & self.dir,  # Reg read aborted by PHY during TX_CMD due to receive
                NextState("RX"),
                NextValue(self.data_t.o, 0x00),
            ),

        )

        fsm.act("REG_RD_TURNAROUND",
            If(self.dir & self.nxt,   # Reg read aborted by PHY during turnaround due to receive
                NextState("RX")
            ).Elif(self.dir & ~self.nxt,
                NextState("REG_RD_DATA"),
            ),
            NextValue(self.data_t.o, 0x00),
        )

        fsm.act("REG_RD_DATA",
            If(self.dir & ~self.nxt,
               NextState("RX"),
               NextValue(ulpi_reg_rd_data, self.data_t.i),
               NextValue(ulpi_reg_rd_busy, 0),
               NextValue(ulpi_reg_rd_done, 1),
            )
        )

        self.sync.usb += [
            If(self.dir & ~self.nxt & fsm.ongoing("RX"),
                past_rx_cmd.eq(current_rx_cmd),
                current_rx_cmd.eq(self.data_t.i)
            )
        ]

        se0 = Signal()
        j_state = Signal()
        k_state = Signal()
        se1 = Signal()

        squelch = Signal()
        n_squelch = Signal()
        FULL_SPEED = 0; HIGH_SPEED = 1
        mode = FULL_SPEED  # 0: Full Speed, 1: High Speed
        self.comb += [
            se0.eq((current_rx_cmd[0:2] == 0b00) & (mode == FULL_SPEED)),
            j_state.eq((current_rx_cmd[0:2] == 0b01) & (mode == FULL_SPEED)),
            k_state.eq((current_rx_cmd[0:2] == 0b10) & (mode == FULL_SPEED)),
            se1.eq((current_rx_cmd[0:2] == 0b11) & (mode == FULL_SPEED)),

            squelch.eq((current_rx_cmd[0:2] == 0b00) & (mode == HIGH_SPEED)),
            n_squelch.eq((current_rx_cmd[0:2] == 0b01) & (mode == HIGH_SPEED)),
        ]


        rx_fifo = self.rx_fifo = ClockDomainsRenamer("usb")(SyncFIFO(9, 20480))  # ClockDomainsRenamer({"write": "usb", "read": "sys"})(AsyncFIFO(9, 2048))
        self.submodules += rx_fifo
        self.sync.usb += [
            self.stp.eq(0),  # ~rx_fifo.writable)  # No need to stop. Always receive unless FIFO full. FIXME stp

            rx_fifo.we.eq(rx_fifo_we)  # Delay we assertion since we are delaying data too in fsm's NextValue
        ]

        self.comb += [
            self.data_t.oe.eq(~self.dir),  # Tristate output enable

            rx_fifo_we.eq(fsm.ongoing("RX") & self.dir & rx_fifo.writable),
            rx_fifo.din.eq(Cat(self.rx_data, self.isRxCmd)),
            # rx_fifo.we.eq(fsm.ongoing("RX") & self.dir & rx_fifo.writable)
        ]

        self.attach_axi_slave(16)

        self.comb += [
            self.axi_reg[0].data_r.eq(Cat(rx_fifo.dout[:8], Constant(0, bits_sign=23), rx_fifo.dout[8])),
            self.axi_reg[0].readable.eq(rx_fifo.readable),
            rx_fifo.re.eq(self.axi_reg[0].re),

            self.axi_reg[1].data_r.eq(rx_fifo.readable),

            # ULPI Register
            ulpi_reg_wr_addr.eq(self.axi_reg[2].data_w[0:6]),
            ulpi_reg_wr_data.eq(self.axi_reg[3].data_w[0:8]),
            ulpi_reg_wr_trig.eq(self.get_rising_edge(self.axi_reg[4].data_w[0])),
            self.axi_reg[5].data_r.eq(Cat(ulpi_reg_wr_busy, ulpi_reg_wr_done)),

            ulpi_reg_rd_addr.eq(self.axi_reg[6].data_w[0:6]),
            self.axi_reg[7].data_r.eq(ulpi_reg_rd_data),
            ulpi_reg_rd_trig.eq(self.get_rising_edge(self.axi_reg[8].data_w[0])),
            self.axi_reg[9].data_r.eq(Cat(ulpi_reg_rd_busy, ulpi_reg_rd_done)),
        ]

        self.comb += [self.axi_reg[i].writable.eq(1) for i in range(16)]

        # self.comb += [
        #     self.debug.eq(Cat(ulpi_reg_rd_busy, ulpi_reg_rd_done, ulpi_reg_rd_trig, ulpi_reg_rd_queue, ulpi_reg_wr_busy, ulpi_reg_wr_done, ulpi_reg_wr_trig, ulpi_reg_wr_queue))
        # ]
        self.sync.usb += [
            If(ulpi_reg_wr_trig, self.debug[0].eq(1)),
            If(ulpi_reg_rd_trig, self.debug[1].eq(1)),
        ]

    def attach_axi_slave(self, num_regs=4):
        self.axi = Record(self.axi_slave_layout, name="axi")
        axi_awaddr = self.axi_awaddr = Signal(32)
        axi_araddr = self.axi_araddr = Signal(32)
        wr_en = Signal()
        rd_en = Signal()

        self.axi_reg = Array([Record(self.axi_reg_layout) for i in range(num_regs)])

        self.comb += [
            wr_en.eq(self.axi.wready & self.axi.wvalid & self.axi.awready & self.axi.awvalid),
            rd_en.eq(~self.axi.rvalid & self.axi.arready & self.axi.arvalid),
        ]

        self.sync.usb += [
            # AWREADY assertion
            If(~self.axi.awready & self.axi.awvalid & self.axi.wvalid,
                self.axi.awready.eq(1),
                axi_awaddr.eq(self.axi.awaddr),
            ).Else(
                self.axi.awready.eq(0)
            ),

            # WREADY assertion
            If(~self.axi.wready & self.axi.wvalid & self.axi.awvalid,
                self.axi.wready.eq(1),
            ).Else(
                self.axi.wready.eq(0)
            ),

            # BVALID and BRESP assertion
            If(self.axi.awready & self.axi.awvalid & ~self.axi.bvalid & self.axi.wready & self.axi.wvalid,
               self.axi.bvalid.eq(1),
               self.axi.bresp.eq(0),
            ).Else(
                If(self.axi.bready & self.axi.bvalid,
                    self.axi.bvalid.eq(0),
                )
            ),

            # ARREADY assertion
            If(~self.axi.arready & self.axi.arvalid,
                self.axi.arready.eq(1),
                axi_araddr.eq(self.axi.araddr)
            ).Else(
                self.axi.arready.eq(0),
            ),

            # RVALID assertion
            If(self.axi.arready & self.axi.arvalid & ~self.axi.rvalid,
                self.axi.rvalid.eq(1),
                self.axi.rresp.eq(0),
            ).Elif(self.axi.rvalid & self.axi.rready,
                self.axi.rvalid.eq(0),
            ),
        ]

        self.sync.usb += [
            If(wr_en,
                [
                    If((axi_awaddr[2:2+log2_int(num_regs)] == i) & self.axi_reg[i].writable,
                        self.axi_reg[i].data_w.eq(self.axi.wdata),
                        self.axi_reg[i].we.eq(1)
                    )
                    for i in range(num_regs)
                ]
            ).Else(
                [
                    self.axi_reg[i].we.eq(0) for i in range(num_regs)
                ]
            ),

            If(rd_en,
                [
                    If((axi_araddr[2:2+log2_int(num_regs)] == i),
                        self.axi.rdata.eq(self.axi_reg[i].data_r),
                        self.axi_reg[i].re.eq(self.axi_reg[i].readable)
                    )
                    for i in range(num_regs)
                ]
            ).Else(
                [
                    self.axi_reg[i].re.eq(0) for i in range(num_regs)
                ]
            ),
        ]

    def get_rising_edge(self, signal):
        signal_r = Signal()
        self.sync.usb += signal_r.eq(signal)
        return signal & ~signal_r

    def get_falling_edge(self, signal):
        signal_r = Signal()
        self.sync.usb += signal_r.eq(signal)
        return signal_r & ~signal

    def get_ios(self):
        ios = {self.data, self.dir, self.nxt, self.stp, self.reset, self.debug}
#               self.rx_fifo.dout, self.rx_fifo.re, self.rx_fifo.readable}
        ios.update(set(self.axi.flatten()))
        # ios.update(set(self.axi_if.flatten()))
        return ios


class USB_ULPI_Top(Module):
    def __init__(self):
            self.dir = Signal()  # Input
            self.nxt = Signal()  # Input
            self.stp = Signal()  # Output
            self.reset = Signal()  # Output

            self.dout = Signal(9)
            self.re = Signal()
            self.readable = Signal()

            self.usb = USB_ULPI()
            self.submodules += self.usb

            self.comb += [
                self.usb.dir.eq(self.dir),
                self.usb.nxt.eq(self.nxt),
                self.stp.eq(self.usb.stp),
                self.usb.reset.eq(self.reset),

                self.dout.eq(self.usb.rx_fifo.dout),
                self.readable.eq(self.usb.rx_fifo.readable),
                self.usb.rx_fifo.re.eq(self.re),
            ]


if __name__ == '__main__':
    m = USB_ULPI()
    if isinstance(m, USB_ULPI):
        f = open("usb_ulpi.v", 'w')
        usb_ulpi_verilog = verilog.convert(m, ios=m.get_ios(), name="usb_ulpi")
        f.write(str(usb_ulpi_verilog))
        # usb_ulpi_verilog.write("usb_ulpi1.v")
        f.close()
        print(usb_ulpi_verilog)
    elif isinstance(m, USB_ULPI_Top):
        print(verilog.convert(m, ios={m.usb.data, m.dir, m.nxt, m.stp, m.reset, m.dout, m.re, m.readable}))
