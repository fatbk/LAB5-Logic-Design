`timescale 1ns / 1ns

module floating_point_subtraction_tb;

    // Khai báo các tín hiệu đầu vào
    reg [31:0] float1;
    reg [31:0] float2;

    // Khai báo tín hiệu kết quả đầu ra từ mô-đun
    wire [31:0] result;

    // Khởi tạo mô-đun
    floating_point_subtraction uut(
        .float1(float1),
        .float2(float2),
        .result(result)
    );

    // Tạo clock
    reg clk = 0;
    always #5 clk = ~clk;

    // Mô phỏng các điều kiện test
    initial begin
        // Test case 1: Trừ 2 số dương
        float1 = 32'h40400000; // 3.0
        float2 = 32'h40000000; // 2.0
        #10;

        // Test case 2: Trừ 2 số âm
        float1 = 32'hC0400000; // -3.0
        float2 = 32'hC0000000; // -2.0
        #10;

        // Test case 3: Trừ số dương với số âm
        float1 = 32'h40400000; // 3.0
        float2 = 32'hC0000000; // -2.0
        #10;

        // Test case 4: Trừ số âm với số dương
        float1 = 32'hC0400000; // -3.0
        float2 = 32'h40000000; // 2.0
        #10;

        // Thêm các test case khác nếu cần

        $finish;
    end

endmodule
