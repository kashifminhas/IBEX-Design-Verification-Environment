interface clk_if(input logic clk);

  clocking cb @(posedge clk);
  endclocking

  clocking cbn @(negedge clk);
  endclocking

  task automatic wait_clks(int num_clks);
    repeat (num_clks) @cb;
  endtask


  task automatic wait_n_clks(int num_clks);
    repeat (num_clks) @cbn;
  endtask

endinterface
