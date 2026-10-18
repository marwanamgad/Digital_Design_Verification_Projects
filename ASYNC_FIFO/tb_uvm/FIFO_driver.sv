class FIFO_driver extends uvm_driver #(FIFO_seq_item);

`uvm_component_utils(FIFO_driver)

virtual FIFO_if FIFO_vif;
FIFO_seq_item   seq_item;

function new (string name = "FIFO_driver", uvm_component parent = null);
    super.new(name,parent);
endfunction

task run_phase (uvm_phase phase);
    super.run_phase(phase);

    // Known values at time 0, before the first clocking-block drive
    FIFO_vif.i_rst_n = 0;
    FIFO_vif.i_wen   = 0;
    FIFO_vif.i_wdata = 0;
    FIFO_vif.i_ren   = 0;

    forever begin
        seq_item_port.get_next_item(seq_item);

        // Each domain is driven through its own clocking block, in parallel.
        // The item is done once both domains have taken it.
        fork
            begin // write domain
                @(FIFO_vif.cb_driver_wr);
                FIFO_vif.cb_driver_wr.i_rst_n <= seq_item.i_rst_n;
                FIFO_vif.cb_driver_wr.i_wen   <= seq_item.i_wen;
                FIFO_vif.cb_driver_wr.i_wdata <= seq_item.i_wdata;
            end
            begin // read domain
                @(FIFO_vif.cb_driver_rd);
                FIFO_vif.cb_driver_rd.i_ren   <= seq_item.i_ren;
            end
        join

        seq_item_port.item_done();
        `uvm_info("run_phase",seq_item.convert2string_stimulus(),UVM_FULL)
    end
endtask

endclass