######################## Reference clock constraints ###########################
# Config clock
create_clock -period 5.000 [get_ports Q0_CLK0_GTREFCLK_PAD_P_IN]

# Config clock
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports CLK25MHZ]
create_clock -period 40.000 -name clk_pin_25MHz -waveform {0.000 20.000} -add [get_ports CLK25MHZ]

# Config memory
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

# Config voltges
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# Config package
set_property PACKAGE_PIN D11 [get_ports TRACK_DATA_OUT0]
set_property IOSTANDARD LVCMOS33 [get_ports TRACK_DATA_OUT0]
set_property DRIVE 4 [get_ports TRACK_DATA_OUT0]

set_property PACKAGE_PIN C12 [get_ports TRACK_DATA_OUT1]
set_property IOSTANDARD LVCMOS33 [get_ports TRACK_DATA_OUT1]
set_property DRIVE 4 [get_ports TRACK_DATA_OUT1]

# Config timing
set_false_path -to [get_pins -hierarchical -filter {NAME =~ sata_*_phy_rxpmareset_*_reg/D}]

# Config placement
set_property LOC GTPE2_CHANNEL_X0Y2 [get_cells GT_WRAPPER_i/inst/gtwizard_0_init_i/gtwizard_0_i/gt0_gtwizard_0_i/gtpe2_i]
set_property LOC GTPE2_CHANNEL_X0Y3 [get_cells GT_WRAPPER_i/inst/gtwizard_0_init_i/gtwizard_0_i/gt1_gtwizard_0_i/gtpe2_i]
set_property PACKAGE_PIN D6 [get_ports Q0_CLK0_GTREFCLK_PAD_P_IN]
set_property PACKAGE_PIN D5 [get_ports Q0_CLK0_GTREFCLK_PAD_N_IN]

# Advanced LEDs
set_property PACKAGE_PIN R13 [get_ports LED1_W]
set_property IOSTANDARD LVCMOS33 [get_ports LED1_W]
set_property DRIVE 4 [get_ports LED1_W]

set_property PACKAGE_PIN U15 [get_ports LED2_W]
set_property IOSTANDARD LVCMOS33 [get_ports LED2_W]
set_property DRIVE 4 [get_ports LED2_W]

set_property PACKAGE_PIN V16 [get_ports LED3_B]
set_property IOSTANDARD LVCMOS33 [get_ports LED3_B]
set_property DRIVE 4 [get_ports LED3_B]

set_property PACKAGE_PIN U16 [get_ports LED4_B]
set_property IOSTANDARD LVCMOS33 [get_ports LED4_B]
set_property DRIVE 4 [get_ports LED4_B]

set_property PACKAGE_PIN V17 [get_ports LED5_Y]
set_property IOSTANDARD LVCMOS33 [get_ports LED5_Y]
set_property DRIVE 4 [get_ports LED5_Y]

set_property PACKAGE_PIN U17 [get_ports LED6_Y]
set_property IOSTANDARD LVCMOS33 [get_ports LED6_Y]
set_property DRIVE 4 [get_ports LED6_Y]

set_property PACKAGE_PIN B16 [get_ports UART_TX]
set_property IOSTANDARD LVCMOS33 [get_ports UART_TX]
set_property DRIVE 4 [get_ports UART_TX]

#set_property PACKAGE_PIN B17 [get_ports UART_RX]
#set_property IOSTANDARD LVCMOS33 [get_ports UART_RX]
#set_property DRIVE 4 [get_ports UART_RX]

set_property PACKAGE_PIN C13 [get_ports UART_GND]
set_property IOSTANDARD LVCMOS33 [get_ports UART_GND]
set_property DRIVE 4 [get_ports UART_GND]

