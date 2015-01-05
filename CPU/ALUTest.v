`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:05:15 12/22/2014
// Design Name:   ALU
// Module Name:   /home/kenlee/ESADHW/CPU/ALUTest.v
// Project Name:  CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ALU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ALUTest;

	// Inputs
	reg [15:0] reg_A;
	reg [15:0] reg_B;
	reg [15:0] ex_ir;
	reg cf_in;

	// Outputs
	wire [15:0] ALUo;
	wire cf_out;

	// Instantiate the Unit Under Test (UUT)
	ALU uut (
		.reg_A(reg_A), 
		.reg_B(reg_B), 
		.ex_ir(ex_ir), 
		.cf_in(cf_in), 
		.ALUo(ALUo), 
		.cf_out(cf_out)
	);
	initial begin
		// Initialize Inputs
		reg_A = 0;
		reg_B = 0;
		ex_ir = 0;
		cf_in = 0;
		// Wait 100 ns for global reset to finish
		#100;
		reg_A<=1;
		reg_B<=1;
      ex_ir<=16'b10000_000_0000_0000;
		// Add stimulus here
	end
      
endmodule

