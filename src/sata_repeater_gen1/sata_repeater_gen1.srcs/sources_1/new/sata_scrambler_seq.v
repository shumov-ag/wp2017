`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: #COMPANY#
// Engineer: a.shumov
// 
// Create Date: 07.03.2018 14:48:11
// Design Name: 
// Module Name: sata_scrambler_seq
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


module sata_scrambler_seq(
    input  wire         clk_in,
    input  wire         reset_in,
    input  wire         update_in,
    
    output wire [31:0]  sequence_out
    );
    
    reg [15:0] context;
    
    (* mark_debug = "true" *)wire reset = reset_in;
    (* mark_debug = "true" *)wire update = update_in;
    (* mark_debug = "true" *)wire [31:0]seq = sequence_out;
    
    assign sequence_out[31] = context[12] ^ context[10] ^ context[7]  ^ context[3]  ^ context[1]  ^ context[0]; 
    assign sequence_out[30] = context[15] ^ context[14] ^ context[12] ^ context[11] ^ context[9]  ^ context[6]  ^ context[3] ^ context[2] ^ context[0]; 
    assign sequence_out[29] = context[15] ^ context[13] ^ context[12] ^ context[11] ^ context[10] ^ context[8]  ^ context[5] ^ context[3] ^ context[2] ^ context[1]; 
    assign sequence_out[28] = context[14] ^ context[12] ^ context[11] ^ context[10] ^ context[9]  ^ context[7]  ^ context[4] ^ context[2] ^ context[1] ^ context[0]; 
    assign sequence_out[27] = context[15] ^ context[14] ^ context[13] ^ context[12] ^ context[11] ^ context[10] ^ context[9] ^ context[8] ^ context[6] ^ context[1] ^ context[0]; 
    assign sequence_out[26] = context[15] ^ context[13] ^ context[11] ^ context[10] ^ context[9]  ^ context[8]  ^ context[7] ^ context[5] ^ context[3] ^ context[0]; 
    assign sequence_out[25] = context[15] ^ context[10] ^ context[9]  ^ context[8]  ^ context[7]  ^ context[6]  ^ context[4] ^ context[3] ^ context[2]; 
    assign sequence_out[24] = context[14] ^ context[9]  ^ context[8]  ^ context[7]  ^ context[6]  ^ context[5]  ^ context[3] ^ context[2] ^ context[1]; 
    assign sequence_out[23] = context[13] ^ context[8]  ^ context[7]  ^ context[6]  ^ context[5]  ^ context[4]  ^ context[2] ^ context[1] ^ context[0]; 
    assign sequence_out[22] = context[15] ^ context[14] ^ context[7]  ^ context[6]  ^ context[5]  ^ context[4]  ^ context[1] ^ context[0]; 
    assign sequence_out[21] = context[15] ^ context[13] ^ context[12] ^ context[6]  ^ context[5]  ^ context[4]  ^ context[0]; 
    assign sequence_out[20] = context[15] ^ context[11] ^ context[5]  ^ context[4]; 
    assign sequence_out[19] = context[14] ^ context[10] ^ context[4]  ^ context[3]; 
    assign sequence_out[18] = context[13] ^ context[9]  ^ context[3]  ^ context[2]; 
    assign sequence_out[17] = context[12] ^ context[8]  ^ context[2]  ^ context[1]; 
    assign sequence_out[16] = context[11] ^ context[7]  ^ context[1]  ^ context[0]; 

    assign sequence_out[15] = context[15] ^ context[14] ^ context[12] ^ context[10] ^ context[6]  ^ context[3]  ^ context[0]; 
    assign sequence_out[14] = context[15] ^ context[13] ^ context[12] ^ context[11] ^ context[9]  ^ context[5]  ^ context[3] ^ context[2]; 
    assign sequence_out[13] = context[14] ^ context[12] ^ context[11] ^ context[10] ^ context[8]  ^ context[4]  ^ context[2] ^ context[1]; 
    assign sequence_out[12] = context[13] ^ context[11] ^ context[10] ^ context[9]  ^ context[7]  ^ context[3]  ^ context[1] ^ context[0]; 
    assign sequence_out[11] = context[15] ^ context[14] ^ context[10] ^ context[9]  ^ context[8]  ^ context[6]  ^ context[3] ^ context[2] ^ context[0]; 
    assign sequence_out[10] = context[15] ^ context[13] ^ context[12] ^ context[9]  ^ context[8]  ^ context[7]  ^ context[5] ^ context[3] ^ context[2] ^ context[1]; 
    assign sequence_out[9]  = context[14] ^ context[12] ^ context[11] ^ context[8]  ^ context[7]  ^ context[6]  ^ context[4] ^ context[2] ^ context[1] ^ context[0]; 
    assign sequence_out[8]  = context[15] ^ context[14] ^ context[13] ^ context[12] ^ context[11] ^ context[10] ^ context[7] ^ context[6] ^ context[5] ^ context[1] ^ context[0]; 
    assign sequence_out[7]  = context[15] ^ context[13] ^ context[11] ^ context[10] ^ context[9]  ^ context[6]  ^ context[5] ^ context[4] ^ context[3] ^ context[0]; 
    assign sequence_out[6]  = context[15] ^ context[10] ^ context[9]  ^ context[8]  ^ context[5]  ^ context[4]  ^ context[2]; 
    assign sequence_out[5]  = context[14] ^ context[9]  ^ context[8]  ^ context[7]  ^ context[4]  ^ context[3]  ^ context[1]; 
    assign sequence_out[4]  = context[13] ^ context[8]  ^ context[7]  ^ context[6]  ^ context[3]  ^ context[2]  ^ context[0]; 
    assign sequence_out[3]  = context[15] ^ context[14] ^ context[7]  ^ context[6]  ^ context[5]  ^ context[3]  ^ context[2] ^ context[1]; 
    assign sequence_out[2]  = context[14] ^ context[13] ^ context[6]  ^ context[5]  ^ context[4]  ^ context[2]  ^ context[1] ^ context[0]; 
    assign sequence_out[1]  = context[15] ^ context[14] ^ context[13] ^ context[5]  ^ context[4]  ^ context[1]  ^ context[0]; 
    assign sequence_out[0]  = context[15] ^ context[13] ^ context[4]  ^ context[0];
    
    always @(posedge clk_in) begin
        if (reset_in) begin
            context[15:0] = 16'hf0f6;
        end
        else if (update_in) begin
            context[15:0] = sequence_out[31:16];
        end
    end
    
endmodule
