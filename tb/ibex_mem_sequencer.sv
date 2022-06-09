
class ibex_mem_intf_response_sequencer extends uvm_sequencer #(ibex_mem_intf_seq_item);

  uvm_tlm_analysis_fifo #(ibex_mem_intf_seq_item) addr_ph_port;

  `uvm_component_utils(ibex_mem_intf_response_sequencer)

  function new (string name, uvm_component parent);
    super.new(name, parent);
    addr_ph_port = new("addr_ph_port_sequencer", this);
  endfunction : new

  function void reset();
    addr_ph_port.flush();
  endfunction

endclass : ibex_mem_intf_response_sequencer