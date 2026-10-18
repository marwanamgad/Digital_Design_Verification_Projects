module ASYNC_FIFO #(
    parameter  FIFO_DEPTH = 8,
    parameter  FIFO_WIDTH = 4,
    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH)
) (
    input       wire                                i_rst_n,
    input       wire                                i_wclk,
    input       wire                                i_wen,
    input       wire        [FIFO_WIDTH-1:0]        i_wdata,
    input       wire                                i_rclk,
    input       wire                                i_ren,
    
    output      wire                                o_full,
    output      wire                                o_empty,
    output      reg         [FIFO_WIDTH-1:0]        o_rdata
);

reg [FIFO_WIDTH-1:0] MEM [FIFO_DEPTH-1:0];

reg  [ADDR_WIDTH:0] wr_ptr; 
wire [ADDR_WIDTH:0] wr_ptr_B2G, wr_ptr_synch, wr_ptr_G2B;

reg  [ADDR_WIDTH:0] rd_ptr;
wire [ADDR_WIDTH:0] rd_ptr_B2G, rd_ptr_synch, rd_ptr_G2B;

Binary2Gray #(.WIDTH(ADDR_WIDTH + 1)) WR_B2G (.i_data_binary(wr_ptr),.o_data_gray(wr_ptr_B2G));
Double_FF_Sync #(.WIDTH(ADDR_WIDTH + 1)) WR_DFF_SYNCH (.i_clk(i_rclk),.i_rst_n(i_rst_n),.i_data(wr_ptr_B2G),.o_data(wr_ptr_synch));
Gray2Binary #(.WIDTH(ADDR_WIDTH + 1)) WR_G2B (.i_data_gray(wr_ptr_synch),.o_data_binary(wr_ptr_G2B));

Binary2Gray #(.WIDTH(ADDR_WIDTH + 1)) RD_B2G (.i_data_binary(rd_ptr),.o_data_gray(rd_ptr_B2G));
Double_FF_Sync #(.WIDTH(ADDR_WIDTH + 1)) RD_DFF_SYNCH (.i_clk(i_wclk),.i_rst_n(i_rst_n),.i_data(rd_ptr_B2G),.o_data(rd_ptr_synch));
Gray2Binary #(.WIDTH(ADDR_WIDTH + 1)) RD_G2B (.i_data_gray(rd_ptr_synch),.o_data_binary(rd_ptr_G2B));

always @(posedge i_wclk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        wr_ptr <= 0;
    end
    else begin
        if (i_wen && !o_full) begin
            MEM[wr_ptr[ADDR_WIDTH-1:0]] <= i_wdata;
            wr_ptr <= wr_ptr + 1'b1;
        end
    end
end

always @(posedge i_rclk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        rd_ptr <= 0;
        o_rdata <= 0;
    end
    else begin
        if (i_ren && !o_empty) begin
            o_rdata <= MEM[rd_ptr[ADDR_WIDTH-1:0]];
            rd_ptr <= rd_ptr + 1'b1;
        end
    end
end

assign o_full = ((wr_ptr[ADDR_WIDTH] != rd_ptr_G2B[ADDR_WIDTH]) && (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr_G2B[ADDR_WIDTH-1:0]))? 1'b1 : 1'b0;
assign o_empty = (rd_ptr == wr_ptr_G2B)? 1'b1 : 1'b0;

endmodule