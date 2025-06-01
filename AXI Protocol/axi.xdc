###############################################################################
# Complete AXI Interface Constraints for ZC7Z014S
# Date: 2025-06-01 10:50:09
# Author: NOSEBLE3D
###############################################################################

#------------------------------------------------------------------------------
# Clock Constraint
#------------------------------------------------------------------------------
set_property PACKAGE_PIN F7 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]

#------------------------------------------------------------------------------
# Reset
#------------------------------------------------------------------------------
set_property PACKAGE_PIN T14 [get_ports reset]

#------------------------------------------------------------------------------
# Write Address Channel
#------------------------------------------------------------------------------
# AWADDR[31:0]
set_property PACKAGE_PIN V10 [get_ports {AWADDR[31]}]
set_property PACKAGE_PIN V9  [get_ports {AWADDR[30]}]
set_property PACKAGE_PIN V8  [get_ports {AWADDR[29]}]
set_property PACKAGE_PIN W8  [get_ports {AWADDR[28]}]
set_property PACKAGE_PIN W11 [get_ports {AWADDR[27]}]
set_property PACKAGE_PIN W10 [get_ports {AWADDR[26]}]
set_property PACKAGE_PIN V12 [get_ports {AWADDR[25]}]
set_property PACKAGE_PIN W12 [get_ports {AWADDR[24]}]
set_property PACKAGE_PIN U12 [get_ports {AWADDR[23]}]
set_property PACKAGE_PIN U11 [get_ports {AWADDR[22]}]
set_property PACKAGE_PIN U10 [get_ports {AWADDR[21]}]
set_property PACKAGE_PIN U9  [get_ports {AWADDR[20]}]
set_property PACKAGE_PIN AA12 [get_ports {AWADDR[19]}]
set_property PACKAGE_PIN AB12 [get_ports {AWADDR[18]}]
set_property PACKAGE_PIN AA11 [get_ports {AWADDR[17]}]
set_property PACKAGE_PIN AB11 [get_ports {AWADDR[16]}]
set_property PACKAGE_PIN AB10 [get_ports {AWADDR[15]}]
set_property PACKAGE_PIN AB9  [get_ports {AWADDR[14]}]
set_property PACKAGE_PIN Y11  [get_ports {AWADDR[13]}]
set_property PACKAGE_PIN Y10  [get_ports {AWADDR[12]}]
set_property PACKAGE_PIN AA9  [get_ports {AWADDR[11]}]
set_property PACKAGE_PIN AA8  [get_ports {AWADDR[10]}]
set_property PACKAGE_PIN Y9   [get_ports {AWADDR[9]}]
set_property PACKAGE_PIN Y8   [get_ports {AWADDR[8]}]
set_property PACKAGE_PIN Y6   [get_ports {AWADDR[7]}]
set_property PACKAGE_PIN Y5   [get_ports {AWADDR[6]}]
set_property PACKAGE_PIN AA7  [get_ports {AWADDR[5]}]
set_property PACKAGE_PIN AA6  [get_ports {AWADDR[4]}]
set_property PACKAGE_PIN AB2  [get_ports {AWADDR[3]}]
set_property PACKAGE_PIN AB1  [get_ports {AWADDR[2]}]
set_property PACKAGE_PIN AB5  [get_ports {AWADDR[1]}]
set_property PACKAGE_PIN AB4  [get_ports {AWADDR[0]}]

# AWLEN[7:0]
set_property PACKAGE_PIN AB7 [get_ports {AWLEN[7]}]
set_property PACKAGE_PIN AB6 [get_ports {AWLEN[6]}]
set_property PACKAGE_PIN Y4  [get_ports {AWLEN[5]}]
set_property PACKAGE_PIN AA4 [get_ports {AWLEN[4]}]
set_property PACKAGE_PIN R6  [get_ports {AWLEN[3]}]
set_property PACKAGE_PIN T6  [get_ports {AWLEN[2]}]
set_property PACKAGE_PIN T4  [get_ports {AWLEN[1]}]
set_property PACKAGE_PIN U4  [get_ports {AWLEN[0]}]

# AWSIZE[2:0]
set_property PACKAGE_PIN V5 [get_ports {AWSIZE[2]}]
set_property PACKAGE_PIN V4 [get_ports {AWSIZE[1]}]
set_property PACKAGE_PIN U6 [get_ports {AWSIZE[0]}]

# AWBURST[1:0]
set_property PACKAGE_PIN U5 [get_ports {AWBURST[1]}]
set_property PACKAGE_PIN V7 [get_ports {AWBURST[0]}]

set_property PACKAGE_PIN W7 [get_ports AWVALID]
set_property PACKAGE_PIN W6 [get_ports AWREADY]

#------------------------------------------------------------------------------
# Write Data Channel
#------------------------------------------------------------------------------
# WDATA[31:0]
set_property PACKAGE_PIN W5  [get_ports {WDATA[31]}]
set_property PACKAGE_PIN U7  [get_ports {WDATA[30]}]
set_property PACKAGE_PIN U19 [get_ports {WDATA[29]}]
set_property PACKAGE_PIN T21 [get_ports {WDATA[28]}]
set_property PACKAGE_PIN U21 [get_ports {WDATA[27]}]
set_property PACKAGE_PIN T22 [get_ports {WDATA[26]}]
set_property PACKAGE_PIN U22 [get_ports {WDATA[25]}]
set_property PACKAGE_PIN V22 [get_ports {WDATA[24]}]
set_property PACKAGE_PIN W22 [get_ports {WDATA[23]}]
set_property PACKAGE_PIN W20 [get_ports {WDATA[22]}]
set_property PACKAGE_PIN W21 [get_ports {WDATA[21]}]
set_property PACKAGE_PIN U20 [get_ports {WDATA[20]}]
set_property PACKAGE_PIN V20 [get_ports {WDATA[19]}]
set_property PACKAGE_PIN V18 [get_ports {WDATA[18]}]
set_property PACKAGE_PIN V19 [get_ports {WDATA[17]}]
set_property PACKAGE_PIN AA22 [get_ports {WDATA[16]}]
set_property PACKAGE_PIN AB22 [get_ports {WDATA[15]}]
set_property PACKAGE_PIN AA21 [get_ports {WDATA[14]}]
set_property PACKAGE_PIN AB21 [get_ports {WDATA[13]}]
set_property PACKAGE_PIN Y20  [get_ports {WDATA[12]}]
set_property PACKAGE_PIN Y21  [get_ports {WDATA[11]}]
set_property PACKAGE_PIN AB19 [get_ports {WDATA[10]}]
set_property PACKAGE_PIN AB20 [get_ports {WDATA[9]}]
set_property PACKAGE_PIN Y19  [get_ports {WDATA[8]}]
set_property PACKAGE_PIN AA19 [get_ports {WDATA[7]}]
set_property PACKAGE_PIN Y18  [get_ports {WDATA[6]}]
set_property PACKAGE_PIN AA18 [get_ports {WDATA[5]}]
set_property PACKAGE_PIN W17  [get_ports {WDATA[4]}]
set_property PACKAGE_PIN W18  [get_ports {WDATA[3]}]
set_property PACKAGE_PIN W16  [get_ports {WDATA[2]}]
set_property PACKAGE_PIN Y16  [get_ports {WDATA[1]}]
set_property PACKAGE_PIN U15  [get_ports {WDATA[0]}]

set_property PACKAGE_PIN U16 [get_ports WVALID]
set_property PACKAGE_PIN U17 [get_ports WREADY]
set_property PACKAGE_PIN V17 [get_ports WLAST]

#------------------------------------------------------------------------------
# Write Response Channel
#------------------------------------------------------------------------------
set_property PACKAGE_PIN AA17 [get_ports BRESP]
set_property PACKAGE_PIN AB17 [get_ports BVALID]
set_property PACKAGE_PIN AA16 [get_ports BREADY]

#------------------------------------------------------------------------------
# Read Address Channel
#------------------------------------------------------------------------------
# ARADDR[31:0]
set_property PACKAGE_PIN AB16 [get_ports {ARADDR[31]}]
set_property PACKAGE_PIN V14  [get_ports {ARADDR[30]}]
set_property PACKAGE_PIN V15  [get_ports {ARADDR[29]}]
set_property PACKAGE_PIN V13  [get_ports {ARADDR[28]}]
set_property PACKAGE_PIN W13  [get_ports {ARADDR[27]}]
set_property PACKAGE_PIN W15  [get_ports {ARADDR[26]}]
set_property PACKAGE_PIN Y15  [get_ports {ARADDR[25]}]
set_property PACKAGE_PIN Y14  [get_ports {ARADDR[24]}]
set_property PACKAGE_PIN AA14 [get_ports {ARADDR[23]}]
set_property PACKAGE_PIN Y13  [get_ports {ARADDR[22]}]
set_property PACKAGE_PIN AA13 [get_ports {ARADDR[21]}]
set_property PACKAGE_PIN AB14 [get_ports {ARADDR[20]}]
set_property PACKAGE_PIN AB15 [get_ports {ARADDR[19]}]
set_property PACKAGE_PIN U14  [get_ports {ARADDR[18]}]
set_property PACKAGE_PIN H15  [get_ports {ARADDR[17]}]
set_property PACKAGE_PIN J15  [get_ports {ARADDR[16]}]
set_property PACKAGE_PIN K15  [get_ports {ARADDR[15]}]
set_property PACKAGE_PIN J16  [get_ports {ARADDR[14]}]
set_property PACKAGE_PIN J17  [get_ports {ARADDR[13]}]
set_property PACKAGE_PIN K16  [get_ports {ARADDR[12]}]
set_property PACKAGE_PIN L16  [get_ports {ARADDR[11]}]
set_property PACKAGE_PIN L17  [get_ports {ARADDR[10]}]
set_property PACKAGE_PIN M17  [get_ports {ARADDR[9]}]
set_property PACKAGE_PIN N17  [get_ports {ARADDR[8]}]
set_property PACKAGE_PIN N18  [get_ports {ARADDR[7]}]
set_property PACKAGE_PIN M15  [get_ports {ARADDR[6]}]
set_property PACKAGE_PIN M16  [get_ports {ARADDR[5]}]
set_property PACKAGE_PIN J18  [get_ports {ARADDR[4]}]
set_property PACKAGE_PIN K18  [get_ports {ARADDR[3]}]
set_property PACKAGE_PIN J21  [get_ports {ARADDR[2]}]
set_property PACKAGE_PIN J22  [get_ports {ARADDR[1]}]
set_property PACKAGE_PIN J20  [get_ports {ARADDR[0]}]

# ARLEN[7:0]
set_property PACKAGE_PIN K21 [get_ports {ARLEN[7]}]
set_property PACKAGE_PIN L21 [get_ports {ARLEN[6]}]
set_property PACKAGE_PIN L22 [get_ports {ARLEN[5]}]
set_property PACKAGE_PIN K19 [get_ports {ARLEN[4]}]
set_property PACKAGE_PIN K20 [get_ports {ARLEN[3]}]
set_property PACKAGE_PIN L18 [get_ports {ARLEN[2]}]
set_property PACKAGE_PIN L19 [get_ports {ARLEN[1]}]
set_property PACKAGE_PIN M19 [get_ports {ARLEN[0]}]

# ARSIZE[2:0]
set_property PACKAGE_PIN M20 [get_ports {ARSIZE[2]}]
set_property PACKAGE_PIN N19 [get_ports {ARSIZE[1]}]
set_property PACKAGE_PIN N20 [get_ports {ARSIZE[0]}]

# ARBURST[1:0]
set_property PACKAGE_PIN M21 [get_ports {ARBURST[1]}]
set_property PACKAGE_PIN M22 [get_ports {ARBURST[0]}]

set_property PACKAGE_PIN N22 [get_ports ARVALID]
set_property PACKAGE_PIN P22 [get_ports ARREADY]

#------------------------------------------------------------------------------
# Read Data Channel
#------------------------------------------------------------------------------
# RDATA[31:0]
set_property PACKAGE_PIN R20 [get_ports {RDATA[31]}]
set_property PACKAGE_PIN R21 [get_ports {RDATA[30]}]
set_property PACKAGE_PIN P20 [get_ports {RDATA[29]}]
set_property PACKAGE_PIN P21 [get_ports {RDATA[28]}]
set_property PACKAGE_PIN N15 [get_ports {RDATA[27]}]
set_property PACKAGE_PIN P15 [get_ports {RDATA[26]}]
set_property PACKAGE_PIN P17 [get_ports {RDATA[25]}]
set_property PACKAGE_PIN P18 [get_ports {RDATA[24]}]
set_property PACKAGE_PIN T16 [get_ports {RDATA[23]}]
set_property PACKAGE_PIN T17 [get_ports {RDATA[22]}]
set_property PACKAGE_PIN R19 [get_ports {RDATA[21]}]
set_property PACKAGE_PIN T19 [get_ports {RDATA[20]}]
set_property PACKAGE_PIN R18 [get_ports {RDATA[19]}]
set_property PACKAGE_PIN T18 [get_ports {RDATA[18]}]
set_property PACKAGE_PIN P16 [get_ports {RDATA[17]}]
set_property PACKAGE_PIN R16 [get_ports {RDATA[16]}]
set_property PACKAGE_PIN R15 [get_ports {RDATA[15]}]
set_property PACKAGE_PIN H17 [get_ports {RDATA[14]}]
set_property PACKAGE_PIN F16 [get_ports {RDATA[13]}]
set_property PACKAGE_PIN E16 [get_ports {RDATA[12]}]
set_property PACKAGE_PIN D16 [get_ports {RDATA[11]}]
set_property PACKAGE_PIN D17 [get_ports {RDATA[10]}]
set_property PACKAGE_PIN E15 [get_ports {RDATA[9]}]
set_property PACKAGE_PIN D15 [get_ports {RDATA[8]}]
set_property PACKAGE_PIN G15 [get_ports {RDATA[7]}]
set_property PACKAGE_PIN G16 [get_ports {RDATA[6]}]
set_property PACKAGE_PIN F18 [get_ports {RDATA[5]}]
set_property PACKAGE_PIN E18 [get_ports {RDATA[4]}]
set_property PACKAGE_PIN G17 [get_ports {RDATA[3]}]
set_property PACKAGE_PIN F17 [get_ports {RDATA[2]}]
set_property PACKAGE_PIN C15 [get_ports {RDATA[1]}]
set_property PACKAGE_PIN B15 [get_ports {RDATA[0]}]

set_property PACKAGE_PIN B16 [get_ports RRESP]
set_property PACKAGE_PIN B17 [get_ports RLAST]
set_property PACKAGE_PIN A16 [get_ports RVALID]
set_property PACKAGE_PIN A17 [get_ports RREADY]

#------------------------------------------------------------------------------
# Set IOSTANDARD for all pins
#------------------------------------------------------------------------------
set_property IOSTANDARD LVCMOS33 [get_ports *]