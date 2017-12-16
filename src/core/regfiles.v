//register file
module regfiles(
	input              clk    ,
	input              rstb   ,
	input       [4: 0] addra  , //read A address
	input       [4: 0] addrb  , //read B address
	input       [4: 0] addrRd , //write address
	input       [31:0] wData  , //write data
	input              write  , //write enable
	output reg  [31:0] dataa  , //read data A
	output reg  [31:0] datab	//read data B
);
	reg [31:0] regs[1:31];
    integer i;
	always @(posedge clk or negedge rstb)
		if (!rstb) begin
			for (i=1; i<32; i=i+1) begin
				regs[i] <=0;
            end
        //write wdata into register file if the address is not zero
		end else if (write & addrRd!=0)begin 
			regs[addrRd] <= wData;
		end

    //port A read
    always @(*) begin
        if (addra == 0) //address is 0
	        dataa =  32'h0 ; 
        else if ((addra == addrRd) && write)//the read address is the same with write address
            dataa =  wData;
        else
            dataa =  regs[addra];
    end

    //port B read
    always @(*) begin
        if (addrb == 0) //address is 0
	        datab = 32'h0 ;
        else if ((addrb == addrRd) && write) //the read address is the same with write address
            datab =  wData;
        else
	        datab = regs[addrb];
    end
	
endmodule
