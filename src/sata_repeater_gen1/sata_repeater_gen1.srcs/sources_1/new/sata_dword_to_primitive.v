`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: #COMPANY#
// Engineer: a.shumov
// 
// Create Date: 12.12.2017 12:44:23
// Design Name: 
// Module Name: sata_dword_to_primitive
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sata_dword_to_primitive #(
    parameter ADV_CONT_REPLACE = "FALSE",
    parameter ADV_ALIGN_REPLACE = "FALSE"
)
(
    input  wire         adv_clk_in,
    input  wire [31:0]  sata_dword_in,
    input  wire [3:0]   sata_controls_in,

    output wire         ALIGNp_out,
    output wire         CONTp_out,
    output wire         DMATp_out,
    output wire         EOFp_out,
    output wire         HOLDp_out,
    output wire         HOLDAp_out,
    output wire         PMACKp_out,
    output wire         PMNAKp_out,
    output wire         PMREQ_Pp_out,
    output wire         PMREQ_Sp_out,
    output wire         R_ERRp_out,
    output wire         R_IPp_out,
    output wire         R_OKp_out,
    output wire         R_RDYp_out,
    output wire         SOFp_out,
    output wire         SYNCp_out,
    output wire         WTRMp_out,
    output wire         X_RDYp_out,
    output wire         D10d2_out
    );

    `include "sata_cmn.vh"


    // Native input ptimitives (as they are)
    wire _native_ALIGNp   = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_ALIGNp));
    wire _native_CONTp    = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_CONTp));
    wire _native_DMATp    = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_DMATp));
    wire _native_EOFp     = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_EOFp));
    wire _native_HOLDp    = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_HOLDp));
    wire _native_HOLDAp   = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_HOLDAp));
    wire _native_PMACKp   = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_PMACKp));
    wire _native_PMNAKp   = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_PMNAKp));
    wire _native_PMREQ_Pp = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_PMREQ_Pp));
    wire _native_PMREQ_Sp = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_PMREQ_Sp));
    wire _native_R_ERRp   = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_R_ERRp));
    wire _native_R_IPp    = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_R_IPp));
    wire _native_R_OKp    = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_R_OKp));
    wire _native_R_RDYp   = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_R_RDYp));
    wire _native_SOFp     = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_SOFp));
    wire _native_SYNCp    = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_SYNCp));
    wire _native_WTRMp    = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_WTRMp));
    wire _native_X_RDYp   = ((sata_controls_in == 4'b0001) && (sata_dword_in == `D_X_RDYp));
    wire _native_D10d2    = ((sata_controls_in == 4'b0000) && (sata_dword_in == `D_D10d2));

    wire _native_ANYp = (_native_ALIGNp & (ADV_ALIGN_REPLACE == "FALSE")) | (_native_CONTp & (ADV_CONT_REPLACE == "FALSE")) | 
                        _native_DMATp   | _native_EOFp      | _native_HOLDp     | _native_HOLDAp    | _native_PMACKp    |
                        _native_PMNAKp  | _native_PMREQ_Pp  | _native_PMREQ_Sp  | _native_R_ERRp    | _native_R_IPp     |
                        _native_R_OKp   | _native_R_RDYp    | _native_SOFp      | _native_SYNCp     | _native_WTRMp     |
                        _native_X_RDYp;

    wire _cont_ANYp = (((ADV_CONT_REPLACE == "TRUE") & _native_CONTp) | (((ADV_ALIGN_REPLACE == "TRUE") & _native_ALIGNp)));
    
    // Continuous primitives (during CONT and ALIGN)
    reg _cont_HOLDp;
    reg _cont_HOLDAp;
    reg _cont_PMREQ_Pp;
    reg _cont_PMREQ_Sp;
    reg _cont_R_ERRp;
    reg _cont_R_IPp;
    reg _cont_R_OKp;
    reg _cont_R_RDYp;
    reg _cont_SYNCp;
    reg _cont_WTRMp;
    reg _cont_X_RDYp;
    
    reg hold_reg;
    
    reg _native_ALIGNp_2;
    wire after_ALIGNp_flag = ~_native_ALIGNp & _native_ALIGNp_2;// Если предыдущий примитив был ALIGNp (!!! для SATA-USB конвертера)
    //wire after_ALIGNp_flag = 0;// (!!! для встроенного SATA-контроллера)
    /*
        На системе со встроенным в мат. плату SATA-хостом наблюдаю ситуацию, когда ALIGNp
        приходит в потоке скремблированного примитива без явного повторения последнего.
        Таким образом, поток скремблированного примитива после ALIGNp воспринимается как поток данных.
        
        На системе с SATA-USB конвертером наблюдаю ситуацию, когда ALIGNp, появляющийся следом за SOFp, экранирует
        следующий за SOFp поток данных.  
    */

    always @(posedge adv_clk_in) begin
        if ((ADV_CONT_REPLACE == "TRUE") | (ADV_ALIGN_REPLACE == "TRUE")) begin
            if (_native_ANYp) begin
                hold_reg = 1'b0; // If there is a native primitive now, then need to switch off hold_reg flag
            end
            else if (_cont_ANYp) begin
                hold_reg = 1'b1;
            end
            else if (after_ALIGNp_flag) begin
                hold_reg = 1'b0;// Если предыдущий примитив был ALIGNp, сбрасываем сохраненные значения  
            end
            
            if (!hold_reg) begin
               _cont_HOLDp = _native_HOLDp;
               _cont_HOLDAp = _native_HOLDAp;
               _cont_PMREQ_Pp = _native_PMREQ_Pp;
               _cont_PMREQ_Sp = _native_PMREQ_Sp;
               _cont_R_ERRp = _native_R_ERRp;
               _cont_R_IPp = _native_R_IPp;
               _cont_R_OKp = _native_R_OKp;
               _cont_R_RDYp = _native_R_RDYp;
               _cont_SYNCp = _native_SYNCp;
               _cont_WTRMp = _native_WTRMp;
               _cont_X_RDYp = _native_X_RDYp;
            end
            
            _native_ALIGNp_2 <= _native_ALIGNp;
        end
    end
    
    
    wire is_holded = (~_native_ANYp) & (_cont_ANYp | hold_reg) & (~after_ALIGNp_flag);
    
    // output hold or current values (for continuous primitives)
    assign HOLDp_out    = is_holded ? _cont_HOLDp   : _native_HOLDp;
    assign HOLDAp_out   = is_holded ? _cont_HOLDAp  : _native_HOLDAp;
    assign PMREQ_Pp_out = is_holded ? _cont_PMREQ_Pp: _native_PMREQ_Pp;
    assign PMREQ_Sp_out = is_holded ? _cont_PMREQ_Sp: _native_PMREQ_Sp;
    assign R_ERRp_out   = is_holded ? _cont_R_ERRp  : _native_R_ERRp;
    assign R_IPp_out    = is_holded ? _cont_R_IPp   : _native_R_IPp;
    assign R_OKp_out    = is_holded ? _cont_R_OKp   : _native_R_OKp;
    assign R_RDYp_out   = is_holded ? _cont_R_RDYp  : _native_R_RDYp;
    assign SYNCp_out    = is_holded ? _cont_SYNCp   : _native_SYNCp;
    assign WTRMp_out    = is_holded ? _cont_WTRMp   : _native_WTRMp;
    assign X_RDYp_out   = is_holded ? _cont_X_RDYp  : _native_X_RDYp;

    // output current values (for non-continuous primitives)
    assign ALIGNp_out   = _native_ALIGNp;
    assign CONTp_out    = _native_CONTp;
    assign DMATp_out    = _native_DMATp;
    assign EOFp_out     = _native_EOFp;
    assign PMACKp_out   = _native_PMACKp;
    assign PMNAKp_out   = _native_PMNAKp;
    assign SOFp_out     = _native_SOFp;
    assign D10d2_out    = _native_D10d2;

endmodule
