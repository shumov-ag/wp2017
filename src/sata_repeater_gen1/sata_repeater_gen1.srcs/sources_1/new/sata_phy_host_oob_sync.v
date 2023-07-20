`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: #COMPANY#
// Engineer: a.shumov
// 
// Create Date: 08.12.2017 17:50:57
// Design Name: 
// Module Name: sata_phy_host_oob_sync
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


`define HOOB_SYNC_RESET             0
`define HOOB_TX_COMRESET_SEQ        1
`define HOOB_RX_COMINIT_WAIT        2
`define HOOB_RX_COMINIT_NEGATION    3
`define HOOB_TX_COMWAKE_SEQ         4
`define HOOB_RX_COMWAKE_WAIT        5
`define HOOB_RX_COMWAKE_NEGATION    6
`define HOOB_SYNC_FINISH            7


module sata_phy_host_oob_sync #(
    parameter RETRY_RESET_TIME = 0,
    parameter TX_COMRESET_SEQ_TIME = 192,
    parameter RX_COMINIT_WAIT_TIME = 7000_000, // Интервал периодической отправки сигнала COMRESET при отсутствии соединения
    parameter RX_COMINIT_NEGATION_TIME = 40,
    parameter TX_COMWAKE_SEQ_TIME = 96,
    parameter RX_COMWAKE_WAIT_TIME = 7000_000,
    parameter RX_COMWAKE_NEGATION_TIME = 14,
    
    parameter RX_IDLE_DTECT_TIME = 60000 // !!! Вынести алгоритм определения логического бездействия на уровень выше !!!
    ) (
    input wire      gt_rxclk_in,
    input wire      gt_rxcominit_in,
    input wire      gt_rxcomwake_in,
    input wire      gt_rxelecidle_in,
    input wire      reset_in,
    
    output reg      gt_txcomreset_out,
    output reg      gt_txcomwake_out,
    output reg      gt_txelecidle_out,
    output reg      sync_complete_out
    );


    reg gt_rxcominit_in2;
    reg gt_rxcomwake_in2;

    wire is_rxcominit_complete = !gt_rxcominit_in && gt_rxcominit_in2;
    wire is_rxcomwake_complete = !gt_rxcomwake_in && gt_rxcomwake_in2;

    always @(posedge gt_rxclk_in) begin
        gt_rxcominit_in2 <= gt_rxcominit_in;
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
            STATE = `HOOB_SYNC_RESET;
        end
        else if (CLR_TIMER == 0) begin
            case (STATE)
                `HOOB_SYNC_RESET: begin
                    STATE = `HOOB_TX_COMRESET_SEQ;
                    CLR_TIMER = 1'b1;
                end
                `HOOB_TX_COMRESET_SEQ: begin
                    if (TIMER > TX_COMRESET_SEQ_TIME) begin
                        STATE = `HOOB_RX_COMINIT_WAIT;
                        CLR_TIMER = 1'b1;
                    end
                end
                `HOOB_RX_COMINIT_WAIT: begin
                    if (TIMER > RX_COMINIT_WAIT_TIME) begin
                        STATE = `HOOB_SYNC_RESET;
                    end
                    else begin
                        if (is_rxcominit_complete) begin
                            STATE = `HOOB_RX_COMINIT_NEGATION;
                            CLR_TIMER = 1'b1;
                        end
                    end
                end
                `HOOB_RX_COMINIT_NEGATION: begin
                    if (TIMER > RX_COMINIT_NEGATION_TIME) begin
                        STATE = `HOOB_TX_COMWAKE_SEQ;
                        CLR_TIMER = 1'b1;
                    end
                end
                `HOOB_TX_COMWAKE_SEQ: begin
                    if (TIMER > TX_COMWAKE_SEQ_TIME) begin
                        STATE = `HOOB_RX_COMWAKE_WAIT;
                        CLR_TIMER = 1'b1;
                    end
                end
                `HOOB_RX_COMWAKE_WAIT: begin
                    if (TIMER > RX_COMWAKE_WAIT_TIME) begin
                        STATE = `HOOB_SYNC_RESET;
                    end
                    else begin
                        if (is_rxcomwake_complete) begin
                            STATE = `HOOB_RX_COMWAKE_NEGATION;
                            CLR_TIMER = 1'b1;
                        end
                    end
                end
                `HOOB_RX_COMWAKE_NEGATION: begin
                    if (TIMER > RX_COMWAKE_NEGATION_TIME) begin
                        STATE = `HOOB_SYNC_FINISH;
                    end
                end
                `HOOB_SYNC_FINISH: begin
                    if (gt_rxelecidle_in) begin
                        if (TIMER > RX_IDLE_DTECT_TIME) begin  // Lost link connection
                            STATE = `HOOB_SYNC_RESET;
                        end
                    end
                    else begin
                        CLR_TIMER = 1'b1;
                    end
                    
                    if (is_rxcominit_complete) begin // Если неожиданно поймали COMINIT
                        STATE = `HOOB_RX_COMINIT_NEGATION;
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
        sync_complete_out = (STATE == `HOOB_SYNC_FINISH);
        gt_txelecidle_out = !sync_complete_out;
        gt_txcomreset_out = (STATE == `HOOB_SYNC_RESET) || (STATE == `HOOB_TX_COMRESET_SEQ);
        gt_txcomwake_out = (STATE == `HOOB_TX_COMWAKE_SEQ);
    end

endmodule
