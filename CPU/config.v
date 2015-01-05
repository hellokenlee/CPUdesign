/**
*宏定义
*
* - 指令的编码
* - PCB状态机编码
* - 通用寄存器编码
*/
//零
`define zero16 16'b0000_0000_0000_0000
`define zero12 12'b0000_0000_0000
`define zero8 8'b0000_0000
`define zero5 5'b00000
//状态代码
`define idle 1'b0
`define exec 1'b1
//指令代码
`define NOP  8'b00000_000
`define HALT 8'b00000_001
`define JUMP 8'b00000_010

`define AND  5'b00010
`define OR   5'b00011
`define XOR  5'b00100

`define SLA  5'b01000
`define SRA  5'b01001
`define SLL  5'b01010
`define SRL  5'b01011

`define SUB  5'b01100
`define SUBI 5'b01101
`define CMP  5'b01110
`define SUBC 5'b01111

`define LOAD  5'b10000
`define STORE 5'b10001
`define LDIH  5'b10010

`define ADD   5'b10100
`define ADDC  5'b10101
`define ADDI  5'b10110

`define JMPR  5'b11001
`define BZ    5'b11010
`define BNZ   5'b11011
`define BN    5'b11100
`define BNN	  5'b11101
`define BC	  5'b11110
`define BNC	  5'b11111

//通用寄存器编号
`define gr0 3'b000
`define gr1 3'b001
`define gr2 3'b010
`define gr3 3'b011
`define gr4 3'b100
`define gr5 3'b101
`define gr6 3'b110
`define gr7 3'b111


