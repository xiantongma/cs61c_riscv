module imem(
	input [31:0] addr,
	output [31:0] data
);
	reg [31:0] mem[0:1024];
	assign data = mem[addr[31:2]];

endmodule