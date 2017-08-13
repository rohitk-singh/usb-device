/* Machine-generated using Migen */
module usb_ulpi(
	inout [7:0] data,
	input dir,
	input nxt,
	output reg stp,
	input reset,
	output reg [7:0] debug,
	input [31:0] axi_awaddr,
	input [2:0] axi_awprot,
	input axi_awvalid,
	output reg axi_awready,
	input [31:0] axi_wdata,
	input [3:0] axi_wstrb,
	input axi_wvalid,
	output reg axi_wready,
	output reg [1:0] axi_bresp,
	output reg axi_bvalid,
	input axi_bready,
	input [31:0] axi_araddr,
	input [2:0] axi_arprot,
	input axi_arvalid,
	output reg axi_arready,
	output reg [31:0] axi_rdata,
	output reg [1:0] axi_rresp,
	output reg axi_rvalid,
	input axi_rready,
	input usb_clk,
	input usb_rst
);

reg [7:0] o = 8'd0;
wire oe;
wire [7:0] i;
reg isRxCmd = 1'd0;
reg [7:0] rx_data = 8'd0;
wire rx_fifo_we;
reg [7:0] past_rx_cmd = 8'd0;
reg [7:0] current_rx_cmd = 8'd0;
wire [5:0] ulpi_reg_wr_addr;
wire [7:0] ulpi_reg_wr_data;
wire ulpi_reg_wr_trig;
reg ulpi_reg_wr_busy = 1'd0;
reg ulpi_reg_wr_done = 1'd0;
reg ulpi_reg_wr_queue = 1'd0;
wire [5:0] ulpi_reg_rd_addr;
reg [7:0] ulpi_reg_rd_data = 8'd0;
wire ulpi_reg_rd_trig;
reg ulpi_reg_rd_busy = 1'd0;
reg ulpi_reg_rd_done = 1'd0;
reg ulpi_reg_rd_queue = 1'd0;
reg is_ongoing0 = 1'd0;
wire se0;
wire j_state;
wire k_state;
wire se1;
wire squelch;
wire n_squelch;
reg syncfifo_we = 1'd0;
wire syncfifo_writable;
wire syncfifo_re;
wire syncfifo_readable;
wire [8:0] syncfifo_din;
wire [8:0] syncfifo_dout;
reg [14:0] level = 15'd0;
reg replace = 1'd0;
reg [14:0] produce = 15'd0;
reg [14:0] consume = 15'd0;
reg [14:0] wrport_adr = 15'd0;
wire [8:0] wrport_dat_r;
wire wrport_we;
wire [8:0] wrport_dat_w;
wire do_read;
wire [14:0] rdport_adr;
wire [8:0] rdport_dat_r;
reg is_ongoing1 = 1'd0;
reg [31:0] axi_awaddr1 = 32'd0;
reg [31:0] axi_araddr1 = 32'd0;
wire wr_en;
wire rd_en;
reg [31:0] record0_data_w = 32'd0;
wire [31:0] record0_data_r;
reg record0_we = 1'd0;
reg record0_re = 1'd0;
wire record0_writable;
wire record0_readable;
reg [31:0] record1_data_w = 32'd0;
wire [31:0] record1_data_r;
reg record1_we = 1'd0;
reg record1_re = 1'd0;
wire record1_writable;
reg record1_readable = 1'd0;
reg [31:0] record2_data_w = 32'd0;
reg [31:0] record2_data_r = 32'd0;
reg record2_we = 1'd0;
reg record2_re = 1'd0;
wire record2_writable;
reg record2_readable = 1'd0;
reg [31:0] record3_data_w = 32'd0;
reg [31:0] record3_data_r = 32'd0;
reg record3_we = 1'd0;
reg record3_re = 1'd0;
wire record3_writable;
reg record3_readable = 1'd0;
reg [31:0] record4_data_w = 32'd0;
reg [31:0] record4_data_r = 32'd0;
reg record4_we = 1'd0;
reg record4_re = 1'd0;
wire record4_writable;
reg record4_readable = 1'd0;
reg [31:0] record5_data_w = 32'd0;
wire [31:0] record5_data_r;
reg record5_we = 1'd0;
reg record5_re = 1'd0;
wire record5_writable;
reg record5_readable = 1'd0;
reg [31:0] record6_data_w = 32'd0;
reg [31:0] record6_data_r = 32'd0;
reg record6_we = 1'd0;
reg record6_re = 1'd0;
wire record6_writable;
reg record6_readable = 1'd0;
reg [31:0] record7_data_w = 32'd0;
wire [31:0] record7_data_r;
reg record7_we = 1'd0;
reg record7_re = 1'd0;
wire record7_writable;
reg record7_readable = 1'd0;
reg [31:0] record8_data_w = 32'd0;
reg [31:0] record8_data_r = 32'd0;
reg record8_we = 1'd0;
reg record8_re = 1'd0;
wire record8_writable;
reg record8_readable = 1'd0;
reg [31:0] record9_data_w = 32'd0;
wire [31:0] record9_data_r;
reg record9_we = 1'd0;
reg record9_re = 1'd0;
wire record9_writable;
reg record9_readable = 1'd0;
reg [31:0] record10_data_w = 32'd0;
reg [31:0] record10_data_r = 32'd0;
reg record10_we = 1'd0;
reg record10_re = 1'd0;
wire record10_writable;
reg record10_readable = 1'd0;
reg [31:0] record11_data_w = 32'd0;
reg [31:0] record11_data_r = 32'd0;
reg record11_we = 1'd0;
reg record11_re = 1'd0;
wire record11_writable;
reg record11_readable = 1'd0;
reg [31:0] record12_data_w = 32'd0;
reg [31:0] record12_data_r = 32'd0;
reg record12_we = 1'd0;
reg record12_re = 1'd0;
wire record12_writable;
reg record12_readable = 1'd0;
reg [31:0] record13_data_w = 32'd0;
reg [31:0] record13_data_r = 32'd0;
reg record13_we = 1'd0;
reg record13_re = 1'd0;
wire record13_writable;
reg record13_readable = 1'd0;
reg [31:0] record14_data_w = 32'd0;
reg [31:0] record14_data_r = 32'd0;
reg record14_we = 1'd0;
reg record14_re = 1'd0;
wire record14_writable;
reg record14_readable = 1'd0;
reg [31:0] record15_data_w = 32'd0;
reg [31:0] record15_data_r = 32'd0;
reg record15_we = 1'd0;
reg record15_re = 1'd0;
wire record15_writable;
reg record15_readable = 1'd0;
reg signal_r0 = 1'd0;
reg signal_r1 = 1'd0;
reg [3:0] state = 4'd0;
reg [3:0] next_state = 4'd0;
reg [7:0] o_next_value0 = 8'd0;
reg o_next_value_ce0 = 1'd0;
reg ulpi_reg_wr_queue_t_next_value0 = 1'd0;
reg ulpi_reg_wr_queue_t_next_value_ce0 = 1'd0;
reg ulpi_reg_wr_busy_t_next_value1 = 1'd0;
reg ulpi_reg_wr_busy_t_next_value_ce1 = 1'd0;
reg ulpi_reg_wr_done_t_next_value2 = 1'd0;
reg ulpi_reg_wr_done_t_next_value_ce2 = 1'd0;
reg ulpi_reg_rd_queue_f_next_value0 = 1'd0;
reg ulpi_reg_rd_queue_f_next_value_ce0 = 1'd0;
reg ulpi_reg_rd_busy_f_next_value1 = 1'd0;
reg ulpi_reg_rd_busy_f_next_value_ce1 = 1'd0;
reg ulpi_reg_rd_done_f_next_value2 = 1'd0;
reg ulpi_reg_rd_done_f_next_value_ce2 = 1'd0;
reg isRxCmd_next_value1 = 1'd0;
reg isRxCmd_next_value_ce1 = 1'd0;
reg [7:0] rx_data_next_value2 = 8'd0;
reg rx_data_next_value_ce2 = 1'd0;
reg stp_next_value3 = 1'd0;
reg stp_next_value_ce3 = 1'd0;
reg [7:0] ulpi_reg_rd_data_next_value4 = 8'd0;
reg ulpi_reg_rd_data_next_value_ce4 = 1'd0;


// Adding a dummy event (using a dummy signal 'dummy_s') to get the simulator
// to run the combinatorial process once at the beginning.
// synthesis translate_off
reg dummy_s;
initial dummy_s <= 1'd0;
// synthesis translate_on

assign se0 = ((current_rx_cmd[1:0] == 1'd0) & 1'd1);
assign j_state = ((current_rx_cmd[1:0] == 1'd1) & 1'd1);
assign k_state = ((current_rx_cmd[1:0] == 2'd2) & 1'd1);
assign se1 = ((current_rx_cmd[1:0] == 2'd3) & 1'd1);
assign squelch = ((current_rx_cmd[1:0] == 1'd0) & 1'd0);
assign n_squelch = ((current_rx_cmd[1:0] == 1'd1) & 1'd0);
assign oe = (~dir);
assign rx_fifo_we = ((is_ongoing1 & dir) & syncfifo_writable);
assign syncfifo_din = {isRxCmd, rx_data};
assign wr_en = (((axi_wready & axi_wvalid) & axi_awready) & axi_awvalid);
assign rd_en = (((~axi_rvalid) & axi_arready) & axi_arvalid);
assign record0_data_r = {syncfifo_dout[8], 23'd0, syncfifo_dout[7:0]};
assign record0_readable = syncfifo_readable;
assign syncfifo_re = record0_re;
assign record1_data_r = syncfifo_readable;
assign ulpi_reg_wr_addr = record2_data_w[5:0];
assign ulpi_reg_wr_data = record3_data_w[7:0];
assign ulpi_reg_wr_trig = (record4_data_w[0] & (~signal_r0));
assign record5_data_r = {ulpi_reg_wr_done, ulpi_reg_wr_busy};
assign ulpi_reg_rd_addr = record6_data_w[5:0];
assign record7_data_r = ulpi_reg_rd_data;
assign ulpi_reg_rd_trig = (record8_data_w[0] & (~signal_r1));
assign record9_data_r = {ulpi_reg_rd_done, ulpi_reg_rd_busy};
assign record0_writable = 1'd1;
assign record1_writable = 1'd1;
assign record2_writable = 1'd1;
assign record3_writable = 1'd1;
assign record4_writable = 1'd1;
assign record5_writable = 1'd1;
assign record6_writable = 1'd1;
assign record7_writable = 1'd1;
assign record8_writable = 1'd1;
assign record9_writable = 1'd1;
assign record10_writable = 1'd1;
assign record11_writable = 1'd1;
assign record12_writable = 1'd1;
assign record13_writable = 1'd1;
assign record14_writable = 1'd1;
assign record15_writable = 1'd1;

// synthesis translate_off
reg dummy_d;
// synthesis translate_on
always @(*) begin
	ulpi_reg_wr_busy_t_next_value1 <= 1'd0;
	stp_next_value_ce3 <= 1'd0;
	ulpi_reg_wr_busy_t_next_value_ce1 <= 1'd0;
	ulpi_reg_wr_done_t_next_value2 <= 1'd0;
	ulpi_reg_wr_done_t_next_value_ce2 <= 1'd0;
	is_ongoing1 <= 1'd0;
	ulpi_reg_rd_queue_f_next_value0 <= 1'd0;
	ulpi_reg_rd_queue_f_next_value_ce0 <= 1'd0;
	ulpi_reg_rd_busy_f_next_value1 <= 1'd0;
	ulpi_reg_rd_busy_f_next_value_ce1 <= 1'd0;
	is_ongoing0 <= 1'd0;
	ulpi_reg_rd_done_f_next_value2 <= 1'd0;
	ulpi_reg_rd_done_f_next_value_ce2 <= 1'd0;
	isRxCmd_next_value1 <= 1'd0;
	isRxCmd_next_value_ce1 <= 1'd0;
	ulpi_reg_rd_data_next_value4 <= 8'd0;
	ulpi_reg_rd_data_next_value_ce4 <= 1'd0;
	rx_data_next_value2 <= 8'd0;
	rx_data_next_value_ce2 <= 1'd0;
	next_state <= 4'd0;
	o_next_value0 <= 8'd0;
	o_next_value_ce0 <= 1'd0;
	ulpi_reg_wr_queue_t_next_value0 <= 1'd0;
	ulpi_reg_wr_queue_t_next_value_ce0 <= 1'd0;
	stp_next_value3 <= 1'd0;
	next_state <= state;
	case (state)
		1'd1: begin
			if (dir) begin
				next_state <= 2'd2;
			end else begin
				if (ulpi_reg_wr_queue) begin
					next_state <= 2'd3;
					o_next_value0 <= {2'd2, ulpi_reg_wr_addr};
					o_next_value_ce0 <= 1'd1;
					ulpi_reg_wr_queue_t_next_value0 <= 1'd0;
					ulpi_reg_wr_queue_t_next_value_ce0 <= 1'd1;
					ulpi_reg_wr_busy_t_next_value1 <= 1'd1;
					ulpi_reg_wr_busy_t_next_value_ce1 <= 1'd1;
					ulpi_reg_wr_done_t_next_value2 <= 1'd0;
					ulpi_reg_wr_done_t_next_value_ce2 <= 1'd1;
				end else begin
					if (ulpi_reg_rd_queue) begin
						next_state <= 3'd6;
						o_next_value0 <= {2'd3, ulpi_reg_rd_addr};
						o_next_value_ce0 <= 1'd1;
						ulpi_reg_rd_queue_f_next_value0 <= 1'd0;
						ulpi_reg_rd_queue_f_next_value_ce0 <= 1'd1;
						ulpi_reg_rd_busy_f_next_value1 <= 1'd1;
						ulpi_reg_rd_busy_f_next_value_ce1 <= 1'd1;
						ulpi_reg_rd_done_f_next_value2 <= 1'd0;
						ulpi_reg_rd_done_f_next_value_ce2 <= 1'd1;
					end
				end
			end
		end
		2'd2: begin
			isRxCmd_next_value1 <= 1'd0;
			isRxCmd_next_value_ce1 <= 1'd1;
			if ((dir & (~nxt))) begin
				rx_data_next_value2 <= i;
				rx_data_next_value_ce2 <= 1'd1;
				isRxCmd_next_value1 <= 1'd1;
				isRxCmd_next_value_ce1 <= 1'd1;
			end else begin
				if ((dir & nxt)) begin
					rx_data_next_value2 <= i;
					rx_data_next_value_ce2 <= 1'd1;
				end else begin
					if (((~dir) & (~nxt))) begin
						next_state <= 1'd1;
					end
				end
			end
			is_ongoing0 <= 1'd1;
			is_ongoing1 <= 1'd1;
		end
		2'd3: begin
			if (((~dir) & nxt)) begin
				next_state <= 3'd4;
				o_next_value0 <= ulpi_reg_wr_data;
				o_next_value_ce0 <= 1'd1;
			end else begin
				if (dir) begin
					next_state <= 2'd2;
					o_next_value0 <= 1'd0;
					o_next_value_ce0 <= 1'd1;
				end
			end
		end
		3'd4: begin
			if (((~dir) & nxt)) begin
				next_state <= 3'd5;
				stp_next_value3 <= 1'd1;
				stp_next_value_ce3 <= 1'd1;
			end else begin
				if ((dir & nxt)) begin
					next_state <= 2'd2;
				end
			end
			o_next_value0 <= 1'd0;
			o_next_value_ce0 <= 1'd1;
		end
		3'd5: begin
			if (((~dir) & (~nxt))) begin
				next_state <= 1'd1;
			end else begin
				if ((dir & nxt)) begin
					next_state <= 2'd2;
				end
			end
			o_next_value0 <= 1'd0;
			o_next_value_ce0 <= 1'd1;
			ulpi_reg_wr_busy_t_next_value1 <= 1'd0;
			ulpi_reg_wr_busy_t_next_value_ce1 <= 1'd1;
			ulpi_reg_wr_done_t_next_value2 <= 1'd1;
			ulpi_reg_wr_done_t_next_value_ce2 <= 1'd1;
		end
		3'd6: begin
			if ((nxt & (~dir))) begin
				next_state <= 3'd7;
			end else begin
				if ((nxt & dir)) begin
					next_state <= 2'd2;
					o_next_value0 <= 1'd0;
					o_next_value_ce0 <= 1'd1;
				end
			end
		end
		3'd7: begin
			if ((dir & nxt)) begin
				next_state <= 2'd2;
			end else begin
				if ((dir & (~nxt))) begin
					next_state <= 4'd8;
				end
			end
			o_next_value0 <= 1'd0;
			o_next_value_ce0 <= 1'd1;
		end
		4'd8: begin
			if ((dir & (~nxt))) begin
				next_state <= 2'd2;
				ulpi_reg_rd_data_next_value4 <= i;
				ulpi_reg_rd_data_next_value_ce4 <= 1'd1;
				ulpi_reg_rd_busy_f_next_value1 <= 1'd0;
				ulpi_reg_rd_busy_f_next_value_ce1 <= 1'd1;
				ulpi_reg_rd_done_f_next_value2 <= 1'd1;
				ulpi_reg_rd_done_f_next_value_ce2 <= 1'd1;
			end
		end
		default: begin
			if ((~dir)) begin
				o_next_value0 <= 1'd0;
				o_next_value_ce0 <= 1'd1;
				next_state <= 1'd1;
			end
		end
	endcase
// synthesis translate_off
	dummy_d <= dummy_s;
// synthesis translate_on
end

// synthesis translate_off
reg dummy_d_1;
// synthesis translate_on
always @(*) begin
	wrport_adr <= 15'd0;
	if (replace) begin
		wrport_adr <= (produce - 1'd1);
	end else begin
		wrport_adr <= produce;
	end
// synthesis translate_off
	dummy_d_1 <= dummy_s;
// synthesis translate_on
end
assign wrport_dat_w = syncfifo_din;
assign wrport_we = (syncfifo_we & (syncfifo_writable | replace));
assign do_read = (syncfifo_readable & syncfifo_re);
assign rdport_adr = consume;
assign syncfifo_dout = rdport_dat_r;
assign syncfifo_writable = (level != 15'd20480);
assign syncfifo_readable = (level != 1'd0);

always @(posedge usb_clk) begin
	if (usb_rst) begin
		stp <= 1'd1;
		o <= 8'd0;
		isRxCmd <= 1'd0;
		rx_data <= 8'd0;
		debug <= 8'd0;
		past_rx_cmd <= 8'd0;
		current_rx_cmd <= 8'd0;
		ulpi_reg_wr_busy <= 1'd0;
		ulpi_reg_wr_done <= 1'd0;
		ulpi_reg_wr_queue <= 1'd0;
		ulpi_reg_rd_data <= 8'd0;
		ulpi_reg_rd_busy <= 1'd0;
		ulpi_reg_rd_done <= 1'd0;
		ulpi_reg_rd_queue <= 1'd0;
		syncfifo_we <= 1'd0;
		level <= 15'd0;
		produce <= 15'd0;
		consume <= 15'd0;
		axi_awready <= 1'd0;
		axi_wready <= 1'd0;
		axi_bresp <= 2'd0;
		axi_bvalid <= 1'd0;
		axi_arready <= 1'd0;
		axi_rdata <= 32'd0;
		axi_rresp <= 2'd0;
		axi_rvalid <= 1'd0;
		axi_awaddr1 <= 32'd0;
		axi_araddr1 <= 32'd0;
		record0_data_w <= 32'd0;
		record0_we <= 1'd0;
		record0_re <= 1'd0;
		record1_data_w <= 32'd0;
		record1_we <= 1'd0;
		record1_re <= 1'd0;
		record2_data_w <= 32'd0;
		record2_we <= 1'd0;
		record2_re <= 1'd0;
		record3_data_w <= 32'd0;
		record3_we <= 1'd0;
		record3_re <= 1'd0;
		record4_data_w <= 32'd0;
		record4_we <= 1'd0;
		record4_re <= 1'd0;
		record5_data_w <= 32'd0;
		record5_we <= 1'd0;
		record5_re <= 1'd0;
		record6_data_w <= 32'd0;
		record6_we <= 1'd0;
		record6_re <= 1'd0;
		record7_data_w <= 32'd0;
		record7_we <= 1'd0;
		record7_re <= 1'd0;
		record8_data_w <= 32'd0;
		record8_we <= 1'd0;
		record8_re <= 1'd0;
		record9_data_w <= 32'd0;
		record9_we <= 1'd0;
		record9_re <= 1'd0;
		record10_data_w <= 32'd0;
		record10_we <= 1'd0;
		record10_re <= 1'd0;
		record11_data_w <= 32'd0;
		record11_we <= 1'd0;
		record11_re <= 1'd0;
		record12_data_w <= 32'd0;
		record12_we <= 1'd0;
		record12_re <= 1'd0;
		record13_data_w <= 32'd0;
		record13_we <= 1'd0;
		record13_re <= 1'd0;
		record14_data_w <= 32'd0;
		record14_we <= 1'd0;
		record14_re <= 1'd0;
		record15_data_w <= 32'd0;
		record15_we <= 1'd0;
		record15_re <= 1'd0;
		signal_r0 <= 1'd0;
		signal_r1 <= 1'd0;
		state <= 4'd0;
	end else begin
		if (ulpi_reg_wr_trig) begin
			ulpi_reg_wr_queue <= 1'd1;
		end
		if (ulpi_reg_rd_trig) begin
			ulpi_reg_rd_queue <= 1'd1;
		end
		if (((dir & (~nxt)) & is_ongoing0)) begin
			past_rx_cmd <= current_rx_cmd;
			current_rx_cmd <= i;
		end
		stp <= 1'd0;
		syncfifo_we <= rx_fifo_we;
		if ((((~axi_awready) & axi_awvalid) & axi_wvalid)) begin
			axi_awready <= 1'd1;
			axi_awaddr1 <= axi_awaddr;
		end else begin
			axi_awready <= 1'd0;
		end
		if ((((~axi_wready) & axi_wvalid) & axi_awvalid)) begin
			axi_wready <= 1'd1;
		end else begin
			axi_wready <= 1'd0;
		end
		if (((((axi_awready & axi_awvalid) & (~axi_bvalid)) & axi_wready) & axi_wvalid)) begin
			axi_bvalid <= 1'd1;
			axi_bresp <= 1'd0;
		end else begin
			if ((axi_bready & axi_bvalid)) begin
				axi_bvalid <= 1'd0;
			end
		end
		if (((~axi_arready) & axi_arvalid)) begin
			axi_arready <= 1'd1;
			axi_araddr1 <= axi_araddr;
		end else begin
			axi_arready <= 1'd0;
		end
		if (((axi_arready & axi_arvalid) & (~axi_rvalid))) begin
			axi_rvalid <= 1'd1;
			axi_rresp <= 1'd0;
		end else begin
			if ((axi_rvalid & axi_rready)) begin
				axi_rvalid <= 1'd0;
			end
		end
		if (wr_en) begin
			if (((axi_awaddr1[5:2] == 1'd0) & record0_writable)) begin
				record0_data_w <= axi_wdata;
				record0_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 1'd1) & record1_writable)) begin
				record1_data_w <= axi_wdata;
				record1_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 2'd2) & record2_writable)) begin
				record2_data_w <= axi_wdata;
				record2_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 2'd3) & record3_writable)) begin
				record3_data_w <= axi_wdata;
				record3_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 3'd4) & record4_writable)) begin
				record4_data_w <= axi_wdata;
				record4_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 3'd5) & record5_writable)) begin
				record5_data_w <= axi_wdata;
				record5_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 3'd6) & record6_writable)) begin
				record6_data_w <= axi_wdata;
				record6_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 3'd7) & record7_writable)) begin
				record7_data_w <= axi_wdata;
				record7_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 4'd8) & record8_writable)) begin
				record8_data_w <= axi_wdata;
				record8_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 4'd9) & record9_writable)) begin
				record9_data_w <= axi_wdata;
				record9_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 4'd10) & record10_writable)) begin
				record10_data_w <= axi_wdata;
				record10_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 4'd11) & record11_writable)) begin
				record11_data_w <= axi_wdata;
				record11_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 4'd12) & record12_writable)) begin
				record12_data_w <= axi_wdata;
				record12_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 4'd13) & record13_writable)) begin
				record13_data_w <= axi_wdata;
				record13_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 4'd14) & record14_writable)) begin
				record14_data_w <= axi_wdata;
				record14_we <= 1'd1;
			end
			if (((axi_awaddr1[5:2] == 4'd15) & record15_writable)) begin
				record15_data_w <= axi_wdata;
				record15_we <= 1'd1;
			end
		end else begin
			record0_we <= 1'd0;
			record1_we <= 1'd0;
			record2_we <= 1'd0;
			record3_we <= 1'd0;
			record4_we <= 1'd0;
			record5_we <= 1'd0;
			record6_we <= 1'd0;
			record7_we <= 1'd0;
			record8_we <= 1'd0;
			record9_we <= 1'd0;
			record10_we <= 1'd0;
			record11_we <= 1'd0;
			record12_we <= 1'd0;
			record13_we <= 1'd0;
			record14_we <= 1'd0;
			record15_we <= 1'd0;
		end
		if (rd_en) begin
			if ((axi_araddr1[5:2] == 1'd0)) begin
				axi_rdata <= record0_data_r;
				record0_re <= record0_readable;
			end
			if ((axi_araddr1[5:2] == 1'd1)) begin
				axi_rdata <= record1_data_r;
				record1_re <= record1_readable;
			end
			if ((axi_araddr1[5:2] == 2'd2)) begin
				axi_rdata <= record2_data_r;
				record2_re <= record2_readable;
			end
			if ((axi_araddr1[5:2] == 2'd3)) begin
				axi_rdata <= record3_data_r;
				record3_re <= record3_readable;
			end
			if ((axi_araddr1[5:2] == 3'd4)) begin
				axi_rdata <= record4_data_r;
				record4_re <= record4_readable;
			end
			if ((axi_araddr1[5:2] == 3'd5)) begin
				axi_rdata <= record5_data_r;
				record5_re <= record5_readable;
			end
			if ((axi_araddr1[5:2] == 3'd6)) begin
				axi_rdata <= record6_data_r;
				record6_re <= record6_readable;
			end
			if ((axi_araddr1[5:2] == 3'd7)) begin
				axi_rdata <= record7_data_r;
				record7_re <= record7_readable;
			end
			if ((axi_araddr1[5:2] == 4'd8)) begin
				axi_rdata <= record8_data_r;
				record8_re <= record8_readable;
			end
			if ((axi_araddr1[5:2] == 4'd9)) begin
				axi_rdata <= record9_data_r;
				record9_re <= record9_readable;
			end
			if ((axi_araddr1[5:2] == 4'd10)) begin
				axi_rdata <= record10_data_r;
				record10_re <= record10_readable;
			end
			if ((axi_araddr1[5:2] == 4'd11)) begin
				axi_rdata <= record11_data_r;
				record11_re <= record11_readable;
			end
			if ((axi_araddr1[5:2] == 4'd12)) begin
				axi_rdata <= record12_data_r;
				record12_re <= record12_readable;
			end
			if ((axi_araddr1[5:2] == 4'd13)) begin
				axi_rdata <= record13_data_r;
				record13_re <= record13_readable;
			end
			if ((axi_araddr1[5:2] == 4'd14)) begin
				axi_rdata <= record14_data_r;
				record14_re <= record14_readable;
			end
			if ((axi_araddr1[5:2] == 4'd15)) begin
				axi_rdata <= record15_data_r;
				record15_re <= record15_readable;
			end
		end else begin
			record0_re <= 1'd0;
			record1_re <= 1'd0;
			record2_re <= 1'd0;
			record3_re <= 1'd0;
			record4_re <= 1'd0;
			record5_re <= 1'd0;
			record6_re <= 1'd0;
			record7_re <= 1'd0;
			record8_re <= 1'd0;
			record9_re <= 1'd0;
			record10_re <= 1'd0;
			record11_re <= 1'd0;
			record12_re <= 1'd0;
			record13_re <= 1'd0;
			record14_re <= 1'd0;
			record15_re <= 1'd0;
		end
		signal_r0 <= record4_data_w[0];
		signal_r1 <= record8_data_w[0];
		if (ulpi_reg_wr_trig) begin
			debug[0] <= 1'd1;
		end
		if (ulpi_reg_rd_trig) begin
			debug[1] <= 1'd1;
		end
		state <= next_state;
		if (o_next_value_ce0) begin
			o <= o_next_value0;
		end
		if (ulpi_reg_wr_queue_t_next_value_ce0) begin
			ulpi_reg_wr_queue <= ulpi_reg_wr_queue_t_next_value0;
		end
		if (ulpi_reg_wr_busy_t_next_value_ce1) begin
			ulpi_reg_wr_busy <= ulpi_reg_wr_busy_t_next_value1;
		end
		if (ulpi_reg_wr_done_t_next_value_ce2) begin
			ulpi_reg_wr_done <= ulpi_reg_wr_done_t_next_value2;
		end
		if (ulpi_reg_rd_queue_f_next_value_ce0) begin
			ulpi_reg_rd_queue <= ulpi_reg_rd_queue_f_next_value0;
		end
		if (ulpi_reg_rd_busy_f_next_value_ce1) begin
			ulpi_reg_rd_busy <= ulpi_reg_rd_busy_f_next_value1;
		end
		if (ulpi_reg_rd_done_f_next_value_ce2) begin
			ulpi_reg_rd_done <= ulpi_reg_rd_done_f_next_value2;
		end
		if (isRxCmd_next_value_ce1) begin
			isRxCmd <= isRxCmd_next_value1;
		end
		if (rx_data_next_value_ce2) begin
			rx_data <= rx_data_next_value2;
		end
		if (stp_next_value_ce3) begin
			stp <= stp_next_value3;
		end
		if (ulpi_reg_rd_data_next_value_ce4) begin
			ulpi_reg_rd_data <= ulpi_reg_rd_data_next_value4;
		end
		if (((syncfifo_we & syncfifo_writable) & (~replace))) begin
			if ((produce == 15'd20479)) begin
				produce <= 1'd0;
			end else begin
				produce <= (produce + 1'd1);
			end
		end
		if (do_read) begin
			if ((consume == 15'd20479)) begin
				consume <= 1'd0;
			end else begin
				consume <= (consume + 1'd1);
			end
		end
		if (((syncfifo_we & syncfifo_writable) & (~replace))) begin
			if ((~do_read)) begin
				level <= (level + 1'd1);
			end
		end else begin
			if (do_read) begin
				level <= (level - 1'd1);
			end
		end
	end
end

assign data = oe ? o : 8'bz;
assign i = data;

reg [8:0] storage[0:20479];
reg [14:0] memadr;
always @(posedge usb_clk) begin
	if (wrport_we)
		storage[wrport_adr] <= wrport_dat_w;
	memadr <= wrport_adr;
end

always @(posedge usb_clk) begin
end

assign wrport_dat_r = storage[memadr];
assign rdport_dat_r = storage[rdport_adr];

endmodule

