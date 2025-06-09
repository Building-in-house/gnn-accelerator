`timescale 1ns / 1ps

module tb_bf16_adder;

  // Inputs
  reg [15:0] a;
  reg [15:0] b;

  // Output
  wire [15:0] sum;

  // Instantiate the Unit Under Test (UUT)
  bf16_adder uut (
    .a(a),
    .b(b),
    .sum(sum)
  );

  initial begin
    // VCD waveform output
    $dumpfile("bf16_adder_sim.vcd");
    $dumpvars(0, tb_bf16_adder);

    $display("Time\t\tA\t\tB\t\tSUM");

    // Test 1: 1.5 (0x3fc0) + 2.5 (0x4020) = 4.0 (0x4080)
    a = 16'h3fc0; // 1.5 in BF16
    b = 16'h4020; // 2.5 in BF16
    #10 $display("%0dns:\t%h + %h = %h", $time, a, b, sum);

    // Test 2: -1.0 (0xbf80) + 1.0 (0x3f80) = 0
    a = 16'hbf80; // -1.0
    b = 16'h3f80; // +1.0
    #10 $display("%0dns:\t%h + %h = %h", $time, a, b, sum);

    // Test 3: -2.0 (0xc000) + -3.0 (0xc040) = -5.0 (0xc0a0)
    a = 16'hc000; // -2.0
    b = 16'hc040; // -3.0
    #10 $display("%0dns:\t%h + %h = %h", $time, a, b, sum);

    // Test 4: 0 (0x0000) + 0 (0x0000) = 0
    a = 16'h0000;
    b = 16'h0000;
    #10 $display("%0dns:\t%h + %h = %h", $time, a, b, sum);

    // Test 5: 5.5 (0x40b0) + 10.25 (0x4124) = 15.75 (approx 0x417c)
    a = 16'h40b0; // 5.5
    b = 16'h4124; // 10.25
    #10 $display("%0dns:\t%h + %h = %h", $time, a, b, sum);

    $finish;
  end

endmodule
