transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vcom -93 -work work {to_usb.vho}

vcom -93 -work work {D:/Dima/Desktop/USB_3_0/simulation/modelsim/generate_signal.vht}

vsim -t 1ps -L altera -L cycloneive -L gate_work -L work -voptargs="+acc"  generate_signal_vhd_tst

do D:/Dima/Desktop/USB_3_0/simulation/wave.do
