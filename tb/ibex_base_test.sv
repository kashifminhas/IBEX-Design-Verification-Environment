class core_ibex_base_test extends uvm_test;

  core_ibex_env                                   env;
  core_ibex_env_cfg                               cfg;
  virtual clk_rst_if                              clk_vif;
  virtual core_ibex_dut_probe_if                  dut_vif;
  mem_model_pkg::mem_model                        mem;
  core_ibex_vseq                                  vseq;
  int unsigned                                    timeout_in_cycles = 100000000;
  int unsigned                                    max_quit_count  = 1;
  int unsigned                                    stimulus_delay = 800;
  bit[ibex_mem_intf_agent_pkg::DATA_WIDTH-1:0]    signature_data_q[$];
  bit[ibex_mem_intf_agent_pkg::DATA_WIDTH-1:0]    signature_data;
  uvm_tlm_analysis_fifo #(ibex_mem_intf_seq_item) item_collected_port;
  uvm_phase                                       cur_run_phase;

  `uvm_component_utils(core_ibex_base_test)

  function new(string name="", uvm_component parent=null);
    core_ibex_report_server ibex_report_server;
    super.new(name, parent);
    ibex_report_server = new();
    uvm_report_server::set_server(ibex_report_server);
    item_collected_port = new("item_collected_port_test", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    $value$plusargs("timeout_in_cycles=%0d", timeout_in_cycles);
    if (!uvm_config_db#(virtual clk_rst_if)::get(null, "", "clk_if", clk_vif)) begin
      `uvm_fatal(`gfn, "Cannot get clk_if")
    end
    if (!uvm_config_db#(virtual core_ibex_dut_probe_if)::get(null, "", "dut_if", dut_vif)) begin
      `uvm_fatal(`gfn, "Cannot get dut_if")
    end
    env = core_ibex_env::type_id::create("env", this);
    cfg = core_ibex_env_cfg::type_id::create("cfg", this);
    uvm_config_db#(core_ibex_env_cfg)::set(this, "*", "cfg", cfg);
    mem = mem_model_pkg::mem_model#()::type_id::create("mem");
    vseq = core_ibex_vseq::type_id::create("vseq");
    vseq.mem = mem;
    vseq.cfg = cfg;
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    env.data_if_response_agent.monitor.item_collected_port.connect(
      this.item_collected_port.analysis_export);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    cur_run_phase = phase;
    dut_vif.dut_cb.fetch_enable <= 1'b0;
    clk_vif.wait_clks(100);
    $display("starting loading bin file");
    load_binary_to_mem();
    $display("completed loading bin file");
    dut_vif.dut_cb.fetch_enable <= 1'b1;
    send_stimulus();
    $display("starting send_stimulus func");
    wait_for_test_done();
    $display("wait_for_test_done_completed");
    $display(mem);
    cur_run_phase = null;
    phase.drop_objection(this);
  endtask

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    void'($value$plusargs("max_quit_count=%0d", max_quit_count));
    uvm_report_server::get_server().set_max_quit_count(max_quit_count);
  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
  endfunction

  virtual task send_stimulus();
    vseq.start(env.vseqr);
  endtask

  virtual task check_perf_stats();
  endtask

  function void load_binary_to_mem();
    string      bin;
    bit [7:0]   r8;
    bit [31:0]  addr = 32'h`BOOT_ADDR;
    int         f_bin;
    void'($value$plusargs("bin=%0s", bin));
    if (bin == "")
      `uvm_fatal(get_full_name(), "Please specify test binary by +bin=binary_name")
    `uvm_info(get_full_name(), $sformatf("Running test : %0s", bin), UVM_LOW)
    f_bin = $fopen(bin,"rb");
    if (!f_bin)
      `uvm_fatal(get_full_name(), $sformatf("Cannot open file %0s", bin))
    while ($fread(r8,f_bin)) begin
      `uvm_info(`gfn, $sformatf("Init mem [0x%h] = 0x%0h", addr, r8), UVM_FULL)
      mem.write(addr, r8);
      addr++;
    end
  endfunction

  virtual task wait_for_test_done();
    fork
      begin
        wait (dut_vif.ecall === 1'b1);
        vseq.stop();
        `uvm_info(`gfn, "ECALL instruction is detected, test done", UVM_LOW)
        dut_vif.dut_cb.fetch_enable <= 1'b0;
        fork
          check_perf_stats();
          clk_vif.wait_clks(3000);
        join
      end
      begin
        clk_vif.wait_clks(timeout_in_cycles);
        `uvm_fatal(`gfn, "TEST TIMEOUT!!")
      end
    join_any
  endtask


  virtual task wait_for_mem_txn(input bit[ibex_mem_intf_agent_pkg::ADDR_WIDTH-1:0] ref_addr,
                                input signature_type_t ref_type);
    ibex_mem_intf_seq_item mem_txn;
    forever begin
      item_collected_port.get(mem_txn);
      if (mem_txn.addr == ref_addr && mem_txn.data[7:0] === ref_type &&
          mem_txn.read_write == WRITE) begin
        signature_data = mem_txn.data;
        case (ref_type)
          CORE_STATUS: begin
            signature_data_q.push_back(signature_data >> 8);
          end
          TEST_RESULT: begin
            signature_data_q.push_back(signature_data >> 8);
          end
          WRITE_GPR: begin
            for(int i = 0; i < 32; i++) begin
              do begin
                item_collected_port.get(mem_txn);
              end while(!(mem_txn.addr == ref_addr && mem_txn.read_write == WRITE));
              signature_data_q.push_back(mem_txn.data);
            end
          end
          WRITE_CSR: begin
            signature_data_q.push_back(signature_data >> 8);
            do begin
              item_collected_port.get(mem_txn);
            end while (!(mem_txn.addr == ref_addr && mem_txn.read_write == WRITE));
            signature_data_q.push_back(mem_txn.data);
          end
          default: begin
            `uvm_fatal(`gfn,
              $sformatf("The data 0x%0h written to the signature address is formatted incorrectly.",
                        signature_data))
          end
        endcase
        return;
      end
    end
  endtask

endclass
