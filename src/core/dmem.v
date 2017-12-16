//data memory top block
module dmem(
    input             clk             ,
    input             rstb            ,
    input     [31:0]  ExMem_AluResult , //the result of ALU
    input     [31:0]  ExMem_AluB_Pc4  ,
    input             ExMem_MemToReg  , //register file write data source selection
    input     [4:0]   ExMem_RegRd     , //register file address
    input             ExMem_RegWrite  , //register file write enable
    output reg [31:0] MemWb_MemRData  , //read data from data memory
    output reg [31:0] MemWb_AluB_Pc4  ,
    output reg        MemWb_MemToReg  , //register file write data source selection
    output reg [4:0]  MemWb_RegRd     , //register file address
    output reg        MemWb_RegWrite   //register file write enable
    );

   //data memory
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

    //MEM/WB pipleline registers
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
