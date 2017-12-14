iverilog:
	iverilog -g2005 -I src/core   -f sve.f -g2005
	vvp a.out
