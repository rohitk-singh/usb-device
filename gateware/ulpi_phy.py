from migen import *
from migen.fhdl.specials import Tristate
from migen.fhdl import verilog
from migen.fhdl.decorators import ClockDomainsRenamer
from migen.genlib.fifo import AsyncFIFO, SyncFIFO


class USB_ULPI_PHY(Module):
    clk = Signal()  # USB 60MHz clock
    data = Signal(8)  # Bidirectional
    dir = Signal()  # Input
    nxt = Signal()  # Input
    stp = Signal(reset=1)  # Output
    reset = Signal()  # Output

    # data_t = TSTriple(8).get_tristate(data)  # TriState
    data_i = Signal(8)
    data_o = Signal(8)
    data_oe = Signal(reset=1)  # At reset, drive bus with 0x00 data, hence enable output drivers

    def __init__(self):
        # self.specials += self.data_t

        # Receive Channel
        rx_data = self.rx_data = Signal(8)     # Data from USB ULPI Phy to Link/SIE
        rx_valid = self.rx_valid = Signal()    # Asserted when rx_data is valid USB raw data
        rx_active = self.rx_active = Signal()  # Indicates that the receive state machine has detected SYNC and is active
        rx_error = self.rx_error = Signal()    # Receive error has been detected
        rx_is_cmd = self.rx_is_cmd = Signal()  # `rx_data` is actually an RXCMD, asserted only for one clock cycle

        # RX Implementation Notes
        #   USB RX Data when rx_valid and rx_active are asserted
        #   RXCMD when rx_is_cmd is asserted and, rx_active/rx_valid are active

        # Transmit Channel
        tx_data = self.tx_data = Signal(8)     # Data from Link/SIE to USB ULPI Phy
        tx_valid = self.tx_valid = Signal()    # Asserted when `tx_data` is valid USB data or TXCMD
        tx_is_cmd = self.tx_is_cmd = Signal()  # 1: `tx_data` is actually a TXCMD, 0: `tx_data` is a USB data
        tx_ready = self.tx_ready = Signal()    # Asserted when Phy is ready to accept new data
        tx_last = self.tx_last = Signal()
        tx_aborted = self.tx_aborted = Signal()

        # TX Implementation Notes
        #   USB Data is captured by Phy when tx_is_cmd is deasserted, and tx_valid and tx_ready are asserted
        #   TXCMD is captured when tx_is_cmd is asserted, along with tx_valid and tx_ready

        # ULPI Register Read/Write Interface
        reg_addr = self.reg_addr = Signal(6)
        reg_addr_internal = self.reg_addr_internal = Signal(6)
        reg_dout = self.reg_dout = Signal(8)
        reg_dout_internal = self.reg_dout_internal = Signal(8)
        reg_din_internal = self.reg_din_internal = Signal(8)
        reg_din = self.reg_din = Signal(8)
        reg_start = self.reg_start = Signal()        # Pulse `reg_start` to start read or write operation (decided by `reg_rd_wr` Signal)
        reg_ready = self.reg_ready = Signal()        # Ready to accept read/write register command
        reg_ack = self.reg_ack = Signal()            # Ack accepting register command and starting of reg rd/wr operation
        reg_rd_wr = self.reg_rd_wr = Signal()        # Read operation: reg_rd_wr=0, Write operation: reg_rd_wr=1
        reg_done = self.reg_done = Signal()          # Single cycle high pulse means previous operation successfully completed
        reg_aborted = self.reg_aborted = Signal()    # Register read/write operation was aborted by USB Receive or RXCMD.

        self.sync.usb += self.stp.eq(0)

        fsm = self.fsm = ClockDomainsRenamer("usb")(FSM(reset_state="RESET"))
        self.submodules += fsm

        fsm.act("RESET",
            If(~self.dir,
                # NextValue(self.data_t.o, 0x00),
                NextState("IDLE"),
            )
        )

        # Which has highest priority? USB RX, or USB TX, or Register R/WR Operations? Answer below
        # USB Receive   -> Highest
        # USB Transmit
        # USB RXCMD
        # USB Reg R/WR  -> Lowest

        fsm.act("IDLE",
            If(self.dir & self.nxt,
                NextState("RX")
            ).Elif(tx_valid & tx_is_cmd,
                NextState("TX")
            ).Elif(reg_start & reg_rd_wr,
                NextState("REG_WR_CMD"),
                NextValue(reg_ack, 1)
            ).Elif(reg_start & ~reg_rd_wr,
                NextState("REG_RD_CMD"),
                NextValue(reg_ack, 1)
            )
        )

        fsm.act("RX",
            If(~self.dir & ~self.nxt,
                NextState("IDLE")
            )
        )

        fsm.act("TX",
            If(self.dir,
                NextState("RX"),  # TX aborted by higher priority read
                NextValue(tx_aborted, 1)
            ).Elif(tx_last & self.nxt,
                NextValue(self.stp, 1),
                NextState("IDLE"),
            )
        )

        fsm.act("REG_WR_CMD",
            If(~self.dir & self.nxt,
                NextState("REG_WR_DATA")
            ).Elif(self.dir,
                NextState("RX"),  # Reg write aborted during Reg Write TXCMD cycle
                NextValue(reg_aborted, 1),
            )
        )

        fsm.act("REG_WR_DATA",
            If(~self.dir & self.nxt,
                NextValue(self.stp, 1),
                NextValue(reg_done, 1),
                NextState("IDLE")
            ).Elif(self.dir,   # Reg write aborted during write data cycle
                NextState("RX"),
                NextValue(reg_aborted, 1),
            )
        )

        fsm.act("REG_RD_CMD",
            If(~self.dir & self.nxt,
                NextState("REG_RD_TURNAROUND")
            ).Elif(self.dir & self.nxt,  # Reg read aborted by PHY during TX_CMD due to receive
                NextState("RX"),
                NextValue(reg_aborted, 1)
            )
        )

        fsm.act("REG_RD_TURNAROUND",
            If(self.dir & ~self.nxt,
                NextState("REG_RD_DATA")
            ).Elif(self.dir & self.nxt,
                NextState("RX"),  # Reg read aborted by PHY during turnaround due to receive
                NextValue(reg_aborted, 1),
            )
        )

        fsm.act("REG_RD_DATA",
            If(self.dir & ~self.nxt,
                NextState("RX"),
                NextValue(reg_done, 1),
                NextValue(reg_dout, reg_dout_internal)
            )
        )

        self.comb += [
            rx_is_cmd.eq(fsm.ongoing("RX") & self.dir & ~self.nxt),
            rx_valid.eq(fsm.ongoing("RX") & self.dir & self.nxt),
            rx_active.eq(fsm.ongoing("RX") & self.dir),
            rx_error.eq(fsm.ongoing("RX") & rx_is_cmd & (rx_data[4:6] == 0b11)),

            tx_ready.eq(fsm.ongoing("TX") & self.nxt),

            reg_ready.eq(fsm.ongoing("IDLE") & ~self.dir),
        ]

        # Data line mux/demux
        self.comb += [
            # Receive Demux
            If(fsm.ongoing("RX"),
                rx_data.eq(self.data_i),
            ).Elif(fsm.ongoing("REG_RD_DATA"),
                reg_dout_internal.eq(self.data_i),
            ),

            # Transmit Mux
            If(fsm.ongoing("TX"),
                self.data_o.eq(tx_data),
            ).Elif(fsm.ongoing("REG_WR_CMD"),
                self.data_o.eq(Cat(reg_addr_internal, Constant(value=2, bits_sign=2)))
            ).Elif(fsm.ongoing("REG_RD_CMD"),
                self.data_o.eq(Cat(reg_addr_internal, Constant(value=3, bits_sign=2)))
            ).Elif(fsm.ongoing("REG_WR_DATA"),
                self.data_o.eq(reg_din_internal)
            ).Else(
                self.data_o.eq(0x00)
            ),

            self.data_oe.eq((fsm.ongoing("IDLE") |
                             fsm.ongoing("TX") |
                             fsm.ongoing("REG_RD_CMD") |
                             fsm.ongoing("REG_WR_CMD") |
                             fsm.ongoing("REG_WR_DATA")) & ~self.dir)
        ]

        self.sync.usb += [
            tx_aborted.eq(0),

            reg_ack.eq(0),
            reg_done.eq(0),
            reg_aborted.eq(0),
            reg_ready.eq(fsm.ongoing("IDLE") & ~self.dir),

            If(reg_start, reg_din_internal.eq(reg_din)),
            If(reg_start, reg_addr_internal.eq(reg_addr)),
        ]

    def get_ios(self):
        ios = set()
        ios.update({self.data_i, self.data_o, self.data_oe})
        ios.update({self.nxt, self.dir, self.stp})

        ios.update({self.tx_data, self.tx_is_cmd, self.tx_valid, self.tx_aborted, self.tx_last, self.tx_ready})
        ios.update({self.rx_data, self.rx_is_cmd, self.rx_valid, self.rx_active, self.rx_error})

        return ios

if __name__ == "__main__":
    dut = USB_ULPI_PHY()
    print(verilog.convert(dut, ios=dut.get_ios()))
