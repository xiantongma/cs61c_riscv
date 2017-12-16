//instruction decode top module
module id(
	input             clk               ,
	input             rstb              ,
    //from IF/ID pipleline register
	input      [31:0] IfId_Inst         , //instruction in IF/ID
	input      [31:0] IfId_Pc           , //PC in IF/ID
    //to IF stage
	output            Id_PcWrite        ,
    output            Id_IfIdWrite      ,
    //to EXE stage
	output reg  [31:0]IdEx_Pc           , //PC in IF/ID
    output reg 		  IdEx_PcSrc     	, //PC source selection in ID/EX 
    output reg 		  IdEx_AluSrc    	, //ALU input B source selection in ID/EX
    output reg [3:0]  IdEx_AluOp     	, //ALU opration in ID/Ex
    output reg 		  IdEx_Branch    	, //
    output reg        IdEx_AluB_Pc4_Sel	, //the result of PC add 4 write to register file destination register in ID/EX
    output reg 		  IdEx_MemRead   	, //data memory read in ID/EX
    output reg 		  IdEx_MemWrite  	, //data memory write in ID/Ex
    output reg 		  IdEx_MemToReg  	, //read data from data memory write to register file destination register in ID/EX
    output reg 		  IdEx_RegWrite  	, //write enable of register file destination register in ID/EX
    output reg [4:0]  IdEx_RegRd        , //address of register file destination register in ID/EX
	output reg [31:0] IdEx_RegDataA     , //read data from register file source register 1 in ID/EX
	output reg [31:0] IdEx_RegDataB     , //read data from register file source register 2 in ID/EX
	output reg [31:0] IdEx_Imm          , //signed expanded immediate in ID/Ex
    //from block after ID block in the pipleline
	input             Ex_IdExFlush      , //ID/EX pipleline register flush control from generate EXE combination logic
    input      [4:0]  MemWb_RegRd       , //address for register file destination in MEM/WB
    input             MemWb_RegWrite    , //write enable for register file destination in MEM/WB
    input      [31:0] Wb_RegWData         //write data for register file destination in MEM/WB
);
    wire [4:0]  RegRd       ;
    wire [4:0]  RegRs1      ;
    wire [4:0]  RegRs2      ;
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
    wire [2:0]  InstFormat  ;
    wire        IdExSel     ; //instead with nop on ID/EXE pipleline register if control hazard detected

    //control hazard detection
    hazardDetectionUnit hazardDetectionUnit(
    /*i*/ .IdEx_MemRead     (IdEx_MemRead   ), //?data memory read enable
    /*i*/ .IdEx_RegRd       (IdEx_RegRd     ), //?address of register file destination to be written
    /*i*/ .IfId_RegRs1      (RegRs1         ), //address of register file source register 1
    /*i*/ .IfId_RegRs2      (RegRs2         ), //address of register file source register 2
    /*o*/ .PcWrite          (Id_PcWrite     ), //enable pc update
    /*o*/ .IfIdWrite        (Id_IfIdWrite   ), //enble update IF/ID pipleline
    /*o*/ .IdExSel          (IdExSel        )  //1: insert nop in ID/EX pipleline register
    );

    //instruction decode
    id_decode id_decode(
	    .Inst      (IfId_Inst   ),
        .Rd        (RegRd       ),
        .Rs1       (RegRs1      ),
        .Rs2       (RegRs2      ),
        .InstUndef (InstUndef   ),
        .RegRs1Read(RegRs1Read  ),
        .RegRs2Read(RegRs2Read  ),
        .PcSrc     (PcSrc       ),
        .AluSrc    (AluSrc      ),
        .AluOp     (AluOp       ),
        .Branch    (Branch      ),
        .AluB_Pc4_Sel(AluB_Pc4_Sel),
        .MemRead   (MemRead     ),
        .MemWrite  (MemWrite    ),
        .MemToReg  (MemToReg    ),
        .RegWrite  (RegWrite    ),
        .InstFormat(InstFormat  )
    );

    //register file
    wire [31:0] RegDataA;
    wire [31:0] RegDataB;
	regfiles regfiles(
		.clk    (clk            ),
		.rstb   (rstb           ),
		.addra  (RegRs1         ), //address of source register 1
		.addrb  (RegRs2         ), //address of source register 2
		.write  (MemWb_RegWrite ), //write enable of destination register
		.addrRd (MemWb_RegRd    ), //address of destination register
		.wData  (Wb_RegWData    ), //write data of destination register
		.dataa  (RegDataA       ), //read data of source register 1
		.datab  (RegDataB       ) // read data of source register 2
	);

    //signed expanded immediate
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
                IdEx_Branch      <= 1'b0;
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
