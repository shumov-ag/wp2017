`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: #COMPANY# 
// Engineer: a.shumov 
// 
// Create Date: 24.12.2017 10:14:33
// Design Name: 
// Module Name: sata_phy_host
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


module sata_phy_host(
    // common inputs
    input  wire         reset_in,
    
    // common outputs
    output wire         oob_sync_complete_out,
    output wire         ready_out,

    // lower layer inputs
    input  wire         gt_rxclk_in,
    input  wire [15:0]  gt_rxdata_in,
    input  wire [1:0]   gt_rxcharisk_in,
    input  wire [1:0]   gt_rxdataerr_in,
    input  wire         gt_rxcominit_in,
    input  wire         gt_rxcomwake_in,
    input  wire         gt_rxelecidle_in,
    input  wire         gt_rxresetdone_in,
    
    // lower layer outputs
    input  wire         gt_txclk_in,
    output wire [15:0]  gt_txdata_out,
    output wire [1:0]   gt_txcharisk_out,
    output wire         gt_txcomreset_out,
    output wire         gt_txcomwake_out,
    output wire         gt_txelecidle_out,
    output wire         gt_rxcdrhold_out,
    output wire         gt_rxpmareset_out,

    // upper layer inputs
    input  wire         sata_new_dword_in,
    input  wire [31:0]  sata_dword_in,
    input  wire [3:0]   sata_controls_in,
    
    // upper layer outputs
    output wire         sata_new_dword_out,
    output wire [31:0]  sata_dword_out,
    output wire [3:0]   sata_controls_out
    );
    
    
    wire OOB_SYNC_COMPLETE;
    
    sata_phy_host_oob_sync sata_phy_host_oob_sync_i (
        .gt_rxclk_in                (gt_rxclk_in),
        .gt_rxcominit_in            (gt_rxcominit_in),
        .gt_rxcomwake_in            (gt_rxcomwake_in),
        .gt_rxelecidle_in           (gt_rxelecidle_in),
        .reset_in                   (reset_in),
        
        .gt_txcomreset_out          (gt_txcomreset_out),
        .gt_txcomwake_out           (gt_txcomwake_out),
        .gt_txelecidle_out          (gt_txelecidle_out),
        .sync_complete_out          (OOB_SYNC_COMPLETE)
    );
    
    
    reg OOB_SYNC_COMPLETE_2;
    reg gt_rxresetdone_in_2;
    reg rxpmareset_trig;
    assign gt_rxpmareset_out = (~OOB_SYNC_COMPLETE_2 & OOB_SYNC_COMPLETE) | rxpmareset_trig;
    
    always @(posedge gt_rxclk_in) begin
        OOB_SYNC_COMPLETE_2 <= OOB_SYNC_COMPLETE;
        if (~OOB_SYNC_COMPLETE_2 & OOB_SYNC_COMPLETE) begin
            rxpmareset_trig = 1;
        end
        
        gt_rxresetdone_in_2 <= gt_rxresetdone_in;
        if (gt_rxresetdone_in_2 & ~gt_rxresetdone_in) begin
            rxpmareset_trig = 0;
        end
    end
    
    
    wire [15:0] GT_RXDATA = {gt_rxdataerr_in[1] ? 8'h00 : gt_rxdata_in[15:8], gt_rxdataerr_in[0] ? 8'h00 : gt_rxdata_in[7:0]};
    wire [1:0]  GT_RXCHARISK = gt_rxdataerr_in | gt_rxcharisk_in;
    wire [31:0] RX_SATA_DWORD;
    wire [3:0]  RX_SATA_CONTROLS;
    wire        RX_SATA_LOWWORD;

    sata_phy_rx_gate sata_phy_rx_gate_i (
        .gt_rxclk_in        (gt_rxclk_in),
        .gt_rxdata_in       (GT_RXDATA),
        .gt_rxcharisk_in    (GT_RXCHARISK),
        
        .DWORD_out          (RX_SATA_DWORD),
        .CONTROL_out        (RX_SATA_CONTROLS),
        .low_word           (RX_SATA_LOWWORD)
    );
        
        
    wire RX_ALIGNp;
    wire RX_SYNCp;
    
    sata_dword_to_primitive sata_dword_to_primitive_i (
        .sata_dword_in      (RX_SATA_DWORD),
        .sata_controls_in   (RX_SATA_CONTROLS),

        .ALIGNp_out         (RX_ALIGNp),
        .SYNCp_out          (RX_SYNCp)
    );


    wire TX_ALIGNp;
    wire TX_SYNCp;
    wire TX_D10d2;
    wire INB_SYNC_COMPLETE;

    sata_phy_host_inb_sync sata_phy_host_inb_sync_i (
        .rxclk_in                   (gt_rxclk_in),
        .rx_align_p_in              (RX_ALIGNp),
        .rx_sync_p_in               (RX_SYNCp),
        .reset_in                   (~OOB_SYNC_COMPLETE | ~gt_rxresetdone_in | gt_rxpmareset_out),
    
        .tx_d10d2_out               (TX_D10d2),
        .tx_align_p_out             (TX_ALIGNp),
        .tx_sync_p_out              (TX_SYNCp),
        .cdrhold_out                (gt_rxcdrhold_out),
        .complete_out               (INB_SYNC_COMPLETE)
    );
    
    
    sata_phy_tx_gate sata_phy_tx_gate_i (
        .gt_txclk_in            (gt_txclk_in),

        .sata_new_dword_in      (sata_new_dword_in),
        .sata_dword_in          (sata_dword_in),
        .sata_controls_in       (sata_controls_in),
        
        .gt_txdata_out          (gt_txdata_out),
        .gt_txcharisk_out       (gt_txcharisk_out),

        .ALIGNp                 (TX_ALIGNp && !INB_SYNC_COMPLETE),
        .SYNCp                  (TX_SYNCp && !INB_SYNC_COMPLETE),
        .D10d2                  (TX_D10d2 && !INB_SYNC_COMPLETE)
    );
    

    assign oob_sync_complete_out = OOB_SYNC_COMPLETE;
    assign ready_out = INB_SYNC_COMPLETE;
    
    assign sata_new_dword_out = RX_SATA_LOWWORD;
    assign sata_dword_out = RX_SATA_DWORD;
    assign sata_controls_out = RX_SATA_CONTROLS;

endmodule
