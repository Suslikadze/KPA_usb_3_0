transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vcom -93 -work work {Cyclone_V_revision.vho}

vcom -93 -work work {D:/Dima/Desktop/USB_3_0_KPA/simulation/modelsim/BION_TOP_tst.vht}

vsim -t 1ps -L altera -L altera_lnsim -L cyclonev -L gate_work -L work -voptargs="+acc"  BION_TOP_vhd_tst

add wave *
view structure
view signals
run -all
