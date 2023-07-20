`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: #COMPANY#
// Engineer: a.shumov 
// 
// Create Date: 22.07.2018 19:23:42
// Design Name: 
// Module Name: sata_logger2
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


module sata_logger2 #(
        parameter CLK_FREQ = 25000000,
        parameter UART_FREQ = 115200   
    ) (
        input  wire         reset_in,
        input  wire         clk_in,
        input  wire [35:0]  data_in,
        input  wire         empty_in,
        output reg          rd_en_out,
        output wire         uart_tx_out
    );

    reg  tx_start;
    wire tx_busy;
    wire [7:0] tx_byte;

    async_transmitter #(
        .ClkFrequency   (CLK_FREQ),
        .Baud           (UART_FREQ)
    ) uart_tx (
        .clk            (clk_in),
        .TxD_start      (tx_start),
        .TxD_data       (tx_byte),
        .TxD            (uart_tx_out),
        .TxD_busy       (tx_busy)
    );


    wire [7:0] data_byte1   =   data_in[ 7: 0];
    wire [7:0] data_byte2   =   data_in[15: 8];
    wire [7:0] data_byte3   =   data_in[23:16];
    wire [7:0] data_byte4   =   data_in[31:24];
    wire [2:0] data_type    =   data_in[34:32]; // Type of a sata dword (1 - first dword in packet, 2 - last dword in packet)
    wire [0:0] data_direction = data_in[35:35]; // Direction of data stream (0 - HDD to PC, 1 - PC to HDD)
    
    reg  [1:0] data_in_byte_index;
    wire [7:0] data_in_byte =   (0 == data_in_byte_index) ? data_byte1 :
                                (1 == data_in_byte_index) ? data_byte2 :
                                (2 == data_in_byte_index) ? data_byte3 :
                                                            data_byte4 ;

    reg  [79:0] format_data; // This 10-byte register contains formatted sata dword with stuffed sequences
    reg  [5:0]  format_data_len; // This is letgth of the formatted data

    reg  [5:0]  tx_byte_index; // Index of a byte in a formatted data buffer
    assign tx_byte[7:0]  =  (0 == tx_byte_index) ? format_data[ 7: 0] :
                            (1 == tx_byte_index) ? format_data[15: 8] :
                            (2 == tx_byte_index) ? format_data[23:16] :
                            (3 == tx_byte_index) ? format_data[31:24] :
                            (4 == tx_byte_index) ? format_data[39:32] :
                            (5 == tx_byte_index) ? format_data[47:40] :
                            (6 == tx_byte_index) ? format_data[55:48] :
                            (7 == tx_byte_index) ? format_data[63:56] :
                            (8 == tx_byte_index) ? format_data[71:64] :
                            (9 == tx_byte_index) ? format_data[79:72] :
                                                   8'h88 ;

    reg RESET;

    always @(posedge clk_in) begin
        RESET <= reset_in; // Obtain the reset signal in current clock domain
    end

    reg [6:0] STATE;
    reg [6:0] STATE2;
    reg [6:0] DATA_CNTR;

    always @(posedge clk_in) begin
        rd_en_out = 0;
        tx_start = 0;

        if (RESET) begin
            STATE = 0;
        end
        else begin 
            case (STATE)
            0:  begin // Wait for a new read cycle
                if (~empty_in) begin
                    rd_en_out = 1;
                    STATE = 1;
                end
            end
            1:  begin // Wait the reading data
                STATE = 2;
                STATE2 = 0;
            end
            2:  begin // We have a new data_in value. We need to format the dword

                if (`LOGGING_WITH_TRUNCATED_DATA && (STATE2 == 0)) begin
                    if (data_type == 0) begin
                        if (DATA_CNTR > `LOGGING_DATA_SIZE_MAX) begin
                            STATE2 = 5;
                        end
                        else begin
                            if (DATA_CNTR == `LOGGING_DATA_SIZE_MAX) begin
                                STATE2 = 6;
                            end
                            DATA_CNTR = DATA_CNTR + 1;
                        end
                    end
                    else begin
                        DATA_CNTR = 0;
                    end
                end

                case (STATE2)
                0:  begin // beginning initialization
                    data_in_byte_index = 0;
                    format_data_len = 0;
                    STATE2 = 1;
                end
                1:  begin // check for the first dword type
                    if (data_type == 1) begin
                        format_data[15: 8] = 8'h77;
                        format_data[ 7: 0] = data_direction ? 8'h20 : 8'h10;
                        format_data_len = 2;
                    end
                    STATE2 = 2;
                end
                2:  begin // check for bytes of sata dword
                    if (data_in_byte == 8'h77) begin
                        format_data = format_data << 16;
                        format_data[15: 8] = 8'h77;
                        format_data[ 7: 0] = 8'h30;
                        format_data_len = format_data_len + 2;
                    end
                    else begin
                        format_data = format_data << 8;
                        format_data[ 7: 0] = data_in_byte;
                        format_data_len = format_data_len + 1;
                    end
                    
                    if (data_in_byte_index < 3) begin
                        data_in_byte_index = data_in_byte_index + 1;
                    end
                    else begin
                        STATE2 = 3;
                    end
                end
                3:  begin // check for the last dword type
                    if (data_type == 2) begin
                        format_data = format_data << 16;
                        format_data[15: 8] = 8'h77;
                        format_data[ 7: 0] = data_direction ? 8'h21 : 8'h11;
                        format_data_len = format_data_len + 2;
                    end
                    STATE2 = 4;
                end
                4:  begin // end of the formatting
                    tx_byte_index = format_data_len - 1;
                    STATE = 3;
                end
                5: begin // skip the dword
                    STATE = 0;
                end
                6: begin // replace the dword by 0x77 0x40
                    format_data[15: 8] = 8'h77;
                    format_data[ 7: 0] = 8'h40;
                    format_data_len = 2;
                    STATE2 = 4;
                end
                endcase

            end
            3:  begin 
                tx_start = 1; // Start first byte request
                if (~tx_busy) begin
                    STATE = 4;
                end
            end
            4:  begin
                if (tx_byte_index == 0) begin
                    STATE = 0;
                end
                else begin
                    tx_byte_index = tx_byte_index - 1; // Select next byte
                    STATE = 5; 
                end
            end
            5:  begin
                tx_start = 1; // Start next byte request
                if (~tx_busy) begin
                    STATE = 4; // get next byte in current dword
                end
            end
            endcase
        end
    end

endmodule
