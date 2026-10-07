module DSP48A1_tb();

// Test signals
    reg CLK;
    reg [17:0] A, B, D;
    reg [47:0] C;
    reg CARRYIN;
    reg [7:0] OPMODE;
    reg CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP;
    reg RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;
    reg [17:0] BCIN;
    reg [47:0] PCIN;

    wire [35:0] M;
    wire [47:0] P;
    wire CARRYOUT, CARRYOUTF;
    wire [17:0] BCOUT;
    wire [47:0] PCOUT;

    // Test tracking variables
    integer test_num = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    reg [47:0] previous_P;
    reg previous_CARRYOUT;


     // Instantiate DUT with specified parameters
    DSP48A1 #(
        .A0REG(0), .A1REG(1), .B0REG(0), .B1REG(1),
        .CREG(1), .DREG(1), .MREG(1), .PREG(1),
        .CARRYINREG(1), .CARRYOUTREG(1), .OPMODEREG(1),
        .CARRYINSEL("OPMODE5"), .B_INPUT("DIRECT"), .RSTTYPE("SYNC")
    ) dut (
        .CLK(CLK),
        .A(A), .B(B), .C(C), .D(D), .CARRYIN(CARRYIN),
        .OPMODE(OPMODE),
        .CEA(CEA), .CEB(CEB), .CEC(CEC), .CECARRYIN(CECARRYIN),
        .CED(CED), .CEM(CEM), .CEOPMODE(CEOPMODE), .CEP(CEP),
        .RSTA(RSTA), .RSTB(RSTB), .RSTC(RSTC), .RSTCARRYIN(RSTCARRYIN),
        .RSTD(RSTD), .RSTM(RSTM), .RSTOPMODE(RSTOPMODE), .RSTP(RSTP),
        .BCIN(BCIN), .PCIN(PCIN),
        .M(M), .P(P), .CARRYOUT(CARRYOUT), .CARRYOUTF(CARRYOUTF),
        .BCOUT(BCOUT), .PCOUT(PCOUT)
    );

    // Clock generation
    initial begin
        CLK = 0;
        forever
        #1 CLK = ~CLK;
    end

    // Task 1: Verify Reset Operation (Enhanced with Internal Signal Verification)
    task test_reset_operation;
        begin
            $display("\nTest 1: Reset Operation Verification");
            $display("====================================");

            // ADDITION: First load some data into registers to verify reset clears them
            $display("Loading test data into internal registers...");
            RSTA = 0; RSTB = 0; RSTC = 0; RSTCARRYIN = 0;
            RSTD = 0; RSTM = 0; RSTOPMODE = 0; RSTP = 0;
            CEA = 1; CEB = 1; CEC = 1; CECARRYIN = 1;
            CED = 1; CEM = 1; CEOPMODE = 1; CEP = 1;

            // Load known test patterns
            A = 18'h3FFFF; B = 18'h2AAAA; C = 48'hAAAAAAAAAAAA;
            D = 18'h15555; OPMODE = 8'hFF; CARRYIN = 1'b1;
            BCIN = 18'h11111; PCIN = 48'h555555555555;

            // Wait for data to propagate
            repeat(3) @(negedge CLK);

            // ADDITION: Display internal register values before reset
            $display("Internal registers BEFORE reset:");
            $display("  A1_reg = 0x%h (A0REG=0, only A1 exists)", dut.A1_reg);
            $display("  B1_reg = 0x%h (B0REG=0, only B1 exists)", dut.B1_reg);
            $display("  C_reg = 0x%h", dut.C_reg);
            $display("  D_reg = 0x%h", dut.D_reg);
            $display("  OPMODE_reg = 0x%h", dut.OPMODE_reg);
            $display("  M_reg = 0x%h, P_reg = 0x%h", dut.M_reg, dut.P_reg);

            // Assert all active-high reset signals
            RSTA = 1; RSTB = 1; RSTC = 1; RSTCARRYIN = 1;
            RSTD = 1; RSTM = 1; RSTOPMODE = 1; RSTP = 1;

            // Drive remaining inputs with arbitrary values
            A = $random;
            B = $random;
            C = $random;
            D = $random;
            CARRYIN = $random;
            OPMODE = $random;
            BCIN = $random;
            PCIN = $random;

            // Wait for negative edge of clock
            @(negedge CLK);

            // ADDITION: Display internal register values after reset
            $display("Internal registers AFTER reset:");
            $display("  A1_reg = 0x%h", dut.A1_reg);
            $display("  B1_reg = 0x%h", dut.B1_reg);
            $display("  C_reg = 0x%h", dut.C_reg);
            $display("  D_reg = 0x%h", dut.D_reg);
            $display("  OPMODE_reg = 0x%h", dut.OPMODE_reg);
            $display("  M_reg = 0x%h, P_reg = 0x%h", dut.M_reg, dut.P_reg);

            // ADDITION: Verify internal registers are cleared
            if (dut.A1_reg !== 18'h0) begin
                $display("ERROR: A1_reg not cleared by RSTA (0x%h)", dut.A1_reg);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: A1_reg cleared by RSTA");
            end

            if (dut.B1_reg !== 18'h0) begin
                $display("ERROR: B1_reg not cleared by RSTB (0x%h)", dut.B1_reg);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: B1_reg cleared by RSTB");
            end

            if (dut.C_reg !== 48'h0) begin
                $display("ERROR: C_reg not cleared by RSTC (0x%h)", dut.C_reg);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: C_reg cleared by RSTC");
            end

            if (dut.D_reg !== 18'h0) begin
                $display("ERROR: D_reg not cleared by RSTD (0x%h)", dut.D_reg);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: D_reg cleared by RSTD");
            end

            if (dut.OPMODE_reg !== 8'h0) begin
                $display("ERROR: OPMODE_reg not cleared by RSTOPMODE (0x%h)", dut.OPMODE_reg);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: OPMODE_reg cleared by RSTOPMODE");
            end

            if (dut.M_reg !== 36'h0) begin
                $display("ERROR: M_reg not cleared by RSTM (0x%h)", dut.M_reg);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: M_reg cleared by RSTM");
            end

            if (dut.P_reg !== 48'h0) begin
                $display("ERROR: P_reg not cleared by RSTP (0x%h)", dut.P_reg);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: P_reg cleared by RSTP");
            end

            // Self-checking: verify all outputs are zero
            if (M == 36'h0 && P == 48'h0 && CARRYOUT == 1'b0 &&
                CARRYOUTF == 1'b0 && BCOUT == 18'h0 && PCOUT == 48'h0) begin
                $display("PASS: Reset Operation - All outputs are zero");
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: Reset Operation");
                $display("      M=%h, P=%h, CARRYOUT=%b, CARRYOUTF=%b, BCOUT=%h, PCOUT=%h",
                        M, P, CARRYOUT, CARRYOUTF, BCOUT, PCOUT);
                fail_count = fail_count + 1;
            end

            // Deassert all reset signals and assert all clock enable signals
            RSTA = 0; RSTB = 0; RSTC = 0; RSTCARRYIN = 0;
            RSTD = 0; RSTM = 0; RSTOPMODE = 0; RSTP = 0;
            CEA = 1; CEB = 1; CEC = 1; CECARRYIN = 1;
            CED = 1; CEM = 1; CEOPMODE = 1; CEP = 1;

            test_num = test_num + 1;
        end
    endtask


    // Task 2: Verify DSP Path 1
    task test_dsp_path_1;
        begin
            $display("\nTest 2: DSP Path 1 - Pre-subtractor and Post-subtractor");
            $display("========================================================");
            $display("Path: Pre-subtractor -> Multiplier -> Post-subtractor");
            $display("OPMODE = 8'b11011101 (Pre-sub, Mult output to X, C to Z, Post-sub)");

            // Apply specified input values
            A = 20;
            B = 10;
            C = 350;
            D = 25;
            OPMODE = 8'b11011101;

            // Drive cascade inputs with arbitrary values
            BCIN = $random;
            PCIN = $random;
            CARRYIN = $random;

            // Wait for four negative clock edges (pipeline depth)
            repeat(4) @(negedge CLK);

            // Expected outputs according to specification
            // Pre-adder: D - B = 25 - 10 = 15
            // Multiplier: A * (D - B) = 20 * 15 = 300 (0x12c)
            // Post-adder: C - (A * (D-B)) = 350 - 300 = 50 (0x32)
            // BCOUT should be B after pipeline = 10 (0xf)


            if (BCOUT == 18'hf && M == 36'h12c && P == 48'h32 &&
                PCOUT == 48'h32 && CARRYOUT == 1'b0 && CARRYOUTF == 1'b0) begin
                $display("PASS: DSP Path 1");
                $display("      BCOUT=%h, M=%h, P=%h, PCOUT=%h, CARRYOUT=%b",
                        BCOUT, M, P, PCOUT, CARRYOUT);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: DSP Path 1");
                $display("      Expected: BCOUT=0xf, M=0x12c, P=0x32, PCOUT=0x32, CARRYOUT=0");
                $display("      Actual:   BCOUT=%h, M=%h, P=%h, PCOUT=%h, CARRYOUT=%b",
                        BCOUT, M, P, PCOUT, CARRYOUT);
                fail_count = fail_count + 1;
            end

            test_num = test_num + 1;
        end
    endtask

    // Task 3: Verify DSP Path 2
    task test_dsp_path_2;
        begin
            $display("\nTest 3: DSP Path 2 - Pre-adder with zeros routing");
            $display("=================================================");
            $display("Path: Pre-adder -> Multiplier -> Zero output");
            $display("OPMODE = 8'b00010000 (Pre-add, zeros to X and Z)");

            // Apply specified input values
            A = 20;
            B = 10;
            C = 350;
            D = 25;
            OPMODE = 8'b00010000;

            // Drive cascade inputs with arbitrary values
            BCIN = $random;
            PCIN = $random;
            CARRYIN = $random;

            // Wait for three negative clock edges
            repeat(3) @(negedge CLK);

            // Expected outputs according to specification
            // Pre-adder: D + B = 25 + 10 = 35 (0x23)
            // Multiplier: A * (D + B) = 20 * 35 = 700 (0x2bc)
            // Post-adder: 0 + 0 = 0 (zeros through both muxes)

            if (BCOUT == 18'h23 && M == 36'h2bc && P == 48'h0 &&
                PCOUT == 48'h0 && CARRYOUT == 1'b0 && CARRYOUTF == 1'b0) begin
                $display("PASS: DSP Path 2");
                $display("      BCOUT=%h, M=%h, P=%h, PCOUT=%h, CARRYOUT=%b",
                        BCOUT, M, P, PCOUT, CARRYOUT);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: DSP Path 2");
                $display("      Expected: BCOUT=0x23, M=0x2bc, P=0x0, PCOUT=0x0, CARRYOUT=0");
                $display("      Actual:   BCOUT=%h, M=%h, P=%h, PCOUT=%h, CARRYOUT=%b",
                        BCOUT, M, P, PCOUT, CARRYOUT);
                fail_count = fail_count + 1;
            end

            test_num = test_num + 1;
        end
    endtask

    // Task 4: Verify DSP Path 3
    task test_dsp_path_3;
        begin
            $display("\nTest 4: DSP Path 3 - P feedback path");
            $display("====================================");
            $display("Path: No pre-adder -> Multiplier -> P feedback");
            $display("OPMODE = 8'b00001010 (No pre-add, P feedback to X and Z)");

            // Store previous P and CARRYOUT values for comparison
            previous_P = P;
            previous_CARRYOUT = CARRYOUT;

            // Apply specified input values
            A = 20;
            B = 10;
            C = 350;
            D = 25;
            OPMODE = 8'b00001010;

            // Drive cascade inputs with arbitrary values
            BCIN = $random;
            PCIN = $random;
            CARRYIN = $random;

            // Wait for three negative clock edges
            repeat(3) @(negedge CLK);

            // Expected outputs according to specification
            // No pre-adder: B passes through = 10 (0xa)
            // Multiplier: A * B = 20 * 10 = 200 (0xc8)
            // Post-adder: P + P = 2*P (P feedback to both X and Z)

            if (BCOUT == 18'ha && M == 36'hc8 && P == previous_P &&
                PCOUT == P && CARRYOUT == previous_CARRYOUT && CARRYOUTF == previous_CARRYOUT) begin
                $display("PASS: DSP Path 3");
                $display("      BCOUT=%h, M=%h, P=%h (previous), PCOUT=%h, CARRYOUT=%b",
                        BCOUT, M, P, PCOUT, CARRYOUT);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: DSP Path 3");
                $display("      Expected: BCOUT=0xa, M=0xc8, P=previous_P, PCOUT=P, CARRYOUT=previous");
                $display("      Actual:   BCOUT=%h, M=%h, P=%h, PCOUT=%h, CARRYOUT=%b",
                        BCOUT, M, P, PCOUT, CARRYOUT);
                $display("      Previous: P=%h, CARRYOUT=%b", previous_P, previous_CARRYOUT);
                fail_count = fail_count + 1;
            end

            test_num = test_num + 1;
        end
    endtask

    // Task 5: Verify DSP Path 4
    task test_dsp_path_4;
        begin
            $display("\nTest 5: DSP Path 4 - Concatenation and subtraction");
            $display("==================================================");
            $display("Path: No pre-adder -> Multiplier -> Concatenation subtraction");
            $display("OPMODE = 8'b10100111 (No pre-add, D:A:B to X, PCIN to Z, subtract)");

            // Apply specified input values
            A = 5;
            B = 6;
            C = 350;
            D = 25;
            PCIN = 3000;
            OPMODE = 8'b10100111;

            // Drive remaining cascade inputs with arbitrary values
            BCIN = $random;
            CARRYIN = $random;

            // Wait for three negative clock edges
            repeat(3) @(negedge CLK);

            // Expected outputs according to specification
            // No pre-adder: B passes through = 6
            // Multiplier: A * B = 5 * 6 = 30 (0x1e)
            // Concatenation: {D[11:0], A, B} = {25[11:0], 5, 6} = {0x019, 0x00005, 0x00006}
            // Post-subtractor: PCIN - {D[11:0], A, B} = 3000 - concatenated_value
            // Expected: BCOUT=0x6, M=0x1e, P=PCOUT=0xfe6fffec0bb1, CARRYOUT=1

            if (BCOUT == 18'h6 && M == 36'h1e && P == 48'hfe6fffec0bb1 &&
                PCOUT == 48'hfe6fffec0bb1 && CARRYOUT == 1'b1 && CARRYOUTF == 1'b1) begin
                $display("PASS: DSP Path 4");
                $display("      BCOUT=%h, M=%h, P=%h, PCOUT=%h, CARRYOUT=%b",
                        BCOUT, M, P, PCOUT, CARRYOUT);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: DSP Path 4");
                $display("      Expected: BCOUT=0x6, M=0x1e, P=0xfe6fffec0bb1, PCOUT=0xfe6fffec0bb1, CARRYOUT=1");
                $display("      Actual:   BCOUT=%h, M=%h, P=%h, PCOUT=%h, CARRYOUT=%b",
                        BCOUT, M, P, PCOUT, CARRYOUT);
                fail_count = fail_count + 1;
            end

            test_num = test_num + 1;
        end
    endtask

    // Main test execution
    initial begin
        $display("Starting DSP48A1 Testbench - Specification Compliant");
        $display("========================================================");

        // Test sequence as per specification
        test_reset_operation();
        test_dsp_path_1();
        test_dsp_path_2();
        test_dsp_path_3();
        test_dsp_path_4();

        // Print final results
        print_test_summary();
        $stop;
    end

    
    task print_test_summary;
        begin
            $display("\n========================================================");
            $display("Test Summary:");
            $display("Total Tests: %0d", test_num);
            $display("Passed:      %0d", pass_count);
            $display("Failed:      %0d", fail_count);
            $display("========================================================");

            if (fail_count == 0) begin
                $display("ALL TESTS PASSED!");
            end else begin
                $display("SOME TESTS FAILED!");
            end
        end
    endtask

endmodule