//instruction fetch top module
module instFetch(
	input 		  	  clk   		,
	input         	  rstb  		,
	input             Flush         , //IF/ID piple line register reset
	input             Id_PcWrite 	, //Program counter(instruction address) update enable
	input         	  PcSel	        , //Program counter(instruction address) source selection
									  //0:from PC+4, 1: branch or jump
	input      [31:0] AluResult     , //Result of alu for PC(program counter) by branch or jump
	output reg [31:0] IfId_Inst	    , //feteched instruction in IF/ID pipleline register
	output reg [31:0] IfId_Pc         //PC(Program counter) in IF/ID pipleline
);
	reg 	[31:0] Pc		;
	
	//PC add 4
	wire 	[31:0] iPcAdd4	;
	assign iPcAdd4 = Pc+4;
	
	//next Pc calculation
	reg 	[31:0] NextPc	;
	always @(*) begin
		if(PcSel)
			NextPc = AluResult;
		else
			NextPc = iPcAdd4;
	end
	
	//Pc
	always @(posedge clk or negedge rstb)
		if (!rstb)
			Pc <= 0;
		else if (Id_PcWrite)
			Pc <= next_Pc;
    
	//Instruction fetch from instruction memory base on PC
	//the instruction memory is zero clock cycle delay.
	wire [31:0] Inst;
	imem imem(
		.addr(Pc),
		.data(Inst)
	);
	
	//IF/ID pipleline register update
	always @(posedge clk or negedge rstb)
		if (!rstb) begin
			IfId_Inst    <= 0;
			IfId_Pc 	 <= 0;
		end else if (Flush)begin
			IfId_Inst    <= 0;
			IfId_Pc 	 <= 0;
		end else begin
			IfId_Inst    <= Inst   ;
			IfId_Pc      <= Pc     ;
		end
		
endmodule
