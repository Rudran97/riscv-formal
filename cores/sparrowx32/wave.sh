#!/bin/bash
set -x #echo on

if [[ "$1" != "cover" ]]
then
	CHECK_TRACE="checks/${1}_ch0/engine_0/trace.vcd"
else
	CHECK_TRACE="checks/cover/engine_0/trace0.vcd"
fi

python3 disasm.py ${CHECK_TRACE}
gtkwave ${CHECK_TRACE}
