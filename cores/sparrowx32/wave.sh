#!/bin/bash
set -x #echo on

CHECK_TRACE="checks/${1}_ch0/engine_0/trace.vcd"

python3 disasm.py ${CHECK_TRACE}
gtkwave ${CHECK_TRACE}
