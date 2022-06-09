`include "ibex_mem_agent_pkg.sv"

package core_ibex_env_pkg;

  import uvm_pkg::*;
  import ibex_mem_intf_agent_pkg::*;

  `include "ibex_vseqr.sv"
  `include "ibex_env_cfg.sv"
  `include "ibex_env.sv"

endpackage