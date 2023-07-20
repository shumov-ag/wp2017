`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: #COMPANY# 
// Engineer: a.shumov
// 
// Create Date: 22.12.2017 23:58:36
// Design Name: 
// Module Name: top
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


`define GT0_OOB_DEBUG (* mark_debug = "true" *)
`define GT0_DEBUG (* mark_debug = "true" *)

`define GT1_OOB_DEBUG (* mark_debug = "true" *)
`define GT1_DEBUG (* mark_debug = "true" *)

module top #
(
    parameter EXAMPLE_LANE_WITH_START_CHAR         =   0,         // specifies lane with unique start frame char
    parameter EXAMPLE_SIM_GTRESET_SPEEDUP          =   "FALSE",    // simulation setting for GT SecureIP model
    parameter EXAMPLE_USE_CHIPSCOPE                =   0,         // Set to 1 to use Chipscope to drive resets
    parameter STABLE_CLOCK_PERIOD                  = 40

)
(
    input logic  Q0_CLK0_GTREFCLK_PAD_N_IN,
    input logic  Q0_CLK0_GTREFCLK_PAD_P_IN,
    input logic  CLK25MHZ,

    input  logic         RXN_IN0,
    input  logic         RXP_IN0,
    output logic         TXN_OUT0,
    output logic         TXP_OUT0,
    
    input  logic         RXN_IN1,
    input  logic         RXP_IN1,
    output logic         TXN_OUT1,
    output logic         TXP_OUT1,

    output logic LED6_Y,
    output logic LED5_Y,
    output logic LED4_B,
    output logic LED3_B,
    output logic LED2_W,
    output logic LED1_W,    

    output logic TRACK_DATA_OUT0,
    output logic TRACK_DATA_OUT1,
    
    output logic UART_TX,
//  output logic UART_RX,
    output logic UART_GND
);

    wire GT_DRP_CLK_ENABLE;
    wire GT_DRP_CLK = GT_DRP_CLK_ENABLE ? CLK25MHZ : 0;
    logic soft_reset_i;
    logic soft_reset_vio_i;

//************************** Register Declarations ****************************
    logic            gt_txfsmresetdone_i;
    logic            gt_rxfsmresetdone_i;

    logic            gt0_txfsmresetdone_i;
    logic            gt0_rxfsmresetdone_i;

    logic            gt1_txfsmresetdone_i;
    logic            gt1_rxfsmresetdone_i;

//---

//**************************** Wire Declarations ******************************//
    //------------------------ GT Wrapper Wires ------------------------------
    //________________________________________________________________________
    //________________________________________________________________________
    //GT0  (X0Y2)
    //-------------------------- Channel - DRP Ports  --------------------------
    logic    [8:0]   gt0_drpaddr_i;
    logic    [15:0]  gt0_drpdi_i;
    logic    [15:0]  gt0_drpdo_i;
    logic            gt0_drpen_i;
    logic            gt0_drprdy_i;
    logic            gt0_drpwe_i;
    //--------------------------- PCI Express Ports ----------------------------
    logic    [2:0]   gt0_rxrate_i;
    //------------------- RX Initialization and Reset Ports --------------------
    logic            gt0_eyescanreset_i;
    logic            gt0_rxuserrdy_i;
    //------------------------ RX Margin Analysis Ports ------------------------
    logic            gt0_eyescandataerror_i;
    logic            gt0_eyescantrigger_i;
    //----------------------------- Receive Ports ------------------------------
    logic            gt0_sigvalidclk_i;
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
`GT0_DEBUG    logic    [15:0]  gt0_rxdata_i;
    //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
    logic    [1:0]   gt0_rxchariscomma_i;
`GT0_DEBUG    logic    [1:0]   gt0_rxcharisk_i;
`GT0_DEBUG    logic    [1:0]   gt0_rxdisperr_i;
`GT0_DEBUG    logic    [1:0]   gt0_rxnotintable_i;
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    logic            gt0_gtprxn_i;
    logic            gt0_gtprxp_i;
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
    logic            gt0_rxdlysreset_i;
    logic            gt0_rxdlysresetdone_i;
    logic            gt0_rxphaligndone_i;
    logic            gt0_rxphdlyreset_i;
    logic    [4:0]   gt0_rxphmonitor_i;
    logic    [4:0]   gt0_rxphslipmonitor_i;
    logic            gt0_rxsyncallin_i;
    logic            gt0_rxsyncdone_i;
    logic            gt0_rxsyncin_i;
    logic            gt0_rxsyncmode_i;
    logic            gt0_rxsyncout_i;
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
    logic            gt0_rxbyteisaligned_i;
    logic            gt0_rxbyterealign_i;
    logic            gt0_rxcommadet_i;
    //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    logic    [14:0]  gt0_dmonitorout_i;
    //------------------ Receive Ports - RX Equailizer Ports -------------------
    logic            gt0_rxlpmhfhold_i;
    logic            gt0_rxlpmhfovrden_i;
    logic            gt0_rxlpmlfhold_i;
    //---------- Receive Ports - RX Fabric ClocK Output Control Ports ----------
    logic            gt0_rxratedone_i;
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    logic            gt0_rxoutclkfabric_i;
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
    logic            gt0_gtrxreset_i;
    logic            gt0_rxlpmreset_i;
    logic            gt0_rxpmareset_i;
    //----------------- Receive Ports - RX OOB Signaling ports -----------------
`GT0_OOB_DEBUG    logic            gt0_rxelecidle_i;
`GT0_OOB_DEBUG    logic            gt0_rxcomwakedet_i;
    //---------------- Receive Ports - RX OOB Signaling ports  -----------------
`GT0_OOB_DEBUG    logic            gt0_rxcominitdet_i;
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
`GT0_DEBUG    logic            gt0_rxresetdone_i;
    //------------------- TX Initialization and Reset Ports --------------------
    logic            gt0_gttxreset_i;
    logic            gt0_txuserrdy_i;
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
`GT1_DEBUG    logic   [15:0]   GT0_TXDATA;
    //------------------- Transmit Ports - PCI Express Ports -------------------
`GT0_OOB_DEBUG    logic            gt0_txelecidle_i;
    logic    [2:0]   gt0_txrate_i;
    //---------------- Transmit Ports - TX 8B/10B Encoder Ports ----------------
`GT1_DEBUG    logic    [1:0]   GT0_TXCHARISK;
    //---------------- Transmit Ports - TX Buffer Bypass Ports -----------------
    logic            gt0_txdlyen_i;
    logic            gt0_txdlysreset_i;
    logic            gt0_txdlysresetdone_i;
    logic            gt0_txphalign_i;
    logic            gt0_txphaligndone_i;
    logic            gt0_txphalignen_i;
    logic            gt0_txphdlyreset_i;
    logic            gt0_txphinit_i;
    logic            gt0_txphinitdone_i;
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    logic            gt0_gtptxn_i;
    logic            gt0_gtptxp_i;
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    logic            gt0_txoutclkfabric_i;
    logic            gt0_txoutclkpcs_i;
    logic            gt0_txratedone_i;
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
    logic            gt0_txresetdone_i;
    //---------------- Transmit Ports - TX OOB signalling Ports ----------------
`GT0_OOB_DEBUG    logic            gt0_txcomfinish_i;
`GT0_OOB_DEBUG    logic            gt0_txcominit_i;
    logic            gt0_rxcdrhold_i;
`GT0_OOB_DEBUG    logic            gt0_txcomwake_i;

    //____________________________COMMON PORTS________________________________
    //------------------------ Common Block - PLL Ports ------------------------
    logic            gt0_pll0lock_i;
    logic            gt0_pll0refclklost_i;
    logic            gt0_pll0reset_i;

    //----------------------------- Global Signals -----------------------------
    logic            gt0_tx_system_reset_c;
    logic            gt0_rx_system_reset_c;

     //--------------------------- User Clocks ---------------------------------
    logic            gt0_txusrclk_i; 
    logic            GT0_TXUSRCLK2; 
    logic            gt0_rxusrclk_i; 
    logic            GT0_RXUSRCLK2; 
    logic            gt0_txmmcm_lock_i;
    logic            gt0_txmmcm_reset_i;
 
    //--------------------------- Reference Clocks ----------------------------
    logic            q0_clk1_refclk_i;

    //--------------------- Frame check/gen Module Signals --------------------
    logic            gt0_matchn_i;
    logic            gt0_block_sync_i;
    logic            gt0_track_data_i;
    
    //--------------------- Chipscope Signals ---------------------------------
    logic            gt0_inc_in_i;
    logic    [15:0]  gt0_unscrambled_data_i;

    logic    [31:0]  gt0_tx_data_vio_async_in_i;
    logic    [31:0]  gt0_tx_data_vio_sync_in_i;
    logic    [31:0]  gt0_tx_data_vio_async_out_i;
    logic    [31:0]  gt0_tx_data_vio_sync_out_i;
    logic    [31:0]  gt0_rx_data_vio_async_in_i;
    logic    [31:0]  gt0_rx_data_vio_sync_in_i;
    logic    [31:0]  gt0_rx_data_vio_async_out_i;
    logic    [31:0]  gt0_rx_data_vio_sync_out_i;
    logic    [163:0] gt0_ila_in_i;
    logic    [31:0]  gt0_channel_drp_vio_async_in_i;
    logic    [31:0]  gt0_channel_drp_vio_sync_in_i;
    logic    [31:0]  gt0_channel_drp_vio_async_out_i;
    logic    [31:0]  gt0_channel_drp_vio_sync_out_i;
    logic    [31:0]  gt0_common_drp_vio_async_in_i;
    logic    [31:0]  gt0_common_drp_vio_sync_in_i;
    logic    [31:0]  gt0_common_drp_vio_async_out_i;
    logic    [31:0]  gt0_common_drp_vio_sync_out_i;
    
    
    
    //________________________________________________________________________
    //GT1  (X0Y3)
    //-------------------------- Channel - DRP Ports  --------------------------
    logic    [8:0]   gt1_drpaddr_i;
    logic    [15:0]  gt1_drpdi_i;
    logic    [15:0]  gt1_drpdo_i;
    logic            gt1_drpen_i;
    logic            gt1_drprdy_i;
    logic            gt1_drpwe_i;
    //--------------------------- PCI Express Ports ----------------------------
    logic    [2:0]   gt1_rxrate_i;
    //------------------- RX Initialization and Reset Ports --------------------
    logic            gt1_eyescanreset_i;
    logic            gt1_rxuserrdy_i;
    //------------------------ RX Margin Analysis Ports ------------------------
    logic            gt1_eyescandataerror_i;
    logic            gt1_eyescantrigger_i;
    //----------------------------- Receive Ports ------------------------------
    logic            gt1_sigvalidclk_i;
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
`GT1_DEBUG    logic    [15:0]  gt1_rxdata_i;
    //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
    logic    [1:0]   gt1_rxchariscomma_i;
`GT1_DEBUG    logic    [1:0]   gt1_rxcharisk_i;
`GT1_DEBUG    logic    [1:0]   gt1_rxdisperr_i;
`GT1_DEBUG    logic    [1:0]   gt1_rxnotintable_i;
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    logic            gt1_gtprxn_i;
    logic            gt1_gtprxp_i;
    //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
    logic            gt1_rxdlysreset_i;
    logic            gt1_rxdlysresetdone_i;
    logic            gt1_rxphaligndone_i;
    logic            gt1_rxphdlyreset_i;
    logic    [4:0]   gt1_rxphmonitor_i;
    logic    [4:0]   gt1_rxphslipmonitor_i;
    logic            gt1_rxsyncallin_i;
    logic            gt1_rxsyncdone_i;
    logic            gt1_rxsyncin_i;
    logic            gt1_rxsyncmode_i;
    logic            gt1_rxsyncout_i;
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
    logic            gt1_rxbyteisaligned_i;
    logic            gt1_rxbyterealign_i;
    logic            gt1_rxcommadet_i;
    //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    logic    [14:0]  gt1_dmonitorout_i;
    //------------------ Receive Ports - RX Equailizer Ports -------------------
    logic            gt1_rxlpmhfhold_i;
    logic            gt1_rxlpmhfovrden_i;
    logic            gt1_rxlpmlfhold_i;
    //---------- Receive Ports - RX Fabric ClocK Output Control Ports ----------
    logic            gt1_rxratedone_i;
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    logic            gt1_rxoutclkfabric_i;
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
    logic            gt1_gtrxreset_i;
    logic            gt1_rxlpmreset_i;
    logic            gt1_rxpmareset_i;
    //----------------- Receive Ports - RX OOB Signaling ports -----------------
`GT1_OOB_DEBUG    logic            gt1_rxelecidle_i;
`GT1_OOB_DEBUG    logic            gt1_rxcomwakedet_i;
    //---------------- Receive Ports - RX OOB Signaling ports  -----------------
`GT1_OOB_DEBUG    logic            gt1_rxcominitdet_i;
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
`GT1_DEBUG    logic            gt1_rxresetdone_i;
    //------------------- TX Initialization and Reset Ports --------------------
    logic            gt1_gttxreset_i;
    logic            gt1_txuserrdy_i;
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
`GT1_DEBUG    logic   [15:0]   GT1_TXDATA;
    //------------------- Transmit Ports - PCI Express Ports -------------------
`GT1_OOB_DEBUG    logic            gt1_txelecidle_i;
    logic    [2:0]   gt1_txrate_i;
    //---------------- Transmit Ports - TX 8B/10B Encoder Ports ----------------
`GT1_DEBUG    logic    [1:0]   GT1_TXCHARISK;
    //---------------- Transmit Ports - TX Buffer Bypass Ports -----------------
    logic            gt1_txdlyen_i;
    logic            gt1_txdlysreset_i;
    logic            gt1_txdlysresetdone_i;
    logic            gt1_txphalign_i;
    logic            gt1_txphaligndone_i;
    logic            gt1_txphalignen_i;
    logic            gt1_txphdlyreset_i;
    logic            gt1_txphinit_i;
    logic            gt1_txphinitdone_i;
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    logic            gt1_gtptxn_i;
    logic            gt1_gtptxp_i;
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    logic            gt1_txoutclkfabric_i;
    logic            gt1_txoutclkpcs_i;
    logic            gt1_txratedone_i;
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
    logic            gt1_txresetdone_i;
    //---------------- Transmit Ports - TX OOB signalling Ports ----------------
`GT1_OOB_DEBUG    logic            gt1_txcomfinish_i;
`GT1_OOB_DEBUG    logic            gt1_txcominit_i;
    logic            gt1_rxcdrhold_i;
`GT1_OOB_DEBUG    logic            gt1_txcomwake_i;

    //____________________________COMMON PORTS________________________________
    //------------------------ Common Block - PLL Ports ------------------------
    logic            gt1_pll0lock_i;
    logic            gt1_pll0refclklost_i;
    logic            gt1_pll0reset_i;

    //----------------------------- Global Signals -----------------------------
    logic            gt1_tx_system_reset_c;
    logic            gt1_rx_system_reset_c;
    
    //--------------------------- User Clocks ---------------------------------
    logic            gt1_txusrclk_i; 
    logic            GT1_TXUSRCLK2; 
    logic            gt1_rxusrclk_i; 
    logic            GT1_RXUSRCLK2; 
    logic            gt1_txmmcm_lock_i;
    logic            gt1_txmmcm_reset_i;
    
    //--------------------- Frame check/gen Module Signals --------------------
    logic            gt1_matchn_i;
    logic            gt1_block_sync_i;
    logic            gt1_track_data_i;
    
    logic            gt1_inc_in_i;
    logic    [15:0]  gt1_unscrambled_data_i;

   //--------------------- Chipscope Signals ---------------------------------
    logic    [31:0]  gt1_tx_data_vio_async_in_i;
    logic    [31:0]  gt1_tx_data_vio_sync_in_i;
    logic    [31:0]  gt1_tx_data_vio_async_out_i;
    logic    [31:0]  gt1_tx_data_vio_sync_out_i;
    logic    [31:0]  gt1_rx_data_vio_async_in_i;
    logic    [31:0]  gt1_rx_data_vio_sync_in_i;
    logic    [31:0]  gt1_rx_data_vio_async_out_i;
    logic    [31:0]  gt1_rx_data_vio_sync_out_i;
    logic    [163:0] gt1_ila_in_i;
    logic    [31:0]  gt1_channel_drp_vio_async_in_i;
    logic    [31:0]  gt1_channel_drp_vio_sync_in_i;
    logic    [31:0]  gt1_channel_drp_vio_async_out_i;
    logic    [31:0]  gt1_channel_drp_vio_sync_out_i;
    logic    [31:0]  gt1_common_drp_vio_async_in_i;
    logic    [31:0]  gt1_common_drp_vio_sync_in_i;
    logic    [31:0]  gt1_common_drp_vio_async_out_i;
    logic    [31:0]  gt1_common_drp_vio_sync_out_i;

        
    //----------------------------- Global Signals -----------------------------
    logic            tied_to_ground_i;
    logic    [63:0]  tied_to_ground_vec_i;
    logic            tied_to_vcc_i;
    logic    [7:0]   tied_to_vcc_vec_i;
    logic            GTTXRESET_IN;
    logic            GTRXRESET_IN;
    logic            PLL0RESET_IN;
    logic            PLL1RESET_IN;
    
    //--------------------- Chipscope Signals ---------------------------------
    logic    [35:0]  tx_data_vio_control_i;
    logic    [35:0]  rx_data_vio_control_i;
    logic    [35:0]  shared_vio_control_i;
    logic    [35:0]  ila_control_i;
    logic    [35:0]  channel_drp_vio_control_i;
    logic    [35:0]  common_drp_vio_control_i;
    logic    [31:0]  tx_data_vio_async_in_i;
    logic    [31:0]  tx_data_vio_sync_in_i;
    logic    [31:0]  tx_data_vio_async_out_i;
    logic    [31:0]  tx_data_vio_sync_out_i;
    logic    [31:0]  rx_data_vio_async_in_i;
    logic    [31:0]  rx_data_vio_sync_in_i;
    logic    [31:0]  rx_data_vio_async_out_i;
    logic    [31:0]  rx_data_vio_sync_out_i;
    logic    [31:0]  shared_vio_in_i;
    logic    [31:0]  shared_vio_out_i;
    logic    [163:0] ila_in_i;
    logic    [31:0]  channel_drp_vio_async_in_i;
    logic    [31:0]  channel_drp_vio_sync_in_i;
    logic    [31:0]  channel_drp_vio_async_out_i;
    logic    [31:0]  channel_drp_vio_sync_out_i;
    logic    [31:0]  common_drp_vio_async_in_i;
    logic    [31:0]  common_drp_vio_sync_in_i;
    logic    [31:0]  common_drp_vio_async_out_i;
    logic    [31:0]  common_drp_vio_sync_out_i;

    logic            gttxreset_i;
    logic            gtrxreset_i;
    
    logic            user_tx_reset_i;
    logic            user_rx_reset_i;
    logic            tx_vio_clk_i;
    logic            tx_vio_clk_mux_out_i;    
    logic            rx_vio_ila_clk_i;
    logic            rx_vio_ila_clk_mux_out_i;
    
    logic            pll0reset_i;
    logic            pll1reset_i;


//**************************** Main Body of Code *******************************

    //  Static signal Assigments    
    assign tied_to_ground_i      = 1'b0;
    assign tied_to_ground_vec_i  = 64'h0000000000000000;
    assign tied_to_vcc_i         = 1'b1;
    assign tied_to_vcc_vec_i     = 8'hff;


    //***********************************************************************//
    //                                                                       //
    //--------------------------- The GT Wrapper ----------------------------//
    //                                                                       //
    //***********************************************************************//
    gtwizard_0 GT_WRAPPER_i (
        .soft_reset_tx_in               (soft_reset_i),
        .soft_reset_rx_in               (soft_reset_i),
        .dont_reset_on_data_error_in    (tied_to_ground_i),
        .q0_clk0_gtrefclk_pad_n_in(Q0_CLK0_GTREFCLK_PAD_N_IN),
        .q0_clk0_gtrefclk_pad_p_in(Q0_CLK0_GTREFCLK_PAD_P_IN),
        //.gt0_tx_mmcm_lock_out           (gt0_txmmcm_lock_i),
        .gt0_tx_fsm_reset_done_out      (gt0_txfsmresetdone_i),
        .gt0_rx_fsm_reset_done_out      (gt0_rxfsmresetdone_i),
        .gt0_data_valid_in              (1'b1/*gt0_track_data_i*/),
 
        .gt0_txusrclk_out(gt0_txusrclk_i),
        .gt0_txusrclk2_out(GT0_TXUSRCLK2),
        .gt0_rxusrclk_out(gt0_rxusrclk_i),
        .gt0_rxusrclk2_out(GT0_RXUSRCLK2),

        //GT0  (X0Y3)
        //-------------------------- Channel - DRP Ports  --------------------------
        .gt0_drpaddr_in                 (gt0_drpaddr_i),
        .gt0_drpdi_in                   (gt0_drpdi_i),
        .gt0_drpdo_out                  (gt0_drpdo_i),
        .gt0_drpen_in                   (gt0_drpen_i),
        .gt0_drprdy_out                 (gt0_drprdy_i),
        .gt0_drpwe_in                   (gt0_drpwe_i),
        //--------------------------- PCI Express Ports ----------------------------
        .gt0_rxrate_in                  (gt0_rxrate_i),
        //------------------- RX Initialization and Reset Ports --------------------
        .gt0_eyescanreset_in            (tied_to_ground_i),
        .gt0_rxuserrdy_in               (gt0_rxuserrdy_i),
        //------------------------ RX Margin Analysis Ports ------------------------
        .gt0_eyescandataerror_out       (gt0_eyescandataerror_i),
        .gt0_eyescantrigger_in          (tied_to_ground_i),
        //----------------------------- Receive Ports ------------------------------
        .gt0_sigvalidclk_in             (gt0_sigvalidclk_i),
        //---------------- Receive Ports - FPGA RX Interface Ports -----------------
        .gt0_rxdata_out                 (gt0_rxdata_i),
        //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
        .gt0_rxchariscomma_out          (gt0_rxchariscomma_i),
        .gt0_rxcharisk_out              (gt0_rxcharisk_i),
        .gt0_rxdisperr_out              (gt0_rxdisperr_i),
        .gt0_rxnotintable_out           (gt0_rxnotintable_i),
        //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gt0_gtprxn_in                  (RXN_IN0),
        .gt0_gtprxp_in                  (RXP_IN0),
        //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
        //.gt0_rxphmonitor_out            (gt0_rxphmonitor_i),
        //.gt0_rxphslipmonitor_out        (gt0_rxphslipmonitor_i),
        //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        .gt0_rxbyteisaligned_out        (gt0_rxbyteisaligned_i),
        .gt0_rxbyterealign_out          (gt0_rxbyterealign_i),
        .gt0_rxcommadet_out             (gt0_rxcommadet_i),
        //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        .gt0_dmonitorout_out            (gt0_dmonitorout_i),
        //------------------ Receive Ports - RX Equailizer Ports -------------------
        .gt0_rxlpmhfhold_in             (tied_to_ground_i),
        .gt0_rxlpmhfovrden_in           (gt0_rxlpmhfovrden_i),
        .gt0_rxlpmlfhold_in             (tied_to_ground_i),
        //---------- Receive Ports - RX Fabric ClocK Output Control Ports ----------
        .gt0_rxratedone_out             (gt0_rxratedone_i),
        //------------- Receive Ports - RX Fabric Output Control Ports -------------
        .gt0_rxoutclkfabric_out         (gt0_rxoutclkfabric_i),
        //----------- Receive Ports - RX Initialization and Reset Ports ------------
        .gt0_gtrxreset_in               (tied_to_ground_i),
        .gt0_rxlpmreset_in              (gt0_rxlpmreset_i),
        .gt0_rxpmareset_in              (gt0_rxpmareset_i),
        //----------------- Receive Ports - RX OOB Signaling ports -----------------
        .gt0_rxelecidle_out            (gt0_rxelecidle_i),
        .gt0_rxcomwakedet_out           (gt0_rxcomwakedet_i),
        //---------------- Receive Ports - RX OOB Signaling ports  -----------------
        .gt0_rxcominitdet_out           (gt0_rxcominitdet_i),
        //------------ Receive Ports -RX Initialization and Reset Ports ------------
        .gt0_rxresetdone_out            (gt0_rxresetdone_i),
        //------------------- TX Initialization and Reset Ports --------------------
        .gt0_gttxreset_in               (tied_to_ground_i),
        .gt0_txuserrdy_in               (gt0_txuserrdy_i),
        //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
        .gt0_txdata_in                  (GT0_TXDATA),
        //------------------- Transmit Ports - PCI Express Ports -------------------
        .gt0_txelecidle_in              (gt0_txelecidle_i),
        .gt0_txrate_in                  (gt0_txrate_i),
        //---------------- Transmit Ports - TX 8B/10B Encoder Ports ----------------
        .gt0_txcharisk_in               (GT0_TXCHARISK),
        //------------- Transmit Ports - TX Configurable Driver Ports --------------
        .gt0_gtptxn_out                 (TXN_OUT0),
        .gt0_gtptxp_out                 (TXP_OUT0),
        //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        .gt0_txoutclkfabric_out         (gt0_txoutclkfabric_i),
        .gt0_txoutclkpcs_out            (gt0_txoutclkpcs_i),
        .gt0_txratedone_out             (gt0_txratedone_i),
        //----------- Transmit Ports - TX Initialization and Reset Ports -----------
        .gt0_txresetdone_out            (gt0_txresetdone_i),
        //---------------- Transmit Ports - TX OOB signalling Ports ----------------
        .gt0_txcomfinish_out            (gt0_txcomfinish_i),
        .gt0_txcominit_in               (gt0_txcominit_i),
        .gt0_rxcdrhold_in                (gt0_rxcdrhold_i),
        .gt0_txcomwake_in               (gt0_txcomwake_i),


        //____________________________COMMON PORTS________________________________
        .gt0_pll0reset_out(),
        .gt0_pll0outclk_out(),
        .gt0_pll0outrefclk_out(),
        .gt0_pll0lock_out(),
        .gt0_pll0refclklost_out(),    
        .gt0_pll1outclk_out(),
        .gt0_pll1outrefclk_out(),
        
        
        //.gt1_tx_mmcm_lock_out           (gt1_txmmcm_lock_i),
        .gt1_tx_fsm_reset_done_out      (gt1_txfsmresetdone_i),
        .gt1_rx_fsm_reset_done_out      (gt1_rxfsmresetdone_i),
        .gt1_data_valid_in              (1'b1/*gt1_track_data_i*/),
 
        .gt1_txusrclk_out(gt1_txusrclk_i),
        .gt1_txusrclk2_out(GT1_TXUSRCLK2),
        .gt1_rxusrclk_out(gt1_rxusrclk_i),
        .gt1_rxusrclk2_out(GT1_RXUSRCLK2),

        //GT1 (X0Y3)
        //-------------------------- Channel - DRP Ports  --------------------------
        .gt1_drpaddr_in                 (gt1_drpaddr_i),
        .gt1_drpdi_in                   (gt1_drpdi_i),
        .gt1_drpdo_out                  (gt1_drpdo_i),
        .gt1_drpen_in                   (gt1_drpen_i),
        .gt1_drprdy_out                 (gt1_drprdy_i),
        .gt1_drpwe_in                   (gt1_drpwe_i),
        //--------------------------- PCI Express Ports ----------------------------
        .gt1_rxrate_in                  (gt1_rxrate_i),
        //------------------- RX Initialization and Reset Ports --------------------
        .gt1_eyescanreset_in            (tied_to_ground_i),
        .gt1_rxuserrdy_in               (gt1_rxuserrdy_i),
        //------------------------ RX Margin Analysis Ports ------------------------
        .gt1_eyescandataerror_out       (gt1_eyescandataerror_i),
        .gt1_eyescantrigger_in          (tied_to_ground_i),
        //----------------------------- Receive Ports ------------------------------
        .gt1_sigvalidclk_in             (gt1_sigvalidclk_i),
        //---------------- Receive Ports - FPGA RX Interface Ports -----------------
        .gt1_rxdata_out                 (gt1_rxdata_i),
        //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
        .gt1_rxchariscomma_out          (gt1_rxchariscomma_i),
        .gt1_rxcharisk_out              (gt1_rxcharisk_i),
        .gt1_rxdisperr_out              (gt1_rxdisperr_i),
        .gt1_rxnotintable_out           (gt1_rxnotintable_i),
        //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gt1_gtprxn_in                  (RXN_IN1),
        .gt1_gtprxp_in                  (RXP_IN1),
        //----------------- Receive Ports - RX Buffer Bypass Ports -----------------
        //.gt1_rxphmonitor_out            (gt1_rxphmonitor_i),
        //.gt1_rxphslipmonitor_out        (gt1_rxphslipmonitor_i),
        //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        .gt1_rxbyteisaligned_out        (gt1_rxbyteisaligned_i),
        .gt1_rxbyterealign_out          (gt1_rxbyterealign_i),
        .gt1_rxcommadet_out             (gt1_rxcommadet_i),
        //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        .gt1_dmonitorout_out            (gt1_dmonitorout_i),
        //------------------ Receive Ports - RX Equailizer Ports -------------------
        .gt1_rxlpmhfhold_in             (tied_to_ground_i),
        .gt1_rxlpmhfovrden_in           (gt1_rxlpmhfovrden_i),
        .gt1_rxlpmlfhold_in             (tied_to_ground_i),
        //---------- Receive Ports - RX Fabric ClocK Output Control Ports ----------
        .gt1_rxratedone_out             (gt1_rxratedone_i),
        //------------- Receive Ports - RX Fabric Output Control Ports -------------
        .gt1_rxoutclkfabric_out         (gt1_rxoutclkfabric_i),
        //----------- Receive Ports - RX Initialization and Reset Ports ------------
        .gt1_gtrxreset_in               (tied_to_ground_i),
        .gt1_rxlpmreset_in              (gt1_rxlpmreset_i),
        .gt1_rxpmareset_in              (gt1_rxpmareset_i),
        //----------------- Receive Ports - RX OOB Signaling ports -----------------
        .gt1_rxelecidle_out            (gt1_rxelecidle_i),
        .gt1_rxcomwakedet_out           (gt1_rxcomwakedet_i),
        //---------------- Receive Ports - RX OOB Signaling ports  -----------------
        .gt1_rxcominitdet_out           (gt1_rxcominitdet_i),
        //------------ Receive Ports -RX Initialization and Reset Ports ------------
        .gt1_rxresetdone_out            (gt1_rxresetdone_i),
        //------------------- TX Initialization and Reset Ports --------------------
        .gt1_gttxreset_in               (tied_to_ground_i),
        .gt1_txuserrdy_in               (gt1_txuserrdy_i),
        //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
        .gt1_txdata_in                  (GT1_TXDATA),
        //------------------- Transmit Ports - PCI Express Ports -------------------
        .gt1_txelecidle_in              (gt1_txelecidle_i),
        .gt1_txrate_in                  (gt1_txrate_i),
        //---------------- Transmit Ports - TX 8B/10B Encoder Ports ----------------
        .gt1_txcharisk_in               (GT1_TXCHARISK),
        //------------- Transmit Ports - TX Configurable Driver Ports --------------
        .gt1_gtptxn_out                 (TXN_OUT1),
        .gt1_gtptxp_out                 (TXP_OUT1),
        //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        .gt1_txoutclkfabric_out         (gt1_txoutclkfabric_i),
        .gt1_txoutclkpcs_out            (gt1_txoutclkpcs_i),
        .gt1_txratedone_out             (gt1_txratedone_i),
        //----------- Transmit Ports - TX Initialization and Reset Ports -----------
        .gt1_txresetdone_out            (gt1_txresetdone_i),
        //---------------- Transmit Ports - TX OOB signalling Ports ----------------
        .gt1_txcomfinish_out            (gt1_txcomfinish_i),
        .gt1_txcominit_in               (gt1_txcominit_i),
        .gt1_rxcdrhold_in                (gt1_rxcdrhold_i),
        .gt1_txcomwake_in               (gt1_txcomwake_i),

        
        .sysclk_in(GT_DRP_CLK)
    );


//-------------------------------------------------------------------------------------
assign  gt0_sigvalidclk_i                    =  gt0_txusrclk_i;//0;!!!!!!!!!!
assign  gt0_rxlpmhfovrden_i                  =  tied_to_ground_i;
//assign  gt0_rxpmareset_i                     =  tied_to_ground_i;
assign  gt0_rxrate_i                         =  0;
assign  gt0_txrate_i                         =  0;

//------------------------------------------------------
assign gt0_rxlpmreset_i = 1'b0;
assign gt0_drpaddr_i = 9'd0;
assign gt0_drpdi_i = 16'd0;
assign gt0_drpen_i = 1'b0;
assign gt0_drpwe_i = 1'b0;
assign gt0_txuserrdy_i = 1'b1;//rrr > 2500000;
assign gt0_rxuserrdy_i = 1'b1;//rrr > 2500000;



//-------------------------------------------------------------------------------------
assign  gt1_sigvalidclk_i                    =  gt1_txusrclk_i;//0;!!!!!!!!!!
assign  gt1_rxlpmhfovrden_i                  =  tied_to_ground_i;
//assign  gt1_rxpmareset_i                     =  tied_to_ground_i;
assign  gt1_rxrate_i                         =  0;
assign  gt1_txrate_i                         =  0;

//------------------------------------------------------
assign gt1_rxlpmreset_i = 1'b0;
assign gt1_drpaddr_i = 9'd0;
assign gt1_drpdi_i = 16'd0;
assign gt1_drpen_i = 1'b0;
assign gt1_drpwe_i = 1'b0;
assign gt1_txuserrdy_i = 1'b1;//rrr > 2500000;
assign gt1_rxuserrdy_i = 1'b1;//rrr > 2500000;



//assign soft_reset_i = tied_to_ground_i;

//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

    /*********************************************************************************/
    wire sata_phy_host_reset;
    wire sata_phy_device_reset;
    wire sata_phy_host_oob_sync_ready;
    wire sata_phy_device_oob_sync_ready;
    
    
    /*********************************************************************************/
    wire sata_phy_host_ready;
    wire        sata_host_phy_rxpmareset;
    wire        sata_host_phy_to_link_new_dword;
    wire [31:0] sata_host_phy_to_link_dword;
    wire [3:0]  sata_host_phy_to_link_controls;
    wire        sata_host_link_to_phy_new_dword;
    wire [31:0] sata_host_link_to_phy_dword;
    wire [3:0]  sata_host_link_to_phy_controls;
        
    sata_phy_host sata_phy_host_i (
        .reset_in                   (sata_phy_host_reset),

        .oob_sync_complete_out      (sata_phy_host_oob_sync_ready),
        .ready_out                  (sata_phy_host_ready),

        .gt_rxclk_in                (GT1_RXUSRCLK2),
        .gt_rxdata_in               (gt1_rxdata_i),
        .gt_rxcharisk_in            (gt1_rxcharisk_i),
        .gt_rxdataerr_in            (gt1_rxdisperr_i | gt1_rxnotintable_i),
        .gt_rxcominit_in            (gt1_rxcominitdet_i),
        .gt_rxcomwake_in            (gt1_rxcomwakedet_i),
        .gt_rxelecidle_in           (gt1_rxelecidle_i),
        .gt_rxresetdone_in          (gt1_rxresetdone_i),

        .gt_txclk_in                (GT1_TXUSRCLK2),
        .gt_txdata_out              (GT1_TXDATA),
        .gt_txcharisk_out           (GT1_TXCHARISK),
        .gt_txcomreset_out          (gt1_txcominit_i),
        .gt_txcomwake_out           (gt1_txcomwake_i),
        .gt_txelecidle_out          (gt1_txelecidle_i),
        .gt_rxcdrhold_out           (gt1_rxcdrhold_i),
        .gt_rxpmareset_out          (sata_host_phy_rxpmareset),

        .sata_new_dword_in          (sata_host_link_to_phy_new_dword),
        .sata_dword_in              (sata_host_link_to_phy_dword),
        .sata_controls_in           (sata_host_link_to_phy_controls),

        .sata_new_dword_out         (sata_host_phy_to_link_new_dword),
        .sata_dword_out             (sata_host_phy_to_link_dword),
        .sata_controls_out          (sata_host_phy_to_link_controls)
    );


    wire sata_phy_device_ready;
    wire        sata_device_phy_rxpmareset;
    wire        sata_device_phy_to_link_new_dword;
    wire [31:0] sata_device_phy_to_link_dword;
    wire [3:0]  sata_device_phy_to_link_controls;
    wire        sata_device_link_to_phy_new_dword;
    wire [31:0] sata_device_link_to_phy_dword;
    wire [3:0]  sata_device_link_to_phy_controls;

    sata_phy_device sata_phy_device_i (
        .reset_in                   (sata_phy_device_reset),

        .oob_sync_complete_out      (sata_phy_device_oob_sync_ready),
        .ready_out                  (sata_phy_device_ready),

        .gt_rxclk_in                (GT0_RXUSRCLK2),
        .gt_rxcomreset_in           (gt0_rxcominitdet_i),
        .gt_rxcomwake_in            (gt0_rxcomwakedet_i),
        .gt_rxelecidle_in           (gt0_rxelecidle_i),
        .gt_rxresetdone_in          (gt0_rxresetdone_i),
        .gt_rxdata_in               (gt0_rxdata_i),
        .gt_rxcharisk_in            (gt0_rxcharisk_i),
        .gt_rxdataerr_in            (gt0_rxdisperr_i | gt0_rxnotintable_i),

        .gt_txclk_in                (GT0_TXUSRCLK2),
        .gt_txdata_out              (GT0_TXDATA),
        .gt_txcharisk_out           (GT0_TXCHARISK),
        .gt_txcominit_out           (gt0_txcominit_i),
        .gt_txcomwake_out           (gt0_txcomwake_i),
        .gt_txelecidle_out          (gt0_txelecidle_i),
        .gt_rxcdrhold_out           (gt0_rxcdrhold_i),
        .gt_rxpmareset_out          (sata_device_phy_rxpmareset),
        
        .sata_new_dword_in          (sata_device_link_to_phy_new_dword),
        .sata_dword_in              (sata_device_link_to_phy_dword),
        .sata_controls_in           (sata_device_link_to_phy_controls),

        .sata_new_dword_out         (sata_device_phy_to_link_new_dword),
        .sata_dword_out             (sata_device_phy_to_link_dword),
        .sata_controls_out          (sata_device_phy_to_link_controls)
    );
    

    /*********************************************************************************/
    wire        sata_host_ex_notify_x_rdy;
    wire        sata_host_ex_notify_r_rdy;
    wire        sata_host_ex_notify_dmat;
    wire        sata_host_ex_notify_sync;
    wire        sata_host_ex_notify_r_ok;
    wire        sata_host_ex_notify_r_err;
    wire        sata_host_ex_notify_phyrdy = sata_phy_device_ready;
    
    wire        sata_device_ex_notify_x_rdy;
    wire        sata_device_ex_notify_r_rdy;
    wire        sata_device_ex_notify_dmat;
    wire        sata_device_ex_notify_sync;
    wire        sata_device_ex_notify_r_ok;
    wire        sata_device_ex_notify_r_err;
    wire        sata_device_ex_notify_phyrdy = sata_phy_host_ready;
    
    
    /*********************************************************************************/
    wire sata_link_host_ready;
    wire        sata_host_rxstream_fifo_full;
    wire        sata_host_rxstream_reset;
    wire [35:0] sata_host_rxstream;
    wire        sata_host_rxstream_wr_en;
    wire        sata_host_txstream_fifo_empty;
    wire [35:0] sata_host_txstream;
    wire        sata_host_txstream_rd_en;

    
    sata_link #(
        .LINK_TYPE                  ("HOST")
    ) sata_link_host_i (
        .reset_in                   (1'b0),
        .phy_ready_in               (sata_phy_host_ready),

        .ready_out                  (sata_link_host_ready),

        .phy_rxclk_in               (GT1_RXUSRCLK2),
        .new_dword_in               (sata_host_phy_to_link_new_dword),
        .dword_in                   (sata_host_phy_to_link_dword),
        .controls_in                (sata_host_phy_to_link_controls),
        
        .phy_txclk_in               (GT1_TXUSRCLK2),        
        .new_dword_out              (sata_host_link_to_phy_new_dword),
        .dword_out                  (sata_host_link_to_phy_dword),
        .controls_out               (sata_host_link_to_phy_controls),
        
        .rxstream_fifo_full_in      (sata_host_rxstream_fifo_full),
        .txstream_fifo_empty_in     (sata_host_txstream_fifo_empty),
        .txstream_in                (sata_host_txstream),
        .ex_notify_x_rdy_in         (sata_host_ex_notify_x_rdy),
        .ex_notify_r_rdy_in         (sata_host_ex_notify_r_rdy),
        .ex_notify_dmat_in          (sata_host_ex_notify_dmat),
        .ex_notify_sync_in          (sata_host_ex_notify_sync),
        .ex_notify_r_ok_in          (sata_host_ex_notify_r_ok),
        .ex_notify_r_err_in         (sata_host_ex_notify_r_err),
        .ex_notify_phyrdy_in        (sata_host_ex_notify_phyrdy),
    
        .rxstream_reset_out         (sata_host_rxstream_reset),
        .rxstream_out               (sata_host_rxstream),
        .rxstream_wr_en_out         (sata_host_rxstream_wr_en),
        .txstream_rd_en_out         (sata_host_txstream_rd_en),
        .ex_notify_x_rdy_out        (sata_device_ex_notify_x_rdy),
        .ex_notify_r_rdy_out        (sata_device_ex_notify_r_rdy),
        .ex_notify_dmat_out         (sata_device_ex_notify_dmat),
        .ex_notify_sync_out         (sata_device_ex_notify_sync),
        .ex_notify_r_ok_out         (sata_device_ex_notify_r_ok),
        .ex_notify_r_err_out        (sata_device_ex_notify_r_err)
    );
    
    
    wire sata_link_device_ready;
    wire        sata_device_rxstream_fifo_full;
    wire        sata_device_rxstream_reset;
    wire [35:0] sata_device_rxstream;
    wire        sata_device_rxstream_wr_en;
    wire        sata_device_txstream_fifo_empty;
    wire [35:0] sata_device_txstream;
    wire        sata_device_txstream_rd_en;
    
    sata_link #(
        .LINK_TYPE                  ("DEVICE")
    ) sata_link_device_i (
        .reset_in                   (1'b0),
        .phy_ready_in               (sata_phy_device_ready),

        .ready_out                  (sata_link_device_ready),

        .phy_rxclk_in               (GT0_RXUSRCLK2),
        .new_dword_in               (sata_device_phy_to_link_new_dword),
        .dword_in                   (sata_device_phy_to_link_dword),
        .controls_in                (sata_device_phy_to_link_controls),
        
        .phy_txclk_in               (GT0_TXUSRCLK2),        
        .new_dword_out              (sata_device_link_to_phy_new_dword),
        .dword_out                  (sata_device_link_to_phy_dword),
        .controls_out               (sata_device_link_to_phy_controls),
        
        .rxstream_fifo_full_in      (sata_device_rxstream_fifo_full),
        .txstream_fifo_empty_in     (sata_device_txstream_fifo_empty),
        .txstream_in                (sata_device_txstream),
        .ex_notify_x_rdy_in         (sata_device_ex_notify_x_rdy),
        .ex_notify_r_rdy_in         (sata_device_ex_notify_r_rdy),
        .ex_notify_dmat_in          (sata_device_ex_notify_dmat),
        .ex_notify_sync_in          (sata_device_ex_notify_sync),
        .ex_notify_r_ok_in          (sata_device_ex_notify_r_ok),
        .ex_notify_r_err_in         (sata_device_ex_notify_r_err),
        .ex_notify_phyrdy_in        (sata_device_ex_notify_phyrdy),

        .rxstream_reset_out         (sata_device_rxstream_reset),
        .rxstream_out               (sata_device_rxstream),
        .rxstream_wr_en_out         (sata_device_rxstream_wr_en),
        .txstream_rd_en_out         (sata_device_txstream_rd_en),
        .ex_notify_x_rdy_out        (sata_host_ex_notify_x_rdy),
        .ex_notify_r_rdy_out        (sata_host_ex_notify_r_rdy),
        .ex_notify_dmat_out         (sata_host_ex_notify_dmat),
        .ex_notify_sync_out         (sata_host_ex_notify_sync),
        .ex_notify_r_ok_out         (sata_host_ex_notify_r_ok),
        .ex_notify_r_err_out        (sata_host_ex_notify_r_err)
    );


    /*********************************************************************************/
    sata_transport_bridge sata_transport_bridge_i (
        .host_rx_link_ready_in      (~sata_host_rxstream_reset),
        .host_rx_clk_in             (GT1_RXUSRCLK2),
        .host_rx_stream_in          (sata_host_rxstream),
        .host_rx_wr_en_in           (sata_host_rxstream_wr_en),
        .host_rx_full_out           (sata_host_rxstream_fifo_full),
        
        .host_tx_link_ready_in      (1'b1),
        .host_tx_clk_in             (GT1_TXUSRCLK2),
        .host_tx_stream_in          (sata_host_txstream),
        .host_tx_rd_en_in           (sata_host_txstream_rd_en),
        .host_tx_empty_out          (sata_host_txstream_fifo_empty),
        
        .device_rx_link_ready_in    (~sata_device_rxstream_reset),
        .device_rx_clk_in           (GT0_RXUSRCLK2),
        .device_rx_stream_in        (sata_device_rxstream),
        .device_rx_wr_en_in         (sata_device_rxstream_wr_en),
        .device_rx_full_out         (sata_device_rxstream_fifo_full),
        
        .device_tx_link_ready_in    (1'b1),
        .device_tx_clk_in           (GT0_TXUSRCLK2),
        .device_tx_stream_in        (sata_device_txstream),
        .device_tx_rd_en_in         (sata_device_txstream_rd_en),
        .device_tx_empty_out        (sata_device_txstream_fifo_empty),
        
        .clk25mhz_in                (CLK25MHZ),
        
        .uart_tx_out                (UART_TX)
    );


    /*********************************************************************************/
    reg sata_host_phy_rxpmareset_1, sata_host_phy_rxpmareset_2;
    always @(posedge GT_DRP_CLK) begin
        sata_host_phy_rxpmareset_1 <= sata_host_phy_rxpmareset;
        sata_host_phy_rxpmareset_2 <= sata_host_phy_rxpmareset_1;
        gt1_rxpmareset_i <= sata_host_phy_rxpmareset_1 & ~sata_host_phy_rxpmareset_2; // Установить флаг rxpmareset на один цикл DRP_CLK 
    end

    reg sata_device_phy_rxpmareset_1, sata_device_phy_rxpmareset_2;
    always @(posedge GT_DRP_CLK) begin
        sata_device_phy_rxpmareset_1 <= sata_device_phy_rxpmareset;
        sata_device_phy_rxpmareset_2 <= sata_device_phy_rxpmareset_1;
        gt0_rxpmareset_i <= sata_device_phy_rxpmareset_1 & ~sata_device_phy_rxpmareset_2; // Установить флаг rxpmareset на один цикл DRP_CLK
    end

    
    /*********************************************************************************/
    reg gt1_rxcominitdet_1, gt1_rxcominitdet_2;
    always @(posedge GT1_RXUSRCLK2) begin
        gt1_rxcominitdet_1 <= gt1_rxcominitdet_i;
        gt1_rxcominitdet_2 <= gt1_rxcominitdet_1;
    end
    
    reg gt0_rxcominitdet_1, gt0_rxcominitdet_2;
    always @(posedge GT0_RXUSRCLK2) begin
        gt0_rxcominitdet_1 <= gt0_rxcominitdet_i;
        gt0_rxcominitdet_2 <= gt0_rxcominitdet_1;
    end
    
    assign sata_phy_host_reset = sata_phy_host_ready/*sata_phy_host_oob_sync_ready*/ & gt0_rxcominitdet_2 & ~gt0_rxcominitdet_1;// Сбросить хост-phy при приходе COMRESET на девайс-phy (по заднему фронту сигнала)
    assign sata_phy_device_reset = sata_phy_device_ready/*sata_phy_device_oob_sync_ready*/ & gt1_rxcominitdet_2 & ~gt1_rxcominitdet_1;// Сбросить девайс-phy при приходе COMINIT на хост-phy (по заднему фронту сигнала)


    /*********************************************************************************/
    assign TRACK_DATA_OUT1 = (gt1_rxnotintable_i == 0) && (gt1_rxdisperr_i == 0) && sata_phy_host_ready;//green
    assign TRACK_DATA_OUT0 = (gt0_rxnotintable_i == 0) && (gt0_rxdisperr_i == 0) && sata_phy_device_ready;//red


    /*********************************************************************************/
    /*Здесь происходит задержка в формировании тактового сигнала на MGT при старте*/
    reg [32:0] START_DELAY_CNT;
    always @(posedge CLK25MHZ) begin
        if (~GT_DRP_CLK_ENABLE) begin
            START_DELAY_CNT = START_DELAY_CNT + 1;
        end
    end
    
    assign GT_DRP_CLK_ENABLE = START_DELAY_CNT > 1_000_000;

    assign UART_GND = 0;

    /*********************************************************************************/
    reg [32:0] DBG_CNT;
    reg [4:0] DBG_LED_NUM;
    always @(posedge CLK25MHZ) begin
        DBG_CNT = DBG_CNT + 1;
        if (DBG_CNT > 12500000) begin
            DBG_CNT = 0;
            DBG_LED_NUM = DBG_LED_NUM + 1;
        end
        
        if (DBG_LED_NUM > 5) begin
            DBG_LED_NUM = 0;
        end
    end
    
    assign LED1_W = (DBG_LED_NUM == 0);
    assign LED2_W = (DBG_LED_NUM == 1);
    assign LED3_B = (DBG_LED_NUM == 2);
    assign LED4_B = (DBG_LED_NUM == 3);
    assign LED5_Y = (DBG_LED_NUM == 4);
    assign LED6_Y = (DBG_LED_NUM == 5);
    
endmodule
