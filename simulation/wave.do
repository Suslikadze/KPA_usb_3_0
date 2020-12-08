
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
add wave -position end                                  sim:/bion_top_vhd_tst/i1/Data_gen_cam_2/Type_of_data
add wave -position end                                  sim:/bion_top_vhd_tst/i1/Data_gen_cam_3/Type_of_data
add wave -position end                                  sim:/bion_top_vhd_tst/i1/Data_gen_cam_4/Type_of_data
add wave -position end                                  sim:/bion_top_vhd_tst/i1/Data_processing_interface_top/clk_cam
add wave -position end -radix unsigned                  sim:/bion_top_vhd_tst/i1/Data_processing_interface_top/clk_interface
add wave -position end -radix unsigned                  sim:/bion_top_vhd_tst/i1/Data_processing_interface_top/Pix_per_line_interface
add wave -position end                                  sim:/bion_top_vhd_tst/i1/Data_processing_interface_top/Line_per_frame_interface
add wave -position end                                  sim:/bion_top_vhd_tst/i1/Data_processing_interface_top/en_write_1
add wave -position end                                  sim:/bion_top_vhd_tst/i1/Data_processing_interface_top/en_write_2
add wave -position end                                  sim:/bion_top_vhd_tst/i1/Data_processing_interface_top/en_read
add wave -position end                                  sim:/bion_top_vhd_tst/i1/Data_processing_interface_top/address_write
add wave -position end                                  sim:/bion_top_vhd_tst/i1/Data_processing_interface_top/address_read
add wave -position end                                  sim:/bion_top_vhd_tst/i1/output_data_interface_arch/databus

add wave -noupdate -divider Testing


add wave -noupdate -divider Testing2

force -freeze sim:/bion_top_vhd_tst/i1/Data_gen_cam_1/Type_of_data 00000001 0
force -freeze sim:/bion_top_vhd_tst/i1/Data_gen_cam_2/Type_of_data 00000001 0
force -freeze sim:/bion_top_vhd_tst/i1/Data_gen_cam_3/Type_of_data 00000001 0
force -freeze sim:/bion_top_vhd_tst/i1/Data_gen_cam_4/Type_of_data 00000001 0