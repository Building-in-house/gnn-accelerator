help: 
	@echo "run-bf16adder           ------> simulate bf 16adder"
	@echo "run-bf16multiplier ------> simulate bf16 multiplier"

run-bf16adder:
	iverilog -o bf16_adder_sim ../rtl/bf16_adder.v ../tb/bf16_adder_tb.v
	vvp bf16_adder_sim
	gtkwave bf16_adder_sim.vcd

run-bf16multiplier:
	iverilog -o bf16_multiplier_sim ../rtl/bf16_multiplier.v ../tb/bf16_multiplier_tb.v
	vvp bf16_multiplier_sim
	gtkwave bf16_multiplier_sim.vcd
