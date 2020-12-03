transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+D:/Dima/Desktop/NIIT\ tasks/USB_3_0_KPA\ -\ 4\ cameras/db {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/db/pll_altpll5.v}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/BION_to_usb/button_debounce/debounce.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/VIDEO_CONSTANTS.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/count_n_modul.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/BION_to_usb/noise_gen.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/Megafunctions/PLL.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/Megafunctions/FIFO.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/Megafunctions/const.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/my_component_pkg.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/BION_to_usb/Synth_gen.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/BION_to_usb/output_data_interface.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/BION_to_usb/JTAG_DEBUG_CONST.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/BION_to_usb/data_generation.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/BION_to_usb/2_ch_to_1/two_ch_to_one_top.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/BION_to_usb/2_ch_to_1/mux_2_ch.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/BION_to_usb/2_ch_to_1/input_serial_channel.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/BION_to_usb/2_ch_to_1/Aligner.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/TRS_gen.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/pathern_generator.vhd}
vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/BION_to_usb/BION_TOP.vhd}

vcom -2008 -work work {D:/Dima/Desktop/NIIT tasks/USB_3_0_KPA - 4 cameras/simulation/modelsim/BION_TOP_tst.vht}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev -L rtl_work -L work -voptargs="+acc"  BION_TOP_vhd_tst

add wave *
view structure
view signals
run -all
