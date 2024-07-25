module tb_Float_Mult_2;

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
        rst = 1;
        start = 0;
        // Test Case 1: Multiplying two positive numbers
        A = 16'b0100000000000001; // 
        B = 16'b0011111111111111; //
        start = 1;
        #200;
        start = 0;
        
        $stop; // Stop the simulation
    end

endmodule

