///////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version : 3.6
//  \   \         Application : 7 Series FPGAs Transceivers Wizard
//  /   /         Filename : gtwizard_0_multi_gt.v
// /___/   /\     
// \   \  /  \ 
//  \___\/\___\
//
//
// Module gtwizard_0_multi_gt (a Multi GT Wrapper)
// Generated by Xilinx 7 Series FPGAs Transceivers Wizard
// 
// 
// (c) Copyright 2010-2012 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 


`default_nettype wire

`timescale 1ns / 1ps
`define DLY #1

//***************************** Entity Declaration ****************************
(* DowngradeIPIdentifiedWarnings="yes" *)
(* CORE_GENERATION_INFO = "gtwizard_0_multi_gt,gtwizard_v3_6_7,{protocol_file=sata}" *) module gtwizard_0_multi_gt #
(
    // Simulation attributes
    parameter   EXAMPLE_SIMULATION       =   0,             // Set to 1 for Simulation
    parameter   WRAPPER_SIM_GTRESET_SPEEDUP    = "FALSE"    // Set to "TRUE" to speed up sim reset
)
(
    //_________________________________________________________________________
    //_________________________________________________________________________
    //GT0  (X0Y2)
    //____________________________CHANNEL PORTS________________________________
output gt0_drp_busy_out,
output gt0_rxpmaresetdone_out,
output gt0_txpmaresetdone_out,
    //-------------------------- Channel - DRP Ports  --------------------------
    input   [8:0]   gt0_drpaddr_in,
    input           gt0_drpclk_in,
    input   [15:0]  gt0_drpdi_in,
    output  [15:0]  gt0_drpdo_out,
    input           gt0_drpen_in,
    output          gt0_drprdy_out,
    input           gt0_drpwe_in,
    //--------------------------- PCI Express Ports ----------------------------
    input   [2:0]   gt0_rxrate_in,
    //------------------- RX Initialization and Reset Ports --------------------
    input           gt0_eyescanreset_in,
    input           gt0_rxuserrdy_in,
    //------------------------ RX Margin Analysis Ports ------------------------
    output          gt0_eyescandataerror_out,
    input           gt0_eyescantrigger_in,
    //----------------------------- Receive Ports ------------------------------
    input           gt0_sigvalidclk_in,
    //----------------------- Receive Ports - CDR Ports ------------------------
    input           gt0_rxcdrhold_in,
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    output  [15:0]  gt0_rxdata_out,
    input           gt0_rxusrclk_in,
    input           gt0_rxusrclk2_in,
    //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
    output  [1:0]   gt0_rxchariscomma_out,
    output  [1:0]   gt0_rxcharisk_out,
    output  [1:0]   gt0_rxdisperr_out,
    output  [1:0]   gt0_rxnotintable_out,
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    input           gt0_gtprxn_in,
    input           gt0_gtprxp_in,
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
    output          gt0_rxbyteisaligned_out,
    output          gt0_rxbyterealign_out,
    output          gt0_rxcommadet_out,
    //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    output  [14:0]  gt0_dmonitorout_out,
    //------------------ Receive Ports - RX Equailizer Ports -------------------
    input           gt0_rxlpmhfhold_in,
    input           gt0_rxlpmhfovrden_in,
    input           gt0_rxlpmlfhold_in,
    //---------- Receive Ports - RX Fabric ClocK Output Control Ports ----------
    output          gt0_rxratedone_out,
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    output          gt0_rxoutclk_out,
    output          gt0_rxoutclkfabric_out,
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
    input           gt0_gtrxreset_in,
    input           gt0_rxlpmreset_in,
    input           gt0_rxpmareset_in,
    //----------------- Receive Ports - RX OOB Signaling ports -----------------
    output          gt0_rxcomsasdet_out,
    output          gt0_rxcomwakedet_out,
    //---------------- Receive Ports - RX OOB Signaling ports  -----------------
    output          gt0_rxcominitdet_out,
    //---------------- Receive Ports - RX OOB signalling Ports -----------------
    output          gt0_rxelecidle_out,
    //--------------- Receive Ports - RX Polarity Control Ports ----------------
    input           gt0_rxpolarity_in,
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
    output          gt0_rxresetdone_out,
    //------------------- TX Initialization and Reset Ports --------------------
    input           gt0_gttxreset_in,
    input           gt0_txuserrdy_in,
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    input   [15:0]  gt0_txdata_in,
    input           gt0_txusrclk_in,
    input           gt0_txusrclk2_in,
    //------------------- Transmit Ports - PCI Express Ports -------------------
    input           gt0_txelecidle_in,
    input   [2:0]   gt0_txrate_in,
    //---------------- Transmit Ports - TX 8B/10B Encoder Ports ----------------
    input   [1:0]   gt0_txcharisk_in,
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    output          gt0_gtptxn_out,
    output          gt0_gtptxp_out,
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    output          gt0_txoutclk_out,
    output          gt0_txoutclkfabric_out,
    output          gt0_txoutclkpcs_out,
    output          gt0_txratedone_out,
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
    output          gt0_txresetdone_out,
    //---------------- Transmit Ports - TX OOB signalling Ports ----------------
    output          gt0_txcomfinish_out,
    input           gt0_txcominit_in,
    input           gt0_txcomwake_in,
    //--------------- Transmit Ports - TX Polarity Control Ports ---------------
    input           gt0_txpolarity_in,

    //_________________________________________________________________________
    //_________________________________________________________________________
    //GT1  (X0Y3)
    //____________________________CHANNEL PORTS________________________________
output gt1_drp_busy_out,
output gt1_rxpmaresetdone_out,
output gt1_txpmaresetdone_out,
    //-------------------------- Channel - DRP Ports  --------------------------
    input   [8:0]   gt1_drpaddr_in,
    input           gt1_drpclk_in,
    input   [15:0]  gt1_drpdi_in,
    output  [15:0]  gt1_drpdo_out,
    input           gt1_drpen_in,
    output          gt1_drprdy_out,
    input           gt1_drpwe_in,
    //--------------------------- PCI Express Ports ----------------------------
    input   [2:0]   gt1_rxrate_in,
    //------------------- RX Initialization and Reset Ports --------------------
    input           gt1_eyescanreset_in,
    input           gt1_rxuserrdy_in,
    //------------------------ RX Margin Analysis Ports ------------------------
    output          gt1_eyescandataerror_out,
    input           gt1_eyescantrigger_in,
    //----------------------------- Receive Ports ------------------------------
    input           gt1_sigvalidclk_in,
    //----------------------- Receive Ports - CDR Ports ------------------------
    input           gt1_rxcdrhold_in,
    //---------------- Receive Ports - FPGA RX Interface Ports -----------------
    output  [15:0]  gt1_rxdata_out,
    input           gt1_rxusrclk_in,
    input           gt1_rxusrclk2_in,
    //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
    output  [1:0]   gt1_rxchariscomma_out,
    output  [1:0]   gt1_rxcharisk_out,
    output  [1:0]   gt1_rxdisperr_out,
    output  [1:0]   gt1_rxnotintable_out,
    //---------------------- Receive Ports - RX AFE Ports ----------------------
    input           gt1_gtprxn_in,
    input           gt1_gtprxp_in,
    //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
    output          gt1_rxbyteisaligned_out,
    output          gt1_rxbyterealign_out,
    output          gt1_rxcommadet_out,
    //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
    output  [14:0]  gt1_dmonitorout_out,
    //------------------ Receive Ports - RX Equailizer Ports -------------------
    input           gt1_rxlpmhfhold_in,
    input           gt1_rxlpmhfovrden_in,
    input           gt1_rxlpmlfhold_in,
    //---------- Receive Ports - RX Fabric ClocK Output Control Ports ----------
    output          gt1_rxratedone_out,
    //------------- Receive Ports - RX Fabric Output Control Ports -------------
    output          gt1_rxoutclk_out,
    output          gt1_rxoutclkfabric_out,
    //----------- Receive Ports - RX Initialization and Reset Ports ------------
    input           gt1_gtrxreset_in,
    input           gt1_rxlpmreset_in,
    input           gt1_rxpmareset_in,
    //----------------- Receive Ports - RX OOB Signaling ports -----------------
    output          gt1_rxcomsasdet_out,
    output          gt1_rxcomwakedet_out,
    //---------------- Receive Ports - RX OOB Signaling ports  -----------------
    output          gt1_rxcominitdet_out,
    //---------------- Receive Ports - RX OOB signalling Ports -----------------
    output          gt1_rxelecidle_out,
    //--------------- Receive Ports - RX Polarity Control Ports ----------------
    input           gt1_rxpolarity_in,
    //------------ Receive Ports -RX Initialization and Reset Ports ------------
    output          gt1_rxresetdone_out,
    //------------------- TX Initialization and Reset Ports --------------------
    input           gt1_gttxreset_in,
    input           gt1_txuserrdy_in,
    //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
    input   [15:0]  gt1_txdata_in,
    input           gt1_txusrclk_in,
    input           gt1_txusrclk2_in,
    //------------------- Transmit Ports - PCI Express Ports -------------------
    input           gt1_txelecidle_in,
    input   [2:0]   gt1_txrate_in,
    //---------------- Transmit Ports - TX 8B/10B Encoder Ports ----------------
    input   [1:0]   gt1_txcharisk_in,
    //------------- Transmit Ports - TX Configurable Driver Ports --------------
    output          gt1_gtptxn_out,
    output          gt1_gtptxp_out,
    //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
    output          gt1_txoutclk_out,
    output          gt1_txoutclkfabric_out,
    output          gt1_txoutclkpcs_out,
    output          gt1_txratedone_out,
    //----------- Transmit Ports - TX Initialization and Reset Ports -----------
    output          gt1_txresetdone_out,
    //---------------- Transmit Ports - TX OOB signalling Ports ----------------
    output          gt1_txcomfinish_out,
    input           gt1_txcominit_in,
    input           gt1_txcomwake_in,
    //--------------- Transmit Ports - TX Polarity Control Ports ---------------
    input           gt1_txpolarity_in,


    //____________________________COMMON PORTS________________________________
input           gt0_pll0reset_in,
input           gt0_pll0outclk_in,
input           gt0_pll0outrefclk_in,
input           gt0_pll1outclk_in,
input           gt0_pll1outrefclk_in

);
//***************************** Parameter Declarations ************************
    localparam PLL0_FBDIV_IN      = 3;
    localparam PLL1_FBDIV_IN      = 1;
    localparam PLL0_FBDIV_45_IN   = 5;
    localparam PLL1_FBDIV_45_IN   = 4;
    localparam PLL0_REFCLK_DIV_IN = 1;
    localparam PLL1_REFCLK_DIV_IN = 1;


//***************************** Wire Declarations *****************************

    // ground and vcc signals
wire            tied_to_ground_i;
wire    [63:0]  tied_to_ground_vec_i;
wire            tied_to_vcc_i;
wire    [63:0]  tied_to_vcc_vec_i;
wire            gt0_pll0clk_i;
wire            gt0_pll0refclk_i;
wire            gt0_pll1clk_i;
wire            gt0_pll1refclk_i;
    wire            gt0_rst_i;
 
wire            gt1_pll0clk_i;
wire            gt1_pll0refclk_i;
wire            gt1_pll1clk_i;
wire            gt1_pll1refclk_i;
    wire            gt1_rst_i;
 
         
//********************************* Main Body of Code**************************

    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 64'h0000000000000000;
    assign tied_to_vcc_i                = 1'b1;
    assign tied_to_vcc_vec_i            = 64'hffffffffffffffff;


    assign  gt0_pll0clk_i    = gt0_pll0outclk_in;  
    assign  gt0_pll0refclk_i = gt0_pll0outrefclk_in; 
    assign  gt0_pll1clk_i    = gt0_pll1outclk_in;  
    assign  gt0_pll1refclk_i = gt0_pll1outrefclk_in; 
    assign  gt0_rst_i        = gt0_pll0reset_in;
      
   
    assign  gt1_pll0clk_i    = gt0_pll0outclk_in;  
    assign  gt1_pll0refclk_i = gt0_pll0outrefclk_in; 
    assign  gt1_pll1clk_i    = gt0_pll1outclk_in;  
    assign  gt1_pll1refclk_i = gt0_pll1outrefclk_in; 
    assign  gt1_rst_i        = gt0_pll0reset_in;
      
   
//------------------------- GT Instances  -------------------------------
    //_________________________________________________________________________
    //_________________________________________________________________________
    //GT0  (X0Y2)
    gtwizard_0_GT #
    (
        // Simulation attributes
        .GT_SIM_GTRESET_SPEEDUP   (WRAPPER_SIM_GTRESET_SPEEDUP),
        .EXAMPLE_SIMULATION       (EXAMPLE_SIMULATION),
        .TXSYNC_OVRD_IN           (1'b0),
        .TXSYNC_MULTILANE_IN      (1'b0) 
    )
gt0_gtwizard_0_i
    (
        .rst_in                         (gt0_rst_i),
        .drp_busy_out                   (gt0_drp_busy_out),
      
        .rxpmaresetdone                 (gt0_rxpmaresetdone_out),
        .txpmaresetdone                 (gt0_txpmaresetdone_out),
        //-------------------------- Channel - DRP Ports  --------------------------
        .drpaddr_in                     (gt0_drpaddr_in),
        .drpclk_in                      (gt0_drpclk_in),
        .drpdi_in                       (gt0_drpdi_in),
        .drpdo_out                      (gt0_drpdo_out),
        .drpen_in                       (gt0_drpen_in),
        .drprdy_out                     (gt0_drprdy_out),
        .drpwe_in                       (gt0_drpwe_in),
        //---------------------- GTPE2_CHANNEL Clocking Ports ----------------------
        .pll0clk_in                     (gt0_pll0clk_i),
        .pll0refclk_in                  (gt0_pll0refclk_i),
        .pll1clk_in                     (gt0_pll1clk_i),
        .pll1refclk_in                  (gt0_pll1refclk_i),
        //--------------------------- PCI Express Ports ----------------------------
        .rxrate_in                      (gt0_rxrate_in),
        //------------------- RX Initialization and Reset Ports --------------------
        .eyescanreset_in                (gt0_eyescanreset_in),
        .rxuserrdy_in                   (gt0_rxuserrdy_in),
        //------------------------ RX Margin Analysis Ports ------------------------
        .eyescandataerror_out           (gt0_eyescandataerror_out),
        .eyescantrigger_in              (gt0_eyescantrigger_in),
        //----------------------------- Receive Ports ------------------------------
        .sigvalidclk_in                 (gt0_sigvalidclk_in),
        //----------------------- Receive Ports - CDR Ports ------------------------
        .rxcdrhold_in                   (gt0_rxcdrhold_in),
        //---------------- Receive Ports - FPGA RX Interface Ports -----------------
        .rxdata_out                     (gt0_rxdata_out),
        .rxusrclk_in                    (gt0_rxusrclk_in),
        .rxusrclk2_in                   (gt0_rxusrclk2_in),
        //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
        .rxchariscomma_out              (gt0_rxchariscomma_out),
        .rxcharisk_out                  (gt0_rxcharisk_out),
        .rxdisperr_out                  (gt0_rxdisperr_out),
        .rxnotintable_out               (gt0_rxnotintable_out),
        //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gtprxn_in                      (gt0_gtprxn_in),
        .gtprxp_in                      (gt0_gtprxp_in),
        //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        .rxbyteisaligned_out            (gt0_rxbyteisaligned_out),
        .rxbyterealign_out              (gt0_rxbyterealign_out),
        .rxcommadet_out                 (gt0_rxcommadet_out),
        //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        .dmonitorout_out                (gt0_dmonitorout_out),
        //------------------ Receive Ports - RX Equailizer Ports -------------------
        .rxlpmhfhold_in                 (gt0_rxlpmhfhold_in),
        .rxlpmhfovrden_in               (gt0_rxlpmhfovrden_in),
        .rxlpmlfhold_in                 (gt0_rxlpmlfhold_in),
        //---------- Receive Ports - RX Fabric ClocK Output Control Ports ----------
        .rxratedone_out                 (gt0_rxratedone_out),
        //------------- Receive Ports - RX Fabric Output Control Ports -------------
        .rxoutclk_out                   (gt0_rxoutclk_out),
        .rxoutclkfabric_out             (gt0_rxoutclkfabric_out),
        //----------- Receive Ports - RX Initialization and Reset Ports ------------
        .gtrxreset_in                   (gt0_gtrxreset_in),
        .rxlpmreset_in                  (gt0_rxlpmreset_in),
        .rxpmareset_in                  (gt0_rxpmareset_in),
        //----------------- Receive Ports - RX OOB Signaling ports -----------------
        .rxcomsasdet_out                (gt0_rxcomsasdet_out),
        .rxcomwakedet_out               (gt0_rxcomwakedet_out),
        //---------------- Receive Ports - RX OOB Signaling ports  -----------------
        .rxcominitdet_out               (gt0_rxcominitdet_out),
        //---------------- Receive Ports - RX OOB signalling Ports -----------------
        .rxelecidle_out                 (gt0_rxelecidle_out),
        //--------------- Receive Ports - RX Polarity Control Ports ----------------
        .rxpolarity_in                  (gt0_rxpolarity_in),
        //------------ Receive Ports -RX Initialization and Reset Ports ------------
        .rxresetdone_out                (gt0_rxresetdone_out),
        //------------------- TX Initialization and Reset Ports --------------------
        .gttxreset_in                   (gt0_gttxreset_in),
        .txuserrdy_in                   (gt0_txuserrdy_in),
        //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
        .txdata_in                      (gt0_txdata_in),
        .txusrclk_in                    (gt0_txusrclk_in),
        .txusrclk2_in                   (gt0_txusrclk2_in),
        //------------------- Transmit Ports - PCI Express Ports -------------------
        .txelecidle_in                  (gt0_txelecidle_in),
        .txrate_in                      (gt0_txrate_in),
        //---------------- Transmit Ports - TX 8B/10B Encoder Ports ----------------
        .txcharisk_in                   (gt0_txcharisk_in),
        //------------- Transmit Ports - TX Configurable Driver Ports --------------
        .gtptxn_out                     (gt0_gtptxn_out),
        .gtptxp_out                     (gt0_gtptxp_out),
        //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        .txoutclk_out                   (gt0_txoutclk_out),
        .txoutclkfabric_out             (gt0_txoutclkfabric_out),
        .txoutclkpcs_out                (gt0_txoutclkpcs_out),
        .txratedone_out                 (gt0_txratedone_out),
        //----------- Transmit Ports - TX Initialization and Reset Ports -----------
        .txresetdone_out                (gt0_txresetdone_out),
        //---------------- Transmit Ports - TX OOB signalling Ports ----------------
        .txcomfinish_out                (gt0_txcomfinish_out),
        .txcominit_in                   (gt0_txcominit_in),
        .txcomwake_in                   (gt0_txcomwake_in),
        //--------------- Transmit Ports - TX Polarity Control Ports ---------------
        .txpolarity_in                  (gt0_txpolarity_in)

    );

    //_________________________________________________________________________
    //_________________________________________________________________________
    //GT1  (X0Y3)
    gtwizard_0_GT #
    (
        // Simulation attributes
        .GT_SIM_GTRESET_SPEEDUP   (WRAPPER_SIM_GTRESET_SPEEDUP),
        .EXAMPLE_SIMULATION       (EXAMPLE_SIMULATION),
        .TXSYNC_OVRD_IN           (1'b0),
        .TXSYNC_MULTILANE_IN      (1'b0) 
    )
gt1_gtwizard_0_i
    (
        .rst_in                         (gt1_rst_i),
        .drp_busy_out                   (gt1_drp_busy_out),
      
        .rxpmaresetdone                 (gt1_rxpmaresetdone_out),
        .txpmaresetdone                 (gt1_txpmaresetdone_out),
        //-------------------------- Channel - DRP Ports  --------------------------
        .drpaddr_in                     (gt1_drpaddr_in),
        .drpclk_in                      (gt1_drpclk_in),
        .drpdi_in                       (gt1_drpdi_in),
        .drpdo_out                      (gt1_drpdo_out),
        .drpen_in                       (gt1_drpen_in),
        .drprdy_out                     (gt1_drprdy_out),
        .drpwe_in                       (gt1_drpwe_in),
        //---------------------- GTPE2_CHANNEL Clocking Ports ----------------------
        .pll0clk_in                     (gt1_pll0clk_i),
        .pll0refclk_in                  (gt1_pll0refclk_i),
        .pll1clk_in                     (gt1_pll1clk_i),
        .pll1refclk_in                  (gt1_pll1refclk_i),
        //--------------------------- PCI Express Ports ----------------------------
        .rxrate_in                      (gt1_rxrate_in),
        //------------------- RX Initialization and Reset Ports --------------------
        .eyescanreset_in                (gt1_eyescanreset_in),
        .rxuserrdy_in                   (gt1_rxuserrdy_in),
        //------------------------ RX Margin Analysis Ports ------------------------
        .eyescandataerror_out           (gt1_eyescandataerror_out),
        .eyescantrigger_in              (gt1_eyescantrigger_in),
        //----------------------------- Receive Ports ------------------------------
        .sigvalidclk_in                 (gt1_sigvalidclk_in),
        //----------------------- Receive Ports - CDR Ports ------------------------
        .rxcdrhold_in                   (gt1_rxcdrhold_in),
        //---------------- Receive Ports - FPGA RX Interface Ports -----------------
        .rxdata_out                     (gt1_rxdata_out),
        .rxusrclk_in                    (gt1_rxusrclk_in),
        .rxusrclk2_in                   (gt1_rxusrclk2_in),
        //---------------- Receive Ports - RX 8B/10B Decoder Ports -----------------
        .rxchariscomma_out              (gt1_rxchariscomma_out),
        .rxcharisk_out                  (gt1_rxcharisk_out),
        .rxdisperr_out                  (gt1_rxdisperr_out),
        .rxnotintable_out               (gt1_rxnotintable_out),
        //---------------------- Receive Ports - RX AFE Ports ----------------------
        .gtprxn_in                      (gt1_gtprxn_in),
        .gtprxp_in                      (gt1_gtprxp_in),
        //------------ Receive Ports - RX Byte and Word Alignment Ports ------------
        .rxbyteisaligned_out            (gt1_rxbyteisaligned_out),
        .rxbyterealign_out              (gt1_rxbyterealign_out),
        .rxcommadet_out                 (gt1_rxcommadet_out),
        //---------- Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
        .dmonitorout_out                (gt1_dmonitorout_out),
        //------------------ Receive Ports - RX Equailizer Ports -------------------
        .rxlpmhfhold_in                 (gt1_rxlpmhfhold_in),
        .rxlpmhfovrden_in               (gt1_rxlpmhfovrden_in),
        .rxlpmlfhold_in                 (gt1_rxlpmlfhold_in),
        //---------- Receive Ports - RX Fabric ClocK Output Control Ports ----------
        .rxratedone_out                 (gt1_rxratedone_out),
        //------------- Receive Ports - RX Fabric Output Control Ports -------------
        .rxoutclk_out                   (gt1_rxoutclk_out),
        .rxoutclkfabric_out             (gt1_rxoutclkfabric_out),
        //----------- Receive Ports - RX Initialization and Reset Ports ------------
        .gtrxreset_in                   (gt1_gtrxreset_in),
        .rxlpmreset_in                  (gt1_rxlpmreset_in),
        .rxpmareset_in                  (gt1_rxpmareset_in),
        //----------------- Receive Ports - RX OOB Signaling ports -----------------
        .rxcomsasdet_out                (gt1_rxcomsasdet_out),
        .rxcomwakedet_out               (gt1_rxcomwakedet_out),
        //---------------- Receive Ports - RX OOB Signaling ports  -----------------
        .rxcominitdet_out               (gt1_rxcominitdet_out),
        //---------------- Receive Ports - RX OOB signalling Ports -----------------
        .rxelecidle_out                 (gt1_rxelecidle_out),
        //--------------- Receive Ports - RX Polarity Control Ports ----------------
        .rxpolarity_in                  (gt1_rxpolarity_in),
        //------------ Receive Ports -RX Initialization and Reset Ports ------------
        .rxresetdone_out                (gt1_rxresetdone_out),
        //------------------- TX Initialization and Reset Ports --------------------
        .gttxreset_in                   (gt1_gttxreset_in),
        .txuserrdy_in                   (gt1_txuserrdy_in),
        //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
        .txdata_in                      (gt1_txdata_in),
        .txusrclk_in                    (gt1_txusrclk_in),
        .txusrclk2_in                   (gt1_txusrclk2_in),
        //------------------- Transmit Ports - PCI Express Ports -------------------
        .txelecidle_in                  (gt1_txelecidle_in),
        .txrate_in                      (gt1_txrate_in),
        //---------------- Transmit Ports - TX 8B/10B Encoder Ports ----------------
        .txcharisk_in                   (gt1_txcharisk_in),
        //------------- Transmit Ports - TX Configurable Driver Ports --------------
        .gtptxn_out                     (gt1_gtptxn_out),
        .gtptxp_out                     (gt1_gtptxp_out),
        //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
        .txoutclk_out                   (gt1_txoutclk_out),
        .txoutclkfabric_out             (gt1_txoutclkfabric_out),
        .txoutclkpcs_out                (gt1_txoutclkpcs_out),
        .txratedone_out                 (gt1_txratedone_out),
        //----------- Transmit Ports - TX Initialization and Reset Ports -----------
        .txresetdone_out                (gt1_txresetdone_out),
        //---------------- Transmit Ports - TX OOB signalling Ports ----------------
        .txcomfinish_out                (gt1_txcomfinish_out),
        .txcominit_in                   (gt1_txcominit_in),
        .txcomwake_in                   (gt1_txcomwake_in),
        //--------------- Transmit Ports - TX Polarity Control Ports ---------------
        .txpolarity_in                  (gt1_txpolarity_in)

    );



endmodule

