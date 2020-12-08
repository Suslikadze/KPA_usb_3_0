transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/db {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/db/pll_altpll5.v}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/Megafunctions/PLL.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/Megafunctions/FIFO.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/Megafunctions/const.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/VIDEO_CONSTANTS.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/count_n_modul.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/BION_to_usb/Synth_gen.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/BION_to_usb/noise_gen.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/RAM_2_ports.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/BION_to_usb/Framing_interface.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/BION_to_usb/Data_processing_interface.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/my_component_pkg.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/BION_to_usb/sync_gen_mult.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/BION_to_usb/output_data_interface.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/BION_to_usb/JTAG_DEBUG_CONST.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/PATHERN_GENERATOR.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/TRS_gen.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/BION_to_usb/2_ch_to_1/two_ch_to_one_top.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/BION_to_usb/2_ch_to_1/mux_2_ch.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/BION_to_usb/2_ch_to_1/input_serial_channel.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/BION_to_usb/2_ch_to_1/Aligner.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/BION_to_usb/Data_gen_cam.vhd}
vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/BION_to_usb/BION_TOP.vhd}

vcom -93 -work work {D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/simulation/modelsim/BION_TOP_tst.vht}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev -L rtl_work -L work -voptargs="+acc"  BION_TOP_vhd_tst

do D:/Dima/Desktop/NIIT_tasks/USB_3_0_KPA_4_cameras/simulation/wave.do
