module id(
	input             clk           ,
	input             rstb          ,
	input             Ex_IdExFlush  ,
	input      [31:0] IfId_Inst     ,
	input      [31:0] IfId_Pc       ,
	output reg  [31:0]IdEx_Pc       ,
	output            Id_PcWrite    ,
    output            Id_IfIdWrite  ,
    output reg 		  IdEx_PcSrc     ,
    output reg 		  IdEx_AluSrc    ,
    output reg [3:0]  IdEx_AluOp     ,
    output reg 		  IdEx_Branch    ,
    output reg        IdEx_AluB_Pc4_Sel,
    output reg 		  IdEx_MemRead   ,
    output reg 		  IdEx_MemWrite  ,
    output reg 		  IdEx_MemToReg  ,
    output reg 		  IdEx_RegWrite  ,
    output reg [4:0]  IdEx_RegRd        ,
	output reg [31:0] IdEx_RegDataA     ,
	output reg [31:0] IdEx_RegDataB     ,
	output reg [31:0] IdEx_Imm       ,
    input      [4:0]  MemWb_RegRd    ,
    input             MemWb_RegWrite ,
    input      [31:0] Wb_RegWData 
);
    wire [4:0]  RegRd          ;
    wire [4:0]  RegRs1         ;
    wire [4:0]  RegRs2         ;
    wire 		InstUndef   ;
    wire        RegRs1Read  ;
    wire        RegRs2Read  ;
    wire 		PcSrc       ;
    wire 		AluSrc      ;
    wire [3:0] 	AluOp       ;
    wire 		Branch      ;
    wire        AluB_Pc4_Sel;
    wire 		MemRead     ;
    wire 		MemWrite    ;
    wire 		MemToReg    ;
    wire 		RegWrite    ;
    wire [2:0] InstFormat   ;
    wire       IdExSel     ;

    hazardDetectionUnit hazardDetectionUnit(
    /*i*/ .IdEx_MemRead    (IdEx_MemRead    ),
    /*i*/ .IdEx_RegRd (IdEx_RegRd ),
    /*i*/ .IfId_RegRs1(RegRs1             ),
    /*i*/ .IfId_RegRs2(RegRs2             ),
    /*o*/ .PcWrite        (Id_PcWrite     ),
    /*o*/ .IfIdWrite      (Id_IfIdWrite   ),
    /*o*/ .IdExSel        (IdExSel        )//1: insert nop
    );
    id_decode id_decode(
	    .Inst      (IfId_Inst      ),
        .Rd        (RegRd        ),
        .Rs1       (RegRs1       ),
        .Rs2       (RegRs2       ),
        .InstUndef (InstUndef ),
        .RegRs1Read(RegRs1Read),
        .RegRs2Read(RegRs2Read),
        .PcSrc     (PcSrc     ),
        .AluSrc    (AluSrc    ),
        .AluOp     (AluOp     ),
        .Branch    (Branch    ),
        .AluB_Pc4_Sel(AluB_Pc4_Sel),
        .MemRead   (MemRead   ),
        .MemWrite  (MemWrite  ),
        .MemToReg  (MemToReg  ),
        .RegWrite  (RegWrite  ),
        .InstFormat(InstFormat)
    );

    wire [31:0] RegDataA;
    wire [31:0] RegDataB;
	regfiles regfiles(
		.clk    (clk           ),
		.rstb   (rstb          ),
		.addra  (RegRs1           ),
		.addrb  (RegRs2           ),
		.write  (MemWb_RegWrite),
		.addrRd (MemWb_RegRd   ),
		.wData  (Wb_RegWData),
		.dataa  (RegDataA      ),
		.datab  (RegDataB      )			
	);

    wire [31:0] Imm;
	ImmGen ImmGen(
		.InstFormat(InstFormat),
		.Inst      (IfId_Inst), // from IfId
		.Imm       (Imm)
    );	
    always @(posedge clk or negedge rstb)
        if (!rstb) begin
        	IdEx_Pc        <= 0;
            IdEx_PcSrc     <= 0;
            IdEx_AluSrc    <= 0;
            IdEx_AluOp     <= 0;
            IdEx_Branch    <= 0;
            IdEx_AluB_Pc4_Sel <=  0;
            IdEx_MemRead   <= 0;
            IdEx_MemWrite  <= 0;
            IdEx_MemToReg  <= 0;
            IdEx_RegWrite  <= 0;
            IdEx_RegRd        <= 0;
        end else begin
        	IdEx_Pc        <= IfId_Pc ;
            IdEx_PcSrc     <= PcSrc   ;
            IdEx_AluSrc    <= AluSrc  ;
            IdEx_AluOp     <= AluOp   ;
            if (Ex_IdExFlush || IdExSel) begin
                IdEx_Branch    <= 1'b0;
                IdEx_AluB_Pc4_Sel <=  0;
                IdEx_MemRead   <= 1'b0;
                IdEx_MemWrite  <= 1'b0;
            end else begin
                IdEx_Branch       <= Branch  ;
                IdEx_AluB_Pc4_Sel <= AluB_Pc4_Sel;
                IdEx_MemRead      <= MemRead ;
                IdEx_MemWrite     <= MemWrite;
            end
            IdEx_MemToReg  <= MemToReg;
            if (Ex_IdExFlush || IdExSel)
                IdEx_RegWrite  <= 1'b0;
            else 
                IdEx_RegWrite  <= RegWrite;

            IdEx_RegRd        <= RegRd      ;
        end
	
    always @(posedge clk or negedge rstb)
        if (!rstb) begin
	        IdEx_RegDataA <= 0;
	        IdEx_RegDataB <= 0;
            IdEx_Imm      <= 0;
        end else begin
	        IdEx_RegDataA <= RegDataA;
	        IdEx_RegDataB <= RegDataB;
            IdEx_Imm      <= Imm     ;
        end
endmodule
