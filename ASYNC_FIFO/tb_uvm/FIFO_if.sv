interface FIFO_if ();
    parameter  FIFO_WIDTH = 4;
    parameter  FIFO_DEPTH = 8;
    // Signals Declaration
    logic                  i_wclk;
    logic                  i_rclk;

    logic                  i_rst_n;

    logic                  i_wen;
    logic [FIFO_WIDTH-1:0] i_wdata;
    logic                  i_ren;

    logic                  o_full;
    logic                  o_empty;
    logic [FIFO_WIDTH-1:0] o_rdata;

    logic                  o_full_gold;
    logic                  o_empty_gold;
    logic [FIFO_WIDTH-1:0] o_rdata_gold;

    // Clock Generation
    initial begin
        i_wclk = 0;
        forever begin
            #10 i_wclk = ~i_wclk;
        end
    end

    initial begin
        i_rclk = 0;
        forever begin
            #5 i_rclk = ~i_rclk;
        end
    end

    
// Driver: change inputs 1 time unit after the edge
clocking cb_driver_wr @(posedge i_wclk);
    default output #1;
    output i_rst_n, i_wen, i_wdata;
endclocking

clocking cb_driver_rd @(posedge i_rclk);
    default output #1;
    output i_ren;
endclocking

// Monitor: sample values as they were just before the edge
clocking cb_monitor_wr @(posedge i_wclk);
    default input #1step;
    input i_rst_n, i_wen, i_wdata, o_full, o_full_gold;
endclocking

clocking cb_monitor_rd @(posedge i_rclk);
    default input #1step;
    input i_rst_n, i_ren, o_empty, o_rdata, o_empty_gold, o_rdata_gold;
endclocking

endinterface