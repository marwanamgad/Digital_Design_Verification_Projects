module Double_FF_Sync #(
    parameter WIDTH = 4
) (
    input       wire        [WIDTH-1:0]         i_data,
    input       wire                            i_clk,
    input       wire                            i_rst_n,
    output      wire        [WIDTH-1:0]         o_data
);

reg [WIDTH-1:0] data_FF1, data_FF2;

always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        data_FF1 <= 0;
        data_FF2 <= 0;
    end
    else begin
        data_FF1 <= i_data;
        data_FF2 <= data_FF1;
    end
end

assign o_data = data_FF2;

endmodule