`include "ibex_env_pkg.sv"
`include "riscv_signature_pkg.sv"

package core_ibex_test_pkg;

  import uvm_pkg::*;
  import core_ibex_env_pkg::*;
  import ibex_mem_intf_agent_pkg::*;
  import riscv_signature_pkg::*;
  import ibex_pkg::*;

  typedef struct {
    ibex_pkg::opcode_e  opcode;
    bit [2:0]           funct3;
    bit [6:0]           funct7;
    bit [11:0]          system_imm;
  } instr_t;

  `include "ibex_report_server.sv"
  `include "ibex_seq_lib.sv"
  `include "ibex_vseq.sv"
  `include "ibex_base_test.sv"
  `include "ibex_test_lib.sv"

endpackage
