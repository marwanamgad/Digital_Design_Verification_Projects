module ASYNCH_FIFO_sva #(
	parameter  FIFO_WIDTH = 4,
	parameter  FIFO_DEPTH = 8,
	localparam ADDR_WIDTH = $clog2(FIFO_DEPTH)
) (
    input       logic                                i_rst_n,
    input       logic                                i_wclk,
    input       logic                                i_wen,
    input       logic        [FIFO_WIDTH-1:0]        i_wdata,
    input       logic                                i_rclk,
    input       logic                                i_ren,
    input       logic                                o_full,
    input       logic                                o_empty,
    input       logic        [FIFO_WIDTH-1:0]        o_rdata,
    input       logic        [ADDR_WIDTH:0]          wr_ptr,
    input       logic        [ADDR_WIDTH:0]          rd_ptr,
    input       logic        [ADDR_WIDTH:0]          wr_ptr_G2B,   // write pointer as seen by the read side
    input       logic        [ADDR_WIDTH:0]          rd_ptr_G2B    // read pointer as seen by the write side
);

// ---------------------------------------------------------------------
// Reset: while reset is active the FIFO is not full, empty, pointers at 0
// ---------------------------------------------------------------------
always_comb begin
	if (!i_rst_n) begin
		RST_ASSERTION: assert final (!o_full && o_empty && (wr_ptr == '0) && (rd_ptr == '0));
		RST_COVER:     cover  final (!o_full && o_empty && (wr_ptr == '0) && (rd_ptr == '0));
	end
end

// ---------------------------------------------------------------------
// Full flag: high exactly when the write pointer is one full lap ahead
// of the synchronized read pointer
// ---------------------------------------------------------------------
property full_cond_property;
	@(posedge i_wclk) disable iff (!i_rst_n)
	o_full == ((wr_ptr[ADDR_WIDTH]     != rd_ptr_G2B[ADDR_WIDTH]) &&
	           (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr_G2B[ADDR_WIDTH-1:0]));
endproperty

// ---------------------------------------------------------------------
// Empty flag: high exactly when the read pointer equals the
// synchronized write pointer
// ---------------------------------------------------------------------
property empty_cond_property;
	@(posedge i_rclk) disable iff (!i_rst_n)
	o_empty == (rd_ptr == wr_ptr_G2B);
endproperty

// ---------------------------------------------------------------------
// Pointer increment: an accepted write/read advances the pointer by 1
// ---------------------------------------------------------------------
property wr_ptr_cond_property;
	@(posedge i_wclk) disable iff (!i_rst_n)
	(i_wen && !o_full) |=> (wr_ptr == $past(wr_ptr) + 1'b1);
endproperty

property rd_ptr_cond_property;
	@(posedge i_rclk) disable iff (!i_rst_n)
	(i_ren && !o_empty) |=> (rd_ptr == $past(rd_ptr) + 1'b1);
endproperty

// ---------------------------------------------------------------------
// Assertions
// ---------------------------------------------------------------------
full_cond_assertion   : assert property (full_cond_property);
empty_cond_assertion  : assert property (empty_cond_property);
wr_ptr_cond_assertion : assert property (wr_ptr_cond_property);
rd_ptr_cond_assertion : assert property (rd_ptr_cond_property);

// ---------------------------------------------------------------------
// Covers: written as plain sequences so they only hit when the
// scenario really happens
// ---------------------------------------------------------------------
full_cond_cover   : cover property (@(posedge i_wclk) disable iff (!i_rst_n) $rose(o_full));
empty_cond_cover  : cover property (@(posedge i_rclk) disable iff (!i_rst_n) $rose(o_empty));
wr_ptr_cond_cover : cover property (@(posedge i_wclk) disable iff (!i_rst_n)
                                    (i_wen && !o_full) ##1 (wr_ptr == $past(wr_ptr) + 1'b1));
rd_ptr_cond_cover : cover property (@(posedge i_rclk) disable iff (!i_rst_n)
                                    (i_ren && !o_empty) ##1 (rd_ptr == $past(rd_ptr) + 1'b1));

endmodule

