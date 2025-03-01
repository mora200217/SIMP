transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/jonathan/Documents/Universidad/Digital/SIMP/src/top_module {/home/jonathan/Documents/Universidad/Digital/SIMP/src/top_module/simp.v}

