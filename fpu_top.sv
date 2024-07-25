// Lab 5 top level for 16-bit IEEE 754 FPU

module fpu_top (
  input logic   clk,
  input logic   reset,
  input logic [15:0] a,
  input logic [15:0] b,
  output logic [15:0] quotient,product,sum,
  input logic start,
  output logic [4:0]  flags 
);

Float_Div div(
    .clk(clk),
    .rst(reset),
    .start(start),
    .A(a),
    .B(b),
    .quotient(quotient),
    .valid(),
    .underflag(flags[2]),
    .overflag(flags[3])
);

Float_Add_16bit add_sub(
.clk(clk), 
.rst(reset), 
.start(start), 
.X(a), 
.Y(b), 
.valid(), 
.sum(sum)
);

Float_Mult(
    .clk(clk),
    .rst(reset),
    .start(start),
    .A(a),
    .B(b),
    .product(product),
    .valid(),
    .underflag(flags[1]),
    .overflag(flags[0])
);

endmodule