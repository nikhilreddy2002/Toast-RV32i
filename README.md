# Toast-RV32i

- Toast is a soft core RISC-V soft core that implements a subset of the RV32I ISA.

- Toast does not support interrupt handling, nor the CSR, FENCE, EBREAK, or ECALL instructions.


<h1> Files in this Repository </h1>

__/Documentation__
- Contains datapath diagrams and notes

__/Mem__
- Contains memory initialization files for IMEM 

__/Sources__
- Contains ToastCore.sv as well as all submodules

<h1> Performance </h1>
- coming soon

<h1> Memory Interface </h1>

![Xilinx Dual-port RAM](https://gyazo.com/69d4dec3f5a1f703b3d292a2f112351b)

Toast uses a simple memory interface based on that of Xilinx dual-port block memory in dual-port RAM configuration. It
drives DIN, ADDR, WE, and RST.


