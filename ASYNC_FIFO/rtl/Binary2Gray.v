module Binary2Gray #(
    parameter WIDTH = 4
) (
    input       wire        [WIDTH-1:0]         i_data_binary,
    output      wire        [WIDTH-1:0]         o_data_gray
);

genvar i;
generate
    for (i = WIDTH-2 ; i >= 0 ; i = i - 1) begin
        assign o_data_gray[i] = i_data_binary[i+1] ^ i_data_binary[i];
    end
endgenerate

assign o_data_gray[WIDTH-1] = i_data_binary[WIDTH-1];


endmodule