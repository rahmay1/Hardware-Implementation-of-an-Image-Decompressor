# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave -uns UUT/UART_timer

add wave -divider -height 10 {SRAM signals}
add wave -dec UUT/SRAM_write_data
add wave -dec UUT/SRAM_read_data
add wave -bin UUT/SRAM_we_n
add wave -uns UUT/SRAM_address

add wave -divider -height 10 {Milestone 2 signals}
add wave -dec UUT/m2_inst/ReadData
add wave -dec UUT/m2_inst/Y_Address
add wave -dec UUT/m2_inst/SRAM_Address
add wave -dec UUT/m2_inst/flag
add wave -dec UUT/m2_inst/flag2
add wave -dec UUT/m2_inst/S0
add wave -dec UUT/m2_inst/S1
add wave -dec UUT/m2_inst/S2
add wave -dec UUT/m2_inst/S3
add wave -dec UUT/m2_inst/S0Acc
add wave -dec UUT/m2_inst/S1Acc
add wave -dec UUT/m2_inst/S2Acc
add wave -dec UUT/m2_inst/S3Acc
add wave -dec UUT/m2_inst/T0
add wave -dec UUT/m2_inst/T1
add wave -dec UUT/m2_inst/T2
add wave -dec UUT/m2_inst/T3
add wave -dec UUT/m2_inst/T0Acc
add wave -dec UUT/m2_inst/T1Acc
add wave -dec UUT/m2_inst/T2Acc
add wave -dec UUT/m2_inst/T3Acc
add wave -dec UUT/m2_inst/M1a
add wave -dec UUT/m2_inst/M1b
add wave -dec UUT/m2_inst/M1Result
add wave -dec UUT/m2_inst/M2a
add wave -dec UUT/m2_inst/M2b
add wave -dec UUT/m2_inst/M2Result
add wave -dec UUT/m2_inst/read_data_a
add wave -dec UUT/m2_inst/read_data_b
add wave -dec UUT/m2_inst/write_enable_a
add wave -dec UUT/m2_inst/write_enable_b
add wave -bin UUT/m2_inst/state
add wave -dec UUT/m2_inst/counter1
add wave -dec UUT/m2_inst/address_0a
add wave -dec UUT/m2_inst/address_0b
add wave -dec UUT/m2_inst/address_1a
add wave -dec UUT/m2_inst/address_1b
add wave -dec UUT/m2_inst/address_2a
add wave -dec UUT/m2_inst/address_2b
add wave -dec UUT/m2_inst/write_data_a
add wave -dec UUT/m2_inst/write_data_b
add wave -dec UUT/m2_inst/SReadAddress
add wave -dec UUT/m2_inst/SWriteAddress


add wave -divider -height 10 {Milestone 1 signals}
add wave -dec UUT/m1_inst/ReadData
add wave -bin UUT/m1_inst/state
add wave -dec UUT/m1_inst/flag1
add wave -dec UUT/m1_inst/n
add wave -dec UUT/m1_inst/n1
add wave -dec UUT/m1_inst/m
add wave UUT/m1_inst/UR
add wave UUT/m1_inst/VR
add wave -dec UUT/m1_inst/M1Result
add wave -dec UUT/m1_inst/M2Result
add wave -dec UUT/m1_inst/M3Result
add wave -dec UUT/m1_inst/M4Result
add wave -dec UUT/m1_inst/UoddStoreShifted
add wave -dec UUT/m1_inst/VoddStoreShifted
add wave -dec UUT/m1_inst/UoddStore
add wave -dec UUT/m1_inst/VoddStore
add wave UUT/m1_inst/YE
add wave UUT/m1_inst/YO
add wave UUT/m1_inst/YETemp
add wave UUT/m1_inst/YOTemp
add wave UUT/m1_inst/UEUO
add wave UUT/m1_inst/VEVO
add wave UUT/m1_inst/UEUO1
add wave UUT/m1_inst/VEVO1
add wave UUT/m1_inst/YEYO
add wave -dec UUT/m1_inst/UevenShifted
add wave -dec UUT/m1_inst/UoddShifted
add wave -dec UUT/m1_inst/VevenShifted
add wave -dec UUT/m1_inst/VoddShifted
add wave -dec UUT/m1_inst/RaccE
add wave -dec UUT/m1_inst/RaccO
add wave -dec UUT/m1_inst/GaccE
add wave -dec UUT/m1_inst/GaccO
add wave -dec UUT/m1_inst/BaccE
add wave -dec UUT/m1_inst/BaccO
add wave -dec UUT/m1_inst/RedE
add wave -dec UUT/m1_inst/RedO
add wave -dec UUT/m1_inst/GreenE
add wave -dec UUT/m1_inst/GreenO
add wave -dec UUT/m1_inst/BlueE
add wave -dec UUT/m1_inst/BlueO


