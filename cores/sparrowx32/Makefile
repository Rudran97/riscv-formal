
get_rtl:
	mkdir -p rtl
	cp ~/Documents/01_Git_Projects/SparrowX32/rtl/*.vhd rtl/

checks: get_rtl
	python3 ../../checks/genchecks.py
	$(MAKE) -C checks

check: checks
	bash cexdata.sh
	cat cexdata-*/status.txt

clean:
	rm -f cexdata-*.zip
	rm -rf disasm.o disasm.s checks/ cexdata-*/ rtl/
	rm -f testbug*.cfg
	rm -rf testbug*/
