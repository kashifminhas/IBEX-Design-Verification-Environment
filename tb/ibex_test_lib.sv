class core_ibex_reset_test extends core_ibex_base_test;

  `uvm_component_utils(core_ibex_reset_test)
  `uvm_component_new

  bit [5:0] num_reset;

  virtual task send_stimulus();
    vseq.start(env.vseqr);
    `DV_CHECK_STD_RANDOMIZE_WITH_FATAL(num_reset, num_reset > 20;)
    for (int i = 0; i < num_reset; i = i + 1) begin
      clk_vif.wait_clks($urandom_range(0, 50000));
      fork
        begin
          dut_vif.dut_cb.fetch_enable <= 1'b0;
          clk_vif.apply_reset(.reset_width_clks (100));
        end
        begin
          clk_vif.wait_clks(1);
          item_collected_port.flush();
          env.reset();
          load_binary_to_mem();
        end
      join
      dut_vif.dut_cb.fetch_enable <= 1'b1;
    end
  endtask

endclass