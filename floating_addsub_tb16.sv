module tb_Float_Mult;

    // Inputs
    logic clk;
    logic rst;
    logic start;
    logic [15:0] A;
    logic [15:0] B;

    // Outputs
    logic [15:0] product;
    logic valid;

    // Instantiate the Unit Under Test (UUT)
    Float_Mult uut (
        .clk(clk), 
        .rst(rst), 
        .start(start), 
        .A(A), 
        .B(B), 
        .product(product), 
        .valid(valid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period clock
    end

    // Test cases
    initial begin
        // Initialize Inputs
        rst = 0;
        start = 0;
        A = 16'b0;
        B = 16'b0;

        // Reset the UUT
        #10;
        rst = 1;
        #10;
        rst = 0;
        #10;
        rst = 1;

        // Test Case 1: Multiplying two positive numbers
        A = 16'b0100000000000001; // 1.5 in half-precision
        B = 16'b0011111111111111; // 1.5 in half-precision
        start = 1;
        #10;
        start = 0;
        
        $stop; // Stop the simulation
    end

endmodule
