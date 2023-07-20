`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: #COMPANY# 
// Engineer: a.shumov 
// 
// Create Date: 26.12.2017 11:19:07
// Design Name: 
// Module Name: bits_stabilization_x32
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


module bits_stabilization_x32 (
    input wire          inclk_in,
    input wire          outclk_in,
    
    input wire [31:0]   bits,
    output reg [31:0]   stable_bits
    );
    
    
    reg [31:0] metastable_bits;
    
    always @(posedge inclk_in) begin
        metastable_bits <= bits;
    end
    
    
    always @(posedge outclk_in) begin
        stable_bits <= metastable_bits;
    end
    
endmodule
