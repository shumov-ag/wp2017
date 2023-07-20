`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: #COMPANY#
// Engineer: a.shumov
// 
// Create Date: 12.12.2017 21:39:30
// Design Name: 
// Module Name: sata_phy_tx_gate
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


module sata_phy_tx_gate(
    input  wire         gt_txclk_in,

    input  wire         sata_new_dword_in,
    input  wire [31:0]  sata_dword_in,
    input  wire [3:0]   sata_controls_in,
    
    output wire [15:0]  gt_txdata_out,
    output wire [1:0]   gt_txcharisk_out,

    input  wire         ALIGNp,
    input  wire         SYNCp,
    input  wire         D10d2
    );
    
    `include "sata_cmn.vh"


    reg ALIGNp_reg;
    reg SYNCp_reg;
    reg D10d2_reg;

    always @(posedge gt_txclk_in) begin // Use previous stable value
        ALIGNp_reg  <= ALIGNp;
        SYNCp_reg   <= SYNCp;
        D10d2_reg   <= D10d2;
    end


    reg is_low_word;
    reg [35:0] force_primitive;
    reg force_out;

    always @(posedge gt_txclk_in) begin
        is_low_word = sata_new_dword_in ? 0 : !is_low_word;
    
        if (is_low_word) begin
            force_primitive =   ALIGNp_reg  ?   {4'b0001, `D_ALIGNp}   : 
                                SYNCp_reg   ?   {4'b0001, `D_SYNCp}    :
                                D10d2_reg   ?   {4'b0000, `D_D10d2}    :   {4'b0000, 32'h00000000};

            force_out = |force_primitive;
        end
    end


    wire [15:0] sata_txword = is_low_word ? sata_dword_in[15:0] : sata_dword_in[31:16];
    wire [1:0]  sata_txcharisk = is_low_word ? sata_controls_in[1:0] : sata_controls_in[3:2];
    wire [15:0] forced_word = is_low_word ? force_primitive[15:0] : force_primitive[31:16];
    wire [1:0]  forced_controls = is_low_word ? force_primitive[33:32] : force_primitive[35:34];

    assign gt_txdata_out = force_out ? forced_word : sata_txword;
    assign gt_txcharisk_out = force_out ? forced_controls : sata_txcharisk;

endmodule
