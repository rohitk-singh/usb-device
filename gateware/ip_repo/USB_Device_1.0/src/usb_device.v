
`timescale 1 ns / 1 ps

module usb_device #
(
    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_AXI_DATA_WIDTH  = 32,
    parameter integer C_AXI_ADDR_WIDTH  = 8
)
(
    input wire [31 : 0] axi_awaddr,
    input wire [2 : 0] axi_awprot,
    input wire  axi_awvalid,
    output wire  axi_awready,
    input wire [31 : 0] axi_wdata,
    input wire [3 : 0] axi_wstrb,
    input wire  axi_wvalid,
    output wire  axi_wready,
    output wire [1 : 0] axi_bresp,
    output wire  axi_bvalid,
    input wire  axi_bready,
    input wire [31 : 0] axi_araddr,
    input wire [2 : 0] axi_arprot,
    input wire  axi_arvalid,
    output wire  axi_arready,
    output wire [31 : 0] axi_rdata,
    output wire [1 : 0] axi_rresp,
    output wire  axi_rvalid,
    input wire  axi_rready,
    
    inout [7:0] data,
    input dir,
    input nxt,
    output stp,
    output [7:0] debug,
    input reset,
    input usb_clk,
    input usb_rst
);

usb_ulpi usb_ulpi(
    .data(data),
    .dir(dir),
    .nxt(nxt),
    .stp(stp),
    .reset(reset),
    .axi_awaddr(axi_awaddr),
    .axi_awprot(axi_awprot),
    .axi_awvalid(axi_awvalid),
    .axi_awready(axi_awready),
    .axi_wdata(axi_wdata),
    .axi_wstrb(axi_wstrb),
    .axi_wvalid(axi_wvalid),
    .axi_wready(axi_wready),
    .axi_bresp(axi_bresp),
    .axi_bvalid(axi_bvalid),
    .axi_bready(axi_bready),
    .axi_araddr(axi_araddr),
    .axi_arprot(axi_arprot),
    .axi_arvalid(axi_arvalid),
    .axi_arready(axi_arready),
    .axi_rdata(axi_rdata),
    .axi_rresp(axi_rresp),
    .axi_rvalid(axi_rvalid),
    .axi_rready(axi_rready),
    .debug(debug),
    .usb_clk(usb_clk),
    .usb_rst(usb_rst)
);

endmodule