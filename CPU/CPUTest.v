`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SYSU.SS
// Engineer: KenLee
//
// Create Date:    21:07:16 12/14/2014 
// Design Name:    CPU TestBench
// Target Devices: NEXYS3
// Dependencies: config.v,CPU.v
//////////////////////////////////////////////////////////////////////////////////
/**宏定义**/
`include "config.v"
module CPUTest;
	// Inputs
	reg clock;
	reg enable;
	reg reset;
	reg start;
	reg [2:0] select_y;
	reg [15:0] d_datain;
	reg [15:0] i_datain;
	// Outputs
	wire [7:0] d_addr;
	wire [15:0] d_dataout;
	wire d_we;
	wire [7:0] i_addr;
	wire [15:0] y;
	//实例化CPU，测试实例pcpu
	CPU pcpu (
		.clock(clock), 
		.enable(enable), 
		.reset(reset), 
		.start(start), 
		.select_y(select_y), 
		.d_datain(d_datain), 
		.i_datain(i_datain),
		.d_addr(d_addr), 
		.d_dataout(d_dataout), 
		.d_we(d_we), 
		.i_addr(i_addr), 
		.y(y)
	);
	//时钟频率100MHZ
	initial begin
		clock=0;
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
		$monitor("pc: %h  id_ir: %b  regA: %h  regB: %h  regC: %h  daddr: %h  ddout: %h  dw: %b  regC1: %h  gr0: %h  gr1: %h  gr2: %h  gr3: %h  cf %b", 
			pcpu.pc, pcpu.id_ir, pcpu.reg_A, pcpu.reg_B, pcpu.reg_C,
			d_addr, d_dataout, d_we, pcpu.reg_C1, pcpu.gr[0],pcpu.gr[1], pcpu.gr[2], pcpu.gr[3],pcpu.cf);
		//初始化变量
		enable <= 1; start <= 0; i_datain <= 0; d_datain <= 0; select_y <= 0;
		//置reset
		#10 reset <= 0;
		#10 reset <= 1;
		#10 enable <= 1;
		#10 start <=1;
		#10 start <= 0;
		//测试ADD
		i_datain <= {`LOAD, `gr1, 1'b0, `gr0, 4'b0000};
		#10 i_datain <= {`LOAD, `gr2, 1'b0, `gr0, 4'b0001};
		#10 i_datain <= {`NOP, 8'b0000_0000};
		d_datain <=16'h00AB;  // 3 clk later from LOAD

			
		#10 i_datain <= {`ADD, `gr3, 1'b0, `gr1, 1'b0, `gr2};
		#10 i_datain <= {`ADD, `gr0, 1'b0, `gr3, 1'b0, `gr2};
		#10 i_datain <= {`STORE, `gr3, 1'b0, `gr0, 4'b0010};
		#10 i_datain <= {`HALT, 8'b0000_0000};
		//测试
	end
endmodule

