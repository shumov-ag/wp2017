`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: #COMPANY#
// Engineer: a.shumov
// 
// Create Date: 14.12.2017 17:36:23
// Design Name: 
// Module Name: sata_phy_device_oob_sync
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


`define DOOB_SYNC_RESET              0
`define DOOB_TX_COMINIT_SEQ          1
`define DOOB_RX_WAIT                 2
`define DOOB_RX_COMRESET_NEGATION    3
`define DOOB_RX_COMWAKE_NEGATION     4
`define DOOB_TX_COMWAKE_SEQ          5
`define DOOB_RX_IDLE_WAIT            6
`define DOOB_SYNC_FINISH             7


module sata_phy_device_oob_sync #(
    parameter RX_WAIT_TIME = 7500_000, // Интервал периодической отправки сигнала COMINIT при отсутствии соединения
    parameter TX_COMINIT_SEQ_TIME = 192,
    parameter COMRESET_NEGATION_TIME = 40,
    parameter TX_COMWAKE_SEQ_TIME = 96,
    parameter COMWAKE_NEGATION_TIME = 14,
    
    parameter RX_IDLE_DTECT_TIME = 60000 // !!! Вынести алгоритм определения логического бездействия на уровень выше !!!
    ) (
    input wire      gt_rxclk_in,
    input wire      gt_rxcomreset_in,
    input wire      gt_rxcomwake_in,
    input wire      gt_rxelecidle_in,
    input wire      reset_in,
    
    output reg      gt_txcominit_out,
    output reg      gt_txcomwake_out,
    output reg      gt_txelecidle_out,
    output reg      sync_complete_out
    );


    reg gt_rxcomreset_in2;
    reg gt_rxcomwake_in2;

    wire is_rxcomreset_complete = !gt_rxcomreset_in && gt_rxcomreset_in2;
    wire is_rxcomwake_complete = !gt_rxcomwake_in && gt_rxcomwake_in2;

    always @(posedge gt_rxclk_in) begin
        gt_rxcomreset_in2 <= gt_rxcomreset_in;
        gt_rxcomwake_in2 <= gt_rxcomwake_in;
    end


    reg init;
    reg reset;
    (* mark_debug = "true" *)reg [5:0] STATE;
    wire [31:0] TIMER;
    reg CLR_TIMER;
    
    COUNTERx32 COUNTERx32_i (
        .CLK(gt_rxclk_in),
        .SCLR(CLR_TIMER),
        .Q(TIMER)
    );

    always @(posedge gt_rxclk_in) begin // State machine logic ----------
        reset <= reset_in;
        if (reset || !init) begin
            init = 1'b1;
            STATE = `DOOB_SYNC_RESET;
        end
        else if (CLR_TIMER == 0) begin
            case (STATE)
                `DOOB_SYNC_RESET: begin
                    STATE = `DOOB_TX_COMINIT_SEQ;
                    CLR_TIMER = 1'b1;
                end
                `DOOB_TX_COMINIT_SEQ: begin
                    if (TIMER > TX_COMINIT_SEQ_TIME) begin
                        STATE = `DOOB_RX_WAIT;
                        CLR_TIMER = 1'b1;
                    end
                end
                `DOOB_RX_WAIT: begin
                    if (TIMER > RX_WAIT_TIME) begin
                        STATE = `DOOB_SYNC_RESET;
                    end
                    else begin
                        if (is_rxcomreset_complete) begin
                            STATE = `DOOB_RX_COMRESET_NEGATION;
                            CLR_TIMER = 1'b1;
                        end
                        else if (is_rxcomwake_complete) begin
                            STATE = `DOOB_RX_COMWAKE_NEGATION;
                            CLR_TIMER = 1'b1;
                        end
                    end
                end
                `DOOB_RX_COMRESET_NEGATION: begin
                    if (TIMER > COMRESET_NEGATION_TIME) begin
                        STATE = `DOOB_TX_COMINIT_SEQ;
                        CLR_TIMER = 1'b1;
                    end
                end
                `DOOB_RX_COMWAKE_NEGATION: begin
                    if (TIMER > COMWAKE_NEGATION_TIME) begin
                        STATE = `DOOB_TX_COMWAKE_SEQ;
                        CLR_TIMER = 1'b1;
                    end
                end
                `DOOB_TX_COMWAKE_SEQ: begin
                    if (TIMER > TX_COMWAKE_SEQ_TIME) begin
                        STATE = `DOOB_RX_IDLE_WAIT;
                        CLR_TIMER = 1'b1;
                    end
                end
                `DOOB_RX_IDLE_WAIT: begin
                    if (TIMER > RX_IDLE_DTECT_TIME) begin
                        STATE = `DOOB_SYNC_RESET;
                    end
                    else begin
                        if (!gt_rxelecidle_in) begin
                            STATE = `DOOB_SYNC_FINISH;
                        end
                    end
                end
                `DOOB_SYNC_FINISH: begin
                    if (gt_rxelecidle_in) begin
                        if (TIMER > RX_IDLE_DTECT_TIME) begin  // Lost link connection
                            STATE = `DOOB_SYNC_RESET;
                        end
                    end
                    else begin
                        CLR_TIMER = 1'b1;
                    end
                    
                    if (is_rxcomreset_complete) begin // Если неожиданно поймали COMRESET
                        STATE = `DOOB_RX_COMRESET_NEGATION;
                        CLR_TIMER = 1'b1;
                    end
                end
            endcase
        end
        else begin
            CLR_TIMER = 1'b0;
        end
    end


    always @(posedge gt_rxclk_in) begin // Generate output signals ----------
        sync_complete_out = (STATE == `DOOB_SYNC_FINISH);
        gt_txelecidle_out = !sync_complete_out;
        gt_txcominit_out = (STATE == `DOOB_TX_COMINIT_SEQ);
        gt_txcomwake_out = (STATE == `DOOB_TX_COMWAKE_SEQ);
    end

endmodule
