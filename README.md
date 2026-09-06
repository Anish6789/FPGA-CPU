FPGA 8-bit CPU / ALU:

An ongoing project to design and implement a custom 8-bit CPU in Verilog.
The project began with an 8-bit ALU and UART interface and is being expanded into a complete processor with a datapath, control unit, register file, memory, and instruction execution.

Overview:

The project started as an FPGA-based ALU capable of performing arithmetic and logical operations.
User inputs are received through UART, processed by the ALU, and the results are returned to a terminal.

The current goal is to build on this design and develop a small 8-bit CPU capable of fetching, decoding, and executing instructions.

Current Features:
- 8-bit ALU implemented in Verilog
- Arithmetic and logical operations
- UART input and output
- FPGA seven-segment display output
- User-controlled ALU operations through a serial terminal
- Custom CPU datapath and control unit under development

CPU Architecture:

- Program counter
- Instruction register
- Register file
- ALU
- Datapath
- Control unit
- Data memory
- Instruction memory
- UART interface

The control unit decodes instructions and generates the signals required to move data through the datapath and execute each instruction.

Instruction Set:

- ALU	- Performs arithmetic/logical operations
- LOAD Immediate - Loads an immediate value into a register
- LOAD Memory	- Loads data from memory into a register
- STORE	- Writes register data to memory
- HALT - Stops processor execution
