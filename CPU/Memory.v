`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SYSU.SS
// Engineer: KenLee
// Create Date:    21:07:16 12/14/2014 
// Design Name:    Memory
// Target Devices: NEXYS3
// Dependencies: config.v
//////////////////////////////////////////////////////////////////////////////////
/**
*内存模块(时序逻辑模拟)
*
*	- 包括指令内存(IM)和数据内存(DM)
*	- 输入是一个地址,一个时钟(和CPU一致),一个读写信号(0读1写),一个输入数据(0时无效)
*	- 输出是输入地址的数据
*/
module Memory(input wire clock,input wire[7:0] address,input wire we,input wire[15:0] data_in,
				output wire[15:0] data_out);
	reg[15:0] RAM[255:0];
	assign data_out=RAM[address];
	always@(posedge clock)
		if(we)
			RAM[address]<=data_in;
endmodule 