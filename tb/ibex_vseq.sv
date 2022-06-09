class core_ibex_vseq extends uvm_sequence;

  ibex_mem_intf_response_seq                       instr_intf_seq;
  ibex_mem_intf_response_seq                       data_intf_seq;
  mem_model_pkg::mem_model                      mem;
  core_ibex_env_cfg                             cfg;
  bit[ibex_mem_intf_agent_pkg::DATA_WIDTH-1:0]  data;

  `uvm_object_utils(core_ibex_vseq)
  `uvm_declare_p_sequencer(core_ibex_vseqr)
  `uvm_object_new

  virtual task body();
    instr_intf_seq = ibex_mem_intf_response_seq::type_id::create("instr_intf_seq");
    data_intf_seq  = ibex_mem_intf_response_seq::type_id::create("data_intf_seq");
    data_intf_seq.is_dmem_seq = 1'b1;
    instr_intf_seq.m_mem = mem;
    data_intf_seq.m_mem  = mem;
    fork
      instr_intf_seq.start(p_sequencer.instr_if_seqr);
      data_intf_seq.start(p_sequencer.data_if_seqr);
    join_none
  endtask

  virtual task stop();

  endtask
  
  virtual task start_debug_stress_seq();
  endtask

  virtual task start_debug_single_seq();
  endtask

  virtual task start_nmi_raise_seq();
  endtask

endclass
