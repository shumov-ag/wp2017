`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: #COMPANY#
// Engineer: a.shumov
// 
// Create Date: 10.12.2017 17:30:02
// Design Name: 
// Module Name: sata_phy_host_inb_sync
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


`define HINB_SYNC_RESET          0
`define HINB_RX_ALIGN_DETECT     1
`define HINB_RX_ALIGN_CDR_SYNC   2
`define HINB_TX_ALIGN            3
`define HINB_RX_NON_ALIGN_DETECT 4
`define HINB_TX_SYNC             5
`define HINB_SYNC_FINISH         6


module sata_phy_host_inb_sync #(
    parameter ALIGN_DETECT_TIME = 20,
    parameter ALIGN_CDR_SYNC_TIME = 200,
    parameter NON_ALIGN_DETECT_TIME = 6,
    parameter TX_SYNC_MIN_TIME = 200
    ) (
    input wire      rxclk_in,
    input wire      rx_align_p_in,
    input wire      rx_sync_p_in,
    input wire      reset_in,
    
    output reg      tx_d10d2_out,
    output reg      tx_align_p_out,
    output reg      tx_sync_p_out,
    output reg      cdrhold_out,
    output reg      complete_out
    );
    
    
    reg reset;
    reg [5:0] STATE;
    wire [31:0] TIMER;
    reg CLR_TIMER;
    
    COUNTERx32 COUNTERx32_i (
        .CLK(rxclk_in),
        .SCLR(CLR_TIMER),
        .Q(TIMER)
    );

    always @(posedge rxclk_in) begin // State machine logic ----------
        reset <= reset_in;
        if (reset) begin
            STATE = `HINB_SYNC_RESET;
        end
        else if (CLR_TIMER == 0) begin
            case (STATE)
                 `HINB_SYNC_RESET: begin
                     STATE = `HINB_RX_ALIGN_DETECT;
                     CLR_TIMER = 1'b1;
                 end
                 `HINB_RX_ALIGN_DETECT: begin
                     if (rx_align_p_in) begin
                         if (TIMER > ALIGN_DETECT_TIME) begin
                             STATE = `HINB_RX_ALIGN_CDR_SYNC;
                             CLR_TIMER = 1'b1;
                         end
                     end
                     else begin
                         CLR_TIMER = 1'b1;
                     end
                 end
                 `HINB_RX_ALIGN_CDR_SYNC: begin
                     if (TIMER > ALIGN_CDR_SYNC_TIME) begin
                          STATE = `HINB_TX_ALIGN;
                     end
                 end
                 `HINB_TX_ALIGN: begin
                     STATE = `HINB_RX_NON_ALIGN_DETECT;
                     CLR_TIMER = 1'b1;
                 end
                 `HINB_RX_NON_ALIGN_DETECT: begin
                     if (!rx_align_p_in) begin
                         if (TIMER > NON_ALIGN_DETECT_TIME) begin
                             STATE = `HINB_TX_SYNC;
                             CLR_TIMER = 1'b1;
                         end
                     end
                     else begin
                         CLR_TIMER = 1'b1;
                     end
                 end
                 `HINB_TX_SYNC: begin
                     if (TIMER > TX_SYNC_MIN_TIME) begin
                         STATE = `HINB_SYNC_FINISH;
                     end
                 end
                 `HINB_SYNC_FINISH: begin
                     ;
                 end
            endcase
        end
        else begin
            CLR_TIMER = 1'b0;
        end
    end


    always @(posedge rxclk_in) begin // Generate output signals ----------
        complete_out = (STATE == `HINB_SYNC_FINISH);
        cdrhold_out = (STATE < `HINB_RX_ALIGN_CDR_SYNC);

        tx_d10d2_out = (STATE < `HINB_TX_ALIGN);
        tx_align_p_out = ((STATE >= `HINB_TX_ALIGN) && (STATE < `HINB_TX_SYNC));
        tx_sync_p_out = (STATE >= `HINB_TX_SYNC);
    end

endmodule
