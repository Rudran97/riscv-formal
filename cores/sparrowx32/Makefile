FLAGS=--std=08 --ieee=standard -fexplicit -frelaxed --workdir=rtl/

get_rtl:
	mkdir -p rtl
	cp ~/Documents/01_Git_Projects/SparrowX32/rtl/*.vhd rtl/
	cp tb_svx32_core.vhd rtl/

compile_rtl: get_rtl
	ghdl -a $(FLAGS) --work=work_rtl rtl/options_pkg.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/mul_unsigned_block.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/int_mul_div_pkg.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/int_alu_pkg.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/core_pkg.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/controller.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/if_unit.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/mem_access_interface_module.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/sys_regiser_file.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/ma_wb_pkg.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/int_mul_div.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/int_alu.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/if_id_pkg.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/id_exe_pkg.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/exe_ma_pkg.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/decoder.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/data_forward_mux_reg.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/ma_unit.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/ma_wb_reg.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/if_id_reg.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/id_unit.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/id_exe_reg.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/exe_unit.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/exe_ma_reg.vhd
	ghdl -a $(FLAGS) --work=work_rtl rtl/svx32_core.vhd
	ghdl synth $(FLAGS) --work=work_rtl --out=verilog svx32_core > rtl/svx32_core.v
	# yosys -m ghdl -p 'ghdl svx32_core.vhd -e svx32_core rtl; write_verilog svx32_core.v'

complete: compile_rtl
	sby -f complete.sby

checks: compile_rtl
	python3 ../../checks/genchecks.py
	$(MAKE) -C checks

check: checks
	bash cexdata.sh
	cat cexdata-*/status.txt

clean:
	rm -f cexdata-*.zip
	rm -rf disasm.o disasm.s checks/ cexdata-*/ rtl/ complete/
	rm -f testbug*.cfg
	rm -rf testbug*/
