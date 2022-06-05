`define DATA_WIDTH 32
`define INST_WIDTH 32
`define DATA_ADDR_WIDTH 32
`define INST_ADDR_WIDTH 32

`define REG_FILE_ADDR_WIDTH 5
`define REG_FILE_DEPTH 32

`define R_INST   7'b0110011
`define I_INST_1 7'b0010011
`define I_INST_2 7'b0000011
`define I_INST_3 7'b1100111
`define I_INST_4 7'b1110011
`define S_INST   7'b0100011
`define B_INST   7'b1100011
`define U_INST_1 7'b0110111
`define U_INST_2 7'b0010111
`define J_INST   7'b1101111

//opd1 sel
`define OPD1_SEL_REG   1'h0
`define OPD1_SEL_PC    1'h1

//opd2 sel
`define OPD2_SEL_REG   2'h0
`define OPD2_SEL_S_IMM 2'h1
`define OPD2_SEL_J_IMM 2'h2
`define OPD2_SEL_I_IMM 2'h3

//base sel
`define BASE_SEL_PC   1'h0
`define BASE_SEL_0    1'h1

//offset sel
`define OFF_SEL_4     2'h0
`define OFF_SEL_B_IMM 2'h1
`define OFF_SEL_U_IMM 2'h2

//op
`define ADD_OP    5'h00
`define SUB_OP    5'h01
`define XOR_OP    5'h02
`define OR_OP     5'h03
`define AND_OP    5'h04
`define SLL_OP    5'h05
`define SRL_OP    5'h06
`define SRA_OP    5'h07
`define SLT_OP    5'h08
`define SLTU_OP   5'h09
`define BEQ_OP    5'h11
`define BNE_OP    5'h12
`define BLT_OP    5'h13
`define BGE_OP    5'h14
`define BLTU_OP   5'h15
`define BGEU_OP   5'h16
`define ECALL_OP  5'h1B
`define EBREAK_OP 5'h1C

