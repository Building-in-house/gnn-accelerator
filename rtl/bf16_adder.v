module bf16_adder (
  input  [15:0] a,
  input  [15:0] b,
  output [15:0] sum
);

  wire sign_a = a[15];
  wire [7:0] exp_a = a[14:7];
  wire [6:0] man_a = a[6:0];

  wire sign_b = b[15];
  wire [7:0] exp_b = b[14:7];
  wire [6:0] man_b = b[6:0];

  // Add implicit leading 1 to mantissa if normalized
  wire [7:0] frac_a = (exp_a == 0) ? {1'b0, man_a} : {1'b1, man_a};
  wire [7:0] frac_b = (exp_b == 0) ? {1'b0, man_b} : {1'b1, man_b};

  wire [7:0] exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
  wire [9:0] aligned_a = (exp_a >= exp_b) ? {frac_a, 2'b00} : ({frac_a, 2'b00} >> exp_diff);
  wire [9:0] aligned_b = (exp_b >= exp_a) ? {frac_b, 2'b00} : ({frac_b, 2'b00} >> exp_diff);
  wire [7:0] exp_common = (exp_a >= exp_b) ? exp_a : exp_b;

  reg [10:0] result_sig;
  reg result_sign;

  // Addition/Subtraction
  always @(*) begin
    if (sign_a == sign_b) begin
      result_sig = aligned_a + aligned_b;
      result_sign = sign_a;
    end else begin
      if (aligned_a >= aligned_b) begin
        result_sig = aligned_a - aligned_b;
        result_sign = sign_a;
      end else begin
        result_sig = aligned_b - aligned_a;
        result_sign = sign_b;
      end
    end
  end

  reg [6:0] mantissa;
  reg [7:0] exponent;
  reg [10:0] norm_sig;
  integer shift;

  always @(*) begin
    if (result_sig == 0) begin
      mantissa = 0;
      exponent = 0;
      result_sign = 0;
    end else begin
      norm_sig = result_sig;
      exponent = exp_common;

      // Normalize
      if (norm_sig[10]) begin
        // MSB overflow: shift right
        norm_sig = norm_sig >> 1;
        exponent = exponent + 1;
      end else begin
        shift = 0;
        while (!norm_sig[9] && exponent > 0 && shift < 10) begin
          norm_sig = norm_sig << 1;
          exponent = exponent - 1;
          shift = shift + 1;
        end
      end

      // Rounding (nearest even)
      mantissa = norm_sig[8:2]; // Take top 7 bits
      if (norm_sig[1] && (norm_sig[0] || norm_sig[2])) begin
        mantissa = mantissa + 1;
        if (mantissa == 7'b10000000) begin
          mantissa = 7'b01000000;
          exponent = exponent + 1;
        end
      end
    end
  end

  assign sum = {result_sign, exponent, mantissa};

endmodule
