module shift_reg_sva (input clk, reset, serial_in, direction, mode,
                      input [5:0] datain, dataout);

    // Reset is asynchronous: check it immediately, not on a clock edge
    always_comb begin
        if (reset)
            a_reset: assert final (dataout == 6'b0);
    end

    property p_shift_left;
        @(posedge clk) disable iff (reset)
        (!mode && direction) |=> dataout == {$past(datain[4:0]), $past(serial_in)};
    endproperty

    property p_shift_right;
        @(posedge clk) disable iff (reset)
        (!mode && !direction) |=> dataout == {$past(serial_in), $past(datain[5:1])};
    endproperty

    property p_rotate_left;
        @(posedge clk) disable iff (reset)
        (mode && direction) |=> dataout == {$past(datain[4:0]), $past(datain[5])};
    endproperty

    property p_rotate_right;
        @(posedge clk) disable iff (reset)
        (mode && !direction) |=> dataout == {$past(datain[0]), $past(datain[5:1])};
    endproperty

    a_shift_left  : assert property (p_shift_left);
    a_shift_right : assert property (p_shift_right);
    a_rotate_left : assert property (p_rotate_left);
    a_rotate_right: assert property (p_rotate_right);

    c_shift_left  : cover property (p_shift_left);
    c_shift_right : cover property (p_shift_right);
    c_rotate_left : cover property (p_rotate_left);
    c_rotate_right: cover property (p_rotate_right);

endmodule