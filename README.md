# IBEX_Design_Verification_Environment

Verification Environment for Instruction Fetch (IF) and Load Store Unit (LSU) of IBEX Core.

![env](https://drive.google.com/file/d/1tNovcWYuRPYIw5Hp3AlLxZkyQd6um9G6/view?usp=sharing)

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

