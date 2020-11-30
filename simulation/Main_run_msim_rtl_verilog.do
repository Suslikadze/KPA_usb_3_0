transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/NII_Televidenia/VSC_2 {D:/NII_Televidenia/VSC_2/Parameters.v}
vlog -vlog01compat -work work +incdir+D:/NII_Televidenia/VSC_2 {D:/NII_Televidenia/VSC_2/RAM_2_ports.v}
vlog -vlog01compat -work work +incdir+D:/NII_Televidenia/VSC_2 {D:/NII_Televidenia/VSC_2/N_line_buffer.v}

vlog -vlog01compat -work work +incdir+D:/NII_Televidenia/VSC_2/simulation/modelsim {D:/NII_Televidenia/VSC_2/simulation/modelsim/test_for_N_line_buffer.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  N_line_buffer_vlg_tst

add wave *
add wave -position end  sim:/generate_signal_vhd_tst/i1/x
add wave -position end  sim:/generate_signal_vhd_tst/i1/y
add wave -position end  sim:/generate_signal_vhd_tst/i1/FIFO_write_volume
add wave -position end  sim:/generate_signal_vhd_tst/i1/wrempty
add wave -position end  sim:/generate_signal_vhd_tst/i1/enable_for_FIFO_count
add wave -position end  sim:/generate_signal_vhd_tst/i1/enable_for_read_buffer
add wave -position end  sim:/generate_signal_vhd_tst/i1/enable_for_write_buffer
view structure
view signals
run -all
