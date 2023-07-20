`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: #COMPANY#
// Engineer: a.shumov 
// 
// Create Date: 24.12.2017 10:14:33
// Design Name: 
// Module Name: sata_link
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

// Link layer state machine states from Serial ATA Revision 3.0
// Link idle states
`define L_IDLE                      5//0
`define L_SyncEscape                1
`define L_NoCommErr                 2
`define L_NoComm                    3
`define L_SendAlign                 4
`define L_RESET                     0//5
// Link transmit states
`define HL_SendChkRdy               6
`define DL_SendChkRdy               7
`define L_SendSOF                   8
`define L_SendData                  9
`define L_RcvrHold                  10
`define L_SendHold                  11
//`define L_SendCRC                   12 !!! Attention !!! This state removed // Все работы с CRC осуществляются на вышестоящем (транспортном) уровне
`define L_SendEOF                   13
`define L_Wait                      14
// Link receive states
`define L_RcvChkRdy                 15
`define L_RcvWaitFifo               16
`define L_RcvData                   17
`define L_Hold                      18
`define L_RcvHold                   19
`define L_RcvEOF                    20
`define L_GoodCRC                   21
`define L_GoodEnd                   22
`define L_BadEnd                    23
// Link power mode states
`define L_TPMPartial                24
`define L_TPMSlumber                25
`define L_PMOff                     26
`define L_PMDeny                    27
`define L_ChkPhyRdy                 28
`define L_NoCommPower               29
`define L_WakeUp1                   30
`define L_WakeUp2                   31
`define L_NoPmnak                   32

// Advanced states
`define exHL_SendHandshake          33
`define exDL_SendHandshake          34


module sata_link #(
    parameter LINK_TYPE = "" // must be "HOST" or "DEVICE"
    ) (
    // common inputs
    input  wire         reset_in,
    input  wire         phy_ready_in,
    
    // common outputs
    output wire         ready_out,
    
    // lower layer inputs
    input  wire         phy_rxclk_in,
    input  wire         new_dword_in,
    input  wire [31:0]  dword_in,
    input  wire [3:0]   controls_in,
    
    // lower layer outputs
    input  wire         phy_txclk_in,
    output wire         new_dword_out,
    output wire [31:0]  dword_out,
    output wire [3:0]   controls_out,

    // upper layer inputs
    input  wire         txstream_fifo_empty_in,
    input  wire [35:0]  txstream_in,
    input  wire         rxstream_fifo_full_in,
    input  wire         ex_notify_x_rdy_in,
    input  wire         ex_notify_r_rdy_in,
    input  wire         ex_notify_dmat_in,
    input  wire         ex_notify_sync_in,
    input  wire         ex_notify_r_ok_in,
    input  wire         ex_notify_r_err_in,
    input  wire         ex_notify_phyrdy_in,

    // upper layer outputs
    output wire         rxstream_reset_out,
    output reg [35:0]   rxstream_out,
    output reg          rxstream_wr_en_out,
    output reg          txstream_rd_en_out,
    output wire         ex_notify_x_rdy_out,
    output wire         ex_notify_r_rdy_out,
    output wire         ex_notify_dmat_out,
    output wire         ex_notify_sync_out,
    output wire         ex_notify_r_ok_out,
    output wire         ex_notify_r_err_out
    );

    `include "sata_cmn.vh"


    wire [31:0] non_stable_primitives;
    
    sata_dword_to_primitive #(
        .ADV_CONT_REPLACE   ("TRUE"),
        .ADV_ALIGN_REPLACE  ("TRUE")
    ) sata_dword_to_primitive_i (
        .adv_clk_in         (phy_rxclk_in),
        .sata_dword_in      (dword_in),
        .sata_controls_in   (controls_in),

        .ALIGNp_out         (non_stable_primitives[0]),
        .SYNCp_out          (non_stable_primitives[1]),
        .CONTp_out          (non_stable_primitives[2]),
        .DMATp_out          (non_stable_primitives[3]),
        .EOFp_out           (non_stable_primitives[4]),
        .HOLDp_out          (non_stable_primitives[5]),
        .HOLDAp_out         (non_stable_primitives[6]),
        .PMACKp_out         (non_stable_primitives[7]),
        .PMNAKp_out         (non_stable_primitives[8]),
        .PMREQ_Pp_out       (non_stable_primitives[9]),
        .PMREQ_Sp_out       (non_stable_primitives[10]),
        .R_ERRp_out         (non_stable_primitives[11]),
        .R_IPp_out          (non_stable_primitives[12]),
        .R_OKp_out          (non_stable_primitives[13]),
        .R_RDYp_out         (non_stable_primitives[14]),
        .SOFp_out           (non_stable_primitives[15]),
        .WTRMp_out          (non_stable_primitives[16]),
        .X_RDYp_out         (non_stable_primitives[17])
    );


    assign ex_notify_x_rdy_out = non_stable_primitives[17];
    assign ex_notify_r_rdy_out = non_stable_primitives[14];
    assign ex_notify_dmat_out = non_stable_primitives[3];
    assign ex_notify_sync_out = non_stable_primitives[1];
    assign ex_notify_r_ok_out = non_stable_primitives[13];
    assign ex_notify_r_err_out = non_stable_primitives[11];
    
    
    /*Проверка входящего DWORDа на наличие в нем ошибок*/
    (* mark_debug = "true" *)wire DecErr;
    assign non_stable_primitives[18] = (~|dword_in[7:0] & controls_in[0]) | (~|dword_in[15:8] & controls_in[1]) | (~|dword_in[23:16] & controls_in[2]) | (~|dword_in[31:24] & controls_in[3]);

    /*Проверка входящего DWORDа на наличие в нем данных*/
    (* mark_debug = "true" *)wire DatDword;
    assign non_stable_primitives[19] = (~|non_stable_primitives[17:1]);// Анализируем все примитивы, кроме ALIGNp

    (* mark_debug = "true" *)wire ALIGNp;
    (* mark_debug = "true" *)wire SYNCp;
    (* mark_debug = "true" *)wire CONTp;
    (* mark_debug = "true" *)wire DMATp;
    (* mark_debug = "true" *)wire EOFp;
    (* mark_debug = "true" *)wire HOLDp;
    (* mark_debug = "true" *)wire HOLDAp;
    (* mark_debug = "true" *)wire PMACKp;
    (* mark_debug = "true" *)wire PMNAKp;
    (* mark_debug = "true" *)wire PMREQ_Pp;
    (* mark_debug = "true" *)wire PMREQ_Sp;
    (* mark_debug = "true" *)wire R_ERRp;
    (* mark_debug = "true" *)wire R_IPp;
    (* mark_debug = "true" *)wire R_OKp;
    (* mark_debug = "true" *)wire R_RDYp;
    (* mark_debug = "true" *)wire SOFp;
    (* mark_debug = "true" *)wire WTRMp;
    (* mark_debug = "true" *)wire X_RDYp;

    bits_stabilization_x32 bits_stabilization_x32_i (
        .inclk_in           (phy_rxclk_in),
        .outclk_in          (phy_txclk_in),
        
        .bits               (non_stable_primitives),
        
        /*
            Предупреждение !!!
            Теоретически возможна ситуация, при которой может быть пропущен один из одиночных примитивов (SOF, EOF, ...).
            Причина подобного явления описана в разделе "Physical Layer. Clock Compensation" книги "Sata Storage Technology" 
            [Don Anderson. ISBN-13:978-0-9770878-1-5. ISBN-10:0-9770878-1-6].
            Из за возможной (и допустимой по стандарту) разницы частот phy_rxclk_in и phy_txclk_in, на каждые 175 тактов
            phy_txclk_in может приходиться только 174 такта phy_rxclk_in. Таким образом, входящий DWORD может быть по времени
            короче исходящего DWORD'а на 32/175 такта (т.е. на 0.57%). Т.е. входящий DWORD может целиком уместиться между
            начальным и конечным тактами исходящего DWORD'a и не будет зафиксирован логикой формирования исходящих DWORD'ов.
            Эта проблема касается только примитивов, состоящих из одного DWORD'а.
            
            Возможные решения проблемы:
                1. Запоминать все активные состояния сигналов, отвечающих за индикацию одиночных примитивов каждый такт (1/2 DWORD'a) и 
                    отрабатывать их на следующем такте. Но возникает проблема обработки двух последовательно идущих одиночных примитивов,
                    приводящая к растягиванию промежуточного буфера. Однако, примитивы SOF, EOF и DMAT, согласно протоколу, не могут идти 
                    друг рядом с другом. Иначе, Link Layer обрабатывает эту ситуацию как ошибочную. Поверхностный анализ алгоритма работы 
                    конечного автомата показал, что пропуск такого лишнего примитива приведет конечный автомат в то же ошибочное состояние,
                    что и его наличие. Если закладываться на такое поведение, то достаточно иметь буфер размером 1 DWORD.
                    Минусы этого подхода:   - Общая задержка на 1 DWORD
                                            - Надежда на прогнозируемое поведение сторонних девайсов (Существенный минус)
                                            - Мудреность реализации
                2. Ввести FIFO для перевода примитивов из одного тактового домена в другой. Это, в лучшем случае, даст задержку в 2-3 DWORD'а.
                    Поэтому необходим механизм быстрой доставки примитива HOLD параллельно потоку данных через FIFO.
                    Этот механизм довольно прост и способен избавить от задержки FIFO. Примитив HOLD будет приходить на несколько тактов
                    раньше и идти параллельно примитиву R_IP. Но и уходить он будет на несколько тактов раньше, но в этом случае, можно продолжить
                    принимать примив HOLD из FIFO и плавно перейти к приему других примитивов.
                    Минусы этого подхода:   - Задержка потока примитивов на 2-3 DWORD'а
                                            - Нерациональное использование аппаратной FIFO размером 512 WORD'ов для хранения 2-3 DWORD'ов 
                    Плюсы этого подхода:    - Простота реализации
                                            - Отсутствие задержек для примитива HOLD
               *3. Примитивы, не требующие срочной генерации ответного примитива, можно обрабатывать каждый такт, меняя состояние конечного автомата.
                    А результирующий выходной примитив можно продолжать генерировать каждые 2 такта, но не на основании входящих данных а на основании
                    состояния коечного автомата.
                    - Прием единичного примитива SOF, EOF, DMAT приводит не к генерации какого-либо ответного примитива, а к переключению
                    конечного автомата из одного состояния в другое.
                    - Прием единичного примитива CONT никак не отражается на исходящем потоке данных, т.к. он обрарабывается
                    только во входящем потоке (с собственной скоростью входящего потока)
                    - Остальные примитивы единичными не являются и всегда отправляются потоком.
                    Минусы этого подхода:   - Мудреность реализации
                    Плюсы этого подхода:    - Отсутствие задержек для потока примитивов
                                            - Хорошо вписывается в общую концепцию реализации конечного автомата
                                            
                                            
            !!! Предупреждение !!!
            Теоретически возможна и обратная ситуация. Когда входящий поток данных немного медленнее исходящего, то входящий DWRORD может
            "растянуться" на два цикла. Это может привести к дублированию одиночных примитивов.
            Как показал поверхностный анализ алгоритма работы конечного автомата, дублирование примитивов SOF, EOF, DMAT никак не
            отразится на его работе.
        */
        .stable_bits        ({  DatDword,
                                DecErr,
                                X_RDYp,
                                WTRMp,
                                SOFp,
                                R_RDYp,
                                R_OKp,
                                R_IPp,
                                R_ERRp,
                                PMREQ_Sp,
                                PMREQ_Pp,
                                PMNAKp,
                                PMACKp,
                                HOLDAp,
                                HOLDp,
                                EOFp,
                                DMATp,
                                CONTp,
                                SYNCp,
                                ALIGNp
                            })
    );


    (* mark_debug = "true" *)reg is_new_dword;

    always @(posedge phy_txclk_in) begin
        is_new_dword = !is_new_dword;
    end

    /*
        Уведомление о приеме соответствующего примитива на другой стороне устройства
    */
    reg exTL_NOTIFY_X_RDYp; // Transport layer notify about X_RDYp from another side
    reg exTL_NOTIFY_R_RDYp; // Transport layer notify about R_RDYp from another side
    reg exTL_NOTIFY_DMATp; // Transport layer notify about DMATp from another side
    reg exTL_NOTIFY_SYNCp; // Transport layer notify about SYNCp from another side
    reg exTL_NOTIFY_R_OKp; // Transport layer notify about R_OKp from another side
    reg exTL_NOTIFY_R_ERRp; // Transport layer notify about R_ERRp from another side
    reg exTL_NOTIFY_PHYRDYn; // Transport layer notify about a PHY error from another side
    

    (* mark_debug = "true" *)reg  [31:0] OUT_DWORD;
    (* mark_debug = "true" *)reg  [3:0]  OUT_CONTROLS;

    (* mark_debug = "true" *)wire TL_SEND_FRAME_REQ = ~txstream_fifo_empty_in & (txstream_in[35:32] == 4'h1); // Transport layer request frame transmission
    wire TL_TO_PARTIAL_REQ = 0; // Transport layer request transition to Partial
    wire TL_TO_SLUMBER_REQ = 0; // Transport layer request transition to Slumber

    wire TL_POWER_MODES_ENABLED = 0;   // Флаг наличия возможности перехода в спящий режим
    wire TL_POWER_MODES_CHECKED = 1;   // Флаг завершения проверки возможности перехода в спящий режим
    reg  TL_POWER_MODES_CHECK_PARTIAL;  // Команда проверки возможности перехода в режим PARTIAL
    reg  TL_POWER_MODES_CHECK_SLUMBER;  // Команда проверки возможности перехода в режим SLUMBER
    
    (* mark_debug = "true" *)wire [31:0] TL_TX_DATA_IN = txstream_in[31:0];
    (* mark_debug = "true" *)wire        TL_TX_DATA_MORE = ~txstream_fifo_empty_in;       // More data to transmit
    wire        TL_TX_DATA_ABORT = exTL_NOTIFY_SYNCp;       // Request to escape current frame
    (* mark_debug = "true" *)wire        TL_TX_DATA_COMPLETE = (txstream_in[35:32] == 4'h2);    // Data were fully transmitted
    (* mark_debug = "true" *)wire        TL_TX_DATA_READ_EN = txstream_rd_en_out;

    reg         TL_RX_DATA_SPACE_AVL;   // FIFO space available
    wire        TL_RX_DATA_ABORT = exTL_NOTIFY_SYNCp;       // Request to escape current frame
    wire        TL_RX_DATA_CRC_GOOD = 1;    // Request frame CRC is good
    wire        TL_RX_DATA_CRC_BAD = 0;     // Request frame CRC is bad
    wire        TL_RX_DATA_GOOD_RESULT = exTL_NOTIFY_R_OKp; // Request frame is good
    wire        TL_RX_DATA_BAD_RESULT = exTL_NOTIFY_R_ERRp;  // Request frame is bad


    reg TL_RX_DMAT_OUT_REQ = 0; // Сигнал на TL о приеме примитива DMAT 
    reg TL_TX_DMAT_IN_REQ = 0;  // Сигнал с TL о необходимости отправить единичный примитив DMAT (по переднему фронту)

    reg  [7:0] OUT_DWORD_IDX;    // Счетчик выходных слов с периодом обнуления = 256
    reg FORCE_OUT_ALIGN; // Флаг форсированного вывода пары примитивов ALIGNp через каждые 256 DWORD'ов
    (* mark_debug = "true" *)reg OUT_DWORD_ENABLE;   // Флаг разрешения вывода в выходной поток нового DWORD'а

    (* mark_debug = "true" *)reg PHYRDY;
    reg LRESET; 
    (* mark_debug = "true" *)reg [5:0] SMSTATE; // Current state machine state 
    (* mark_debug = "true" *)reg [5:0] SOFCTR;
    (* mark_debug = "true" *)reg [15:0] DWCNT;
    (* mark_debug = "true" *)reg DBG_REG1;
    reg [15:0] DBG_CNT1;


    wire [31:0] input_scrambler_sequence;
    wire        input_scrambler_reset;
    wire        input_scrambler_update;
    wire [31:0] output_scrambler_sequence;
    wire        output_scrambler_reset;
    wire        output_scrambler_update;

  always @(posedge phy_txclk_in) begin
        /*
            !!! Внимание !!!
            Необходимо учитывать механизм генерации выходного DWORD'а.
            OUT_DWORD способен генерироваться каждый цикл, но в выходной поток попадет только тот OUT_DWORD, 
            который сгенерирован при условии "if (OUT_DWORD_ENABLE)". Поэтому, при генерировании единичного DWORD'а 
            необходимо дожидаться выставления флага OUT_DWORD_ENABLE, и только затем переходить к следующей итерации.
        */

        /*
            !!! Attention !!!
            Need to add watchdog timer for a change the state machine state.
            If the state machine sets in the one state very long time, need to reset it's state to L_SyncEscape.
        */

        /*Стабизизация сигналов из других тактовых доменов. Предотвращает переход конечного автомата в неопределенное состояние*/
        if (1) begin
            PHYRDY <= phy_ready_in;
            LRESET <= reset_in;
            TL_RX_DATA_SPACE_AVL <= ~rxstream_fifo_full_in;   // FIFO space available
            
            exTL_NOTIFY_X_RDYp <= ex_notify_x_rdy_in & ex_notify_phyrdy_in; // Transport layer notify about X_RDYp from another side
            exTL_NOTIFY_R_RDYp <= ex_notify_r_rdy_in & ex_notify_phyrdy_in; // Transport layer notify about R_RDYp from another side
            exTL_NOTIFY_DMATp <= ex_notify_dmat_in & ex_notify_phyrdy_in; // Transport layer notify about DMATp from another side
            exTL_NOTIFY_SYNCp <= ex_notify_sync_in & ex_notify_phyrdy_in; // Transport layer notify about SYNCp from another side
            exTL_NOTIFY_R_OKp <= ex_notify_r_ok_in & ex_notify_phyrdy_in; // Transport layer notify about R_OKp from another side
            exTL_NOTIFY_R_ERRp <= ex_notify_r_err_in & ex_notify_phyrdy_in; // Transport layer notify about R_ERRp from another side
            exTL_NOTIFY_PHYRDYn <= ~ex_notify_phyrdy_in; // Transport layer notify about a PHY error from another side
        end

        /*The output dwords counter increment*/
        if (is_new_dword) begin
            OUT_DWORD_IDX = OUT_DWORD_IDX + 1;
        end

        if (1) begin
            FORCE_OUT_ALIGN = (OUT_DWORD_IDX == 2) || (OUT_DWORD_IDX == 3); // Флаг форсированного вывода пары примитивов ALIGNp через каждые 256 DWORD'ов
            OUT_DWORD_ENABLE = is_new_dword && !FORCE_OUT_ALIGN;   // Флаг разрешения вывода в выходной поток нового DWORD'а
        end
        
        /*The asyncronous enter to the reset state*/
        if (LRESET) begin
            SMSTATE = `L_RESET;
        end

        /*Асинхронный сброс запросов на проверку возможности перехода в спящий режим*/            
        if (1) begin
            TL_POWER_MODES_CHECK_PARTIAL = 1'b0;
            TL_POWER_MODES_CHECK_SLUMBER = 1'b0;
        end
        
        if (1) begin
            txstream_rd_en_out = 1'b0; // Автоматический сброс флага, разрешающего обновление данных на выходе FIFO. Время жизни этого флага = 1 такт.
        end
        
        if (DatDword & OUT_DWORD_ENABLE) begin
            DWCNT = DWCNT + 1;
        end
        else if (X_RDYp) begin
            DWCNT = 0;
        end
        
        if (!PHYRDY) begin
            SOFCTR = 0;
        end
        
        DBG_REG1 = 0;
       
        /*The SATA link layer state machine*/        
        case (SMSTATE)
        
            `L_IDLE: begin 
                /*This state is entered when a frame transmission has been completed by the Link layer.
                When in this state, the Link layer transmits SYNC P and waits for X_RDY P from the Phy layer or a
                frame transmission request from the Transport layer.*/
                OUT_DWORD = `D_SYNCp; OUT_CONTROLS = 4'b0001;


                /*!!! ATTENTION !!! Обновить выход FIFO, если в нем есть данные, не являющиеся началом фрейма*/
                if (TL_TX_DATA_MORE & ~TL_SEND_FRAME_REQ & OUT_DWORD_ENABLE) begin
                    txstream_rd_en_out <= 1'b1;
                end


                if (PHYRDY) begin
                    if (exTL_NOTIFY_X_RDYp) begin
                        if (LINK_TYPE == "HOST") begin
                            /*Если host-стороной получено уведомление о приеме X_RDYp на другой стороне устройства,
                            выполнить переход в состояние exHL_SendHandshake */
                            SMSTATE = `exHL_SendHandshake;
                        end
                        else begin
                            /*Если device-стороной получено уведомление о приеме X_RDYp надругой стороне устройства,
                            выполнить переход в состояние exDL_SendHandshake */
                            SMSTATE = `exDL_SendHandshake;
                            DBG_CNT1 = 0;
                        end
                    end
                    else if (TL_SEND_FRAME_REQ) begin
                        if (LINK_TYPE == "HOST") begin
                            /*When the host Link layer receives a request to transmit a frame from the
                            Transport layer and the Phy layer is ready, the Link layer shall make a transition to the LT1:
                            HL_SendChkRdy state.*/
                            SMSTATE = `HL_SendChkRdy;
                        end
                        else begin
                            /*When the device Link layer receives a request to transmit a frame from the
                            Transport layer and the Phy layer is ready, the Link layer shall make a transition to the LT2:
                            DL_SendChkRdy state.*/
                            SMSTATE = `DL_SendChkRdy;
                        end
                    end
                    else if (TL_TO_PARTIAL_REQ) begin
                        /*When the Link layer receives a request to enter the Partial power mode from
                        the Transport layer and the Phy layer is ready, the Link layer shall make a transition to the
                        L_TPMPartial state.*/
                        SMSTATE = `L_TPMPartial;
                    end
                    else if (TL_TO_SLUMBER_REQ) begin
                        /*When the Link layer receives a request to enter the Slumber power mode from
                        the Transport layer and the Phy layer is ready, the Link layer shall make a transition to the
                        L_TPMSlumber state.*/
                        SMSTATE = `L_TPMSlumber;
                    end
                    else if (X_RDYp) begin
                        /*When the Link layer receives an X_RDY P from the Phy layer, the Link layer
                        shall make a transition to the LR2: L_RcvWaitFifo state.*/
                        SMSTATE = `L_RcvWaitFifo;
                        SOFCTR = SOFCTR + 1;
                    end
                    else if (PMREQ_Pp | PMREQ_Sp) begin
                        if (TL_POWER_MODES_CHECKED) begin // Завершена проверка возможности перехода в спящий режим
                            if (TL_POWER_MODES_ENABLED) begin
                                /*When the Link layer receives a PMREQ_P P or PMREQ_S P from the Phy
                                layer,is enabled to perform power management modes, and in a state to accept power mode
                                requests, the Link layer shall make a transition to the LPM3: L_PMOff state.*/
                                SMSTATE = `L_PMOff;
                            end
                            else begin
                                /*When the Link layer receives a PMREQ_P P or a PMREQ_S P from the Phy layer
                                and is not enabled to perform power management modes or is not in a state to accept power
                                mode requests, the Link layer shall make a transition to the LR0: L_PMDeny state. This
                                transition is still valid if interface power states are supported and enabled as verified by Word 76
                                bit 9 set to one in IDENTIFY (PACKET) DEVICE data.*/
                                SMSTATE = `L_PMDeny;
                            end
                        end
                        else begin
                            /*Отправка запросов на проверку возможности перехода в спящий режим*/
                            TL_POWER_MODES_CHECK_PARTIAL = PMREQ_Pp;
                            TL_POWER_MODES_CHECK_SLUMBER = PMREQ_Sp;
                        end
                    end
                    else begin
                        /*When the Link layer does not receive a request to transmit a frame from the
                        Transport layer, does not receive a request to go to a power mode from the Transport layer, does
                        not receive an X_RDY P from the Phy layer or does not receive a PMREQ_x from the Phy layer
                        the Link layer shall make a transition to the L1: L_IDLE state.*/
                        SMSTATE = `L_IDLE;
                    end
                end
                else begin
                    /*If the Phy layer becomes not ready even if the Transport layer is requesting an
                    operation, the Link layer transitions to the L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end 
            end
            
            `L_SyncEscape: begin
                /*This state is entered when the Link layer transmits SYNC P to
                escape a FIS transmission. The Link layer may choose to escape a FIS transmission due to a
                request from the Transport layer or due to an invalid state transition. This state is only entered by
                the initiator of the SYNC Escape.
                When in this state, the Link layer transmits SYNC P and waits for a SYNC P from the Phy layer
                before proceeding to L_IDLE. The Link layer also transitions to L_IDLE if X_RDY P is received in
                order to avoid a deadlock condition.*/
                OUT_DWORD = `D_SYNCp; OUT_CONTROLS = 4'b0001;
                
                if (PHYRDY) begin
                    if (X_RDYp | SYNCp) begin
                        /*When the Link layer receives X_RDY P or SYNC P from the Phy, the Link layer
                        shall make a transition to the L1: L_IDLE state.*/
                        SMSTATE = `L_IDLE;
                    end
                    else begin
                        /*When the Link layer receives any Dword from the Phy that is not X_RDY P or
                        SYNC P , the Link layer shall make a transition to the L2: L_SyncEscape state.*/
                        SMSTATE = `L_SyncEscape;
                    end
                end
                else begin
                    /*When the host Link layer detects that the Phy layer is not ready the Link layer
                    shall notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr
                    state.*/
                    SMSTATE = `L_NoCommErr;
                end 
            end
            
            `L_NoCommErr: begin 
                /*This state is entered upon detection of a non ready condition of
                the Phy layer while attempting to process another state. The entry into this state heralds a
                relatively serious error condition in the Link layer. This state is executed only once so as to pass
                on the error condition up to the Transport layer.*/
                if (1) begin
                    /*The transition is made to LS1:L_NoComm unconditionally.*/
                    SMSTATE = `L_NoComm;
                end
            end
            
            `L_NoComm: begin
                /*This state is entered directly from the LS1:L_NoCommErr state or
                the LS4:L_RESET State. The Link layer remains in this state until the Phy signals that it has
                established communications and is ready.*/
                //OUT_DWORD = `D_ALIGNp; OUT_CONTROLS = 4'b0001;
                /*                                              *\
                    !!! Attention !!! The logic is changed !!!
                \*                                              */
                OUT_DWORD = `D_SYNCp; OUT_CONTROLS = 4'b0001;
                
                if (!PHYRDY) begin
                    /*For as long as the Phy layer stays not ready, the transition is made to LS2: L_NoComm.*/
                    SMSTATE = `L_NoComm;
                end
                else begin
                    /*When the Phy layer signals it is ready, a transition is made to LS3: L_SendAlign.*/
                    SMSTATE = `L_SendAlign;
                end 
            end
            
            `L_SendAlign: begin
                /*This state is entered whenever an ALIGN P needs to be sent to the Phy layer.*/
                //OUT_DWORD = `D_ALIGNp; OUT_CONTROLS = 4'b0001;
                /*                                              *\
                    !!! Attention !!! The logic is changed !!!
                \*                                              */
                OUT_DWORD = `D_SYNCp; OUT_CONTROLS = 4'b0001;
                OUT_DWORD_IDX = 0;
                
                if (!PHYRDY) begin
                    /*If the Phy layer becomes not ready, then a transition is made to LS1: L_NoCommErr.*/
                    SMSTATE = `L_NoCommErr;
                end
                else begin
                    /*If the Phy layer indicates that it is ready, a transition is made to the L1: L_IDLE state.*/
                    SMSTATE = `L_IDLE;
                end
            end
            
            `L_RESET: begin
                /*This state is entered whenever the Link LRESET control is active. All Link layer hardware is 
                initialized to and held at a known state/value. While in this state all requests or triggers 
                from other layers are ignored. While in this state, the Phy reset signal is also asserted.*/
                if (LRESET) begin
                    /*While the RESET control is active a transition is made back to the LS4: L_RESET state.*/
                    SMSTATE = `L_RESET;
                end
                else begin
                    /*When the RESET control goes inactive a transition is made to the LS2: L_NoComm state.*/
                    SMSTATE = `L_NoComm;
                end 
            end
            
            `HL_SendChkRdy: begin
                /*This state is entered when a frame transmission has been
                requested by the host Transport layer.
                When in this state, the Link layer transmits X_RDY P and waits for X_RDY P or R_RDY P from the
                Phy layer.*/
                OUT_DWORD = `D_X_RDYp; OUT_CONTROLS = 4'b0001;
                
                if (PHYRDY) begin
                    if (R_RDYp) begin
                        /*When the host Link layer receives R_RDY P from the Phy layer, the Link layer
                        shall make a transition to the LT3: L_SendSOF state.*/
                        SMSTATE = `L_SendSOF;
                    end
                    else if (X_RDYp) begin
                        /*When the host Link layer receives X_RDY P from the Phy layer, the Link layer
                        shall make a transition to the LR2: L_RcvWaitFifo state.*/
                        SMSTATE = `L_RcvWaitFifo;
                    end
                    else begin
                        /*When the host Link layer receives any Dword other than R_RDY P or X_RDY P
                        from the Phy layer, the Link layer shall make a transition to the LT1: HL_SendChkRdy state.*/
                        SMSTATE = `HL_SendChkRdy;
                    end
                end
                else begin
                    /*When the host Link layer detects that the Phy layer is not ready the Link layer shall notify 
                    the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end
            end
            
            `DL_SendChkRdy: begin
                /*This state is entered when a frame transmission has been requested by the device Transport layer.
                When in this state, the Link layer transmits X_RDY P and waits for R_RDY P from the Phy layer.*/
                OUT_DWORD = `D_X_RDYp; OUT_CONTROLS = 4'b0001;
                
                if (PHYRDY) begin
                    if (R_RDYp) begin
                        /*When the device Link layer receives R_RDY P from the Phy layer, the Link
                        layer shall make a transition to the LT3: L_SendSOF state.*/
                        SMSTATE = `L_SendSOF;
                    end
                    else begin
                        /*When the device Link layer does not receive R_RDY P from the Phy layer, the
                        Link layer shall make a transition to the LT2: DL_SendChkRdy state.*/
                        SMSTATE = `DL_SendChkRdy;
                    end
                end
                else begin
                    /*When the device Link layer detects that the Phy layer is not ready the Link layer shall notify 
                    the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end 
            end
            
            `L_SendSOF: begin 
                /*This state is entered when R_RDY P has been received from the Phy layer.
                When in this state, the Link layer transmits SOF P .*/
                OUT_DWORD = `D_SOFp; OUT_CONTROLS = 4'b0001;
                
                if (PHYRDY) begin
                    if (SYNCp) begin
                        /*When the Link layer receives SYNC P from the Phy layer, the Link layer shall notify the Transport 
                        layer of the illegal transition error condition and shall make a transition to the L1:L_IDLE state.*/
                        SMSTATE = `L_IDLE;
                    end
                    else begin
                        /*When the device Link layer has transmitted SOF P , the Link layer shall make a
                        transition to the LT4: L_SendDATA state.*/
                        if (OUT_DWORD_ENABLE) begin// Дополнительное условие: Если сгенерированный DWORD будет помещен в выходной поток
                            SMSTATE = `L_SendData;
                        end
                    end
                end
                else begin
                    /*When the Link layer detects that the Phy layer is not ready the Link layer shall
                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end
            end

            `L_SendData: begin
                OUT_DWORD = TL_TX_DATA_IN ^ output_scrambler_sequence; OUT_CONTROLS = 4'b0000;
                
                /*
                    !!! Внимаение !!! Если произошел переход в это состояние, значит в TL_TX_DATA_IN уже находятся данные на отправку
                    и их необходимо отправить перед выполнением других действий.
                */
                
                if (PHYRDY) begin
                    if (TL_TX_DATA_ABORT) begin
                        SMSTATE = `L_SyncEscape;
                    end
                    else begin
                        if (SYNCp) begin
                            SMSTATE = `L_IDLE;
                        end
                        else if (TL_TX_DATA_COMPLETE | DMATp) begin
                            //SMSTATE = `L_SendCRC;
                            /*                                              *\
                                !!! Attention !!! The logic was changed !!!
                            \*                                              */
                            if (~DMATp) begin
                                if (OUT_DWORD_ENABLE) begin// Дополнительное условие: Если сгенерированный DWORD будет помещен в выходной поток
                                    SMSTATE = `L_SendEOF;
                                end
                            end
                            else begin
                                SMSTATE = `L_SendData;
                            end
                        end
                        else if (~TL_TX_DATA_MORE) begin
                            if (OUT_DWORD_ENABLE) begin// Дополнительное условие: Если сгенерированный DWORD будет помещен в выходной поток
                                SMSTATE = `L_SendHold;
                            end
                        end
                        else if (HOLDp) begin
                            if (OUT_DWORD_ENABLE) begin// Дополнительное условие: Если сгенерированный DWORD будет помещен в выходной поток
                                SMSTATE = `L_RcvrHold;
                                txstream_rd_en_out = 1'b1;//Обновить выход FIFO
                                /*                                                                              *\
                                    !!! Внимание !!! после этого действия флаг TL_TX_DATA_MORE может
                                    сброситься, однако, на выходе FIFO все еще будет лежать неотправленный DWORD.
                                    Это необходимо учитывать в состоянии L_RcvrHold
                                \*                                                                              */
                            end
                        end
                        else begin
                            if (OUT_DWORD_ENABLE) begin// Дополнительное условие: Если сгенерированный DWORD будет помещен в выходной поток
                                SMSTATE = `L_SendData;
                                txstream_rd_en_out = 1'b1;//Обновить выход FIFO
                            end
                        end
                    end
                end
                else begin
                    SMSTATE = `L_NoCommErr;
                end           end

            `L_RcvrHold: begin
                /*This state is entered when HOLD P has been received from the Phy layer.
                When in this state, the Link layer shall transmit HOLDA P .*/
                OUT_DWORD = `D_HOLDAp; OUT_CONTROLS = 4'b0001;

                if (PHYRDY) begin
                    if (TL_TX_DATA_ABORT/* | ~TL_TX_DATA_MORE*/) begin
                        /*When the Link layer receives notification from the Transport layer that the
                        current frame should be escaped, a transition to the L_SyncEscape state shall be made.*/
                        SMSTATE = `L_SyncEscape;
                        
                        /*                                                                                      *\
                            !!! Внимание !!! Закомментированное условие (~TL_TX_DATA_MORE) никогда не должно 
                            выполняться, т.к. для перехода на этот шаг необходимо выполнение обратного условия.
                            Тем не менее, флаг TL_TX_DATA_MORE может быть сброшен, однако на выходе FIFO 
                            все еще будет лежать неотправленный DWORD.
                        \*                                                                                      */
                    end
                    else begin
                        if (HOLDp | DecErr) begin
                            /*When the device Link layer receives HOLD P from the Phy layer or a decoding
                            error was detected, the Link layer shall make a transition to the LT5: L_RcvrHold state.*/
                            SMSTATE = `L_RcvrHold;
                        end
                        else if (SYNCp) begin
                            /*When the Link layer receives SYNC P from the Phy layer, the Link layer shall
                            make a transition to the L1: L_IDLE state. The Transport layer shall be notified of the illegal
                            transition error condition.*/
                            SMSTATE = `L_IDLE;
                        end
                        else if (DMATp) begin
                            /*When the Link layer receives DMAT P from the Phy layer, it shall notify the
                            Transport layer and terminate the transmission in progress as described in section 9.4.4 and shall
                            transition to the LT7: L_SendCRC state.*/
                            //SMSTATE = `L_SendCRC;
                            /*                                              *\
                                !!! Attention !!! The logic was changed !!!
                            \*                                              */
                            SMSTATE = `L_RcvrHold;
                        end
                        else begin
                            /*When the Link layer receives any Dword other than a HOLD P , SYNC P , or a
                            DMAT P primitive from the Phy layer with no decoding error detected, and the Transport layer
                            indicates that a Dword is available for transfer, the Link layer shall make a transition to the LT4:
                            L_SendData state.*/
                            //SMSTATE = `L_SendData;
                                                        
                            /* !!! Attention !!! The logic was changed
                                Следующее условие необходимо для того, чтобы перейти в состояние SendData в начале цикла
                            */
                            if (OUT_DWORD_ENABLE) begin// Дополнительное условие: Если сгенерированный DWORD будет помещен в выходной поток
                                SMSTATE = `L_SendData;
                            end
                        end                            
                    end
                end
                else begin
                    /*When the Link layer detects that the Phy layer is not ready the Link layer shall
                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end 
            end

            `L_SendHold: begin
                /*This state is entered when the Transport layer indicates a Dword
                is not available for transfer and HOLD P has not been received from the Phy layer.
                When in this state, the Link layer shall transmit HOLD P .*/
                OUT_DWORD = `D_HOLDp; OUT_CONTROLS = 4'b0001;
            
                if (PHYRDY) begin
                    if (TL_TX_DATA_ABORT) begin
                        /*When the Link layer receives notification from the Transport layer that the
                        current frame should be escaped, a transition to the L_SyncEscape state shall be made.*/
                        SMSTATE = `L_SyncEscape;
                    end
                    else begin
                        if (SYNCp) begin
                            /*When the Link layer receives SYNC P from the Phy layer, the Link layer shall
                            make a transition to the L1: L_IDLE state. The Transport layer shall be notified of the illegal
                            transition error condition.*/
                            SMSTATE = `L_IDLE;
                        end
                        else if (TL_TX_DATA_MORE & ~HOLDp) begin
                            /*When the Link layer receives any Dword other than a HOLD P or SYNC P
                            primitive from the Phy layer and the Transport layer indicates that a Dword is available for
                            transfer, the Link layer shall make a transition to the LT4: L_SendData state.*/
                            //SMSTATE = `L_SendData;
                            
                            /* !!! Attention !!! The logic was changed
                                Следующее условие необходимо для того, чтобы перейти в состояние SendData в начале цикла
                                И чтобы подать на выход fifo только что появившиеся данные
                            */
                            if (OUT_DWORD_ENABLE) begin// Дополнительное условие: Если сгенерированный DWORD будет помещен в выходной поток
                                SMSTATE = `L_SendData;
                                txstream_rd_en_out = 1'b1;//Обновить выход FIFO
                            end
                        end
                        else if (TL_TX_DATA_MORE & HOLDp) begin
                            /*When the Link layer receives HOLD P from the Phy layer and the Transport layer indicates 
                            a Dword is available for transfer, the Link layer shall make a transition to the LT5: L_RcvrHold state.*/
                            SMSTATE = `L_RcvrHold;

                            /* !!! Attention !!! The logic was changed
                                Следующее действие необходимо, чтобы выдать на выход FIFO только что появившиеся данные
                            */                            
                            txstream_rd_en_out = 1'b1;//Обновить выход FIFO
                            /*                                                                              *\
                                !!! Внимание !!! после этого действия флаг TL_TX_DATA_MORE может
                                сброситься, однако, на выходе FIFO все еще будет лежать неотправленный DWORD.
                                Это необходимо учитывать в состоянии L_RcvrHold
                            \*                                                                              */
                        end
                        else if (TL_TX_DATA_COMPLETE | DMATp) begin
                            /*When the Transport layer indicates that all data for the frame has been
                            transferred and any Dword other than SYNC P has been received from the Phy layer, the Link
                            layer shall make a transition to the LT7: L_SendCRC state. When the Link layer receives DMAT P
                            from the Phy layer, it shall notify the Transport layer and terminate the transmission in progress
                            as described in section 9.4.4 and shall transition to the LT7:L_SendCRC state.*/
                            //SMSTATE = `L_SendCRC;
                            /*                                              *\
                                !!! Attention !!! The logic was changed !!!
                            \*                                              */
                            if (~DMATp) begin
                                SMSTATE = `L_SendEOF;
                            end
                            else begin
                                SMSTATE = `L_SendHold;
                            end
                        end
                        else begin
                            /*When the Transport layer indicates that a Dword is not available for transfer
                            and any Dword other than SYNC P is received from the Phy layer, the Link layer shall make a
                            transition to the LT6: L_SendHold state.*/
                            SMSTATE = `L_SendHold;
                        end
                    end
                end
                else begin
                    /*When the Link layer detects that the Phy layer is not ready the Link layer shall
                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end 
            end

//           `L_SendCRC: begin
//                /*This state is entered when the Transport layer indicates that all data Dwords have been transferred for this frame.
//                When in this state, the Link layer shall transmit the calculated CRC for the frame.*/
//                OUT_DWORD = 0; OUT_CONTROLS = 4'b0000;
//
//                if (PHYRDY) begin
//                    if (SYNCp) begin
//                        /* When the Link layer receives SYNC P from the Phy layer, the Link layer shall notify the Transport layer 
//                        of the illegal transition error condition and shall make a transition to the L1:L_IDLE state.*/
//                        SMSTATE = `L_IDLE;
//                    end
//                    else begin
//                        /*When the CRC has been transmitted, the Link layer shall make a transition to the LT8: L_SendEOF state.*/
//                        if (OUT_DWORD_ENABLE) begin// Дополнительное условие: Если сгенерированный DWORD будет помещен в выходной поток
//                            SMSTATE = `L_SendEOF;
//                        end
//                    end
//                end
//                else begin
//                    /*When the Link layer detects that the Phy layer is not ready the Link layer shall
//                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
//                    SMSTATE = `L_NoCommErr;
//                end 
//            end

            `L_SendEOF: begin 
                /*This state is entered when the CRC for the frame has been transmitted.
                When in this state, the Link layer shall transmit EOF P .*/
                OUT_DWORD = `D_EOFp; OUT_CONTROLS = 4'b0001;
                            
                if (PHYRDY) begin
                    if (SYNCp) begin
                        /*When the Link layer receives SYNC P from the Phy layer, the Link layer shall notify the Transport layer 
                        of the illegal transition error condition and shall make a transition to the L1:L_IDLE state.*/
                        SMSTATE = `L_IDLE;
                    end
                    else begin
                        /*When EOF P has been transmitted, the Link layer shall make a transition to the LT9: L_Wait state.*/
                        if (OUT_DWORD_ENABLE) begin// Дополнительное условие: Если сгенерированный DWORD будет помещен в выходной поток
                            SMSTATE = `L_Wait;
                        end
                    end
                end
                else begin
                    /*When the Link layer detects that the Phy layer is not ready the Link layer shall
                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end 
            end

            `L_Wait: begin
                /*This state is entered when EOF P has been transmitted. 
                When in this state, the Link layer shall transmit WTRM P .*/
                OUT_DWORD = `D_WTRMp; OUT_CONTROLS = 4'b0001;
                        
                if (PHYRDY) begin
                    if (R_OKp) begin
                        /*When the Link layer receives R_OK P from the Phy layer, the Link layer shall
                        notify the Transport layer and make a transition to the L1: L_IDLE state.*/
                        SMSTATE = `L_IDLE;
                        /*                                                      *\
                            !!! Attention !!! The logic needs to be changed !!!
                        \*                                                      */
                        //;transmit good status to TL
                    end
                    else if (R_ERRp) begin
                        /*When the Link layer receives R_ERR P from the Phy layer, the Link layer shall
                        notify the Transport layer and make a transition to the L1: L_IDLE state.*/
                        SMSTATE = `L_IDLE;
                        /*                                                      *\
                            !!! Attention !!! The logic needs to be changed !!!
                        \*                                                      */
                        //;transmit bad status to TL
                    end
                    else if (SYNCp) begin
                        /*When the Link layer receives SYNC P from the Phy layer, the Link layer shall
                        notify the Transport layer and make a transition to the L1: L_IDLE state.*/
                        SMSTATE = `L_IDLE;
                    end
                    else begin
                        /* When the Link layer receives any Dword other than an R_OK P , R_ERR P , or
                        SYNC P primitive from the Phy layer, the Link layer shall make a transition to the LT9: L_Wait state.*/
                        SMSTATE = `L_Wait;
                    end
                end
                else begin
                    /*When the Link layer detects that the Phy layer is not ready the Link layer shall
                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end 
            end

            `L_RcvChkRdy: begin
                /*This state is entered when X_RDY P has been received from the Phy layer.
                When in this state, the Link layer shall transmit R_RDY P and wait for SOF P from the Phy layer.*/
                OUT_DWORD = `D_R_RDYp; OUT_CONTROLS = 4'b0001;
                    
                if (PHYRDY) begin
                    if (X_RDYp) begin
                        /*When the Link layer receives X_RDY P from the Phy layer, the Link layer shall
                        make a transition to the LR1: L_RcvChkRdy state.*/
                        SMSTATE = `L_RcvChkRdy;
                    end
                    else if (SOFp) begin
                        /*When the Link layer receives SOF P from the Phy layer, the Link layer shall
                        make a transition to the LR3: L_RcvData state.*/
                        SMSTATE = `L_RcvData;
                    end
                    else begin
                        /*When the Link layer receives any Dword other than an X_RDY P or SOF P
                        primitive from the Phy layer, the Link layer shall notify the Transport layer of the condition and
                        make a transition to the L1: L_IDLE state.*/
                        SMSTATE = `L_IDLE;
                    end
                end
                else begin
                    /*When the Link layer detects that the Phy layer is not ready the Link layer shall
                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end 
            end

            `L_RcvWaitFifo: begin
                /* This state is entered when an X_RDY P has been received, and the FIFO is not ready to receive a FIS.
                When in this state, the Link layer shall transmit SYNC P */
                OUT_DWORD = `D_SYNCp; OUT_CONTROLS = 4'b0001;
                    
                if (PHYRDY) begin
                    if (X_RDYp) begin
                        if (TL_RX_DATA_SPACE_AVL) begin
                            /*When the Link layer receives X_RDY P from the Phy layer and the FIFO is
                            ready to accept data, the Link layer shall make a transition to the LR1: L_RcvChkRdy state.*/
                            //SMSTATE = `L_RcvChkRdy;
                            /*                                                      *\
                               !!! Attention !!! The logic was changed !!!
                            \*                                                      */
                            if (exTL_NOTIFY_PHYRDYn) begin
                                /*Если на другой стороне отсутствует связь на физическом уровне, переходим в состояние L_IDLE*/
                                SMSTATE = `L_IDLE;
                            end
                            else begin
                                /*Ждем от другой стороны уведомления о получении примитива R_RDYp*/
                                if (exTL_NOTIFY_R_RDYp) begin
                                    /*Если на другой стороне принят примитив R_RDYp, процесс рукопожатия завершен.
                                    Переходим в состояние L_RcvChkRdy для приема фрейма*/
                                    SMSTATE = `L_RcvChkRdy;
                                end
                                else begin
                                    if (exTL_NOTIFY_X_RDYp) begin
                                        if (LINK_TYPE == "HOST") begin
                                            /*Если host-сторона получает уведомление о приеме примитива X_RDYp на device-стороне,
                                            игнорируем это уведомление и продолжаем ждать завершения процесса рукопожатия*/
                                            SMSTATE = `L_RcvWaitFifo;
                                        end
                                        else begin
                                            /*Если device-стороной получено уведомление о приеме X_RDYp на другой стороне устройства,
                                            прекращаем процесс рукопожатия переходом в состояние L_IDLE*/
                                            SMSTATE = `L_IDLE;
                                        end
                                    end
                                end
                            end
                        end
                        else begin
                            /*When the Link layer receives X_RDY P from the Phy layer and the FIFO is not
                            ready to accept data, the Link layer shall make a transition to the LR2: L_RcvWaitFifo state.*/
                            SMSTATE = `L_RcvWaitFifo;
                        end
                    end
                    else begin
                        /*When the Link layer receives any Dword other than X_RDY P from the Phy layer, the Link layer 
                        shall notify the Transport layer of the condition and make a transition to the L1: L_IDLE state.*/
                        SMSTATE = `L_IDLE;
                    end
                end
                else begin
                    /*When the Link layer detects that the Phy layer is not ready the Link layer shall
                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end  
            end

            `L_RcvData: begin
                /*This state is entered when SOF P has been received from the Phy layer.
                When in this state, the Link layer receives an encoded character sequence from the Phy layer,
                decodes it into a Dword, and passes the Dword to the Transport layer. The Dword is also entered
                into the CRC calculation. When in this state the Link layer either transmits R_IP P to signal
                transmission to continue or transmits DMAT P to signal the transmitter to terminate the transmission.*/
                OUT_DWORD = `D_R_IPp; OUT_CONTROLS = 4'b0001;
                /*                                                      *\
                    !!! Attention !!! The logic needs to be changed !!!
                \*                                                      */
                //OUT_DWORD = `D_R_DMATp; OUT_CONTROLS = 4'b0001;    
                    
                if (PHYRDY) begin
                    if (TL_RX_DATA_ABORT) begin
                        /*When the Link layer receives notification from the Transport layer that the
                        current frame should be escaped, a transition to the L_SyncEscape state shall be made.*/
                        SMSTATE = `L_SyncEscape;
                    end
                    else begin
                        if (HOLDp) begin
                            /*When the Link layer receives HOLD P from the Phy layer, the Link layer shall
                            make a transition to the LR5: L_RcvHold state.*/
                            SMSTATE = `L_RcvHold;
                        end
                        else if (EOFp) begin
                            /*When the Link layer receives EOF P from the Phy layer, the Link layer shall
                            make a transition to the LR6: L_RcvEOF state.*/
                            SMSTATE = `L_RcvEOF;
                        end
                        else if (WTRMp) begin
                            /*When the Link layer receives WTRM P from the Phy layer, the Link layer shall
                            make a transition to the LR9: L_BadEnd state.*/
                            SMSTATE = `L_BadEnd;
                        end
                        else if (SYNCp) begin
                            /*When the Link layer receives SYNC P from the Phy layer, the Link layer shall notify the 
                            Transport layer that reception was aborted and shall make a transition to the L1: L_IDLE state.*/
                            SMSTATE = `L_IDLE;
                        end
                        else if ((DatDword & TL_RX_DATA_SPACE_AVL) | HOLDAp) begin
                            /*When the Transport layer indicates that space is available in its FIFO, the Link
                            layer shall make a transition to the LR3: L_RcvData state.*/
                            SMSTATE = `L_RcvData;
                        end
                        else if (DatDword & ~TL_RX_DATA_SPACE_AVL) begin
                            /*When the Transport layer indicates that sufficient space is not available in its
                            FIFO, the Link layer shall make a transition to the LR4: L_Hold state.*/
                            SMSTATE = `L_Hold;
                        end
                        else begin
                            /*When the Link layer receives any Dword other than a HOLD P , HOLDA P , EOF P , or SYNC P 
                            primitive from the Phy layer, the Link layer shall make a transition to the LR3: L_RcvData state.*/
                            SMSTATE = `L_RcvData;
                        end
                    end
                end
                else begin
                    /*When the Link layer detects that the Phy layer is not ready the Link layer shall
                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end  
            end

            `L_Hold: begin
                /*This state is entered when the Transport layer indicates that sufficient space is not available in its receive FIFO.
                When in this state, the Link layer shall transmit HOLD P and may receive an encoded character from the Phy layer.*/
                OUT_DWORD = `D_HOLDp; OUT_CONTROLS = 4'b0001;

                if (PHYRDY) begin
                    if (TL_RX_DATA_ABORT) begin
                        /*When the Link layer receives notification from the Transport layer that the
                        current frame should be escaped, a transition to the L_SyncEscape state shall be made.*/
                        SMSTATE = `L_SyncEscape;
                    end
                    else begin
                        if (SYNCp) begin
                            /*When the Link layer receives SYNC P from the Phy layer, the Link layer shall notify the Transport 
                            layer of the illegal transition error condition and shall make a transition to the L1: L_IDLE state.*/
                            SMSTATE = `L_IDLE;
                        end
                        else if (EOFp) begin
                            /*When the Link layer receives EOF P from the Phy layer, the Link layer shall
                            make a transition to the LR6: L_RcvEOF state. Note that due to pipeline latency, an EOF P may
                            be received when in the L_Hold state in which case the receiving Link shall use its FIFO
                            headroom to receive the EOF P and close the frame reception.*/
                            SMSTATE = `L_RcvEOF;
                        end
                        else if (TL_RX_DATA_SPACE_AVL) begin
                            if (HOLDp) begin
                                /*When the Link layer receives HOLD P from the Phy layer and the Transport layer indicates that 
                                space is now available in its FIFO, the Link layer shall make a transition to the LR5: L_RcvHold state.*/
                                SMSTATE = `L_RcvHold;
                            end
                            else begin
                                /*When the Link layer receives any Dword other than a HOLD P primitive from
                                the Phy layer and the Transport layer indicates that sufficient space is now available in its receive
                                FIFO, the Link layer shall make a transition to the LR3: L_RcvData state.*/
                                SMSTATE = `L_RcvData;
                            end
                        end
                        else begin
                            /*When the Transport layer indicates that there is not sufficient space available
                            in its FIFO and the Phy layer is ready, the Link layer shall make a transition to the LR4: L_Hold state.*/
                            SMSTATE = `L_Hold;
                        end
                    end
                end
                else begin
                    /*When the Link layer detects that the Phy layer is not ready the Link layer shall
                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end  
            end

            `L_RcvHold: begin
                /*This state is entered when HOLD P has been received from the Phy layer.
                When in this state, the Link layer shall either transmit HOLDA P to signal transmission to proceed
                when the transmitter becomes ready or transmit DMAT P to signal the transmitter to terminate the transmission.*/
                OUT_DWORD = `D_HOLDAp; OUT_CONTROLS = 4'b0001;
                /*                                                      *\
                    !!! Attention !!! The logic needs to be changed !!!
                \*                                                      */
                //OUT_DWORD = `D_R_DMATp; OUT_CONTROLS = 4'b0001;
                
                if (PHYRDY) begin
                    if (TL_RX_DATA_ABORT) begin
                        /*When the Link layer receives notification from the Transport layer that the
                        current frame should be escaped, a transition to the L_SyncEscape state shall be made.*/
                        SMSTATE = `L_SyncEscape;
                    end
                    else begin
                        if (HOLDp) begin
                            /*When the Link layer receives HOLD P from the Phy layer, the Link layer shall
                            make a transition to the LR5: L_RcvHold state.*/
                            SMSTATE = `L_RcvHold;
                        end
                        else if (EOFp) begin
                            /*When the Link layer receives EOF P from the Phy layer, the Link layer shall
                            make a transition to the LR6: L_RcvEOF state.*/
                            SMSTATE = `L_RcvEOF;
                        end
                        else if (SYNCp) begin
                            /*When the Link layer receives SYNC P from the Phy layer, the Link layer shall
                            make a transition to the L1: L_IDLE state. The Transport layer shall be notified of the illegal
                            transition error condition.*/
                            SMSTATE = `L_IDLE;
                        end
                        else begin
                            /*When the Link layer receives any Dword other than a HOLD P or SYNC P
                            primitive from the Phy layer, the Link layer shall make a transition to the LR3: L_RcvData state.*/
                            SMSTATE = `L_RcvData;
                        end
                    end
                end
                else begin
                    /*When the Link layer detects that the Phy layer is not ready the Link layer shall
                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end 
            end
            
            `L_RcvEOF: begin
                /* This state is entered when the Link layer has received EOF P from the Phy layer.
                When in this state, the Link layer shall check the calculated CRC for the frame and transmit one
                or more R_IP P primitives.*/
                OUT_DWORD = `D_R_IPp; OUT_CONTROLS = 4'b0001;
                                
                if (PHYRDY) begin
                    if (TL_RX_DATA_CRC_GOOD) begin
                        /*When the CRC indicates no error, the Link layer shall notify the Transport
                        layer and make a transition to the LR7: L_GoodCRC state.*/
                        SMSTATE = `L_GoodCRC;
                    end
                    else if (TL_RX_DATA_CRC_BAD) begin
                        /*When the CRC indicates an error has occurred, the Link layer shall notify the
                        Transport layer and make a transition to the LR9: L_BadEnd state.*/
                        SMSTATE = `L_BadEnd;
                    end
                    else begin
                        /*If the CRC calculation and check is not yet completed, the Link layer shall
                        make a transition to the LR6: L_RcvEOF state.*/
                        SMSTATE = `L_RcvEOF;
                    end
                end
                else begin
                    /*When the Link layer detects that the Phy layer is not ready the Link layer shall
                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end
            end
            
            `L_GoodCRC: begin
                /*This state is entered when the CRC for the frame has been checked and determined to be good.
                When in this state, the Link layer shall wait for the Transport layer to check the frame and
                transmit one or more R_IP P primitives.*/
                OUT_DWORD = `D_R_IPp; OUT_CONTROLS = 4'b0001;
                                
                if (PHYRDY) begin
                    if (SYNCp) begin
                        /*When the Link layer receives SYNC P from the Phy layer, the Link layer shall notify the Transport layer 
                        of the illegal transition error condition and shall make a transition to the L1: L_IDLE state.*/
                        SMSTATE = `L_IDLE;
                    end
                    else if (TL_RX_DATA_GOOD_RESULT) begin
                        /*When the Transport layer indicates a good result, the Link layer shall transition to the LR8: L_GoodEnd state.*/
                        SMSTATE = `L_GoodEnd;
                    end
                    else if (TL_RX_DATA_BAD_RESULT) begin
                        /*When the Transport layer indicates an unrecognized FIS, the Link layer shall transition to the LR9: L_BadEnd state.*/
                        /*When the Transport layer or Link layer indicates an error was encountered during the reception of the recognized FIS, 
                        the Link layer shall transition to the LR9: L_BadEnd state.*/
                        SMSTATE = `L_BadEnd;
                    end
                    else if (TL_RX_DATA_ABORT) begin
                        /*!!! Новый переход !!! Если необходимо прервать передачу фрейма. Переходим в состояние L_SyncEscape*/
                        SMSTATE = `L_SyncEscape;
                    end
                    else begin
                        /*If the Transport layer has not supplied status, then the Link layer shall transition to the LR7: L_GoodCRC state.*/
                        SMSTATE = `L_GoodCRC;
                    end
                end
                else begin
                    /*When the Link layer detects that the Phy layer is not ready, the Link layer shall
                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end
            end

            `L_GoodEnd: begin
                /*This state is entered when the CRC for the frame has been checked and determined to be good.
                When in this state, the Link layer shall transmit R_OK P .*/
                OUT_DWORD = `D_R_OKp; OUT_CONTROLS = 4'b0001;

                if (PHYRDY) begin
                    if (SYNCp) begin
                        /*When the Link layer receives SYNC P from the Phy layer, the Link layer shall
                        make a transition to the L1: L_IDLE state.*/
                        SMSTATE = `L_IDLE;
                    end
                    else begin
                        /*When the Link layer receives any Dword other than a SYNC P primitive from
                        the Phy layer, the Link layer shall make a transition to the LR7: L_GoodEnd state.*/
                        SMSTATE = `L_GoodEnd;
                    end
                end
                else begin
                    /*When the Link layer detects that the Phy layer is not ready, the Link layer shall
                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end 
            end

            `L_BadEnd: begin
                /*This state is entered when the CRC for the frame has been checked and determined to be bad or when the 
                Transport layer has notified the Link layer that the received FIS is invalid.
                When in this state, the Link layer shall transmit R_ERR P .*/
                OUT_DWORD = `D_R_ERRp; OUT_CONTROLS = 4'b0001;
                                    
                if (PHYRDY) begin
                    if (SYNCp) begin
                        /*When the Link layer receives SYNC P from the Phy layer, the Link layer shall make a transition to the L1: L_IDLE state.*/
                        SMSTATE = `L_IDLE;
                    end
                    else begin
                        /*When the Link layer receives any Dword other than SYNC P from the Phy
                        layer, the Link layer shall make a transition to the LR9: BadEnd state.*/
                        SMSTATE = `L_BadEnd;
                    end
                end
                else begin
                    /*When the Link layer detects that the Phy layer is not ready the Link layer shall
                    notify the Transport layer of the condition and make a transition to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end 
            end
 
            `L_TPMPartial: begin
                /*This state is entered when the Transport layer has indicated that a transition to the Partial power state is desired.
                When in this state PMREQ_P P shall be transmitted.*/
                OUT_DWORD = `D_PMREQ_Pp; OUT_CONTROLS = 4'b0001;
                    
                if (PHYRDY) begin
                    if (PMACKp) begin
                        /*When the Link layer receives PMACK P a transition to the LPM5: L_ChkPhyRdy state shall be made.*/
                        SMSTATE = `L_ChkPhyRdy;
                    end
                    else if (PMNAKp) begin
                        /*If the Link layer receives a PMNAK P , then the request to enter the Partial
                        state is aborted and a transition to LPM9: L_NoPmnak shall be made.*/
                        SMSTATE = `L_NoPmnak;
                    end
                    else if (X_RDYp) begin
                        /*If the Link layer receives X_RDY P a transition shall be made to the LR2:
                        L_RcvWaitFifo state, effectively aborting the request to a power mode state.*/
                        SMSTATE = `L_RcvWaitFifo;
                    end
                    else if (SYNCp | R_OKp) begin
                        /*If the Link layer receives a SYNC P or R_OK P primitive, then it is assumed
                        that the opposite side has not yet processed PMREQ_P P yet and time is needed. A transition to
                        the LPM1: L_TPMPartial state shall be made.*/
                        SMSTATE = `L_TPMPartial;
                    end
                    else if (PMREQ_Pp | PMREQ_Sp) begin
                        if (LINK_TYPE == "HOST") begin
                            SMSTATE = `L_IDLE;
                        end
                        else begin
                            /*The host Link layer shall not make this transition as it applies only to the
                            device Link layer. If the device Link layer receives PMREQ_P P or PMREQ_S P from the host, it
                            shall remain in this state by transitioning back to LPM1: L_TPMPartial.*/
                            SMSTATE = `L_TPMPartial;
                        end
                    end
                    else begin
                        /*If the host Link layer receives any Dword from the Phy layer other than a
                        PMACK P , PMNAK P , X_RDY P , SYNC P or R_OK P primitive, then the request to enter the Partial
                        state is aborted and a transition to L1: L_IDLE shall be made. If the device Link layer receives
                        any Dword from the Phy layer other than a PMACK P , PMNAK P , X_RDY P , SYNC P , PMREQ_P P ,
                        PMREQ_S P , or R_OK P primitive, then the request to enter the Partial state is aborted and a
                        transition to L1: L_IDLE shall be made.*/
                        SMSTATE = `L_IDLE;
                    end
                end
                else begin
                    /*If the Link layer detects that the Phy layer has become not ready, this is
                    interpreted as an error condition. The Transport layer shall be notified of the condition and a
                    transition shall be made to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end 
            end

            `L_TPMSlumber: begin
                /*This state is entered when the Transport layer has indicated that a transition to the Slumber power state is desired.
                When in this state PMREQ_S P shall be transmitted.*/
                OUT_DWORD = `D_PMREQ_Sp; OUT_CONTROLS = 4'b0001;
                    
                if (PHYRDY) begin
                    if (PMACKp) begin
                        /*When the Link layer receives PMACK P , a transition to the LPM5: L_ChkPhyRdy state shall be made.*/
                        SMSTATE = `L_ChkPhyRdy;
                    end
                    else if (PMNAKp) begin
                        /*If the Link layer receives a PMNAK P , then the request to enter the Slumber
                        state is aborted and a transition to LPM9: L_NoPmnak shall be made.*/
                        SMSTATE = `L_NoPmnak;
                    end
                    else if (X_RDYp) begin
                        /*If the Link layer receives X_RDY P , a transition to the LR2: L_RcvWaitFifo
                        state shall be made, effectively aborting the request to a power mode state.*/
                        SMSTATE = `L_RcvWaitFifo;
                    end
                    else if (SYNCp | R_OKp) begin
                        /*If the Link layer receives SYNC P or R_OK P , then it is assumed that the
                        opposite side has not yet processed PMREQ_S P yet and time is needed. The transition to the
                        LPM2: L_TPMSlumber state shall be made.*/
                        SMSTATE = `L_TPMSlumber;
                    end
                    else if (PMREQ_Pp | PMREQ_Sp) begin
                        if (LINK_TYPE == "HOST") begin
                            SMSTATE = `L_IDLE;
                        end
                        else begin
                            /*The host Link layer shall not make this transition as it applies only to the
                            device Link layer. If the device Link layer receives PMREQ_P P or PMREQ_S P from the host, it
                            shall remain in this state by transitioning back to LPM2: L_TPMSlumber.*/
                            SMSTATE = `L_TPMSlumber;
                        end
                    end 
                    else begin
                        /*If the host Link layer receives any Dword from the Phy layer other than a
                        PMACK P , PMNAK P , X_RDY P , SYNC P , or R_OK P primitive, then the request to enter the Slumber
                        state is aborted and a transition to L1: L_IDLE shall be made. If the device Link layer receives
                        any Dword from the Phy layer other than a PMACK P , PMNAK P , X_RDY P , SYNC P , PMREQ_P P ,
                        PMREQ_S P , or R_OK P primitive, then the request to enter the Slumber state is aborted and a
                        transition to L1: L_IDLE shall be made.*/
                        SMSTATE = `L_IDLE;
                    end
                end
                else begin
                    /*If the Link layer detects that the Phy layer has become not ready, this is
                    interpreted as an error condition. The Transport layer shall be notified of the condition and a
                    transition shall be made to the L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end 
            end

            `L_PMOff: begin
                /*This state is entered when either PMREQ_S P or PMREQ_P P was
                received by the Link layer. The Link layer transmits PMACK P for each execution of this state.*/
                OUT_DWORD = `D_PMACKp; OUT_CONTROLS = 4'b0001;
                                
                if (0/*!!! ATTENTION !!! The logic need to be changed !!!*/) begin
                    /*If 4<=n<=16 PMACK P primitives have been transmitted, a transition shall be made to the L_ChkPhyRdy state.*/
                    SMSTATE = `L_ChkPhyRdy;
                end
                else begin
                    /*If less than n PMACK P primitives have been transmitted, a transition shall be made to L_PMOff state.*/
                    SMSTATE = `L_PMOff;
                end
            end

            `L_PMDeny: begin
                /*This state is entered when any primitive is received by the Link
                layer to enter a power mode and power modes are currently disabled. The Link layer shall
                transmit PMNAK P to inform the opposite end that a power mode is not allowed.*/
                OUT_DWORD = `D_PMNAKp; OUT_CONTROLS = 4'b0001;
                                
                if (PHYRDY) begin
                    if (PMREQ_Pp | PMREQ_Sp) begin
                        /*If the Link layer continues to receive a request to enter any power mode
                        than a transition back to the same LPM4: L_PMDeny state shall be made.*/
                        SMSTATE = `L_PMDeny;
                    end
                    else begin
                        /*If the Link layer receives any Dword other than a power mode request
                        primitive, then the Link layer assumes that the power mode request has been removed and shall
                        make a transition to the L1: L_IDLE state.*/
                        SMSTATE = `L_IDLE;
                    end
                end
                else begin
                    /*If the Link layer detects that the Phy layer has become not ready, this is
                    interpreted as an error condition. The Transport layer shall be notified of the condition and a
                    transition shall be made to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end 
            end

            `L_ChkPhyRdy: begin
                /*This state is entered whenever it is desired for the Phy layer
                to enter a low power condition. For each execution in this state a request is made to the Phy layer
                to enter the state and deactivate the PHYRDY signal. Partial or Slumber is asserted to the Phy
                layer as appropriate.*/
                                
                if (PHYRDY) begin
                    /*If the Phy layer has not yet processed the request to enter the power saving
                    state and not deactivated the PHYRDY signal, then the Link layer shall remain in the LPM5:
                    L_ChkPhyRdy state and continue to request the Phy layer to enter the power mode state.*/
                    SMSTATE = `L_ChkPhyRdy;
                end
                else begin
                    /*When the Phy layer has processed the power mode request and has
                    deactivated the PHYRDY signal, then a transition shall be made to the LPM6: L_NoCommPower state.*/
                    SMSTATE = `L_NoCommPower;
                end 
            end

            `L_NoCommPower: begin
                /*OUT_DWORD = `D_p; OUT_CONTROLS = 4'b0001;
                    
                if (PHYRDY) begin
                    if (X_RDYp) begin
                        SMSTATE = `L_;
                    end
                    else if (SOFp) begin
                        SMSTATE = `L_;
                    end
                    else begin
                        SMSTATE = `L_;
                    end
                end
                else begin
                    SMSTATE = `L_NoCommErr;
                end*/ 
            end

            `L_WakeUp1: begin
                /*OUT_DWORD = `D_p; OUT_CONTROLS = 4'b0001;
                                
                if (PHYRDY) begin
                    if (X_RDYp) begin
                        SMSTATE = `L_;
                    end
                    else if (SOFp) begin
                        SMSTATE = `L_;
                    end
                    else begin
                        SMSTATE = `L_;
                    end
                end
                else begin
                    SMSTATE = `L_NoCommErr;
                end*/ 
            end

            `L_WakeUp2: begin
                /*This state is entered when the Phy layer has acknowledged an
                initiated wakeup request by asserting its PHYRDY signal. In this state, the Link layer shall
                transmit the ALIGN sequence, and transition to the L1: L_IDLE state.*/
                OUT_DWORD = `D_SYNCp; OUT_CONTROLS = 4'b0001;
                                
                if (PHYRDY) begin
                    /*If the Phy layer keeps PHYRDY asserted, a transition shall be made to the L1: L_IDLE state.*/
                    SMSTATE = `L_IDLE;
                end
                else begin
                    /*If the Phy layer negates PHYRDY, this is an error condition. The Transport
                    layer shall be notified of the condition and a transition shall be made to the LS1: L_NoCommErr state.*/
                    SMSTATE = `L_NoCommErr;
                end
            end

            `L_NoPmnak: begin
                /*This state is entered when the Link layer has indicated that a
                request to enter the Slumber or Partial state has been denied. The Link layer transmits SYNC P
                for each execution of this state. In this state, the Link layer waits for receipt of any Dword that is
                not PMNAK P from the Phy layer.*/
                OUT_DWORD = `D_SYNCp; OUT_CONTROLS = 4'b0001;

                if (PMNAKp) begin
                    /*If the Link layer receives PMNAK P , then the Link layer shall remain in the LPM9: L_NoPmnak state 
                    and continue to wait for receipt of a primitive that is not PMNAK P from the Phy layer.*/
                    SMSTATE = `L_NoPmnak;
                end
                else begin
                    /*If the Link layer receives any Dword from the Phy layer other than PMNAK P , then the request to 
                    enter the power management state is aborted and a transition to L1: L_IDLE shall be made.*/
                    SMSTATE = `L_IDLE;
                end 
            end

            `exHL_SendHandshake: begin
                /*Переход в это состояние осуществляется host-стороной при приеме X_RDYp на device-стороне устройства
                для выполнения блокирующего X_RDYp/R_RDYp рукопожатия.
                В этом состоянии происходит отправка примитива X_RDYp и ожидается возможный прием примитива X_RDYp.*/
                OUT_DWORD = `D_X_RDYp; OUT_CONTROLS = 4'b0001;

                /*!!! ATTENTION !!! Обновить выход FIFO, если в нем есть данные, не являющиеся началом фрейма*/
                if (TL_TX_DATA_MORE & ~TL_SEND_FRAME_REQ & OUT_DWORD_ENABLE) begin
                    txstream_rd_en_out <= 1'b1;
                end
                
                if (PHYRDY) begin
                    if (TL_SEND_FRAME_REQ) begin
                        /*Если поступил запрос на передачу фрейма, переходим в состояние HL_SendChkRdy*/
                        SMSTATE = `HL_SendChkRdy;
                    end
                    else if (X_RDYp) begin
                        /*При приеме примитива X_RDYp хост пректащает рукопожатие и переходит в состояние L_RcvWaitFifo*/
                        SMSTATE = `L_RcvWaitFifo;
                    end
                    else if (exTL_NOTIFY_SYNCp | exTL_NOTIFY_R_RDYp | exTL_NOTIFY_PHYRDYn) begin
                        /*Если процесс рукопожатия прервался на другой стороне, переходим в состояние L_SyncEscape*/
                        SMSTATE = `L_SyncEscape;
                    end
                    else begin
                        SMSTATE = `exHL_SendHandshake;
                    end
                end
                else begin
                    /*При пропадании связи на физическом уровне, переходим в состояние L_NoCommErr*/
                    SMSTATE = `L_NoCommErr;
                end
            end

            `exDL_SendHandshake: begin
                /*Переход в это состояние осуществляется device-стороной при приеме X_RDYp на host-стороне устройства
                для выполнения блокирующего X_RDYp/R_RDYp рукопожатия.
                В этом состоянии происходит отправка примитива X_RDYp.*/
                OUT_DWORD = `D_X_RDYp; OUT_CONTROLS = 4'b0001;
                
                DBG_CNT1 = DBG_CNT1 + 1;
                if (DBG_CNT1 > 300) begin
                    DBG_REG1 = 1;
                end

                /*!!! ATTENTION !!! Обновить выход FIFO, если в нем есть данные, не являющиеся началом фрейма*/
                if (TL_TX_DATA_MORE & ~TL_SEND_FRAME_REQ & OUT_DWORD_ENABLE) begin
                    txstream_rd_en_out <= 1'b1;
                end
                
                if (PHYRDY) begin
                    if (TL_SEND_FRAME_REQ) begin
                        /*Если поступил запрос на передачу фрейма, переходим в состояние DL_SendChkRdy*/
                        SMSTATE = `DL_SendChkRdy;
                    end
                    else if (exTL_NOTIFY_SYNCp | exTL_NOTIFY_R_RDYp | exTL_NOTIFY_PHYRDYn) begin
                        /*Если процесс рукопожатия прервался на другой стороне, переходим в состояние L_SyncEscape*/
                        SMSTATE = `L_SyncEscape;
                    end
                    else begin
                        SMSTATE = `exDL_SendHandshake;
                    end
                end
                else begin
                    /*При пропадании связи на физическом уровне, переходим в состояние L_NoCommErr*/
                    SMSTATE = `L_NoCommErr;
                end
            end
        endcase

        /*The forced output the pair of ALIGNp primitices*/
        if (FORCE_OUT_ALIGN) begin
            OUT_DWORD = `D_ALIGNp; OUT_CONTROLS = 4'b0001;
        end
    end


    wire [31:0] OUT_DWORD_0 = OUT_DWORD;
    reg  [31:0] OUT_DWORD_1;
    reg  [31:0] OUT_DWORD_2;
    wire [3:0]  OUT_CONTROLS_0 = OUT_CONTROLS;
    reg  [3:0]  OUT_CONTROLS_1;
    reg  [3:0]  OUT_CONTROLS_2;
    
    always @(posedge phy_txclk_in) begin
        if (!is_new_dword) begin
            OUT_DWORD_1 <= OUT_DWORD_0;
            OUT_DWORD_2 <= OUT_DWORD_1;
            
            OUT_CONTROLS_1 <= OUT_CONTROLS_0;
            OUT_CONTROLS_2 <= OUT_CONTROLS_1;
        end
    end


    assign rxstream_reset_out = ~phy_ready_in | SYNCp;// Reset input stream when there is SYNCp or PHYRDYn

    wire [31:0]  dword_in_0 = dword_in;
    wire         dat_dword_0 = ~|non_stable_primitives[17:0]; // Ни один из примитивов
    wire         sof_dword_0 = non_stable_primitives[15];
    wire         eof_dword_0 = non_stable_primitives[4];
    wire         wtrm_dword_0 = non_stable_primitives[16];
    wire         sync_dword_0 = non_stable_primitives[1];

    reg  [31:0]  dword_in_1;
    reg  [3:0]   dword_type_1;
    (* mark_debug = "true" *)reg  [31:0]  dword_in_2;
    (* mark_debug = "true" *)reg  [3:0]   dword_type_2;

    reg sof_dword_trig;
    reg frame_detect;
    
    always @(posedge phy_rxclk_in) begin // Передача данных из входящегго потока на верхний уровень
        rxstream_wr_en_out = 0;
        
        if (new_dword_in) begin
            if (sof_dword_0) begin          // Если принят SOF
                sof_dword_trig = 1;         // Выставить флаг принятия SOF
            end
            else if (dat_dword_0) begin     // Если принят data DWORD
                dword_in_2 = dword_in_1;    // Сдвинуть
                dword_type_2 = dword_type_1;// Сдвинуть
                
                dword_in_1 = dword_in_0;    // Запомнить принятый DWORD
                
                if (sof_dword_trig) begin   // Если перед этим был принят SOF
                    sof_dword_trig = 0;     // Сбросить флаг принятия SOF
                    dword_type_1 = 4'h1;    // Установить тип DWORD'а как "первый во фрейме"
                    frame_detect = 1;       // Запомнить найденный фрейм
                end
                else begin
                    dword_type_1 = 0;        // Установить тип DWORD'а как "в середине фрейма"
                    rxstream_wr_en_out = frame_detect;  // Передать dword_in_2 в FIFO
                end
            end
            else if (eof_dword_0) begin        // Если принят EOF
                dword_in_2 = dword_in_1;    // Сдвинуть
                dword_type_2 = 4'h2;        // Установить тип DWORD'а как "последний во фрейме"
                
                rxstream_wr_en_out = 1;     // Передать dword_in_2 в FIFO
                frame_detect = 0;           // Забыть найденный фрейм
            end
            else if (wtrm_dword_0 | sync_dword_0) begin
                frame_detect = 0;           // Забыть найденный фрейм
            end

            rxstream_out = {dword_type_2, dword_in_2 ^ input_scrambler_sequence};
        end
    end


//////////////////////

    reg         dat_dword_1;
    reg         sof_dword_1;
    reg         eof_dword_1;

(* mark_debug = "true" *)reg primitive_before_eof;
(* mark_debug = "true" *)reg primitive_after_sof;

    always @(posedge phy_rxclk_in) begin
        if (new_dword_in) begin
            primitive_before_eof = eof_dword_0 & ~dat_dword_1;
            primitive_after_sof = sof_dword_1 & ~dat_dword_0;
            dat_dword_1 = dat_dword_0;
            sof_dword_1 = sof_dword_0;
            eof_dword_1 = eof_dword_0;
        end
    end

//////////////////////

    assign input_scrambler_reset = sof_dword_trig;
    assign input_scrambler_update = rxstream_wr_en_out;
    
    sata_scrambler_seq input_scrambler (
        .clk_in         (phy_rxclk_in),
        .reset_in       (input_scrambler_reset),
        .update_in      (input_scrambler_update),
    
        .sequence_out   (input_scrambler_sequence)
    );

//////////////////////
    
    assign output_scrambler_reset = TL_SEND_FRAME_REQ & ~TL_TX_DATA_READ_EN;
    assign output_scrambler_update = TL_TX_DATA_READ_EN;

    sata_scrambler_seq output_scrambler (
        .clk_in         (phy_txclk_in),
        .reset_in       (output_scrambler_reset),
        .update_in      (output_scrambler_update),

        .sequence_out   (output_scrambler_sequence)
    );
        
//////////////////////

    assign ready_out = !reset_in;
    assign new_dword_out = is_new_dword;
    assign dword_out = OUT_DWORD_1;
    assign controls_out = OUT_CONTROLS_1;
    
endmodule
