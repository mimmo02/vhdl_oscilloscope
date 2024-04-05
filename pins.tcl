# Use all available processors and silence the associated warning
set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL

########################################################################
# Clocks
########################################################################

# set_location_assignment PIN_B11 -to clk_25_MHz
set_location_assignment PIN_T22 -to clk
set_global_assignment -name SDC_FILE ../scripts/clocks.sdc

# ########################################################################
# # Push buttons
# ########################################################################

set_location_assignment PIN_A11 -to n_reset
# set_location_assignment PIN_T2  -to
# set_location_assignment PIN_V3  -to 
# set_location_assignment PIN_G11 -to 
# set_location_assignment PIN_T21 -to 
# set_location_assignment PIN_T1  -to

# ########################################################################
# # SSD
# ########################################################################

# set_location_assignment PIN_N6  -to seg4_n[6]
# set_location_assignment PIN_M5  -to seg4_n[5]
# set_location_assignment PIN_N5  -to seg4_n[4]
# set_location_assignment PIN_M4  -to seg4_n[3]
# set_location_assignment PIN_M6  -to seg4_n[2]
# set_location_assignment PIN_N7  -to seg4_n[1]
# set_location_assignment PIN_L6  -to seg4_n[0]
# set_location_assignment PIN_P7  -to

# set_location_assignment PIN_T5  -to seg3_n[6]
# set_location_assignment PIN_R5  -to seg3_n[5]
# set_location_assignment PIN_T4  -to seg3_n[4]
# set_location_assignment PIN_J21 -to seg3_n[3]
# set_location_assignment PIN_R6  -to seg3_n[2]
# set_location_assignment PIN_P6  -to seg3_n[1]
# set_location_assignment PIN_P4  -to seg3_n[0]
# set_location_assignment PIN_P5  -to

# set_location_assignment PIN_R19 -to seg2_n[6]
# set_location_assignment PIN_N17 -to seg2_n[5]
# set_location_assignment PIN_R18 -to seg2_n[4]
# set_location_assignment PIN_P17 -to seg2_n[3]
# set_location_assignment PIN_N18 -to seg2_n[2]
# set_location_assignment PIN_N16 -to seg2_n[1]
# set_location_assignment PIN_N19 -to seg2_n[0]
# set_location_assignment PIN_V4  -to

# set_location_assignment PIN_R17 -to seg1_n[6]
# set_location_assignment PIN_H22 -to seg1_n[5]
# set_location_assignment PIN_Y2  -to seg1_n[4]
# set_location_assignment PIN_Y1  -to seg1_n[3]
# set_location_assignment PIN_W19 -to seg1_n[2]
# set_location_assignment PIN_T17 -to seg1_n[1]
# set_location_assignment PIN_T18 -to seg1_n[0]
# set_location_assignment PIN_U19 -to


########################################################################
# LED matrix
########################################################################

# set_location_assignment PIN_E21  -to columnAddress[3]
# set_location_assignment PIN_E22  -to columnAddress[2]
# set_location_assignment PIN_F21  -to columnAddress[1]
# set_location_assignment PIN_M22  -to columnAddress[0]

# set_location_assignment PIN_F22  -to rowRedLeds_b[0]
# set_location_assignment PIN_K19  -to rowRedLeds_b[1]
# set_location_assignment PIN_M21  -to rowRedLeds_b[2]
# set_location_assignment PIN_P22  -to rowRedLeds_b[3]
# set_location_assignment PIN_R22  -to rowRedLeds_b[4]
# set_location_assignment PIN_J22  -to rowRedLeds_b[5]
# set_location_assignment PIN_U20  -to rowRedLeds_b[6]
# set_location_assignment PIN_W22  -to rowRedLeds_b[7]
# set_location_assignment PIN_Y22  -to rowRedLeds_b[8]
# set_location_assignment PIN_AA21 -to rowRedLeds_b[9]

# set_location_assignment PIN_J17  -to rowGreenLeds_b[0]
# set_location_assignment PIN_K17  -to rowGreenLeds_b[1]
# set_location_assignment PIN_F17  -to rowGreenLeds_b[2]
# set_location_assignment PIN_M20  -to rowGreenLeds_b[3]
# set_location_assignment PIN_P21  -to rowGreenLeds_b[4]
# set_location_assignment PIN_R21  -to rowGreenLeds_b[5]
# set_location_assignment PIN_U22  -to rowGreenLeds_b[6]
# set_location_assignment PIN_V22  -to rowGreenLeds_b[7]
# set_location_assignment PIN_W21  -to rowGreenLeds_b[8]
# set_location_assignment PIN_Y21  -to rowGreenLeds_b[9]

# set_location_assignment PIN_J18  -to rowBlueLeds_b[0]
# set_location_assignment PIN_K18  -to rowBlueLeds_b[1]
# set_location_assignment PIN_M19  -to rowBlueLeds_b[2]
# set_location_assignment PIN_N20  -to rowBlueLeds_b[3]
# set_location_assignment PIN_P20  -to rowBlueLeds_b[4]
# set_location_assignment PIN_R20  -to rowBlueLeds_b[5]
# set_location_assignment PIN_U21  -to rowBlueLeds_b[6]
# set_location_assignment PIN_V21  -to rowBlueLeds_b[7]
# set_location_assignment PIN_W20  -to rowBlueLeds_b[8]
# set_location_assignment PIN_AA22 -to rowBlueLeds_b[9]

########################################################################
# Pmods
########################################################################

# PMOD 4
set_location_assignment PIN_J2 -to nCS_DA2
set_location_assignment PIN_H1 -to D0_DA2
set_location_assignment PIN_H5 -to D1_DA2
set_location_assignment PIN_F1 -to SCK_DA2
# set_location_assignment PIN_J1 -to PMOD4_B[7]
# set_location_assignment PIN_J3 -to PMOD4_B[8]
# set_location_assignment PIN_H2 -to PMOD4_B[9]
# set_location_assignment PIN_G3 -to PMOD4_B[10]