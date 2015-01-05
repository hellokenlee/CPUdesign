`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SYSU.SS
// Engineer: KenLee
// Create Date:    21:07:16 12/14/2014 
// Design Name:    ALU
// Target Devices: NEXYS3
// Dependencies: config.v
//////////////////////////////////////////////////////////////////////////////////
`include "config.v"

/**
*ALU模块
*
*	- 对于每一个时钟周期,把reg_A 和 reg_B的数据根据ex_ir指令运算,把结果输出到ALUo
*	- 标志位(flag)的判断留给CPU
*	- 对于每一个regA或者regB或者cf变化,ALUo变化
*/
module ALU(input wire signed [15:0] reg_A,
	input wire signed [15:0] reg_B,
	input wire [4:0] ex_ir,
	input wire cf_in,
	output reg [15:0] ALUo,
	output reg cf_out);
	always@(*)
		begin
			//如果最高为位1 做加法 
			if(ex_ir[4]==1)
				{cf_out,ALUo}<=reg_A+reg_B+cf_in;
			// 如果为0 逻辑运算,减法或者其他操作
			else
			begin
				//如果011 开头 做减法
				if(ex_ir[4:3]==2'b11)
					{cf_out,ALUo}<=reg_A-reg_B-cf_in;
				//逻辑运算+移位运算
				else
					begin
						cf_out<=0;
						case(ex_ir[4:0])
							//逻辑运算
							`AND:ALUo<=reg_A&reg_B;
							`OR: ALUo<=reg_A|reg_B;
							`XOR:ALUo<=reg_A^reg_B;
							//算术,逻辑左移
							`SLL:{cf_out,ALUo}<=reg_A<<reg_B;
							`SRL:{cf_out,ALUo}<=reg_A<<reg_B;
							`SRA:{cf_out,ALUo}<=reg_A>>>reg_B;
							`SLA:{cf_out,ALUo}<=reg_A<<<reg_B;
							default 
								ALUo<=`zero16;
						endcase
					end
			end
		end
endmodule
