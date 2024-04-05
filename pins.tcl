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
set_location_assignment PIN_T2  -to n_btn_sel_channel
set_location_assignment PIN_V3  -to n_btn_sel_parameter
set_location_assignment PIN_T21 -to n_btn_sel_acq_mode
set_location_assignment PIN_T1  -to n_btn_run
set_location_assignment PIN_W2  -to n_btn_plus
set_location_assignment PIN_E9  -to n_btn_minus

# ########################################################################
# # SSD
# ########################################################################

set_location_assignment PIN_N6  -to n_seg4[6]
set_location_assignment PIN_M5  -to n_seg4[5]
set_location_assignment PIN_N5  -to n_seg4[4]
set_location_assignment PIN_M4  -to n_seg4[3]
set_location_assignment PIN_M6  -to n_seg4[2]
set_location_assignment PIN_N7  -to n_seg4[1]
set_location_assignment PIN_L6  -to n_seg4[0]
# set_location_assignment PIN_P7  -to n_DP4

set_location_assignment PIN_T5  -to n_seg3[6]
set_location_assignment PIN_R5  -to n_seg3[5]
set_location_assignment PIN_T4  -to n_seg3[4]
set_location_assignment PIN_J21 -to n_seg3[3]
set_location_assignment PIN_R6  -to n_seg3[2]
set_location_assignment PIN_P6  -to n_seg3[1]
set_location_assignment PIN_P4  -to n_seg3[0]
# set_location_assignment PIN_P5  -to n_DP3

set_location_assignment PIN_R19 -to n_seg2[6]
set_location_assignment PIN_N17 -to n_seg2[5]
set_location_assignment PIN_R18 -to n_seg2[4]
set_location_assignment PIN_P17 -to n_seg2[3]
set_location_assignment PIN_N18 -to n_seg2[2]
set_location_assignment PIN_N16 -to n_seg2[1]
set_location_assignment PIN_N19 -to n_seg2[0]
# set_location_assignment PIN_V4  -to n_DP2

set_location_assignment PIN_R17 -to n_seg1[6]
set_location_assignment PIN_H22 -to n_seg1[5]
set_location_assignment PIN_Y2  -to n_seg1[4]
set_location_assignment PIN_Y1  -to n_seg1[3]
set_location_assignment PIN_W19 -to n_seg1[2]
set_location_assignment PIN_T17 -to n_seg1[1]
set_location_assignment PIN_T18 -to n_seg1[0]
# set_location_assignment PIN_U19 -to n_DP1


########################################################################
# LED matrix
########################################################################

set_location_assignment PIN_E21  -to columnAddress[3]
set_location_assignment PIN_E22  -to columnAddress[2]
set_location_assignment PIN_F21  -to columnAddress[1]
set_location_assignment PIN_M22  -to columnAddress[0]

set_location_assignment PIN_F22  -to rowRedLeds_b[0]
set_location_assignment PIN_K19  -to rowRedLeds_b[1]
set_location_assignment PIN_M21  -to rowRedLeds_b[2]
set_location_assignment PIN_P22  -to rowRedLeds_b[3]
set_location_assignment PIN_R22  -to rowRedLeds_b[4]
set_location_assignment PIN_J22  -to rowRedLeds_b[5]
set_location_assignment PIN_U20  -to rowRedLeds_b[6]
set_location_assignment PIN_W22  -to rowRedLeds_b[7]
set_location_assignment PIN_Y22  -to rowRedLeds_b[8]
set_location_assignment PIN_AA21 -to rowRedLeds_b[9]

set_location_assignment PIN_J17  -to rowGreenLeds_b[0]
set_location_assignment PIN_K17  -to rowGreenLeds_b[1]
set_location_assignment PIN_F17  -to rowGreenLeds_b[2]
set_location_assignment PIN_M20  -to rowGreenLeds_b[3]
set_location_assignment PIN_P21  -to rowGreenLeds_b[4]
set_location_assignment PIN_R21  -to rowGreenLeds_b[5]
set_location_assignment PIN_U22  -to rowGreenLeds_b[6]
set_location_assignment PIN_V22  -to rowGreenLeds_b[7]
set_location_assignment PIN_W21  -to rowGreenLeds_b[8]
set_location_assignment PIN_Y21  -to rowGreenLeds_b[9]

set_location_assignment PIN_J18  -to rowBlueLeds_b[0]
set_location_assignment PIN_K18  -to rowBlueLeds_b[1]
set_location_assignment PIN_M19  -to rowBlueLeds_b[2]
set_location_assignment PIN_N20  -to rowBlueLeds_b[3]
set_location_assignment PIN_P20  -to rowBlueLeds_b[4]
set_location_assignment PIN_R20  -to rowBlueLeds_b[5]
set_location_assignment PIN_U21  -to rowBlueLeds_b[6]
set_location_assignment PIN_V21  -to rowBlueLeds_b[7]
set_location_assignment PIN_W20  -to rowBlueLeds_b[8]
set_location_assignment PIN_AA22 -to rowBlueLeds_b[9]

########################################################################
# Pmods
########################################################################

# PMOD 1
set_location_assignment PIN_E13 -to GREEN
set_location_assignment PIN_E14 -to HDMI_CLOCK
set_location_assignment PIN_D15 -to HSYNC
# set_location_assignment PIN_F15 -to PMOD1_A[4]
set_location_assignment PIN_D13 -to RED
set_location_assignment PIN_F13 -to BLUE
set_location_assignment PIN_F14 -to ACTIVE_VIDEO
set_location_assignment PIN_E15 -to VSYNC

# PMOD 3
set_location_assignment PIN_E1 -to nCS_AD1
set_location_assignment PIN_E4 -to D0_AD1
set_location_assignment PIN_B1 -to D1_AD1
set_location_assignment PIN_C3 -to SCK_AD1
# set_location_assignment PIN_F2 -to PMOD3_B[7]
# set_location_assignment PIN_E3 -to PMOD3_B[8]
# set_location_assignment PIN_D2 -to PMOD3_B[9]
# set_location_assignment PIN_B2 -to PMOD3_B[10]

# PMOD 4
set_location_assignment PIN_J2 -to nCS_DA2
set_location_assignment PIN_H1 -to D0_DA2
set_location_assignment PIN_H5 -to D1_DA2
set_location_assignment PIN_F1 -to SCK_DA2
# set_location_assignment PIN_J1 -to PMOD4_B[7]
# set_location_assignment PIN_J3 -to PMOD4_B[8]
# set_location_assignment PIN_H2 -to PMOD4_B[9]
# set_location_assignment PIN_G3 -to PMOD4_B[10]