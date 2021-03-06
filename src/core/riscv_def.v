//instruction format type
localparam InstFormat_R  = 0;  //register-register
localparam InstFormat_I  = 1;  //register-Immediate
localparam InstFormat_S  = 2;  //store
localparam InstFormat_SB = 3;  //branch
localparam InstFormat_U  = 4;  //
localparam InstFormat_UJ = 5;

localparam AluOp_ADD  = 'h0; //alu addition
localparam AluOp_SUB  = 'h1; //
localparam AluOp_SUBU = 'h2;
localparam AluOp_AND  = 'h3;
localparam AluOp_OR   = 'h4;
localparam AluOp_XOR  = 'h5;
localparam AluOp_SLL  = 'h6;
localparam AluOp_SRL  = 'h7;
localparam AluOp_SRA  = 'h8;
localparam AluOp_MUL  = 'h9;
localparam AluOp_DIV  = 'ha;

//localparam Wb_mux_RegToReg = 0;
//localparam Wb_mux_MemToReg = 1;
//localparam Wb_mux_Pc4ToReg = 2;
