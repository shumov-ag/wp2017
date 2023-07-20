`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: #COMPANY#
// Engineer: a.shumov
// 
// Create Date: 14.12.2017 21:42:00
// Design Name: 
// Module Name: sata_phy_device_inb_sync
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


`define DINB_SYNC_RESET          0
`define DINB_TX_ALIGN            1
`define DINB_RX_ALIGN_DETECT     2
`define DINB_TX_SYNC             3
`define DINB_RX_NON_ALIGN_DETECT 4
`define DINB_SYNC_FINISH         5


module sata_phy_device_inb_sync #(
    parameter ALIGN_DETECT_TIME = 20,
    parameter NON_ALIGN_DETECT_TIME = 6
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
            STATE = `DINB_SYNC_RESET;
        end
        else if (CLR_TIMER == 0) begin
            case (STATE)
                 `DINB_SYNC_RESET: begin
                     STATE = `DINB_TX_ALIGN;
                 end
                 `DINB_TX_ALIGN: begin
                     STATE = `DINB_RX_ALIGN_DETECT;
                     CLR_TIMER = 1'b1;
                 end
                 `DINB_RX_ALIGN_DETECT: begin
                     if (rx_align_p_in) begin
                         if (TIMER > ALIGN_DETECT_TIME) begin
                             STATE = `DINB_TX_SYNC;
                         end
                     end
                     else begin
                         CLR_TIMER = 1'b1;
                     end
                 end
                 `DINB_TX_SYNC: begin
                     STATE = `DINB_RX_NON_ALIGN_DETECT;
                     CLR_TIMER = 1'b1;
                 end
                 `DINB_RX_NON_ALIGN_DETECT: begin
                     if (!rx_align_p_in) begin
                         if (TIMER > NON_ALIGN_DETECT_TIME) begin
                             STATE = `DINB_SYNC_FINISH;
                         end
                     end
                     else begin
                         CLR_TIMER = 1'b1;
                     end
                 end
                 `DINB_SYNC_FINISH: begin
                     ;
                 end
            endcase
        end
        else begin
            CLR_TIMER = 1'b0;
        end
    end


    always @(posedge rxclk_in) begin // Generate output signals ----------
        complete_out = (STATE == `DINB_SYNC_FINISH);
        cdrhold_out = (STATE == `DINB_SYNC_RESET);

        tx_d10d2_out = 1'b0;
        tx_align_p_out = (STATE < `DINB_TX_SYNC);
        tx_sync_p_out = (STATE >= `DINB_TX_SYNC);
    end

endmodule
