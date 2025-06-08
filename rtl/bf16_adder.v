module bf16_adder (
  input  [15:0] a,
  input  [15:0] b,
  output [15:0] sum
);

  wire        sign_a = a[15];
  wire [7:0]  exp_a  = a[14:7];
  wire [6:0]  man_a  = a[6:0];
  wire        sign_b = b[15];
  wire [7:0]  exp_b  = b[14:7];
  wire [6:0]  man_b  = b[6:0];

  wire [7:0] sig_a = (exp_a == 8'd0) ? {1'b0, man_a} : {1'b1, man_a};
  wire [7:0] sig_b = (exp_b == 8'd0) ? {1'b0, man_b} : {1'b1, man_b};

  wire [7:0] exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);

  wire [9:0] sig_a_shifted = (exp_a >= exp_b) ? {sig_a, 2'b00} : ({sig_a, 2'b00} >> exp_diff);
  wire [9:0] sig_b_shifted = (exp_b >= exp_a) ? {sig_b, 2'b00} : ({sig_b, 2'b00} >> exp_diff);

  wire [7:0] exp_max = (exp_a >= exp_b) ? exp_a : exp_b;

  reg [10:0] sig_res;
  reg        res_sign;

  always @(*) begin
    if (sign_a == sign_b) begin
      sig_res = sig_a_shifted + sig_b_shifted;
      res_sign = sign_a;
    end else begin
      if (sig_a_shifted >= sig_b_shifted) begin
        sig_res = sig_a_shifted - sig_b_shifted;
        res_sign = sign_a;
      end else begin
        sig_res = sig_b_shifted - sig_a_shifted;
        res_sign = sign_b;
      end
    end
  end

  reg [6:0] mantissa_out;
  reg [7:0] exponent_out;
  integer i;

  always @(*) begin
    if (sig_res == 0) begin
      mantissa_out = 0;
      exponent_out = 0;
      res_sign = 0;
    end else begin
      exponent_out = exp_max;
      for (i = 9; i >= 0; i = i - 1) begin
        if (sig_res[i]) begin
          if (i < 9) begin
            mantissa_out = sig_res[i-1 -:7];
            exponent_out = exponent_out - (9 - i);
          end else begin
            mantissa_out = sig_res[8:2];
            if (sig_res[10]) begin
              mantissa_out = sig_res[9:3];
              exponent_out = exponent_out + 1;
            end
          end
          disable for;
        end
      end
    end
  end

  assign sum = {res_sign, exponent_out, mantissa_out};

endmodule
