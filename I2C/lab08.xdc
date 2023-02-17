# 12 MHz System Clock
set_property -dict { PACKAGE_PIN M9    IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_14 Sch=gclk
create_clock -add -name sys_clk_pin -period 83.33 -waveform {0 41.66} [get_ports { clk }];

# Pmod Header JA
set_property -dict { PACKAGE_PIN H1    IOSTANDARD LVCMOS33 } [get_ports { srx }]; #IO_L12P_T1_MRCC_34 Sch=ja[8]
set_property -dict { PACKAGE_PIN H2    IOSTANDARD LVCMOS33 } [get_ports { stx }]; #IO_L14N_T2_SRCC_34 Sch=ja[2]
set_property -dict { PACKAGE_PIN H3    IOSTANDARD LVCMOS33 } [get_ports { nss }]; #IO_L13N_T2_MRCC_34 Sch=ja[7]
set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { sck }]; #IO_L14P_T2_SRCC_34 Sch=ja[1]
set_property -dict { PACKAGE_PIN F3    IOSTANDARD LVCMOS33 } [get_ports { sdi }]; #IO_L11N_T1_SRCC_34 Sch=ja[4]
set_property -dict { PACKAGE_PIN F4    IOSTANDARD LVCMOS33 } [get_ports { sdo }]; #IO_L11P_T1_SRCC_34 Sch=ja[10]
set_property -dict { PACKAGE_PIN H4    IOSTANDARD LVCMOS33 } [get_ports { scl }]; #IO_L13P_T2_MRCC_34 Sch=ja[3]
set_property -dict { PACKAGE_PIN G1    IOSTANDARD LVCMOS33 } [get_ports { sda }]; #IO_L12N_T1_MRCC_34 Sch=ja[9]

# USB UART
set_property -dict { PACKAGE_PIN L12   IOSTANDARD LVCMOS33 } [get_ports { tx }]; #IO_L6N_T0_D08_VREF_14 Sch=uart_rxd_out
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { rx }]; #IO_L5N_T0_D07_14 Sch=uart_txd_in
