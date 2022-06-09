`include "mem_model_pkg.sv"

package ibex_mem_intf_agent_pkg;

  import uvm_pkg::*;
  import mem_model_pkg::*;

  parameter int DATA_WIDTH = 32;
  parameter int ADDR_WIDTH = 32;

  typedef enum { READ, WRITE } rw_e;

  `include "uvm_macros.svh"
  `include "ibex_mem_seq_item.sv"
  `include "ibex_mem_monitor.sv"
  `include "ibex_mem_driver.sv"
  `include "ibex_mem_sequencer.sv"
  `include "ibex_mem_seq_lib.sv"
  `include "ibex_mem_agent.sv"

endpackage
