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
*�ڴ�ģ��(ʱ���߼�ģ��)
*
*	- ����ָ���ڴ�(IM)�������ڴ�(DM)
*	- ������һ����ַ,һ��ʱ��(��CPUһ��),һ����д�ź�(0��1д),һ����������(0ʱ��Ч)
*	- ����������ַ������
*/
module Memory(input wire clock,input wire[7:0] address,input wire we,input wire[15:0] data_in,
				output wire[15:0] data_out);
	reg[15:0] RAM[255:0];
	assign data_out=RAM[address];
	always@(posedge clock)
		if(we)
			RAM[address]<=data_in;
endmodule 