
_add_menu main controls right SystemButtonFace black RUN_1uS   {run 1000000}
_add_menu main controls right SystemButtonFace blue RUN_10uS   {run 10000000}
_add_menu main controls right SystemButtonFace red  RUN_100uS  {run 100000000}
_add_menu main controls right SystemButtonFace green RUN_1mS   {run 1000000000}
_add_menu main controls right SystemButtonFace magenta  RUN_10mS   {run 10000000000}
_add_menu main controls right SystemButtonFace yellow  RUN_100mS   {run 100000000000}

onerror {resume}
quietly WaveActivateNextPane {} 0

onerror {resume}
quietly WaveActivateNextPane {} 0



add wave -noupdate -divider SYNC_GEN

add wave -position end                              sim:/camera_and_bion_top_vhd_tst/i1/Camera_simulation/clk_in
add wave -position end   -radix unsigned            sim:/camera_and_bion_top_vhd_tst/i1/Camera_simulation/Pix_per_line
add wave -position end   -radix unsigned            sim:/camera_and_bion_top_vhd_tst/i1/Camera_simulation/Line_per_frame




add wave -noupdate -divider Image_Sensor

add wave -noupdate -divider Interface
add wave -position end                              sim:/camera_and_bion_top_vhd_tst/i1/BION_component/slwr
add wave -position end                              sim:/camera_and_bion_top_vhd_tst/i1/BION_component/PCLK

add wave -noupdate -divider Testing
add wave -position end                              sim:/camera_and_bion_top_vhd_tst/i1/BION_component/two_ch_to_one_comp/align_num
add wave -position end                              sim:/camera_and_bion_top_vhd_tst/i1/BION_component/two_ch_to_one_comp/align_flag
add wave -position end                              sim:/camera_and_bion_top_vhd_tst/i1/BION_component/two_ch_to_one_comp/data_in_ch_1
add wave -position end                              sim:/camera_and_bion_top_vhd_tst/i1/BION_component/two_ch_to_one_comp/data_in_ch_2
add wave -position end                              sim:/camera_and_bion_top_vhd_tst/i1/BION_component/two_ch_to_one_comp/data_par_1
add wave -position end                              sim:/camera_and_bion_top_vhd_tst/i1/BION_component/two_ch_to_one_comp/data_par_2
add wave -position end                              sim:/camera_and_bion_top_vhd_tst/i1/BION_component/two_ch_to_one_comp/data_out

add wave -noupdate -divider Testing2
add wave -position end                              sim:/bion_top_vhd_tst/i1/data_generation_top/clk_in
add wave -position end                              sim:/bion_top_vhd_tst/i1/data_generation_top/debug_1
add wave -position end                              sim:/bion_top_vhd_tst/i1/data_generation_top/debug_2
add wave -position end                              sim:/bion_top_vhd_tst/i1/data_generation_top/Pix_per_line
add wave -position end                              sim:/bion_top_vhd_tst/i1/data_generation_top/Line_per_frame
add wave -position end                              sim:/bion_top_vhd_tst/i1/data_generation_top/window
add wave -position end                              sim:/bion_top_vhd_tst/i1/data_generation_top/data_generator_blanc
add wave -position end                              sim:/bion_top_vhd_tst/i1/data_generation_top/data_generator_out
