`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2018 15:00:59
// Design Name: 
// Module Name: sata_crc_generator
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


module sata_crc_generator(
    input  wire         clk_in,
    input  wire         reset_in,
    input  wire         enable_in,
    input  wire [31:0]  data_in,
    
    output wire [31:0]  crc_out
    );

    reg  [31:0] last_crc;
    wire [31:0] pre_crc = last_crc ^ data_in;
    wire [31:0] new_crc;
 
    assign new_crc[31] = pre_crc[31] ^ pre_crc[30] ^ pre_crc[29] ^ pre_crc[28] ^ pre_crc[27] ^ pre_crc[25] ^ pre_crc[24] ^ pre_crc[23] ^ pre_crc[15] ^ pre_crc[11] ^ pre_crc[9]  ^ pre_crc[8]  ^ pre_crc[5]; 
    assign new_crc[30] = pre_crc[30] ^ pre_crc[29] ^ pre_crc[28] ^ pre_crc[27] ^ pre_crc[26] ^ pre_crc[24] ^ pre_crc[23] ^ pre_crc[22] ^ pre_crc[14] ^ pre_crc[10] ^ pre_crc[8]  ^ pre_crc[7]  ^ pre_crc[4]; 
    assign new_crc[29] = pre_crc[31] ^ pre_crc[29] ^ pre_crc[28] ^ pre_crc[27] ^ pre_crc[26] ^ pre_crc[25] ^ pre_crc[23] ^ pre_crc[22] ^ pre_crc[21] ^ pre_crc[13] ^ pre_crc[9]  ^ pre_crc[7]  ^ pre_crc[6] ^ pre_crc[3]; 
    assign new_crc[28] = pre_crc[30] ^ pre_crc[28] ^ pre_crc[27] ^ pre_crc[26] ^ pre_crc[25] ^ pre_crc[24] ^ pre_crc[22] ^ pre_crc[21] ^ pre_crc[20] ^ pre_crc[12] ^ pre_crc[8]  ^ pre_crc[6]  ^ pre_crc[5] ^ pre_crc[2]; 
    assign new_crc[27] = pre_crc[29] ^ pre_crc[27] ^ pre_crc[26] ^ pre_crc[25] ^ pre_crc[24] ^ pre_crc[23] ^ pre_crc[21] ^ pre_crc[20] ^ pre_crc[19] ^ pre_crc[11] ^ pre_crc[7]  ^ pre_crc[5]  ^ pre_crc[4] ^ pre_crc[1]; 
    assign new_crc[26] = pre_crc[31] ^ pre_crc[28] ^ pre_crc[26] ^ pre_crc[25] ^ pre_crc[24] ^ pre_crc[23] ^ pre_crc[22] ^ pre_crc[20] ^ pre_crc[19] ^ pre_crc[18] ^ pre_crc[10] ^ pre_crc[6]  ^ pre_crc[4] ^ pre_crc[3] ^ pre_crc[0]; 
    assign new_crc[25] = pre_crc[31] ^ pre_crc[29] ^ pre_crc[28] ^ pre_crc[22] ^ pre_crc[21] ^ pre_crc[19] ^ pre_crc[18] ^ pre_crc[17] ^ pre_crc[15] ^ pre_crc[11] ^ pre_crc[8]  ^ pre_crc[3]  ^ pre_crc[2]; 
    assign new_crc[24] = pre_crc[30] ^ pre_crc[28] ^ pre_crc[27] ^ pre_crc[21] ^ pre_crc[20] ^ pre_crc[18] ^ pre_crc[17] ^ pre_crc[16] ^ pre_crc[14] ^ pre_crc[10] ^ pre_crc[7]  ^ pre_crc[2]  ^ pre_crc[1]; 
    assign new_crc[23] = pre_crc[31] ^ pre_crc[29] ^ pre_crc[27] ^ pre_crc[26] ^ pre_crc[20] ^ pre_crc[19] ^ pre_crc[17] ^ pre_crc[16] ^ pre_crc[15] ^ pre_crc[13] ^ pre_crc[9]  ^ pre_crc[6]  ^ pre_crc[1] ^ pre_crc[0]; 
    assign new_crc[22] = pre_crc[31] ^ pre_crc[29] ^ pre_crc[27] ^ pre_crc[26] ^ pre_crc[24] ^ pre_crc[23] ^ pre_crc[19] ^ pre_crc[18] ^ pre_crc[16] ^ pre_crc[14] ^ pre_crc[12] ^ pre_crc[11] ^ pre_crc[9] ^ pre_crc[0]; 
    assign new_crc[21] = pre_crc[31] ^ pre_crc[29] ^ pre_crc[27] ^ pre_crc[26] ^ pre_crc[24] ^ pre_crc[22] ^ pre_crc[18] ^ pre_crc[17] ^ pre_crc[13] ^ pre_crc[10] ^ pre_crc[9]  ^ pre_crc[5]; 
    assign new_crc[20] = pre_crc[30] ^ pre_crc[28] ^ pre_crc[26] ^ pre_crc[25] ^ pre_crc[23] ^ pre_crc[21] ^ pre_crc[17] ^ pre_crc[16] ^ pre_crc[12] ^ pre_crc[9]  ^ pre_crc[8]  ^ pre_crc[4]; 
    assign new_crc[19] = pre_crc[29] ^ pre_crc[27] ^ pre_crc[25] ^ pre_crc[24] ^ pre_crc[22] ^ pre_crc[20] ^ pre_crc[16] ^ pre_crc[15] ^ pre_crc[11] ^ pre_crc[8]  ^ pre_crc[7]  ^ pre_crc[3]; 
    assign new_crc[18] = pre_crc[31] ^ pre_crc[28] ^ pre_crc[26] ^ pre_crc[24] ^ pre_crc[23] ^ pre_crc[21] ^ pre_crc[19] ^ pre_crc[15] ^ pre_crc[14] ^ pre_crc[10] ^ pre_crc[7]  ^ pre_crc[6]  ^ pre_crc[2]; 
    assign new_crc[17] = pre_crc[31] ^ pre_crc[30] ^ pre_crc[27] ^ pre_crc[25] ^ pre_crc[23] ^ pre_crc[22] ^ pre_crc[20] ^ pre_crc[18] ^ pre_crc[14] ^ pre_crc[13] ^ pre_crc[9]  ^ pre_crc[6]  ^ pre_crc[5] ^ pre_crc[1]; 
    assign new_crc[16] = pre_crc[30] ^ pre_crc[29] ^ pre_crc[26] ^ pre_crc[24] ^ pre_crc[22] ^ pre_crc[21] ^ pre_crc[19] ^ pre_crc[17] ^ pre_crc[13] ^ pre_crc[12] ^ pre_crc[8]  ^ pre_crc[5]  ^ pre_crc[4] ^ pre_crc[0]; 

    assign new_crc[15] = pre_crc[30] ^ pre_crc[27] ^ pre_crc[24] ^ pre_crc[21] ^ pre_crc[20] ^ pre_crc[18] ^ pre_crc[16] ^ pre_crc[15] ^ pre_crc[12] ^ pre_crc[9]  ^ pre_crc[8]  ^ pre_crc[7]  ^ pre_crc[5] ^ pre_crc[4] ^ pre_crc[3]; 
    assign new_crc[14] = pre_crc[29] ^ pre_crc[26] ^ pre_crc[23] ^ pre_crc[20] ^ pre_crc[19] ^ pre_crc[17] ^ pre_crc[15] ^ pre_crc[14] ^ pre_crc[11] ^ pre_crc[8]  ^ pre_crc[7]  ^ pre_crc[6]  ^ pre_crc[4] ^ pre_crc[3] ^ pre_crc[2]; 
    assign new_crc[13] = pre_crc[31] ^ pre_crc[28] ^ pre_crc[25] ^ pre_crc[22] ^ pre_crc[19] ^ pre_crc[18] ^ pre_crc[16] ^ pre_crc[14] ^ pre_crc[13] ^ pre_crc[10] ^ pre_crc[7]  ^ pre_crc[6]  ^ pre_crc[5] ^ pre_crc[3] ^ pre_crc[2] ^ pre_crc[1]; 
    assign new_crc[12] = pre_crc[31] ^ pre_crc[30] ^ pre_crc[27] ^ pre_crc[24] ^ pre_crc[21] ^ pre_crc[18] ^ pre_crc[17] ^ pre_crc[15] ^ pre_crc[13] ^ pre_crc[12] ^ pre_crc[9]  ^ pre_crc[6]  ^ pre_crc[5] ^ pre_crc[4] ^ pre_crc[2] ^ pre_crc[1] ^ pre_crc[0]; 
    assign new_crc[11] = pre_crc[31] ^ pre_crc[28] ^ pre_crc[27] ^ pre_crc[26] ^ pre_crc[25] ^ pre_crc[24] ^ pre_crc[20] ^ pre_crc[17] ^ pre_crc[16] ^ pre_crc[15] ^ pre_crc[14] ^ pre_crc[12] ^ pre_crc[9] ^ pre_crc[4] ^ pre_crc[3] ^ pre_crc[1] ^ pre_crc[0]; 
    assign new_crc[10] = pre_crc[31] ^ pre_crc[29] ^ pre_crc[28] ^ pre_crc[26] ^ pre_crc[19] ^ pre_crc[16] ^ pre_crc[14] ^ pre_crc[13] ^ pre_crc[9]  ^ pre_crc[5]  ^ pre_crc[3]  ^ pre_crc[2]  ^ pre_crc[0]; 
    assign new_crc[9]  = pre_crc[29] ^ pre_crc[24] ^ pre_crc[23] ^ pre_crc[18] ^ pre_crc[13] ^ pre_crc[12] ^ pre_crc[11] ^ pre_crc[9]  ^ pre_crc[5]  ^ pre_crc[4]  ^ pre_crc[2]  ^ pre_crc[1]; 
    assign new_crc[8]  = pre_crc[31] ^ pre_crc[28] ^ pre_crc[23] ^ pre_crc[22] ^ pre_crc[17] ^ pre_crc[12] ^ pre_crc[11] ^ pre_crc[10] ^ pre_crc[8]  ^ pre_crc[4]  ^ pre_crc[3]  ^ pre_crc[1]  ^ pre_crc[0]; 
    assign new_crc[7]  = pre_crc[29] ^ pre_crc[28] ^ pre_crc[25] ^ pre_crc[24] ^ pre_crc[23] ^ pre_crc[22] ^ pre_crc[21] ^ pre_crc[16] ^ pre_crc[15] ^ pre_crc[10] ^ pre_crc[8]  ^ pre_crc[7]  ^ pre_crc[5] ^ pre_crc[3] ^ pre_crc[2] ^ pre_crc[0]; 
    assign new_crc[6]  = pre_crc[30] ^ pre_crc[29] ^ pre_crc[25] ^ pre_crc[22] ^ pre_crc[21] ^ pre_crc[20] ^ pre_crc[14] ^ pre_crc[11] ^ pre_crc[8]  ^ pre_crc[7]  ^ pre_crc[6]  ^ pre_crc[5]  ^ pre_crc[4] ^ pre_crc[2] ^ pre_crc[1]; 
    assign new_crc[5]  = pre_crc[29] ^ pre_crc[28] ^ pre_crc[24] ^ pre_crc[21] ^ pre_crc[20] ^ pre_crc[19] ^ pre_crc[13] ^ pre_crc[10] ^ pre_crc[7]  ^ pre_crc[6]  ^ pre_crc[5]  ^ pre_crc[4]  ^ pre_crc[3] ^ pre_crc[1] ^ pre_crc[0]; 
    assign new_crc[4]  = pre_crc[31] ^ pre_crc[30] ^ pre_crc[29] ^ pre_crc[25] ^ pre_crc[24] ^ pre_crc[20] ^ pre_crc[19] ^ pre_crc[18] ^ pre_crc[15] ^ pre_crc[12] ^ pre_crc[11] ^ pre_crc[8]  ^ pre_crc[6] ^ pre_crc[4] ^ pre_crc[3] ^ pre_crc[2] ^ pre_crc[0]; 
    assign new_crc[3]  = pre_crc[31] ^ pre_crc[27] ^ pre_crc[25] ^ pre_crc[19] ^ pre_crc[18] ^ pre_crc[17] ^ pre_crc[15] ^ pre_crc[14] ^ pre_crc[10] ^ pre_crc[9]  ^ pre_crc[8]  ^ pre_crc[7]  ^ pre_crc[3] ^ pre_crc[2] ^ pre_crc[1]; 
    assign new_crc[2]  = pre_crc[31] ^ pre_crc[30] ^ pre_crc[26] ^ pre_crc[24] ^ pre_crc[18] ^ pre_crc[17] ^ pre_crc[16] ^ pre_crc[14] ^ pre_crc[13] ^ pre_crc[9]  ^ pre_crc[8]  ^ pre_crc[7]  ^ pre_crc[6] ^ pre_crc[2] ^ pre_crc[1] ^ pre_crc[0]; 
    assign new_crc[1]  = pre_crc[28] ^ pre_crc[27] ^ pre_crc[24] ^ pre_crc[17] ^ pre_crc[16] ^ pre_crc[13] ^ pre_crc[12] ^ pre_crc[11] ^ pre_crc[9]  ^ pre_crc[7]  ^ pre_crc[6]  ^ pre_crc[1]  ^ pre_crc[0]; 
    assign new_crc[0]  = pre_crc[31] ^ pre_crc[30] ^ pre_crc[29] ^ pre_crc[28] ^ pre_crc[26] ^ pre_crc[25] ^ pre_crc[24] ^ pre_crc[16] ^ pre_crc[12] ^ pre_crc[10] ^ pre_crc[9]  ^ pre_crc[6]  ^ pre_crc[0];

    always @(posedge clk_in) begin
        if (reset_in) begin
            last_crc[31:0] = 32'h52325032;
        end
        else if (enable_in) begin
            last_crc[31:0] = new_crc[31:0];
        end
    end

endmodule
