module regfiles(
	input	 	 clk  ,
	input        rstb ,
	input [4: 0] addra,
	input [4: 0] addrb,
	input [4: 0] addrRd,
	input [31:0] wData,
	input        write,
	output [31:0] dataa,
	output [31:0] datab			
);
	reg [31:0] regs[1:31];
    integer i;
	always @(posedge clk or negedge rstb)
		if (!rstb) begin
			for (i=1; i<32; i=i+1) begin
				regs[i] <=0;
            end
		end else if (write & addrRd!=0)begin
			regs[addrRd] <= wData;
		end
		
	assign  dataa = (addra == 0) ? 32'h0 : regs[addra];
	assign  datab = (addrb == 0) ? 32'h0 : regs[addrb];
	
endmodule
