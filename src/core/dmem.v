module dmem(
    input             clk             ,
    input             rstb            ,
    input             ExMem_MemToReg  ,
    input     [31:0]  ExMem_AluResult ,
    input     [31:0]  ExMem_AluB_Pc4   ,
    input     [4:0]   ExMem_RegRd     ,
    input             ExMem_RegWrite  ,
    output reg        MemWb_MemToReg  ,
    output reg [31:0] MemWb_AluB_Pc4  ,
    output reg [31:0] MemWb_MemRData  ,
    output reg [4:0]  MemWb_RegRd     ,
    output reg        MemWb_RegWrite  
    );
    wire [31:0] MemRData;
     dram dram(
        /*i*/ .clk  (clk            ),
        /*i*/ .rstb (rstb           ),
        /*i*/ .addr (ExMem_AluResult),
        /*i*/ .wdata(ExMem_AluB_Pc4  ),
        /*i*/ .write(ExMem_MemWrite),
        /*i*/ .read (ExMem_MemRead ),
        /*o*/ .rdata(MemRData      ) 
    );   

    always @(posedge clk or negedge rstb)
        if (!rstb) begin
            MemWb_MemToReg   <= 0;
            MemWb_AluB_Pc4    <= 0;
            MemWb_MemRData   <= 0;
            MemWb_RegRd      <= 0;
            MemWb_RegWrite   <= 0;
        end else begin
            MemWb_MemToReg   <= ExMem_MemToReg  ;
            MemWb_AluB_Pc4    <= ExMem_AluB_Pc4   ;
            MemWb_MemRData   <= MemRData        ;
            MemWb_RegRd      <= ExMem_RegRd     ;
            MemWb_RegWrite   <= ExMem_RegWrite  ;
        end
endmodule
