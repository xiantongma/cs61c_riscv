//
//example: 
//ld x2, 4(x1)
//add x3, x2, x2
//or  x5, x4, x4
//               cc1   cc2  cc3  cc4  cc5
//ld x2, 4(x1)   if    id   ex   mem  wb
//add x3, x2, x2       if   id   ex   ex  mem wb
//or  x5, x4, x4            if   id   id   ex  mem wb
module hazardDetectionUnit(
    input       IdEx_MemRead    ,
    input [4:0] IdEx_RegRd ,
    input [4:0] IfId_RegRs1,
    input [4:0] IfId_RegRs2,
    output      PcWrite        ,
    output      IfIdWrite      ,
    output      IdExSel        //1: insert nop
);

    assign stall = IdEx_MemRead
                    && (IdEx_RegRd !=0)
                    && ((IdEx_RegRd == IdEx_RegRs1) || (IdEx_RegRd == IdEx_RegRs2));

    assign PcWrite   = !stall;
    assign IfIdWrite = !stall;
    assign IdExSel   = stall;
    
endmodule
