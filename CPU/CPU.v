`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SYSU.SS
// Engineer: KenLee
// Create Date:    21:07:16 12/14/2014 
// Design Name:    CPU
// Target Devices: NEXYS3
// Dependencies: config.v ALU.v
//////////////////////////////////////////////////////////////////////////////////
/**宏定义导入(定义了状态,指令等)**/
`include "config.v"
/**
*CPU模块
*
*	- 里面包含一个ALU
*	- (solved)BUG1:ID和WB阶段对通用寄存器有读写冲突 
		-> 对于一般运算和STORE: 在ID阶段 data forwarding(3种)  解决
		-> 对于LOAD： 在ID阶段stall加df解决
*	- (solved)BUG2:跳转之后要加3个NOP...
*		-> check idir,exir,memir and place idir<=NOP(stall 3times);
*/
module CPU(input clock,input enable,input reset,input start,input wire[2:0] select_y,input wire[15:0] d_datain,input wire[15:0] i_datain,
				output wire[7:0] d_addr,output wire[15:0] d_dataout,output d_we,output wire[7:0] i_addr,output wire[15:0] y);
	//状态机状态
	reg next_state,state;
	//指令计数器
	reg[7:0] pc=`zero8;
	//8*16b 的通用寄存器
	reg[15:0] gr[7:0];
	//各级流水线的指令寄存器
	reg[15:0] id_ir=`zero16,ex_ir=`zero16,mem_ir=`zero16;
	reg[7:0] wb_ir=`zero8;
	//运算相关寄存器
	reg[15:0] reg_A=`zero16,reg_B=`zero16,reg_C=`zero16,reg_C1=`zero16;
	//ALU输出
	wire[15:0] ALUo;
	//存储相关寄存器
	reg[15:0] smdr=`zero16,smdr1=`zero16;
	//标志位
	reg zf,nf,cf,pcf;
	wire cfo;
	//内存r/w信号
	reg dw;
	//ALU实例化
	ALU alu(reg_A,reg_B,ex_ir[15:11],cf,ALUo,cfo);
	//输出
	assign d_we=dw;
	assign d_addr=reg_C[7:0];
	assign d_dataout=smdr1;
	assign i_addr=pc;
	assign y=gr[select_y];
	/**控制器Control级流水**/
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
	/**指令读取IF级流水**/
	always @(posedge clock or negedge reset)
		begin
			if (!reset)
				begin
					id_ir <= `zero16;
					pc <= `zero8;
				end
			else if (state ==`exec)
				begin
					//各种跳转
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
	/**数据读取ID级流水**/
	always @(posedge clock or negedge reset)
		begin
			if (!reset)
				begin
					ex_ir <= `zero16;	
				end
			else if (state == `exec)
				begin
					//给下一级流水输入指令到ir
					ex_ir <= id_ir;
					//赋值Reg_A:
					if (id_ir[15:14]==2'b11 ||id_ir[15:11]==`LDIH ||id_ir[15:11]==`SUBI||id_ir[15:11]==`ADDI)
						begin
							//	- 当op为 ADDI ,JMPR ,B* ,LDIH,SUBI的时候,reg_A为r1
							if(id_ir[10:8]==ex_ir[10:8])
							// - 解决冲突: 如果上一级的r1在这一级需要用到，直接从ALUo取值
								reg_A<=ALUo;
							else if(id_ir[10:8] == mem_ir[10:8])
							// - 解决冲突: 如果上两级的r1在这一级需要用到，从regC取值
								reg_A<=reg_C;
							else if(id_ir[10:8] == wb_ir[2:0])
							// - 解决冲突: 如果上三级的r1在这一级需要用到，从regC1取值
								if(mem_ir[15:11]==`LOAD)
									reg_A<=d_datain;
								else
									reg_A<= reg_C;
							else
							// - 没有冲突：在GR取数
								reg_A <= gr[id_ir[10:8]];
						end
					else if(id_ir[15:11]==`zero5)
						// - 当为JUMP的时候,regA为0
						reg_A<=`zero8;
					else
						//	- 其他情况regA为r2
						begin
							if(id_ir[6:4]==ex_ir[10:8])
							// - 解决冲突: 如果上一级的r2在这一级需要用到，直接从ALUo取值
								reg_A<=ALUo;
							else if(id_ir[6:4] == mem_ir[10:8])
							// - 解决冲突: 如果上两级的r2在这一级需要用到，从regC取值
								if(mem_ir[15:11]==`LOAD)
									reg_A<=d_datain;
								else
									reg_A<= reg_C;
							else if(id_ir[6:4] == wb_ir[2:0])
							// - 解决冲突: 如果上三级的r2在这一级需要用到，从regC1取值
								reg_A<=reg_C1;
							else
							// - 没有冲突：在GR取数
								reg_A <= gr[id_ir[6:4]];
						end
						
					//赋值Reg_B:
					if (id_ir[15:14] == 2'b11||id_ir[15:11]==`SUBI||id_ir[15:11]==`ADDI)
						// - 当op为 ADDI ,JUMP,JMPR ,B* ,LDIH,SUBI的时候,reg_B为{val2,val3}
						reg_B <= {`zero8, id_ir[7:0]};
					else if(id_ir[15:11]==`LDIH )
						reg_B <= { id_ir[7:0],`zero8};
					else if (id_ir[15:13]==3'b010 || id_ir[15:11]==`LOAD)
						// - 当op为 S**,STORE,LOAD 时,reg_B为val3
						reg_B <= {`zero12, id_ir[3:0]};
					else if (id_ir[15:11]==`STORE)
						// - 特别的 为STORE 处理smdr
						begin
							reg_B <= {`zero12, id_ir[3:0]};
							//smdr <= gr[id_ir[10:8]]; //解决smdr读通用寄存器冲突
							if(id_ir[10:8]==ex_ir[10:8])
							// - 解决冲突: 如果上一级的r1在这一级需要用到，直接从ALUo取值
								smdr <= ALUo;
							else if(id_ir[10:8] == mem_ir[10:8])
							// - 解决冲突: 如果上两级的r1在这一级需要用到，从regC取值
								if(mem_ir[15:11]==`LOAD)
									smdr<=d_datain;
								else
									smdr <= reg_C;
							else if(id_ir[10:8] == wb_ir[2:0])
							// - 解决冲突: 如果上三级的r1在这一级需要用到，从regC1取值
								smdr <= reg_C1;
							else
							// - 没有冲突：在GR置数
								smdr <= gr[id_ir[10:8]];
						end
					else
						// - 其他的时候,reg_B为r3
						begin
							if(id_ir[2:0]==ex_ir[10:8])
							// - 解决冲突: 如果上一级的r1在这一级需要用到，直接从ALUo取值
								reg_B<=ALUo;
							else if(id_ir[2:0] == mem_ir[10:8])
							// - 解决冲突: 如果上两级的r1在这一级需要用到，从regC取值
								if(mem_ir[15:11]==`LOAD)
									reg_B<=d_datain;
								else
									reg_B<= reg_C;
							else if(id_ir[2:0] == wb_ir[2:0])
							// - 解决冲突: 如果上三级的r1在这一级需要用到，从regC1取值
								reg_B<=reg_C1;
							else
							// - 没有冲突：在GR置数
								reg_B <= gr[id_ir[2:0]];
						end
				end
		end
	/**执行EX级流水*/
	always @(posedge clock or negedge reset)
		begin
			if (!reset)
				begin
					mem_ir <= `zero16;
					cf<=0;
				end
			else if (state == `exec)
				begin
					//给下一级ir赋值
					mem_ir <= ex_ir;
					//接收ALU的运算结果 存到reg_C
					reg_C <= ALUo;
					//处理标志位 对于除了B*,JMPR,LOAD,STORE以外的处理标志位
					if(ex_ir[15:14]==2'b11 || ex_ir[15:11]==`zero5 ||ex_ir[15:11] == `LOAD||ex_ir[15:11] == `STORE)
						cf<=cf;
					else
						begin
							//进位标志位
							cf<=cfo;
							//零标志位
							if (ALUo == `zero16)
								zf <= 1'b1;
							else
								zf <= 1'b0;
							//负数标志位
							if (ALUo[15] == 1'b1)
								nf <= 1'b1;
							else
								nf <= 1'b0;
						end
					//特别的对于store指令,把smdr往下传,把datawrite标志为1
					if (ex_ir[15:11] == `STORE)
						begin
							dw <= 1'b1;
							smdr1 <= smdr;
						end
					else
						dw <= 1'b0;
				end
		end
	/**存储MEM级流水**/
	always @(posedge clock or negedge reset)
		begin
			if (!reset)
				begin 
					wb_ir <=`zero8;
				end
			else if (state == `exec)
				begin
					wb_ir <= mem_ir[15:8];
					//如果为load指令,读入d_datain数据,
					if (mem_ir[15:11] == `LOAD)
						reg_C1 <= d_datain;
					//否则读入上一级结果
					else
						reg_C1 <= reg_C;
				end
		end
	/**回写WB级流水**/
	always @(posedge clock or negedge reset)
		begin
			if (!reset)
				begin
					//通用寄存器初始化
					gr[0]<=`zero16;gr[1]<=`zero16;gr[2]<=`zero16;gr[3]<=`zero16;
					gr[4]<=`zero16;gr[5]<=`zero16;gr[6]<=`zero16;gr[7]<=`zero16;
				end
			else if (state == `exec)
			begin
				//对于需要返回赋值的指令,把上一级的结果写回指令指定的寄存器
				// 除了JMPR,B*,STORE,CMP,和单指令之外
				if (wb_ir[7:6]==2'b11||wb_ir[7:3]==`STORE||wb_ir[7:3]==`CMP||wb_ir[7:3]==`zero5)
					;
				else
					gr[wb_ir[2:0]] <= reg_C1;
			end
		end
endmodule


