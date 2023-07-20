// SATA Logger
`define ENABLE_SATA_LOGGING 1
`define LOGGING_WITH_TRUNCATED_DATA 1
`define LOGGING_DATA_SIZE_MAX 10

// SATA primitives
`define D_ALIGNp    32'h7b_4a_4a_bc
`define D_CONTp     32'h99_99_aa_7c
`define D_DMATp     32'h36_36_b5_7c
`define D_EOFp      32'hd5_d5_b5_7c
`define D_HOLDp     32'hd5_d5_aa_7c
`define D_HOLDAp    32'h95_95_aa_7c
`define D_PMACKp    32'h95_95_95_7c
`define D_PMNAKp    32'hf5_f5_95_7c
`define D_PMREQ_Pp  32'h17_17_b5_7c
`define D_PMREQ_Sp  32'h75_75_95_7c
`define D_R_ERRp    32'h56_56_b5_7c
`define D_R_IPp     32'h55_55_b5_7c
`define D_R_OKp     32'h35_35_b5_7c
`define D_R_RDYp    32'h4a_4a_95_7c
`define D_SOFp      32'h37_37_b5_7c
`define D_SYNCp     32'hb5_b5_95_7c
`define D_WTRMp     32'h58_58_b5_7c
`define D_X_RDYp    32'h57_57_b5_7c

`define D_D10d2     32'h4a_4a_4a_4a
