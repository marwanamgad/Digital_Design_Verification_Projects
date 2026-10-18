module ASYNC_FIFO_GOLD #(parameter DATA_WIDTH=4, parameter FIFO_DEPTH=8)( 
    input  wire                     i_rst_n, 
    input  wire                     i_wr_clk, 
    input  wire                     i_wr_en, 
    input  wire [DATA_WIDTH-1:0]    i_wr_data, 
    input  wire                     i_rd_clk, 
    input  wire                     i_rd_en,
    output wire                     o_full, 
    output wire                     o_empty,
    output wire [DATA_WIDTH-1:0]    o_rd_data
); 
    parameter PTR_WIDTH = $clog2(FIFO_DEPTH); 
     
    wire                    enable_wr; 
    wire                    enable_rd; 
     
    wire [PTR_WIDTH:0]      rdptr; 
    wire [PTR_WIDTH:0]      wrptr; 
     
    wire [PTR_WIDTH:0]      rdptr_sync; 
    wire [PTR_WIDTH:0]      wrptr_sync; 
     
    wire [PTR_WIDTH:0]      rdptr_b2g_out; 
    wire [PTR_WIDTH:0]      wrptr_b2g_out; 
     
    wire [PTR_WIDTH:0]      rdptr_g2b_out; 
    wire [PTR_WIDTH:0]      wrptr_g2b_out; 
     
    wire [PTR_WIDTH-1:0]    wraddr; 
    wire [PTR_WIDTH-1:0]    rdaddr; 
     
    assign enable_wr = (i_wr_en && !o_full); 
    assign enable_rd = (i_rd_en && !o_empty); 
     
    fifo_mem #(.MEM_DEPTH(FIFO_DEPTH), .MEM_WIDTH(DATA_WIDTH)) u_fifo_mem ( 
    .i_rst_n(i_rst_n), 
    .i_wr_clk(i_wr_clk), 
    .i_wr_en(enable_wr), 
    .i_wr_data(i_wr_data), 
    .i_wr_addr(wraddr), 
    .i_rd_clk(i_rd_clk), 
    .i_rd_en(enable_rd), 
    .i_rd_addr(rdaddr), 
    .o_rd_data(o_rd_data) 
    ); 
     
    wrptr_full #(.PTR_WIDTH(PTR_WIDTH)) u_wrptr_full ( 
    .i_wr_clk(i_wr_clk), 
    .i_rst_n(i_rst_n), 
    .i_wr_en(i_wr_en), 
    .i_rdptr_sync(rdptr_g2b_out), 
    .o_wrptr(wrptr), 
    .o_wraddr(wraddr), 
    .o_full_flag(o_full) 
    );

    bin2gray u_wrptr_bin2gray( 
    .i_bin(wrptr), 
    .o_gray(wrptr_b2g_out) 
    ); 
     
    syn2stage #(.SIG_WIDTH(DATA_WIDTH)) u_wrptr_syn( 
    .i_clk(i_rd_clk), 
    .i_rst_n(i_rst_n), 
    .i_sig(wrptr_b2g_out), 
    .o_sig_sync(wrptr_sync) 
    ); 
     
    gray2bin u_wrptr_gray2bin( 
    .i_gray(wrptr_sync), 
    .o_bin(wrptr_g2b_out) 
    ); 
     
    rdptr_empty #(.PTR_WIDTH(PTR_WIDTH)) u_rdptr_empty ( 
    .i_rd_clk(i_rd_clk), 
    .i_rst_n(i_rst_n), 
    .i_rd_en(i_rd_en), 
    .i_wrptr_sync(wrptr_g2b_out), 
    .o_rdptr(rdptr), 
    .o_rdaddr(rdaddr), 
    .o_empty_flag(o_empty) 
    ); 
     
    bin2gray u_rdptr_bin2gray( 
    .i_bin(rdptr), 
    .o_gray(rdptr_b2g_out) 
    ); 
     
    syn2stage #(.SIG_WIDTH(DATA_WIDTH)) u_rdptr_syn( 
    .i_clk(i_wr_clk), 
    .i_rst_n(i_rst_n), 
    .i_sig(rdptr_b2g_out), 
    .o_sig_sync(rdptr_sync) 
    ); 
     
    gray2bin u_rdptr_gray2bin( 
    .i_gray(rdptr_sync), 
    .o_bin(rdptr_g2b_out) 
    ); 
 
endmodule

module fifo_mem #(parameter MEM_DEPTH=8, parameter MEM_WIDTH=4)( 
    input  wire                         i_wr_clk, 
    input  wire                         i_rst_n, 
    input  wire                         i_wr_en, 
    input  wire [MEM_WIDTH-1:0]         i_wr_data, 
    input  wire [$clog2(MEM_DEPTH)-1:0] i_wr_addr, 
    input  wire                         i_rd_clk, 
    input  wire                         i_rd_en, 
    input  wire [$clog2(MEM_DEPTH)-1:0] i_rd_addr, 
    output reg  [MEM_WIDTH-1:0]         o_rd_data 
); 
 
    reg [MEM_WIDTH-1:0] mem_r [MEM_DEPTH-1:0]; 
    integer i; 
     
    always @ (posedge i_wr_clk or negedge i_rst_n) begin 
        if(!i_rst_n) begin 
            for (i=0;i<MEM_DEPTH;i=i+1) begin 
                mem_r[i] = 'b0; 
            end 
        end 
        else if(i_wr_en) begin 
            mem_r[i_wr_addr] <= i_wr_data; 
        end 
    end 
     
    always @ (posedge i_rd_clk or negedge i_rst_n) begin 
        if(!i_rst_n) begin 
            o_rd_data <= 'b0; 
        end 
        else if(i_rd_en) begin 
            o_rd_data <= mem_r[i_rd_addr]; 
        end 
    end 
 
endmodule 

module wrptr_full #(parameter PTR_WIDTH=3)( 
    input  wire                 i_wr_clk, 
    input  wire                 i_rst_n, 
    input  wire                 i_wr_en, 
    input  wire [PTR_WIDTH:0]   i_rdptr_sync, 
    output reg  [PTR_WIDTH:0]   o_wrptr, 
    output wire [PTR_WIDTH-1:0] o_wraddr, 
    output wire                 o_full_flag 
); 
 
    always @ (posedge i_wr_clk or negedge i_rst_n) begin 
        if(!i_rst_n) begin 
            o_wrptr     <= 'b0; 
        end else begin 
            if(i_wr_en && !o_full_flag) begin 
                o_wrptr <= o_wrptr + 1; 
            end 
        end 
    end 
     
    assign o_wraddr = o_wrptr[PTR_WIDTH-1:0]; 
     
    assign o_full_flag = ({~o_wrptr[PTR_WIDTH],o_wrptr[PTR_WIDTH-1:0]} == i_rdptr_sync); 
 
endmodule

module rdptr_empty #(parameter PTR_WIDTH=3)( 
    input  wire                 i_rd_clk, 
    input  wire                 i_rst_n, 
    input  wire                 i_rd_en, 
    input  wire [PTR_WIDTH:0]   i_wrptr_sync, 
    output reg  [PTR_WIDTH:0]   o_rdptr, 
    output wire [PTR_WIDTH-1:0] o_rdaddr, 
    output wire                 o_empty_flag 
); 
 
    always @ (posedge i_rd_clk or negedge i_rst_n) begin 
        if(!i_rst_n) begin 
            o_rdptr     <= 'b0; 
        end else begin 
            if(i_rd_en && !o_empty_flag) begin 
                o_rdptr <= o_rdptr + 1; 
            end 
        end 
    end 
     
    assign o_rdaddr = o_rdptr[PTR_WIDTH-1:0]; 
     
    assign o_empty_flag = (o_rdptr == i_wrptr_sync); 
 
endmodule 

module bin2gray ( 
input  wire [3:0] i_bin, 
output reg  [3:0] o_gray 
); 
    always@(*) begin 
        case(i_bin) 
            4'b0000: o_gray = 4'b0000; 
            4'b0001: o_gray = 4'b0001; 
            4'b0010: o_gray = 4'b0011; 
            4'b0011: o_gray = 4'b0010; 
            4'b0100: o_gray = 4'b0110; 
            4'b0101: o_gray = 4'b0111; 
            4'b0110: o_gray = 4'b0101; 
            4'b0111: o_gray = 4'b0100; 
            4'b1000: o_gray = 4'b1100; 
            4'b1001: o_gray = 4'b1101; 
            4'b1010: o_gray = 4'b1111; 
            4'b1011: o_gray = 4'b1110; 
            4'b1100: o_gray = 4'b1010; 
            4'b1101: o_gray = 4'b1011; 
            4'b1110: o_gray = 4'b1001; 
            4'b1111: o_gray = 4'b1000; 
            default: o_gray = 4'b0000; 
        endcase 
    end 
endmodule 

module gray2bin ( 
input  wire [3:0] i_gray, 
output reg  [3:0] o_bin 
); 
    always@(*) begin 
        case(i_gray) 
            4'b0000: o_bin = 4'b0000; 
            4'b0001: o_bin = 4'b0001; 
            4'b0011: o_bin = 4'b0010; 
            4'b0010: o_bin = 4'b0011; 
            4'b0110: o_bin = 4'b0100; 
            4'b0111: o_bin = 4'b0101; 
            4'b0101: o_bin = 4'b0110; 
            4'b0100: o_bin = 4'b0111; 
            4'b1100: o_bin = 4'b1000; 
            4'b1101: o_bin = 4'b1001; 
            4'b1111: o_bin = 4'b1010; 
            4'b1110: o_bin = 4'b1011; 
            4'b1010: o_bin = 4'b1100; 
            4'b1011: o_bin = 4'b1101; 
            4'b1001: o_bin = 4'b1110; 
            4'b1000: o_bin = 4'b1111; 
            default: o_bin = 4'b0000; 
        endcase 
    end 
endmodule

module syn2stage #(parameter SIG_WIDTH = 4)( 
    input  wire                 i_clk, 
    input  wire                 i_rst_n, 
    input  wire [SIG_WIDTH-1:0] i_sig, 
    output reg  [SIG_WIDTH-1:0] o_sig_sync 
); 
 
    reg [SIG_WIDTH-1:0] sig_r; 
    always@(posedge i_clk or negedge i_rst_n) begin 
        if(!i_rst_n) begin 
            sig_r      <= 3'b0; 
            o_sig_sync <= 3'b0; 
        end else begin 
            sig_r      <= i_sig; 
            o_sig_sync <= sig_r; 
        end 
    end 
 
endmodule 