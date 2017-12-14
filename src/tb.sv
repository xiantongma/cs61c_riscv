/****************************************************************************
 * tb.sv
 ****************************************************************************/

/**
 * Module: tb
 * 
 * TODO: Add module documentation
 */
`timescale 1ns/1ns
module tb;

	reg clk=0;
	reg rstb=0;
	initial
		forever #5 clk = ~clk;
		
	initial begin
		$dumpvars();
			
		$display("%m, risc-v testcase starting...");
		#33 rstb=1;
		#1000;
		$display("%m, risc-v testcase finished");
		$finish;	
	end
		
	riscv riscv(
		.clk(clk),
		.rstb(rstb)
	);

endmodule


