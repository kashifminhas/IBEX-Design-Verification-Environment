`define BOOT_ADDR 8000_0000
`include "dv_macros.svh"
`include "bus_params_pkg.sv"
`include "ibex_test_pkg.sv"
`include "ibex_mem_intf.sv"
`include "clk_rst_if.sv"
`include "ibex_dut_intf.sv"
module core_ibex_tb_top;

  import uvm_pkg::*;
  import core_ibex_test_pkg::*;

  wire clk;
  wire rst_n;
  logic fetch_enable;

  clk_rst_if     ibex_clk_if(.clk(clk), .rst_n(rst_n));
  ibex_mem_intf  data_mem_vif(.clk(clk));
  ibex_mem_intf  instr_mem_vif(.clk(clk));
  core_ibex_dut_probe_if dut_if(.clk(clk));

  `ifndef IBEX_CFG_RV32M
    `define IBEX_CFG_RV32M ibex_pkg::RV32MFast
  `endif

  `ifndef IBEX_CFG_RV32B
    `define IBEX_CFG_RV32B ibex_pkg::RV32BNone
  `endif

  `ifndef IBEX_CFG_RegFile
    `define IBEX_CFG_RegFile ibex_pkg::RegFileFF
  `endif

  parameter bit          PMPEnable       = 1'b0;
  parameter int unsigned PMPGranularity  = 0;
  parameter int unsigned PMPNumRegions   = 4;
  parameter bit RV32E                    = 1'b0;
  parameter ibex_pkg::rv32m_e RV32M      = `IBEX_CFG_RV32M;
  parameter ibex_pkg::rv32b_e RV32B      = `IBEX_CFG_RV32B;
  parameter ibex_pkg::regfile_e RegFile  = `IBEX_CFG_RegFile;
  parameter bit BranchTargetALU          = 1'b0;
  parameter bit WritebackStage           = 1'b0;
  parameter bit ICache                   = 1'b0;
  parameter bit ICacheECC                = 1'b0;
  parameter bit BranchPredictor          = 1'b0;
  parameter bit SecureIbex               = 1'b0;

  ibex_top_tracing #(
    .DmHaltAddr      (32'h`BOOT_ADDR + 'h0 ),
    .DmExceptionAddr (32'h`BOOT_ADDR + 'h4 ),
    .PMPEnable       (PMPEnable        ),
    .PMPGranularity  (PMPGranularity   ),
    .PMPNumRegions   (PMPNumRegions    ),
    .RV32E           (RV32E            ),
    .RV32M           (RV32M            ),
    .RV32B           (RV32B            ),
    .RegFile         (RegFile          ),
    .BranchTargetALU (BranchTargetALU  ),
    .WritebackStage  (WritebackStage   ),
    .ICache          (ICache           ),
    .ICacheECC       (ICacheECC        ),
    .SecureIbex      (SecureIbex       ),
    .BranchPredictor (BranchPredictor  )
  ) dut (
    .clk_i          (clk                  ),
    .rst_ni         (rst_n                ),

    .test_en_i      (1'b0                 ),
    .scan_rst_ni    (1'b1                 ),
    .ram_cfg_i      ('b0                  ),

    .hart_id_i      (32'b0                ),
    .boot_addr_i    (32'h`BOOT_ADDR       ), 

    .instr_req_o    (instr_mem_vif.request),
    .instr_gnt_i    (instr_mem_vif.grant  ),
    .instr_rvalid_i (instr_mem_vif.rvalid ),
    .instr_addr_o   (instr_mem_vif.addr   ),
    .instr_rdata_i  (instr_mem_vif.rdata  ),
    .instr_err_i    (instr_mem_vif.error  ),

    .data_req_o     (data_mem_vif.request ),
    .data_gnt_i     (data_mem_vif.grant   ),
    .data_rvalid_i  (data_mem_vif.rvalid  ),
    .data_addr_o    (data_mem_vif.addr    ),
    .data_we_o      (data_mem_vif.we      ),
    .data_be_o      (data_mem_vif.be      ),
    .data_rdata_i   (data_mem_vif.rdata   ),
    .data_wdata_o   (data_mem_vif.wdata   ),
    .data_err_i     (data_mem_vif.error   ),

    .irq_software_i (),
    .irq_timer_i    (),
    .irq_external_i (),
    .irq_fast_i     (),
    .irq_nm_i       (),
    
    .irq_software_i (1'b0 ),
    .irq_timer_i    (1'b0    ),
    .irq_external_i (1'b0 ),
    .irq_fast_i     (15'b0),
    .irq_nm_i       (1'b0),

    .debug_req_i    (dut_if.debug_req     ),
    .crash_dump_o   (                     ),

    .fetch_enable_i (dut_if.fetch_enable  ),
    .alert_minor_o  (dut_if.alert_minor   ),
    .alert_major_o  (dut_if.alert_major   ),
    .core_sleep_o   (dut_if.core_sleep    )
  );

  assign data_mem_vif.reset                   = ~rst_n;
  assign instr_mem_vif.reset                  = ~rst_n;
  assign instr_mem_vif.we                     = 0;
  assign instr_mem_vif.be                     = 0;
  assign instr_mem_vif.wdata                  = 0;
  assign dut_if.ecall                         = dut.u_ibex_top.u_ibex_core.id_stage_i.controller_i.ecall_insn;
  assign dut_if.wfi                           = dut.u_ibex_top.u_ibex_core.id_stage_i.controller_i.wfi_insn;
  assign dut_if.ebreak                        = dut.u_ibex_top.u_ibex_core.id_stage_i.controller_i.ebrk_insn;
  assign dut_if.illegal_instr                 = dut.u_ibex_top.u_ibex_core.id_stage_i.controller_i.illegal_insn_d;
  assign dut_if.dret                          = dut.u_ibex_top.u_ibex_core.id_stage_i.controller_i.dret_insn;
  assign dut_if.mret                          = dut.u_ibex_top.u_ibex_core.id_stage_i.controller_i.mret_insn;
  assign dut_if.reset                         = ~rst_n;
  assign dut_if.priv_mode                     = dut.u_ibex_top.u_ibex_core.priv_mode_id;

  initial begin
    ibex_clk_if.set_active();
    fork
      ibex_clk_if.apply_reset(.reset_width_clks (100));
    join_none

    uvm_config_db#(virtual clk_rst_if)::set(null, "*", "clk_if", ibex_clk_if);
    uvm_config_db#(virtual core_ibex_dut_probe_if)::set(null, "*", "dut_if", dut_if);
    uvm_config_db#(virtual ibex_mem_intf)::set(null, "*data_if_response*", "vif", data_mem_vif);
    uvm_config_db#(virtual ibex_mem_intf)::set(null, "*instr_if_response*", "vif", instr_mem_vif);
    run_test("core_ibex_base_test");
  end
initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
  $fsdbDumpvars(0, "+mda", "+struct", "+all");
  $fsdbDumpfile("waves.fsdb");
end
  

endmodule
