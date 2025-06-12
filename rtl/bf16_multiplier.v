module bf16_multiplier (
  input  [15:0] a,
  input  [15:0] b,
  output [15:0] product
);

  wire sign_a = a[15];
  wire [7:0] exp_a = a[14:7];
  wire [6:0] man_a = a[6:0];

  wire sign_b = b[15];
  wire [7:0] exp_b = b[14:7];
  wire [6:0] man_b = b[6:0];

  wire sign_res = sign_a ^ sign_b;

  wire [7:0] sig_a = (exp_a == 0) ? {1'b0, man_a} : {1'b1, man_a};
  wire [7:0] sig_b = (exp_b == 0) ? {1'b0, man_b} : {1'b1, man_b};

  wire [15:0] mantissa_mult = sig_a * sig_b;

  wire [7:0] exp_sum = exp_a + exp_b - 8'd127;

  reg [6:0] mantissa_out;
  reg [7:0] exponent_out;

  always @(*) begin
    if (mantissa_mult[15]) begin
      mantissa_out = mantissa_mult[14:8];
      exponent_out = exp_sum + 1;
    end else begin
      mantissa_out = mantissa_mult[13:7];
      exponent_out = exp_sum;
    end
  end

  assign product = (mantissa_mult == 0) ? 16'b0 : {sign_res, exponent_out, mantissa_out};

endmodule
