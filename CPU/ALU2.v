`include "config.v"
//~~~~~~~~~ALU Module~~~~~~~~~~~
module ALU2(
	input wire signed [15:0] a,
	input wire signed [15:0] b,
	input wire [4:0] ir,
	input wire cin,
	output reg [15:0] ALUo,
	output reg cf
	);
	
always @ (*)
	if (
			(ir == `LOAD)
		|| (ir == `STORE)
		|| (ir == `LDIH)
		|| (ir == `ADD)
		|| (ir == `ADDI)
		|| (ir[4:3] == 2'b11)
		)
		{cf, ALUo} <= a+b;
	else if (ir == `ADDC)
		{cf, ALUo} <= a+b+cin;
	else if (
			(ir == `SUB)
		|| (ir == `SUBI)
		|| (ir == `CMP)
		)
		{cf, ALUo} <= a-b;
	else if (ir == `SUBC)
		{cf, ALUo} <= a-b-cin;
	else if (ir == `AND)
		ALUo <= a & b;
	else if (ir == `OR)
		ALUo <= a | b;
	else if (ir == `XOR)
		ALUo <= a ^ b;
	else if (ir == `SLL)
		ALUo <= a << b;
	else if (ir == `SRL)
		ALUo <= a >> b;
	else if (ir == `SLA)
		ALUo <= a <<< b;
	else if (ir == `SRA)
		ALUo <= a >>> b;
	else if (ir == `JUMP)
		ALUo <= b;
	else
		ALUo <= 16'b0000_0000_0000_0000;

endmodule
