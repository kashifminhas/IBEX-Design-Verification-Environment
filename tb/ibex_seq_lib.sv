class core_base_seq #(type REQ = uvm_sequence_item) extends uvm_sequence#(REQ);

  rand int unsigned  interval;
  rand int unsigned  delay;
  int unsigned       num_of_iterations;
  int unsigned       iteration_cnt;
  int unsigned       max_interval;
  int unsigned       max_delay = 500;
  virtual clk_rst_if clk_vif;
  bit                is_started;
  bit                stop_seq;
  bit                seq_finished;

  `uvm_object_param_utils(core_base_seq#(REQ))
  `uvm_object_new

  constraint reasonable_interval_c {
    interval dist {[0                 : max_interval/10]    :/ 1,
                   [max_interval/10   : 9*max_interval/10]  :/ 1,
                   [9*max_interval/10 : max_interval]       :/ 1
    };
  }

  constraint reasonable_delay_c {
    delay inside {[max_delay/10 : max_delay]};
  }

  virtual task body();
    if(!uvm_config_db#(virtual clk_rst_if)::get(null, "", "clk_if", clk_vif)) begin
       `uvm_fatal(get_full_name(), "Cannot get clk_if")
    end
    `DV_CHECK_MEMBER_RANDOMIZE_FATAL(delay)
    clk_vif.wait_clks(delay);
    `uvm_info(get_full_name(), "Starting sequence...", UVM_LOW)
    if (!is_started) is_started = 1'b1;
    while (!stop_seq) begin
      send_req();
      iteration_cnt++;
      `DV_CHECK_MEMBER_RANDOMIZE_FATAL(interval)
      clk_vif.wait_clks(interval);
      if (num_of_iterations > 0 && iteration_cnt >= num_of_iterations) begin
        break;
      end
    end
    seq_finished = 1'b1;
    `uvm_info(get_full_name(), "Exiting sequence", UVM_LOW)
  endtask

  virtual task send_req();
    `uvm_fatal(get_full_name(), "This task must be implemented in the extended class")
  endtask

  virtual task stop();
    stop_seq = 1'b1;
    `uvm_info(get_full_name(), "Stopping sequence", UVM_LOW)
    wait (seq_finished == 1'b1);
    is_started = 1'b0;
  endtask

endclass


