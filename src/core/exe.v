module exe(
    input             clk              ,
    input             rstb             ,
    //from ID/EXE pipleline register
    input   [31:0]    IdEx_Pc          , //PC
    input             IdEx_AluSrc      , //ALU input B port selection
    input   [3:0]     IdEx_AluOp       , //ALU operation
    input   [31:0]    IdEx_Imm         , //signed expand immediate
    input   [4:0]     IdEx_RegRs1      ,
    input   [4:0]     IdEx_RegRs2      ,
    input   [31:0]    IdEx_RegDataA    ,
    input   [31:0]    IdEx_RegDataB    ,
    input             IdEx_AluB_Pc4_Sel,
    input             IdEx_MemRead     , //data memory read enable
    input             IdEx_MemWrite    , //data memory write enable
    input             IdEx_MemToReg    , //register file write data source selection
    input   		  IdEx_RegWrite    , //register file write enable
    input   [4:0]     IdEx_RegRd       , //register file address
    //to EXE/MEM pipleline register
    output reg [31:0] ExMem_AluResult  ,
    output reg [31:0] ExMem_AluB_Pc4   ,
    output reg        ExMem_MemRead    , //memory read
    output reg        ExMem_MemWrite   , //memory write
    output reg        ExMem_MemToReg   , //register file write data source selection
    output reg [4:0]  ExMem_RegRd      , //register file address
    output reg        ExMem_RegWrite   , //register file write enable
    //from stage after EXE stage for forwading unit
    input      [4:0]  MemWb_RegRd      , //register file address in MEM/WB
    input             MemWb_RegWrite   , //register file write enable in MEM/WB
    input      [31:0] Wb_RegWData        //register file write data in WB stage
    );
    //forwarding unit for ALU port A
    wire [1:0] ForwardA;
    wire [1:0] ForwardB;
    reg [31:0] AluA;
    reg [31:0] AluB;
    always @(*)begin
        case(ForwardA)
        2'b01:AluA = Wb_RegWData;
        2'b10:AluA = ExMem_AluB_Pc4; //forward from ExMem register
        default:AluA = IdEx_RegDataA;
        endcase
    end

    //forwarding unit for ALU port B
    always @(*)begin
        if(IdEx_AluSrc) begin //from register file or forwarding from later stage
            case(ForwardB)
            2'b01:AluB = Wb_RegWData;
            2'b10:AluB = ExMem_AluB_Pc4; //forward from ExMem register
            default:AluB = IdEx_RegDataB;
            endcase
        end else begin //from immediate
            AluB = IdEx_Imm;
        end
    end

    //result of ALU
    wire [31:0] iAluResult;
    alu alu(
    /*i*/ .aluop     (IdEx_AluOp),
    /*i*/ .alu_a     (AluA     ),    
    /*i*/ .alu_b     (AluB     ),    
    /*o*/ .alu_result(iAluResult)
    );
    
    //forwarding enable detection
    forward_unit forward_unit(
    /*i*/ .ExMem_RegWrite   (ExMem_RegWrite  ),
    /*i*/ .ExMem_RegRd      (ExMem_RegRd     ),
    /*i*/ .MemWb_RegWrite   (MemWb_RegWrite  ),
    /*i*/ .MemWb_RegRd      (MemWb_RegRd     ),
    /*i*/ .IdEx_RegRs1      (IdEx_RegRs1     ),
    /*i*/ .IdEx_RegRs2      (IdEx_RegRs2     ),
    /*o*/ .ForwardA         (ForwardA        ),
    /*o*/ .ForwardB         (ForwardB        )
    );

    wire [31:0] iPcAdd4 = IdEx_Pc + 4;
    wire [31:0] iAluB_Pc4 = IdEx_AluB_Pc4_Sel ? AluB : iPcAdd4;

    //EX/MEM pipleline register
    always @(posedge clk or negedge rstb)
        if (!rstb)begin
            ExMem_AluResult <= 0;
            ExMem_AluB_Pc4  <= 0;
            ExMem_MemRead   <=0;
            ExMem_MemWrite  <=0;
            ExMem_MemToReg  <=0;
            ExMem_RegRd     <=0;
            ExMem_RegWrite  <=0;
        end else begin
            ExMem_AluResult <= iAluResult     ;
            ExMem_AluB_Pc4  <= iAluB_Pc4      ;
            ExMem_MemRead   <= IdEx_MemRead   ;
            ExMem_MemWrite  <= IdEx_MemWrite  ;
            ExMem_MemToReg  <= IdEx_MemToReg  ;
            ExMem_RegRd     <= IdEx_RegRd     ;
            ExMem_RegWrite  <= IdEx_RegWrite  ;
        end

endmodule
