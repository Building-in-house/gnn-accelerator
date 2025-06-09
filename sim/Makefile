help: 
	@echo "run-bf16adder ------> simulate bf16adder"

run-bf16adder:
	iverilog -o bf16_adder_sim ../rtl/bf16_adder.v ../tb/bf16_adder_tb.v
	vvp bf16_adder_sim
	gtkwave bf16_adder_sim.vcd

run-bf16multiplier:
