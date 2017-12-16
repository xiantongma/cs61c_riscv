//risc v core top block
module riscv(
    input clk,
    input rstb
    );

    //--------------------------------------------------------------------------------
    //instruction fetch
    //from later stage
	wire        Id_PcWrite   ;
	wire        Ex_IfFlush   ;
	wire        Ex_PcSel	 ;
	wire [31:0] Ex_AluResult ;
    //IF/ID pipleline register
	wire [31:0] IfId_Inst    ;
	wire [31:0] IfId_Pc      ;
    instFetch instFetch(
	    /*i*/.clk   	    (clk   	      ),
	    /*i*/.rstb  	    (rstb  	      ),
	    /*i*/.Id_PcWrite    (Id_PcWrite   ),
	    /*i*/.Flush         (Ex_IfFlush   ),
	    /*i*/.PcSel	   		(Ex_PcSel	  ), //pc source select
	    /*i*/.AluResult     (Ex_AluResult ), //result of alu
	    /*o*/.IfId_Inst	    (IfId_Inst     ),
	    /*o*/.IfId_Pc       (IfId_Pc       )
            );
    
    //--------------------------------------------------------------------------------
    // IF/ID
    //instruction decode
	wire        clk            ;
	wire        rstb           ;
    //to IF stage
	wire        Ex_IdExFlush    ;
    wire        Id_IfIdWrite  ;
    //to EXE stage
    wire [31:0] IdEx_Pc       ;
    wire 		IdEx_PCSrc      ;
    wire 		IdEx_AluSrc     ;
    wire [3:0]  IdEx_AluOp     ;
    wire 		IdEx_Branch     ;
    wire        IdEx_AluB_Pc4_Sel;
    wire 		IdEx_MemRead    ;
    wire 		IdEx_MemWrite   ;
    wire 		IdEx_MemToReg   ;
    wire 		IdEx_RegWrite   ;
    wire [4:0]  IdEx_RegRd        ;
    wire [4:0]  IdEx_RegRs1     ;
    wire [4:0]  IdEx_RegRs2     ;   
	wire [31:0] IdEx_RegDataA     ;
	wire [31:0] IdEx_RegDataB     ;
	wire [31:0] IdEx_Imm       ;
    //from later stage
    wire [4:0]  MemWb_RegRd    ;
    wire        MemWb_RegWrite ;
    wire [31:0] Wb_RegWData    ;

    id id(
	    /*i*/ .clk            (clk              ),
	    /*i*/ .rstb           (rstb             ),
	    /*i*/ .Ex_IdExFlush   (Ex_IdExFlush     ),
	    /*i*/ .IfId_Inst      (IfId_Inst        ),
	    /*i*/ .Id_PcWrite     (Id_PcWrite       ),
        /*i*/ .Id_IfIdWrite   (Id_IfIdWrite     ),
    		  .IfId_Pc        (IfId_Pc          ),
    		  .IdEx_Pc        (IdEx_Pc		    ),
        /*i*/ .IdEx_PcSrc     (IdEx_PcSrc       ),
        /*i*/ .IdEx_AluSrc    (IdEx_AluSrc      ),
        /*i*/ .IdEx_AluOp     (IdEx_AluOp       ),
        /*i*/ .IdEx_Branch    (IdEx_Branch      ),
              .IdEx_AluB_Pc4_Sel(IdEx_AluB_Pc4_Sel  ),
        /*i*/ .IdEx_MemRead   (IdEx_MemRead         ),
        /*i*/ .IdEx_MemWrite  (IdEx_MemWrite        ),
        /*i*/ .IdEx_MemToReg  (IdEx_MemToReg        ),
        /*i*/ .IdEx_RegWrite  (IdEx_RegWrite        ),
        /*i*/ .IdEx_RegRd     (IdEx_RegRd           ),
	    /*i*/ .IdEx_RegDataA  (IdEx_RegDataA        ),
	    /*i*/ .IdEx_RegDataB  (IdEx_RegDataB        ),
	    /*i*/ .IdEx_Imm       (IdEx_Imm             ),
        /*i*/ .MemWb_RegRd    (MemWb_RegRd          ),
        /*i*/ .MemWb_RegWrite (MemWb_RegWrite       )
            );

    // ID/EX
    //--------------------------------------------------------------------------------
    //instruction execution
    wire        ExMem_MemRead   ; 
    wire        ExMem_MemWrite  ; 
    wire [31:0] ExMem_AluResult ;
    wire [31:0] ExMem_AluB_Pc4  ;
    wire        ExMem_MemToReg  ;
    wire [4:0]  ExMem_RegRd     ;
    wire        ExMem_RegWrite  ;
    exe exe(
        .clk             (clk             ),
        .rstb            (rstb            ),
        .IdEx_Pc         (IdEx_Pc         ),
        .IdEx_AluSrc     (IdEx_AluSrc     ),
        .IdEx_AluOp      (IdEx_AluOp      ),
        .IdEx_Imm        (IdEx_Imm        ),
        .IdEx_RegWrite   (IdEx_RegWrite   ),
        .IdEx_RegRd      (IdEx_RegRd      ),
        .IdEx_RegRs1     (IdEx_RegRs1     ),
        .IdEx_RegRs2     (IdEx_RegRs2     ),
        .IdEx_RegDataA   (IdEx_RegDataA   ),
        .IdEx_RegDataB   (IdEx_RegDataB   ),
        .IdEx_AluB_Pc4_Sel(IdEx_AluB_Pc4_Sel),
        .IdEx_MemRead     (IdEx_MemRead     ),
        .IdEx_MemWrite    (IdEx_MemWrite    ),
        .IdEx_MemToReg    (IdEx_MemToReg    ),
        .ExMem_MemToReg  (ExMem_MemToReg  ),
        .ExMem_MemRead   (ExMem_MemRead   ), 
        .ExMem_MemWrite  (ExMem_MemWrite  ), 
        .ExMem_AluResult (ExMem_AluResult ),
        .ExMem_AluB_Pc4   (ExMem_AluB_Pc4 ),
        .ExMem_RegRd     (ExMem_RegRd     ),
        .ExMem_RegWrite  (ExMem_RegWrite  ),
        //from laster stage for forwarding unit
        .MemWb_RegRd      (MemWb_RegRd    ),
        .MemWb_RegWrite   (MemWb_RegWrite ),        
        .Wb_RegWData     (Wb_RegWData     )
    );

    // EX/MEM
    //--------------------------------------------------------------------------------
    //data memory accesss
    wire        MemWb_MemToReg  ;
    wire [31:0] MemWb_MemRData  ;
    wire [31:0] MemWb_AluB_Pc4  ;
    dmem dmem(
        /*i*/ .clk             (clk             ),
        /*i*/ .rstb            (rstb            ),
        /*i*/ .ExMem_AluResult (ExMem_AluResult ),
        /*i*/ .ExMem_RegRd     (ExMem_RegRd     ),
        /*i*/ .ExMem_RegWrite  (ExMem_RegWrite  ),
        /*i*/ .ExMem_AluB_Pc4   (ExMem_AluB_Pc4   ),
        /*i*/ .ExMem_MemToReg  (ExMem_MemToReg  ),
        /*o*/ .MemWb_MemRData  (MemWb_MemRData  ),
        /*o*/ .MemWb_AluB_Pc4   (MemWb_AluB_Pc4   ),
        /*o*/ .MemWb_MemToReg  (MemWb_MemToReg  ),
        /*o*/ .MemWb_RegRd     (MemWb_RegRd     ),
        /*o*/ .MemWb_RegWrite  (MemWb_RegWrite  )
    );

    // MEM/WB
    //--------------------------------------------------------------------------------
    //write back stage
    wb wb(   .MemWb_MemToReg  (MemWb_MemToReg),
    		 .MemWb_MemRData  (MemWb_MemRData),
    		 .MemWb_AluB_Pc4  (MemWb_AluB_Pc4),
    		 .Wb_RegData      (Wb_RegWData   )
    );

endmodule
