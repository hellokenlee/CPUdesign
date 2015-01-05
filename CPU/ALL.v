`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SYSU.SS
// Engineer: KenLee
// Create Date:    21:07:16 12/14/2014 
// Design Name:    ALL(CPU+2Memory)
// Target Devices: NEXYS3
// Dependencies: CPU.v Memory.v
//////////////////////////////////////////////////////////////////////////////////
/**
*总模块封装
*	- 包括指令内存(IM)和数据内存(DM)
*	- 包括一个CPU(内含一个ALU)
*/

module ALL(input wire clock,input wire enable,input wire reset,input wire start,input wire[2:0] select_y,input wire i_we,input wire[15:0] i_dataout,input wire[7:0] IM_addr,
				output wire[15:0] y);
	wire[15:0] d_datain,d_dataout,i_datain;
	wire[7:0] d_addr,pc;
	reg[7:0] i_addr;
	wire d_we;
	always@(*)
		if(i_we)
			i_addr<=IM_addr;
		else
			i_addr<=pc;
	//实例化控存
	Memory IM(clock,i_addr,i_we,i_dataout,i_datain);
	//实例化数存
	Memory DM(clock,d_addr,d_we,d_dataout,d_datain);
	//实例化CPU
	CPU C(clock,enable,reset,start,select_y,d_datain,i_datain,d_addr,d_dataout,d_we,pc,y);
endmodule