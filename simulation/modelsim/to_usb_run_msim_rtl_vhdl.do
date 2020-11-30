transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+D:/Dima/Desktop/USB_3_0_KPA/db {D:/Dima/Desktop/USB_3_0_KPA/db/pll_altpll5.v}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/VIDEO_CONSTANTS.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/count_n_modul.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/BION_to_usb/noise_gen.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/Megafunctions/PLL.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/Megafunctions/FIFO.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/Megafunctions/const.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/BION_to_usb/BION_TOP.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/my_component_pkg.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/BION_to_usb/Synth_gen.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/BION_to_usb/output_data_interface.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/BION_to_usb/JTAG_DEBUG_CONST.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/BION_to_usb/data_generation.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/BION_to_usb/2_ch_to_1/two_ch_to_one_top.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/BION_to_usb/2_ch_to_1/mux_2_ch.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/BION_to_usb/2_ch_to_1/input_serial_channel.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/BION_to_usb/2_ch_to_1/Aligner.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/Camera_simulation/TRS_gen.vhd}
vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/pathern_generator.vhd}

vcom -2008 -work work {D:/Dima/Desktop/USB_3_0_KPA/simulation/modelsim/BION_TOP_tst.vht}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneive -L rtl_work -L work -voptargs="+acc"  BION_TOP_vhd_tst

add wave *
view structure
view signals
run -all
