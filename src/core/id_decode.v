module id_decode(
	input      [31:0]   Inst      ,
    output wire [4:0]   Rd        ,
    output wire [4:0]   Rs1       ,
    output wire [4:0]   Rs2       ,
    output reg 		    InstUndef ,
    output reg          RegRs1Read,
    output reg          RegRs2Read,
    output reg 		    PcSrc     ,
    output reg 		    AluSrc    ,
    output reg [3:0]    AluOp     ,
    output reg 		    Branch    ,
    output reg          AluB_Pc4_Sel,
    output reg 		    MemRead   ,
    output reg 		    MemWrite  ,
    output reg 		    MemToReg  ,
    output reg 		    RegWrite  ,
    output reg [2:0]    InstFormat 
);
    wire [6:0] OpCode  = Inst[ 6: 0];
    assign 		Rd      = Inst[11: 7];
    wire [2:0] Funct3  = Inst[14:12];
    assign 		Rs1     = Inst[19:15];
    assign		 Rs2     = Inst[24:20];
    wire [6:0] Funct7  = Inst[31:25];


    `include "riscv_def.v" 
    //The Instructions
    //--------------------------------------------------------------------------------
    //Instruction 	        Type 	OpCode 	Funct3 	Funct7/IMM 	Operation
    //--------------------------------------------------------------------------------
    always @(*)begin
    	InstUndef   = 0;
        RegRs1Read  = 0;
        RegRs2Read  = 0;
        AluSrc      = 0;
        AluOp       = 0;
        Branch      = 0;
        AluB_Pc4_Sel= 0;
        MemRead     = 0;
        MemWrite    = 0;
        MemToReg    = 0;
        RegWrite    = 0;
        PcSrc       = 0;
        case(OpCode)
        'h33: begin //OpCode
            RegWrite= 1;
            InstFormat = InstFormat_R;
            case(Funct3)
    //add rd, rs1, rs2 	    R 	    0x33 	0x0 	0x00 	R[rd] ← R[rs1] + R[rs2]
    //mul rd, rs1, rs2 	                    0x0 	0x01 	R[rd] ← (R[rs1] * R[rs2])[31:0]
    //sub rd, rs1, rs2 	                    0x0 	0x20 	R[rd] ← R[rs1] - R[rs2]
            'h00:begin //Funct3    
                case(Funct7)
                'h00:begin
                    AluOp = AluOp_AND;
                end
                'h01:begin
                    AluOp = AluOp_MUL;
                end
                'h20:begin
                    AluOp = AluOp_SUB;
                end
                default: begin
                	InstUndef=1;
                end
                endcase
            end
    //sll rd, rs1, rs2 	                    0x1 	0x00 	R[rd] ← R[rs1] << R[rs2
    //mulh rd, rs1, rs2 	                0x1 	0x01 	R[rd] ← (R[rs1] * R[rs2])[63:32]
            'h01:begin //Funct3
                case(Funct7)
                'h00:begin
                    AluOp = AluOp_SLL;
                end
                'h01:begin
                    AluOp = AluOp_MUL;
                end
                default:begin
                	InstUndef=1;
                end
                endcase
            end
    //slt rd, rs1, rs2 	                    0x2 	0x00 	R[rd] ← (R[rs1] < R[rs2]) ? 1 : 0 (signed)
            'h02:begin //Funct3
                case(Funct7)
                'h00:begin
                    AluOp = AluOp_SUB;
                end
                default:begin
                	InstUndef=1;
                end
                endcase
            end
    //xor rd, rs1, rs2 	                    0x4 	0x00 	R[rd] ← R[rs1] ^ R[rs2]
    //div rd, rs1, rs2 	                    0x4 	0x01 	R[rd] ← R[rs1] / R[rs2]
            'h04:begin //Funct3
                case(Funct7)
                'h00: begin
                    AluOp = AluOp_XOR;
                end
                'h01: begin
                    AluOp = AluOp_DIV;
                end
                default:begin
                	InstUndef=1;
                end
                endcase
            end
    //srl rd, rs1, rs2 	                    0x5 	0x00 	R[rd] ← R[rs1] >> R[rs2]
            'h05:begin //Funct3
                case(Funct7) 
                'h00:begin
                    AluOp = AluOp_SRL;
                end
                default:begin
                	InstUndef=1;
                end
                endcase
            end
    //or rd, rs1, rs2 	                    0x6 	0x00 	R[rd] ← R[rs1] | R[rs2]
    //rem rd, rs1, rs2 	                    0x6 	0x01 	R[rd] ← (R[rs1] % R[rs2]
            'h06:begin //Funct3
                case(Funct7)
                'h00:begin
                    AluOp = AluOp_OR;
                end
                'h01:begin
                    AluOp = AluOp_DIV;
                end
                default:begin
                	InstUndef=1;
                end
                endcase
            end
    //and rd, rs1, rs2 	                    0x7 	0x00 	R[rd] ← R[rs1] & R[rs2]
            'h07:begin //Funct3
                case(Funct7) 
                'h00: begin
                    AluOp = AluOp_AND;
                end
                default:begin
                	InstUndef=1;
                end 
                endcase
             end
             default:begin
             	InstUndef=1;
             end
        endcase
    	end 
        'h03:begin //OpCode
    //--------------------------------------------------------------------------------
    //lb rd, offset(rs1) 	I 	    0x03 	0x0 	        R[rd] ← SignExt(Mem(R[rs1] + offset, byte))
    //lh rd, offset(rs1) 	                0x1 		    R[rd] ← SignExt(Mem(R[rs1] + offset, half))
    //lw rd, offset(rs1) 	                0x2 		    R[rd] ← Mem(R[rs1] + offset, word)
            AluOp = AluOp_ADD;
            MemRead = 1;
            MemToReg =1;
            case(Funct7)
            'h00: begin
            end
            'h01:begin
            end
            'h02:begin
            end
            default:begin
            	InstUndef=1;
            end
            endcase
        end
        'h13:begin //OpCode
    //addi rd, rs1, imm 	        0x13 	0x0 	        R[rd] ← R[rs1] + imm
    //slli rd, rs1, imm 	                0x1 	0x00 	R[rd] ← R[rs1] << imm
    //slti rd, rs1, imm 	                0x2 		    R[rd] ← (R[rs1] < imm) ? 1 : 0
    //xori rd, rs1, imm 	                0x4 		    R[rd] ← R[rs1] ^ imm
    //srli rd, rs1, imm 	                0x5 	0x00 	R[rd] ← R[rs1] >> imm
    //ori rd, rs1, imm 	                    0x6 		    R[rd] ← R[rs1] | imm
    //andi rd, rs1, imm 	                0x7 		    R[rd] ← R[rs1] & imm
            InstFormat = InstFormat_I;
            RegWrite= 1;
            case(Funct3)
            'h0:begin //Funct3
                AluOp = AluOp_ADD;
            end
            'h1:begin //Funct3
                case(Funct7)
                'h00:begin
                    AluOp = AluOp_SLL;
                end
                default:begin
                	InstUndef=1;
                end
                endcase
            end
            'h2: begin //Funct3
                    AluOp = AluOp_SUB;
            end
            'h4: begin //Funct3
                    AluOp = AluOp_XOR;
            end
            'h5: begin //Funct3
                case(Funct7)
                'h00:begin
                    AluOp = AluOp_SRL;
                end
                default:begin
                	InstUndef=1;
                end
                endcase
            end
            'h6: begin //Funct3
                    AluOp = AluOp_OR;
            end
            'h7: begin //Funct3
                    AluOp = AluOp_AND;
            end
            default:begin
            	InstUndef=1;
            end
            endcase //Funct3
        end
        'h23:begin //OpCode
    //--------------------------------------------------------------------------------
    //sw rs2, offset(rs1) 	S 	     0x23 	0x2 	        Mem(R[rs1] + offset) ← R[rs2]
            MemWrite =1;
            InstFormat = InstFormat_S;
            case(Funct3)
            'h2:begin
                AluOp = AluOp_ADD;
            end
            default:begin
            	InstUndef=1;
            end
            endcase //Funct3
        end
        'h63:begin //OpCode
    //--------------------------------------------------------------------------------
    //beq rs1, rs2, offset 	SB 	     0x63 	0x0 	        if(R[rs1] == R[rs2])
    //                                                      PC ← PC + {offset, 1b'0}
    //blt rs1, rs2, offset 	                0x4 		    if(R[rs1] less than R[rs2] (signed))
    //                                                      PC ← PC + {offset, 1b'0}
    //bltu rs1, rs2, offset 	            0x6 		    if(R[rs1] less than R[rs2] (unsigned))
    //                                                      PC ← PC + {offset, 1b'0}
            InstFormat = InstFormat_I;
            case(Funct3)
            'h0:begin //Funct3
                AluOp = AluOp_SUB;
            end
            'h4:begin //Funct3
                AluOp = AluOp_SUB;
            end
            'h6:begin //Funct3
                AluOp = AluOp_SUBU;
            end
            default:begin
            end
            endcase //Funct3
        end
    //--------------------------------------------------------------------------------
    //lui rd, offset 	    U 	     0x37                   R[rd] ← {offset, 12b'0}
        'h37:begin //OpCode
            InstFormat = InstFormat_U;
            RegWrite= 1;
        end
    //--------------------------------------------------------------------------------
    //jal rd, imm 	        UJ 	     0x6f 			        R[rd] ← PC + 4
    //                                                      PC ← PC + {imm, 1b'0}
        'h6f:begin //OpCode
            RegWrite= 1;
        end
    //--------------------------------------------------------------------------------
    //jalr rd,rs, imm 	    I 	     0x67 	0x0 	        R[rd] ← PC + 4
    //                                                      PC ← R[rs] + {imm} 
    //--------------------------------------------------------------------------------
        'h67:begin //OpCode
            InstFormat = InstFormat_I;
            RegWrite= 1;
        end
        default: begin
        end
        endcase //OpCode
    end	
	
endmodule
