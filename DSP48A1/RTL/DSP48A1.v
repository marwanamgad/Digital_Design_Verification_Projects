module DSP48A1 #(
    parameter A0REG = 0,
    parameter A1REG = 1,
    parameter B0REG = 0,
    parameter B1REG = 1,
    parameter CREG = 1,
    parameter DREG = 1,
    parameter MREG = 1,
    parameter PREG = 1,
    parameter CARRYINREG = 1,
    parameter CARRYOUTREG = 1,
    parameter OPMODEREG = 1,

    // Configuration parameters
    parameter CARRYINSEL = "OPMODE5",  // "CARRYIN" or "OPMODE5"
    parameter B_INPUT = "DIRECT",      // "DIRECT" or "CASCADE"
    parameter RSTTYPE = "SYNC"         // "SYNC" or "ASYNC"

) (
    // Clock
    input CLK,

    //Data Inputs

    input [17:0] A,
    input [17:0] B,
    input [47:0] C,
    input [17:0] D,
    input CARRYIN,

    // Control inputs
    input [7:0] OPMODE,

    // Clock enables
    input CEA,
    input CEB,
    input CEC,
    input CECARRYIN,
    input CED,
    input CEM,
    input CEOPMODE,
    input CEP,

    // Resets
    input RSTA,
    input RSTB,
    input RSTC,
    input RSTCARRYIN,
    input RSTD,
    input RSTM,
    input RSTOPMODE,
    input RSTP,

    // Cascade inputs
    input [17:0] BCIN,
    input [47:0] PCIN,

    // Data outputs
    output [35:0] M,
    output [47:0] P,
    output CARRYOUT,
    output CARRYOUTF,

    // Cascade outputs
    output [17:0] BCOUT,
    output [47:0] PCOUT

);

// Internal registers and wires
    reg [17:0] A0_reg, A1_reg;
    reg [17:0] B0_reg, B1_reg;
    reg [47:0] C_reg;
    reg [17:0] D_reg;
    reg [7:0] OPMODE_reg;
    reg CARRYIN_reg;
    reg [35:0] M_reg;
    reg [47:0] P_reg;
    reg CARRYOUT_reg;

    wire [17:0] A0_out, A1_out;
    wire [17:0] B0_out, B1_out;
    wire [47:0] C_out;
    wire [17:0] D_out;
    wire [7:0] OPMODE_out;
    wire CARRYIN_out;
    wire [35:0] M_out;
    wire [47:0] P_out;
    wire CARRYOUT_out;

    wire [17:0] B_input_mux;
    wire CARRYIN_mux;
    wire [17:0] pre_adder_out;
    wire [35:0] multiplier_out;
    wire [47:0] X_mux, Z_mux;
    wire [47:0] post_adder_out;
    wire post_adder_carryout;

    // NOTE: Every register below uses one of two clean styles, chosen by RSTTYPE:
    //   ASYNC : always @(posedge CLK or posedge RSTx)  -> reset checked first
    //   SYNC  : always @(posedge CLK)                  -> reset only on clock edge
    // (The old rst_a ... rst_opmode wires are no longer needed.)

     //B Input Multiplexer
    generate
        if (B_INPUT == "DIRECT")begin
            assign B_input_mux = B;
        end else if (B_INPUT == "CASCADE") begin
            assign B_input_mux = BCIN;
        end else begin
            assign B_input_mux = 18'b0;
        end
    endgenerate


    //CarryIn Multiplexer
    generate
        if (CARRYINSEL == "CARRYIN") begin
            assign CARRYIN_mux = CARRYIN_out;
        end else if (CARRYINSEL == "OPMODE5") begin
            assign CARRYIN_mux = OPMODE_out[5];
        end else begin
            assign CARRYIN_mux = 1'b0;
        end
    endgenerate

    // OPMODE register
    generate
        if (OPMODEREG == 1) begin
            if (RSTTYPE == "ASYNC") begin
                always @(posedge CLK or posedge RSTOPMODE) begin
                    if (RSTOPMODE)
                        OPMODE_reg <= 8'b0;
                    else if (CEOPMODE)
                        OPMODE_reg <= OPMODE;
                end
            end else begin
                always @(posedge CLK) begin
                    if (RSTOPMODE)
                        OPMODE_reg <= 8'b0;
                    else if (CEOPMODE)
                        OPMODE_reg <= OPMODE;
                end
            end
            assign OPMODE_out = OPMODE_reg;
        end else begin
            assign OPMODE_out = OPMODE;
        end
    endgenerate

    // A pipeline registers
    generate
        // A0 register
        if (A0REG == 1) begin
            if (RSTTYPE == "ASYNC") begin
                always @(posedge CLK or posedge RSTA) begin
                    if (RSTA)
                        A0_reg <= 18'b0;
                    else if (CEA)
                        A0_reg <= A;
                end
            end else begin
                always @(posedge CLK) begin
                    if (RSTA)
                        A0_reg <= 18'b0;
                    else if (CEA)
                        A0_reg <= A;
                end
            end
            assign A0_out = A0_reg;
        end else begin
            assign A0_out = A;
        end

        // A1 register
        if (A1REG == 1) begin
            if (RSTTYPE == "ASYNC") begin
                always @(posedge CLK or posedge RSTA) begin
                    if (RSTA)
                        A1_reg <= 18'b0;
                    else if (CEA)
                        A1_reg <= A0_out;
                end
            end else begin
                always @(posedge CLK) begin
                    if (RSTA)
                        A1_reg <= 18'b0;
                    else if (CEA)
                        A1_reg <= A0_out;
                end
            end
            assign A1_out = A1_reg;
        end else begin
            assign A1_out = A0_out;
        end
    endgenerate


    // Pre-adder/subtracter
    assign pre_adder_out = OPMODE_out[6] ? (D_out - B0_out) : (D_out + B0_out);


    // B pipeline registers
    generate
        // B0 register
        if (B0REG == 1) begin
            if (RSTTYPE == "ASYNC") begin
                always @(posedge CLK or posedge RSTB) begin
                    if (RSTB)
                        B0_reg <= 18'b0;
                    else if (CEB)
                        B0_reg <= B_input_mux;
                end
            end else begin
                always @(posedge CLK) begin
                    if (RSTB)
                        B0_reg <= 18'b0;
                    else if (CEB)
                        B0_reg <= B_input_mux;
                end
            end
            assign B0_out = B0_reg;
        end else begin
            assign B0_out = B_input_mux;
        end

        // B1 register
        if (B1REG == 1) begin
            if (RSTTYPE == "ASYNC") begin
                always @(posedge CLK or posedge RSTB) begin
                    if (RSTB)
                        B1_reg <= 18'b0;
                    else if (CEB)
                        B1_reg <= (OPMODE_out[4]) ? pre_adder_out : B0_out;
                end
            end else begin
                always @(posedge CLK) begin
                    if (RSTB)
                        B1_reg <= 18'b0;
                    else if (CEB)
                        B1_reg <= (OPMODE_out[4]) ? pre_adder_out : B0_out;
                end
            end
            assign B1_out = B1_reg;
        end else begin
            assign B1_out = B0_out;
        end
    endgenerate


    // C register
    generate
        if (CREG == 1) begin
            if (RSTTYPE == "ASYNC") begin
                always @(posedge CLK or posedge RSTC) begin
                    if (RSTC)
                        C_reg <= 48'b0;
                    else if (CEC)
                        C_reg <= C;
                end
            end else begin
                always @(posedge CLK) begin
                    if (RSTC)
                        C_reg <= 48'b0;
                    else if (CEC)
                        C_reg <= C;
                end
            end
            assign C_out = C_reg;
        end else begin
            assign C_out = C;
        end
    endgenerate


    // D Register
    generate
        if (DREG == 1) begin
            if (RSTTYPE == "ASYNC") begin
                always @(posedge CLK or posedge RSTD) begin
                    if (RSTD)
                        D_reg <= 18'b0;
                    else if (CED)
                        D_reg <= D;
                end
            end else begin
                always @(posedge CLK) begin
                    if (RSTD)
                        D_reg <= 18'b0;
                    else if (CED)
                        D_reg <= D;
                end
            end
            assign D_out = D_reg;
        end else begin
            assign D_out = D;
        end
    endgenerate


    //CarryIn Register
    generate
        if (CARRYINREG == 1) begin
            if (RSTTYPE == "ASYNC") begin
                always @(posedge CLK or posedge RSTCARRYIN) begin
                    if (RSTCARRYIN)
                        CARRYIN_reg <= 1'b0;
                    else if (CECARRYIN)
                        CARRYIN_reg <= CARRYIN;
                end
            end else begin
                always @(posedge CLK) begin
                    if (RSTCARRYIN)
                        CARRYIN_reg <= 1'b0;
                    else if (CECARRYIN)
                        CARRYIN_reg <= CARRYIN;
                end
            end
            assign CARRYIN_out = CARRYIN_reg;
        end else begin
            assign CARRYIN_out = CARRYIN;
        end
    endgenerate


    // Multiplier input selection and multiplication
    wire [17:0] mult_a = A1_out;
    wire [17:0] mult_b = OPMODE_out[4] ? pre_adder_out : B1_out;
    assign multiplier_out = mult_a * mult_b;


    // M register
    generate
        if (MREG == 1) begin
            if (RSTTYPE == "ASYNC") begin
                always @(posedge CLK or posedge RSTM) begin
                    if (RSTM)
                        M_reg <= 36'b0;
                    else if (CEM)
                        M_reg <= multiplier_out;
                end
            end else begin
                always @(posedge CLK) begin
                    if (RSTM)
                        M_reg <= 36'b0;
                    else if (CEM)
                        M_reg <= multiplier_out;
                end
            end
            assign M_out = M_reg;
        end else begin
            assign M_out = multiplier_out;
        end
    endgenerate

     // X multiplexer (48-bit)
    reg [47:0] X_mux_out;
    always @(*) begin
        case (OPMODE_out[1:0])
            2'b00: X_mux_out = 48'b0;
            2'b01: X_mux_out = {{12{M_out[35]}}, M_out}; // Sign extend M
            2'b10: X_mux_out = P_out;
            2'b11: X_mux_out = {D_out[11:0], A1_out, B1_out};
            default: X_mux_out = 48'b0;
        endcase
    end
    assign X_mux = X_mux_out;

    // Z multiplexer (48-bit)
    reg [47:0] Z_mux_out;
    always @(*) begin
        case (OPMODE_out[3:2])
            2'b00: Z_mux_out = 48'b0;
            2'b01: Z_mux_out = PCIN;
            2'b10: Z_mux_out = P_out;
            2'b11: Z_mux_out = C_out;
            default: Z_mux_out = 48'b0;
        endcase
    end
    assign Z_mux = Z_mux_out;

    // Post-adder/subtracter
    assign {post_adder_carryout, post_adder_out} =
        OPMODE_out[7] ? (Z_mux - (X_mux + CARRYIN_mux)) :
                        (Z_mux + X_mux + CARRYIN_mux);

     // P register
    generate
        if (PREG == 1) begin
            if (RSTTYPE == "ASYNC") begin
                always @(posedge CLK or posedge RSTP) begin
                    if (RSTP)
                        P_reg <= 48'b0;
                    else if (CEP)
                        P_reg <= post_adder_out;
                end
            end else begin
                always @(posedge CLK) begin
                    if (RSTP)
                        P_reg <= 48'b0;
                    else if (CEP)
                        P_reg <= post_adder_out;
                end
            end
            assign P_out = P_reg;
        end else begin
            assign P_out = post_adder_out;
        end
    endgenerate

    // CARRYOUT register
    generate
        if (CARRYOUTREG == 1) begin
            if (RSTTYPE == "ASYNC") begin
                always @(posedge CLK or posedge RSTCARRYIN) begin
                    if (RSTCARRYIN)
                        CARRYOUT_reg <= 1'b0;
                    else if (CECARRYIN)
                        CARRYOUT_reg <= post_adder_carryout;
                end
            end else begin
                always @(posedge CLK) begin
                    if (RSTCARRYIN)
                        CARRYOUT_reg <= 1'b0;
                    else if (CECARRYIN)
                        CARRYOUT_reg <= post_adder_carryout;
                end
            end
            assign CARRYOUT_out = CARRYOUT_reg;
        end else begin
            assign CARRYOUT_out = post_adder_carryout;
        end
    endgenerate


     // Output assignments
    assign M = M_out;
    assign P = P_out;
    assign CARRYOUT = CARRYOUT_out;
    assign CARRYOUTF = CARRYOUT_out;
    assign BCOUT = B1_out;
    assign PCOUT = P_out;

endmodule