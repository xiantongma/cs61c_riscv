module wb(
	input 		       MemWb_MemToReg, //mux select
	input 		[31:0] MemWb_AluB_Pc4,
	input 		[31:0] MemWb_MemRData,
	output reg 	[31:0] Wb_RegData      
	);
    
	always @(*)begin
		if (MemWb_MemToReg)
	        Wb_RegData= MemWb_MemRData;
        else
	        Wb_RegData= MemWb_AluB_Pc4;
	end
endmodule
