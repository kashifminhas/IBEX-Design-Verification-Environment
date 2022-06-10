# IBEX Design Verification Environment

Verification Environment for Instruction Fetch (IFU) and Load Store Unit (LSU) of IBEX Core.

## Directory Structure

```tree

UVM_PROJECT_AHB3_SLAVE/

├── bin_files
│   ├── fab.bin
│   └── riscv_arithmetic_basic_test_0.bin
├── README.md
├── rtl
│   ├── design.sv
│   ├── dv_fcov_macros.svh
│   ├── ibex_alu.sv
│   ├── ibex_branch_predict.sv
│   ├── ibex_compressed_decoder.sv
│   ├── ibex_controller.sv
│   ├── ibex_core.sv
│   ├── ibex_counter.sv
│   ├── ibex_cs_registers.sv
│   ├── ibex_csr.sv
│   ├── ibex_decoder.sv
│   ├── ibex_dummy_instr.sv
│   ├── ibex_ex_block.sv
│   ├── ibex_fetch_fifo.sv
│   ├── ibex_icache.sv
│   ├── ibex_id_stage.sv
│   ├── ibex_if_stage.sv
│   ├── ibex_load_store_unit.sv
│   ├── ibex_lockstep.sv
│   ├── ibex_multdiv_fast.sv
│   ├── ibex_multdiv_slow.sv
│   ├── ibex_pkg.sv
│   ├── ibex_pmp.sv
│   ├── ibex_prefetch_buffer.sv
│   ├── ibex_register_file_ff.sv
│   ├── ibex_register_file_fpga.sv
│   ├── ibex_register_file_latch.sv
│   ├── ibex_top.sv
│   ├── ibex_tracer_pkg.sv
│   ├── ibex_tracer.sv
│   ├── ibex_wb_stage.sv
│   ├── prim_assert_standard_macros.svh
│   ├── prim_assert.sv
│   ├── prim_clock_gating.sv
│   ├── prim_generic_clock_gating.sv
│   ├── prim_pkg.sv
│   └── prim_ram_1p_pkg.sv
└── tb
    ├── ahb_uvm_agent.sv
    ├── ahb_uvm_driver.sv
    ├── ahb_uvm_env.sv
    ├── ahb_uvm_intf.sv
    ├── ahb_uvm_monitor.sv
    ├── ahb_uvm_pkg.sv
    ├── ahb_uvm_scoreboard.sv
    ├── ahb_uvm_seqitem.sv
    ├── ahb_uvm_seq.sv
    ├── ahb_uvm_sequencer.sv
    ├── ahb_uvm_subscriber.sv
    ├── ahb_uvm_test.sv
    ├── amba_ahb_defines.v
    └── testbench.sv


```

## INSTRUCTION FETCH UNIT (IFU)

![68747470733a2f2f696265782d636f72652e72656164746865646f63732e696f2f656e2f6c61746573742f5f696d616765732f69665f73746167652e737667](https://user-images.githubusercontent.com/75377950/172785076-dee21004-5b49-4369-9017-892874ef66e2.svg)

## LOAD STORE UNIT (LSU)

![env](https://ibex-core.readthedocs.io/en/latest/_images/de_ex_stage.svg)

## RTL

- rtl folder contains the design files of the IBEX core.

## TESTBENCH

- tb folder contains the verification environment files.

## BINARY FILES

- bin_files folder contains two binary file, which are given as an input to the core to test the behaviour of the verification environment.

  1. fab.bin is a binary file to test simple fibonacci series.
  2. riscv_arithmetic_basic_test_0.bin is a binary file of riscv_arithmetic_basic_test of riscv-dv.

## Tools Used

- VCS Synopsis 2016 is used for compilation and simulation.
- Verdi Synopsis is used for signal tracing.

## Running the Environment:

- Give following commands on the terminal for Compilation and simulation of the Environment.

### To Compile the Test Environment
"vcs -licqueue '-timescale=1ns/1ns' '+vcs+flush+all' '+warn=all' '-sverilog' -ntb_opts uvm-1.2 -CFLAGS -DVCS design.sv testbench.sv -debug_access+r"

### To Simulate the Test Environment

"./simv +bin=<binary_file_name> -gui"

<div class="section" id="protocol">
<span id="lsu-protocol"></span><h2>Protocol<a class="headerlink" href="#protocol" title="Permalink to this headline">¶</a></h2>
<p>The protocol that is used by the LSU to communicate with a memory works as follows:</p>
<ol class="arabic simple">
<li><p>The LSU provides a valid address in <code class="docutils literal notranslate"><span class="pre">data_addr_o</span></code> and sets <code class="docutils literal notranslate"><span class="pre">data_req_o</span></code> high. In the case of a store, the LSU also sets <code class="docutils literal notranslate"><span class="pre">data_we_o</span></code> high and configures <code class="docutils literal notranslate"><span class="pre">data_be_o</span></code> and <code class="docutils literal notranslate"><span class="pre">data_wdata_o</span></code>. The memory then answers with a <code class="docutils literal notranslate"><span class="pre">data_gnt_i</span></code> set high as soon as it is ready to serve the request. This may happen in the same cycle as the request was sent or any number of cycles later.</p></li>
<li><p>After receiving a grant, the address may be changed in the next cycle by the LSU. In addition, the <code class="docutils literal notranslate"><span class="pre">data_wdata_o</span></code>, <code class="docutils literal notranslate"><span class="pre">data_we_o</span></code> and <code class="docutils literal notranslate"><span class="pre">data_be_o</span></code> signals may be changed as it is assumed that the memory has already processed and stored that information.</p></li>
<li><p>The memory answers with a <code class="docutils literal notranslate"><span class="pre">data_rvalid_i</span></code> set high for exactly one cycle to signal the response from the bus or the memory using <code class="docutils literal notranslate"><span class="pre">data_err_i</span></code> and <code class="docutils literal notranslate"><span class="pre">data_rdata_i</span></code> (during the very same cycle). This may happen one or more cycles after the grant has been received. If <code class="docutils literal notranslate"><span class="pre">data_err_i</span></code> is low, the request could successfully be handled at the destination and in the case of a load, <code class="docutils literal notranslate"><span class="pre">data_rdata_i</span></code> contains valid data. If <code class="docutils literal notranslate"><span class="pre">data_err_i</span></code> is high, an error occurred in the memory system and the core will raise an exception.</p></li>
<li><p>When multiple granted requests are outstanding, it is assumed that the memory requests will be kept in-order and one <code class="docutils literal notranslate"><span class="pre">data_rvalid_i</span></code> will be signalled for each of them, in the order they were issued.</p></li>
</ol>
<p>Figures below show example-timing diagrams of the protocol.</p>
</div>

![1](https://user-images.githubusercontent.com/75377950/172986897-7b7d558c-f898-4bc9-812a-0cc1db5141f4.svg)

<p class="caption"><span class="caption-text">Basic Memory Transaction</span></p>

![2](https://user-images.githubusercontent.com/75377950/172986932-6d9ff172-6433-4ae3-a8fd-923da7925959.svg)

<p class="caption"><span class="caption-text">Back-to-back Memory Transaction</span></p>

![3](https://user-images.githubusercontent.com/75377950/172986662-f185de32-ae40-41ac-85c9-83070fa131c9.svg)
<p class="caption" ><span class="caption-number"></span><span class="caption-text" >Slow Response Memory Transaction</span></p>


