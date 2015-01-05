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
*ALUģ��
*
*	- ����ÿһ��ʱ������,��reg_A �� reg_B�����ݸ���ex_irָ������,�ѽ�������ALUo
*	- ��־λ(flag)���ж�����CPU
*	- ����ÿһ��regA����regB����cf�仯,ALUo�仯
*/
module ALU(input wire signed [15:0] reg_A,
	input wire signed [15:0] reg_B,
	input wire [4:0] ex_ir,
	input wire cf_in,
	output reg [15:0] ALUo,
	output reg cf_out);
	always@(*)
		begin
			//������Ϊλ1 ���ӷ� 
			if(ex_ir[4]==1)
				{cf_out,ALUo}<=reg_A+reg_B+cf_in;
			// ���Ϊ0 �߼�����,����������������
			else
			begin
				//���011 ��ͷ ������
				if(ex_ir[4:3]==2'b11)
					{cf_out,ALUo}<=reg_A-reg_B-cf_in;
				//�߼�����+��λ����
				else
					begin
						cf_out<=0;
						case(ex_ir[4:0])
							//�߼�����
							`AND:ALUo<=reg_A&reg_B;
							`OR: ALUo<=reg_A|reg_B;
							`XOR:ALUo<=reg_A^reg_B;
							//����,�߼�����
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
