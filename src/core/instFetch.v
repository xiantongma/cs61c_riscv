module instFetch(
	input 		  	  clk   	,
	input         	  rstb  	,
	input             Id_PcWrite  ,
	input             Flush     ,
	input         	  PcSel	, //Pc source select
	input      [31:0] AluResult, //result of alu
	output reg [31:0] IfId_Inst	,
	output reg [31:0] IfId_Pc
);
	reg [31:0] next_Pc;
	reg [31:0] Pc;
	wire [31:0] Pc_add4;
	assign iPcAdd4 = Pc+4;
	always @(*) begin
		if(PcSel)
			next_Pc = AluResult;
		else
			next_Pc = iPcAdd4;
	end
	
	always @(posedge clk or negedge rstb)
		if (!rstb)
			Pc <= 0;
		else if (Id_PcWrite)
			Pc <= next_Pc;

	wire [31:0] Inst;
	imem imem(
		.addr(Pc),
		.data(Inst)
	);
	
	always @(posedge clk or negedge rstb)
		if (!rstb) begin
			IfId_Inst    <= 0;
			IfId_Pc <= 0;
		end else if (Flush)begin
			IfId_Inst    <= 0;
			IfId_Pc <= 0;
		end else begin
			IfId_Inst    <= Inst   ;
			IfId_Pc      <= Pc     ;
		end
		
endmodule
