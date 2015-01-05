`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SYSU.SS
// Engineer: KenLee
// Create Date:    21:07:16 12/14/2014 
// Design Name:    CPU
// Target Devices: NEXYS3
// Dependencies: config.v ALU.v
//////////////////////////////////////////////////////////////////////////////////
/**�궨�嵼��(������״̬,ָ���)**/
`include "config.v"
/**
*CPUģ��
*
*	- �������һ��ALU
*	- (solved)BUG1:ID��WB�׶ζ�ͨ�üĴ����ж�д��ͻ 
		-> ����һ�������STORE: ��ID�׶� data forwarding(3��)  ���
		-> ����LOAD�� ��ID�׶�stall��df���
*	- (solved)BUG2:��ת֮��Ҫ��3��NOP...
*		-> check idir,exir,memir and place idir<=NOP(stall 3times);
*/
module CPU(input clock,input enable,input reset,input start,input wire[2:0] select_y,input wire[15:0] d_datain,input wire[15:0] i_datain,
				output wire[7:0] d_addr,output wire[15:0] d_dataout,output d_we,output wire[7:0] i_addr,output wire[15:0] y);
	//״̬��״̬
	reg next_state,state;
	//ָ�������
	reg[7:0] pc=`zero8;
	//8*16b ��ͨ�üĴ���
	reg[15:0] gr[7:0];
	//������ˮ�ߵ�ָ��Ĵ���
	reg[15:0] id_ir=`zero16,ex_ir=`zero16,mem_ir=`zero16;
	reg[7:0] wb_ir=`zero8;
	//������ؼĴ���
	reg[15:0] reg_A=`zero16,reg_B=`zero16,reg_C=`zero16,reg_C1=`zero16;
	//ALU���
	wire[15:0] ALUo;
	//�洢��ؼĴ���
	reg[15:0] smdr=`zero16,smdr1=`zero16;
	//��־λ
	reg zf,nf,cf,pcf;
	wire cfo;
	//�ڴ�r/w�ź�
	reg dw;
	//ALUʵ����
	ALU alu(reg_A,reg_B,ex_ir[15:11],cf,ALUo,cfo);
	//���
	assign d_we=dw;
	assign d_addr=reg_C[7:0];
	assign d_dataout=smdr1;
	assign i_addr=pc;
	assign y=gr[select_y];
	/**������Control����ˮ**/
	always @(posedge clock)
		begin
			if (!reset)
				state <= `idle;
			else
				state <= next_state;
		end
	always @(*)
		begin
			case (state)
				`idle : 
					if ((enable == 1'b1) && (start == 1'b1))
						next_state <= `exec;
					else
						next_state <= `idle;
				`exec :
					if ((enable == 1'b0) || (wb_ir[7:0] == `HALT))
						next_state <= `idle;
					else
						next_state <= `exec;
			endcase
		end
	/**ָ���ȡIF����ˮ**/
	always @(posedge clock or negedge reset)
		begin
			if (!reset)
				begin
					id_ir <= `zero16;
					pc <= `zero8;
				end
			else if (state ==`exec)
				begin
					//������ת
					if(id_ir[15:8]==`HALT)
					begin
						id_ir<={`HALT,`zero8};
						pc<=pc;
					end
					else if(id_ir[15:8]==`JUMP||id_ir[15:14]==2'b11)
						begin
							pc<=pc;
							id_ir<=`zero16;
						end
					else if(ex_ir[15:8]==`JUMP||ex_ir[15:14]==2'b11)
						begin
							pc<=pc;
							id_ir<=`zero16;
						end
					else if(mem_ir[15:8]==`JUMP)
						begin
							pc <= mem_ir[7:0];
							id_ir <= `zero16;
						end
					else
						case(mem_ir[15:11])
							`BZ:if(zf)
								begin
									pc<=reg_C[7:0];
									id_ir<=`zero16;
								end
							`BNZ:if(!zf)
								begin
									pc<=reg_C[7:0];
									id_ir<=`zero16;
								end
							`BN:if(nf)
								begin
									pc<=reg_C[7:0];
									id_ir<=`zero16;
								end
							`BNN:if(!nf)
								begin
									pc<=reg_C[7:0];
									id_ir<=`zero16;
								end
							`BC:if(cf)
								begin
									pc<=reg_C[7:0];
									id_ir<=`zero16;
								end
							`BNC:if(cf)
								begin
									pc<=reg_C[7:0];
									id_ir<=`zero16;
								end
							default 
							begin
								if(id_ir[15:11]==`LOAD)
								begin
									pc<=pc;
									id_ir<=`zero16;
								end
								else
								begin
									pc<=pc+1'b1;
									id_ir<=i_datain;
								end;
							end
						endcase
				end
		end
	/**���ݶ�ȡID����ˮ**/
	always @(posedge clock or negedge reset)
		begin
			if (!reset)
				begin
					ex_ir <= `zero16;	
				end
			else if (state == `exec)
				begin
					//����һ����ˮ����ָ�ir
					ex_ir <= id_ir;
					//��ֵReg_A:
					if (id_ir[15:14]==2'b11 ||id_ir[15:11]==`LDIH ||id_ir[15:11]==`SUBI||id_ir[15:11]==`ADDI)
						begin
							//	- ��opΪ ADDI ,JMPR ,B* ,LDIH,SUBI��ʱ��,reg_AΪr1
							if(id_ir[10:8]==ex_ir[10:8])
							// - �����ͻ: �����һ����r1����һ����Ҫ�õ���ֱ�Ӵ�ALUoȡֵ
								reg_A<=ALUo;
							else if(id_ir[10:8] == mem_ir[10:8])
							// - �����ͻ: �����������r1����һ����Ҫ�õ�����regCȡֵ
								reg_A<=reg_C;
							else if(id_ir[10:8] == wb_ir[2:0])
							// - �����ͻ: �����������r1����һ����Ҫ�õ�����regC1ȡֵ
								if(mem_ir[15:11]==`LOAD)
									reg_A<=d_datain;
								else
									reg_A<= reg_C;
							else
							// - û�г�ͻ����GRȡ��
								reg_A <= gr[id_ir[10:8]];
						end
					else if(id_ir[15:11]==`zero5)
						// - ��ΪJUMP��ʱ��,regAΪ0
						reg_A<=`zero8;
					else
						//	- �������regAΪr2
						begin
							if(id_ir[6:4]==ex_ir[10:8])
							// - �����ͻ: �����һ����r2����һ����Ҫ�õ���ֱ�Ӵ�ALUoȡֵ
								reg_A<=ALUo;
							else if(id_ir[6:4] == mem_ir[10:8])
							// - �����ͻ: �����������r2����һ����Ҫ�õ�����regCȡֵ
								if(mem_ir[15:11]==`LOAD)
									reg_A<=d_datain;
								else
									reg_A<= reg_C;
							else if(id_ir[6:4] == wb_ir[2:0])
							// - �����ͻ: �����������r2����һ����Ҫ�õ�����regC1ȡֵ
								reg_A<=reg_C1;
							else
							// - û�г�ͻ����GRȡ��
								reg_A <= gr[id_ir[6:4]];
						end
						
					//��ֵReg_B:
					if (id_ir[15:14] == 2'b11||id_ir[15:11]==`SUBI||id_ir[15:11]==`ADDI)
						// - ��opΪ ADDI ,JUMP,JMPR ,B* ,LDIH,SUBI��ʱ��,reg_BΪ{val2,val3}
						reg_B <= {`zero8, id_ir[7:0]};
					else if(id_ir[15:11]==`LDIH )
						reg_B <= { id_ir[7:0],`zero8};
					else if (id_ir[15:13]==3'b010 || id_ir[15:11]==`LOAD)
						// - ��opΪ S**,STORE,LOAD ʱ,reg_BΪval3
						reg_B <= {`zero12, id_ir[3:0]};
					else if (id_ir[15:11]==`STORE)
						// - �ر�� ΪSTORE ����smdr
						begin
							reg_B <= {`zero12, id_ir[3:0]};
							//smdr <= gr[id_ir[10:8]]; //���smdr��ͨ�üĴ�����ͻ
							if(id_ir[10:8]==ex_ir[10:8])
							// - �����ͻ: �����һ����r1����һ����Ҫ�õ���ֱ�Ӵ�ALUoȡֵ
								smdr <= ALUo;
							else if(id_ir[10:8] == mem_ir[10:8])
							// - �����ͻ: �����������r1����һ����Ҫ�õ�����regCȡֵ
								if(mem_ir[15:11]==`LOAD)
									smdr<=d_datain;
								else
									smdr <= reg_C;
							else if(id_ir[10:8] == wb_ir[2:0])
							// - �����ͻ: �����������r1����һ����Ҫ�õ�����regC1ȡֵ
								smdr <= reg_C1;
							else
							// - û�г�ͻ����GR����
								smdr <= gr[id_ir[10:8]];
						end
					else
						// - ������ʱ��,reg_BΪr3
						begin
							if(id_ir[2:0]==ex_ir[10:8])
							// - �����ͻ: �����һ����r1����һ����Ҫ�õ���ֱ�Ӵ�ALUoȡֵ
								reg_B<=ALUo;
							else if(id_ir[2:0] == mem_ir[10:8])
							// - �����ͻ: �����������r1����һ����Ҫ�õ�����regCȡֵ
								if(mem_ir[15:11]==`LOAD)
									reg_B<=d_datain;
								else
									reg_B<= reg_C;
							else if(id_ir[2:0] == wb_ir[2:0])
							// - �����ͻ: �����������r1����һ����Ҫ�õ�����regC1ȡֵ
								reg_B<=reg_C1;
							else
							// - û�г�ͻ����GR����
								reg_B <= gr[id_ir[2:0]];
						end
				end
		end
	/**ִ��EX����ˮ*/
	always @(posedge clock or negedge reset)
		begin
			if (!reset)
				begin
					mem_ir <= `zero16;
					cf<=0;
				end
			else if (state == `exec)
				begin
					//����һ��ir��ֵ
					mem_ir <= ex_ir;
					//����ALU�������� �浽reg_C
					reg_C <= ALUo;
					//�����־λ ���ڳ���B*,JMPR,LOAD,STORE����Ĵ����־λ
					if(ex_ir[15:14]==2'b11 || ex_ir[15:11]==`zero5 ||ex_ir[15:11] == `LOAD||ex_ir[15:11] == `STORE)
						cf<=cf;
					else
						begin
							//��λ��־λ
							cf<=cfo;
							//���־λ
							if (ALUo == `zero16)
								zf <= 1'b1;
							else
								zf <= 1'b0;
							//������־λ
							if (ALUo[15] == 1'b1)
								nf <= 1'b1;
							else
								nf <= 1'b0;
						end
					//�ر�Ķ���storeָ��,��smdr���´�,��datawrite��־Ϊ1
					if (ex_ir[15:11] == `STORE)
						begin
							dw <= 1'b1;
							smdr1 <= smdr;
						end
					else
						dw <= 1'b0;
				end
		end
	/**�洢MEM����ˮ**/
	always @(posedge clock or negedge reset)
		begin
			if (!reset)
				begin 
					wb_ir <=`zero8;
				end
			else if (state == `exec)
				begin
					wb_ir <= mem_ir[15:8];
					//���Ϊloadָ��,����d_datain����,
					if (mem_ir[15:11] == `LOAD)
						reg_C1 <= d_datain;
					//���������һ�����
					else
						reg_C1 <= reg_C;
				end
		end
	/**��дWB����ˮ**/
	always @(posedge clock or negedge reset)
		begin
			if (!reset)
				begin
					//ͨ�üĴ�����ʼ��
					gr[0]<=`zero16;gr[1]<=`zero16;gr[2]<=`zero16;gr[3]<=`zero16;
					gr[4]<=`zero16;gr[5]<=`zero16;gr[6]<=`zero16;gr[7]<=`zero16;
				end
			else if (state == `exec)
			begin
				//������Ҫ���ظ�ֵ��ָ��,����һ���Ľ��д��ָ��ָ���ļĴ���
				// ����JMPR,B*,STORE,CMP,�͵�ָ��֮��
				if (wb_ir[7:6]==2'b11||wb_ir[7:3]==`STORE||wb_ir[7:3]==`CMP||wb_ir[7:3]==`zero5)
					;
				else
					gr[wb_ir[2:0]] <= reg_C1;
			end
		end
endmodule


