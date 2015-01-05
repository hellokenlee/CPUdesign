`timescale 1ns / 1ps
`include "config.v"
module ALLTest;

	// Inputs
	reg clock;
	reg enable;
	reg reset;
	reg start;
	reg [2:0] select_y;
	reg i_we;
	reg [15:0] i_dataout;
	reg [7:0] IM_addr;

	// Outputs
	wire [15:0] y;
 
	// Instantiate the Unit Under Test (UUT)
	ALL uut (
		.clock(clock), 
		.enable(enable), 
		.reset(reset), 
		.start(start), 
		.select_y(select_y), 
		.i_we(i_we), 
		.i_dataout(i_dataout), 
		.IM_addr(IM_addr), 
		.y(y)
	);
	//初始化IM
	initial begin
		i_we <= 1;
		#10
		IM_addr <= 8'b0000_0000;
		i_dataout <= {`SUB, `gr4, 1'b0, `gr4, 1'b0, `gr4};//0
		#10
		IM_addr <= IM_addr+1;
		i_dataout <= {`SUB, `gr5, 1'b0, `gr5, 1'b0, `gr5};//1
		#10
		IM_addr <= IM_addr+1;
		i_dataout <= {`ADDI, `gr4, 8'b1111_1111};//2
		#10
		IM_addr <= IM_addr+1;
		i_dataout <= {`LDIH, `gr5, 8'b1111_1111};//3
		#10
		IM_addr <= IM_addr+1;
		i_dataout <= {`STORE, `gr4, 1'b0, `gr0, 4'b0000};//4
		#10
		IM_addr <= IM_addr+1;
		i_dataout <= {`STORE, `gr5, 1'b0, `gr0, 4'b0001};//5
		#10
		IM_addr <= IM_addr+1;
		i_dataout <= {`LOAD, `gr1, 1'b0, `gr0, 4'b0000};//6
		#10
		IM_addr <= IM_addr+1;
		i_dataout <= {`LOAD, `gr2, 1'b0, `gr0, 4'b0001};//7
		#10
		IM_addr <= IM_addr+1;
		i_dataout <= {`ADD, `gr3, 1'b0, `gr1, 1'b0, `gr2};//8
		#10
		IM_addr <= IM_addr+1;
		i_dataout <= {`JUMP, 8'b0000_1011};//9
		#10
		IM_addr <= IM_addr+1;
		i_dataout <= {`ADDI, `gr3, 8'b0000_0001};//10
		#10
		IM_addr <= IM_addr+1;
		i_dataout <= {`STORE, `gr3, 1'b0, `gr0, 4'b0010};//11
		#10
		IM_addr <= IM_addr+1;
		i_dataout <= {`HALT, `zero8};//12
		#10
		i_we<=0;
	end
	//时钟频率100MHZ
	initial begin
		clock=0;
		#10;
		while(1)
		begin
			#5;
			clock<=1;
			#5;
			clock<=0;
		end
	end
	   //测试代码
	initial begin
		$monitor("pc: %h  id_ir: %b  regA: %h  regB: %h  regC: %h  daddr: %h  ddout: %h  dw: %b  regC1: %h  gr0: %h  gr1: %h  gr2: %h  gr3: %h gr4: %h gr5: %h cf %b", 
			uut.C.pc, uut.C.id_ir, uut.C.reg_A, uut.C.reg_B, uut.C.reg_C,
			uut.d_addr, uut.d_dataout, uut.d_we, uut.C.reg_C1, uut.C.gr[0],uut.C.gr[1], uut.C.gr[2], uut.C.gr[3],uut.C.gr[4],uut.C.gr[5],uut.C.cf);
		//初始化变量
		enable <= 1; start <= 0;select_y <= 0;
		//置reset
		#300 reset <= 0;
		#10 reset <= 1;
		#10 enable <= 1;
		#10 start <=1;
		#10 start <= 0;
		//测试
	end
      
endmodule

