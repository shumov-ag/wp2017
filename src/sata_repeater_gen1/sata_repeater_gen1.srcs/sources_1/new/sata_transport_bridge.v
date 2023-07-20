`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: #COMPANY# 
// Engineer: a.shumov 
// 
// Create Date: 01.01.2018 10:46:38
// Design Name: 
// Module Name: sata_transport_bridge
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


module sata_transport_bridge(
    input  wire         host_rx_link_ready_in,
    input  wire         host_rx_clk_in,
    input  wire [35:0]  host_rx_stream_in,
    input  wire         host_rx_wr_en_in,
    output wire         host_rx_full_out,
    
    input  wire         host_tx_link_ready_in,
    input  wire         host_tx_clk_in,
    input  wire [35:0]  host_tx_stream_in,
    input  wire         host_tx_rd_en_in,
    output wire         host_tx_empty_out,
    
    input wire          device_rx_link_ready_in,
    input wire          device_rx_clk_in,
    input wire [35:0]   device_rx_stream_in,
    input wire          device_rx_wr_en_in,
    output wire         device_rx_full_out,
    
    input  wire         device_tx_link_ready_in,
    input  wire         device_tx_clk_in,
    input  wire [35:0]  device_tx_stream_in,
    input  wire         device_tx_rd_en_in,
    output wire         device_tx_empty_out,
    
    input  wire         clk25mhz_in,
    
    output wire         uart_tx_out
    );


    reg         ENABLE_LOGGER = `ENABLE_SATA_LOGGING;
    reg         logger_stop_rw;
    wire        int_rw_clk = device_tx_clk_in;/*clk25mhz;*/

    /* Внимание !!!  Когда rw_clk = clk25mhz, из host_in_fifo2 иногда вычитываются данные без стартового регистра.
    Возможно, это мусор. Но как он туда попадает?
    При rw_clk = clk25mhz повторитель работает ужасно.  */
    wire [35:0] htod_rw_data;
    wire        htod_r_empty;
    wire        htod_w_full;
    wire        htod_r_en = ~htod_r_empty & ~htod_w_full & ~logger_stop_rw;
    reg         htod_w_en;

    always @(posedge int_rw_clk) begin
        htod_w_en = htod_r_en;
    end

    /*FIFOx36_ASYNC host_in_fifo (
        .rst        (~host_rx_link_ready_in),
        .wr_clk     (host_rx_clk_in),
        .din        (host_rx_stream_in),
        .wr_en      (host_rx_wr_en_in & host_rx_link_ready_in),
        .prog_full  (host_rx_full_out),
        .full       ( ),
        
        .rd_clk     (device_tx_clk_in),
        .rd_en      (device_tx_rd_en_in & host_rx_link_ready_in),
        .dout       (device_tx_stream_in),
        .empty      (device_tx_empty_out)
    );*/
    FIFOx36_ASYNC host_in_fifo (
        .rst        (~host_rx_link_ready_in),
        .wr_clk     (host_rx_clk_in),
        .din        (host_rx_stream_in),
        .wr_en      (host_rx_wr_en_in & host_rx_link_ready_in),
        .prog_full  (host_rx_full_out),
        .full       ( ),
        
        .rd_clk     (int_rw_clk),
        .rd_en      (htod_r_en),
        .dout       (htod_rw_data),
        .empty      (htod_r_empty)
    );
    FIFOx36_ASYNC host_in_fifo2 (
        .rst        (~host_rx_link_ready_in),
        .wr_clk     (int_rw_clk),
        .din        (htod_rw_data),
        .wr_en      (htod_w_en),
        .prog_full  (htod_w_full),
        .full       ( ),
        
        .rd_clk     (device_tx_clk_in),
        .rd_en      (device_tx_rd_en_in & host_rx_link_ready_in),
        .dout       (device_tx_stream_in),
        .empty      (device_tx_empty_out)
    );




    wire [35:0] dtoh_rw_data;
    wire        dtoh_r_empty;
    wire        dtoh_w_full;
    wire        dtoh_r_en = ~dtoh_r_empty & ~dtoh_w_full & ~logger_stop_rw;
    reg         dtoh_w_en;

    always @(posedge int_rw_clk) begin
        dtoh_w_en = dtoh_r_en;
    end

    /*FIFOx36_ASYNC device_in_fifo (
        .rst        (~device_rx_link_ready_in),
        .wr_clk     (device_rx_clk_in),
        .din        (device_rx_stream_in),
        .wr_en      (device_rx_wr_en_in & device_rx_link_ready_in),
        .prog_full  (device_rx_full_out),
        .full       ( ),
        
        .rd_clk     (host_tx_clk_in),
        .rd_en      (host_tx_rd_en_in & device_rx_link_ready_in),
        .dout       (host_tx_stream_in),
        .empty      (host_tx_empty_out)
    );*/
    FIFOx36_ASYNC device_in_fifo (
        .rst        (~device_rx_link_ready_in),
        .wr_clk     (device_rx_clk_in),
        .din        (device_rx_stream_in),
        .wr_en      (device_rx_wr_en_in & device_rx_link_ready_in),
        .prog_full  (device_rx_full_out),
        .full       ( ),
        
        .rd_clk     (int_rw_clk),
        .rd_en      (dtoh_r_en),
        .dout       (dtoh_rw_data),
        .empty      (dtoh_r_empty)
    );
    FIFOx36_ASYNC device_in_fifo2 (
        .rst        (~device_rx_link_ready_in),
        .wr_clk     (int_rw_clk),
        .din        (dtoh_rw_data),
        .wr_en      (dtoh_w_en),
        .prog_full  (dtoh_w_full),
        .full       ( ),
        
        .rd_clk     (host_tx_clk_in),
        .rd_en      (host_tx_rd_en_in & device_rx_link_ready_in),
        .dout       (host_tx_stream_in),
        .empty      (host_tx_empty_out)
    );
    
    
    
    wire        log_w_full;
    wire [31:0] TIMER;
    reg         CLR_TIMER;
    COUNTERx32 COUNTERx32_i (
        .CLK(int_rw_clk),
        .SCLR(CLR_TIMER),
        .Q(TIMER)
    );
    
    always @(posedge int_rw_clk) begin
        if (log_w_full) begin
            logger_stop_rw = 1'b1;
            CLR_TIMER = 1'b1;
        end
        else begin
            CLR_TIMER = 1'b0;
            logger_stop_rw = TIMER < 512*1024 ? ENABLE_LOGGER : 1'b0;// Задержка на несколько циклов для уменьшения частоты чередования данных и примитива HOLD
        end
    end

    wire        log_rd_clk = int_rw_clk;
    wire        log_rd_rst = 0; // Отключить сброс FIFO для предотвращения потери логов
    wire        log_rx_empty;
    wire [35:0] log_rx_data;
    wire        log_rx_rd_en;

    FIFOx36_ASYNC fifo_log (
        .rst        (log_rd_rst),
        .wr_clk     (int_rw_clk),
        .din        (htod_w_en ? {1'b0, htod_rw_data[34:0]} : {1'b1, dtoh_rw_data[34:0]}),
        .wr_en      ((htod_w_en | dtoh_w_en) & ENABLE_LOGGER),
        .prog_full  (log_w_full),
        .full       ( ),
        
        .rd_clk     (log_rd_clk),
        .rd_en      (log_rx_rd_en),
        .dout       (log_rx_data),
        .empty      (log_rx_empty)
    );
    sata_logger2 #(
        .CLK_FREQ   (75000000),
        .UART_FREQ  (921600)   
    ) logger (
        .reset_in   (log_rd_rst),
        .clk_in     (log_rd_clk),
        .data_in    (log_rx_data),
        .empty_in   (log_rx_empty),
        .rd_en_out  (log_rx_rd_en),
        .uart_tx_out(uart_tx_out)
    );
    
endmodule
