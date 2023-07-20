`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: #COMPANY#
// Engineer: a.shumov
// 
// Create Date: 08.12.2017 18:02:10
// Design Name: 
// Module Name: sata_phy_rx_gate
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


module sata_phy_rx_gate (
    input   wire        gt_rxclk_in,
    input   wire [15:0] gt_rxdata_in,
    input   wire [1:0]  gt_rxcharisk_in,
    input   wire        reset_in,

    output  reg [31:0]  DWORD_out,
    output  reg [3:0]   CONTROL_out,
    output  wire        low_word,
    output  reg         valid_out
    );


    reg [15:0] in_data_0;
    reg [15:0] in_data_1;
    reg [1:0] in_charisk_0;
    reg [1:0] in_charisk_1;

    always @(posedge gt_rxclk_in) begin // Store last three input words to the memory ----------
        in_data_1 <= gt_rxdata_in;
        in_data_0 <= in_data_1;
        in_charisk_1 <= gt_rxcharisk_in;
        in_charisk_0 <= in_charisk_1;
    end


    wire [31:0] possible_dword_0 = {in_data_1, in_data_0};
    wire [31:0] possible_dword_1 = {gt_rxdata_in[7:0], in_data_1, in_data_0[15:8]};

    wire [3:0] possible_controls_0 = {in_charisk_1, in_charisk_0};
    wire [3:0] possible_controls_1 = {gt_rxcharisk_in[0], in_charisk_1, in_charisk_0[1]};

    wire possible_dword_0_is_align = ((possible_controls_0 == 4'b0001) && (possible_dword_0 == 32'h7b_4a_4a_bc));
    wire possible_dword_1_is_align = ((possible_controls_1 == 4'b0001) && (possible_dword_1 == 32'h7b_4a_4a_bc));

    reg in_shift;
    reg word_idx;

    always @(posedge gt_rxclk_in) begin // Convert last three input words to one output sata dword ----------
        if (reset_in) begin // Reset the state machine ----------
            valid_out = 1'b0;
        end
        else begin
            if (possible_dword_0_is_align || possible_dword_1_is_align) begin
                word_idx = 1'b0;
                valid_out = 1'b1;
                in_shift = possible_dword_1_is_align;
            end
            else begin
                word_idx = !word_idx;//word_idx = word_idx + 1;
            end
    
            if (0 == word_idx) begin
                DWORD_out = in_shift ? possible_dword_1 : possible_dword_0;
                CONTROL_out = in_shift ? possible_controls_1 : possible_controls_0;
            end
        end
    end
    
    assign low_word = valid_out && (0 == word_idx); 
endmodule
