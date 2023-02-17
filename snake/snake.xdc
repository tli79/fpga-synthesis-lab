# 12 MHz System Clock
set_property -dict { PACKAGE_PIN M9    IOSTANDARD LVCMOS33 } [get_ports { clk }]; #IO_L13P_T2_MRCC_14 Sch=gclk
create_clock -add -name sys_clk_pin -period 83.33 -waveform {0 41.66} [get_ports { clk }];

# Pmod Header JA
set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { red[0] }]; #IO_L14P_T2_SRCC_34 Sch=ja[1]
set_property -dict { PACKAGE_PIN H3    IOSTANDARD LVCMOS33 } [get_ports { red[1] }]; #IO_L13N_T2_MRCC_34 Sch=ja[7]
set_property -dict { PACKAGE_PIN H2    IOSTANDARD LVCMOS33 } [get_ports { green[0] }]; #IO_L14N_T2_SRCC_34 Sch=ja[2]
set_property -dict { PACKAGE_PIN H1    IOSTANDARD LVCMOS33 } [get_ports { green[1] }]; #IO_L12P_T1_MRCC_34 Sch=ja[8]
set_property -dict { PACKAGE_PIN H4    IOSTANDARD LVCMOS33 } [get_ports { blue[0] }]; #IO_L13P_T2_MRCC_34 Sch=ja[3]
set_property -dict { PACKAGE_PIN G1    IOSTANDARD LVCMOS33 } [get_ports { blue[1] }]; #IO_L12N_T1_MRCC_34 Sch=ja[9]
set_property -dict { PACKAGE_PIN F4    IOSTANDARD LVCMOS33 } [get_ports { hsync }]; #IO_L11P_T1_SRCC_34 Sch=ja[10]
set_property -dict { PACKAGE_PIN F3    IOSTANDARD LVCMOS33 } [get_ports { vsync }]; #IO_L11N_T1_SRCC_34 Sch=ja[4]

# Button inputs
set_property -dict { PACKAGE_PIN N13   IOSTANDARD LVCMOS33 } [get_ports { u_o }]; #IO_L8N_T1_D12_14 Sch=pio[18]
set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { u_i }]; #IO_L10N_T1_D15_14 Sch=pio[19]
set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { l_o }]; #IO_L7N_T1_D10_14 Sch=pio[26]
set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS33 } [get_ports { l_i }]; #IO_L4P_T0_D04_14 Sch=pio[27]
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { d_o }]; #IO_L5P_T0_D06_14 Sch=pio[28]
set_property -dict { PACKAGE_PIN L13   IOSTANDARD LVCMOS33 } [get_ports { d_i }]; #IO_L7P_T1_D09_14 Sch=pio[29]
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { r_o }]; #IO_L8P_T1_D11_14 Sch=pio[30]
set_property -dict { PACKAGE_PIN J11   IOSTANDARD LVCMOS33 } [get_ports { r_i }]; #IO_0_14 Sch=pio[31]

# USB UART
set_property -dict { PACKAGE_PIN L12   IOSTANDARD LVCMOS33 } [get_ports { tx }]; #IO_L6N_T0_D08_VREF_14 Sch=uart_rxd_out

set_property -dict { PACKAGE_PIN D2    IOSTANDARD LVCMOS33 } [get_ports { btn0 }]; #IO_L6P_T0_34 Sch=btn[0]
set_property -dict { PACKAGE_PIN D1    IOSTANDARD LVCMOS33 } [get_ports { btn1 }]; #IO_L6N_T0_VREF_34 Sch=btn[1]

set_property -dict { PACKAGE_PIN E2    IOSTANDARD LVCMOS33 } [get_ports { led0 }]; #IO_L8P_T1_34 Sch=led[1]
set_property -dict { PACKAGE_PIN K1    IOSTANDARD LVCMOS33 } [get_ports { led1 }]; #IO_L16P_T2_34 Sch=led[2]
