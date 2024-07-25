module floating_point_subtraction(
    input [31:0] float1, // số dạng dấu chấm động thứ nhất
    input [31:0] float2, // số dạng dấu chấm động thứ hai
    output reg [31:0] result // kết quả phép trừ
);
    
    reg sign1, sign2;
    reg [7:0] exponent1, exponent2;
    reg [22:0] fraction1, fraction2;
    reg [31:0] result_fraction;
    reg [7:0] result_exponent;
    reg result_sign;

    // Lấy ra dấu, phần mũ và phần trị số của hai số
    always @* begin
        sign1 = float1[31];
        sign2 = float2[31];
        exponent1 = float1[30:23];
        exponent2 = float2[30:23];
        fraction1 = float1[22:0];
        fraction2 = float2[22:0];
    end
    
    // Cân chỉnh phần trị số sao cho phần mũ của hai số bằng nhau
    always @* begin
        if (exponent1 > exponent2) begin
            fraction2 = fraction2 >> (exponent1 - exponent2);
            result_exponent = exponent1;
        end
        else begin
            fraction1 = fraction1 >> (exponent2 - exponent1);
            result_exponent = exponent2;
        end
    end
    
    // Thực hiện phép trừ trên phần trị số
    always @* begin
        if (sign1 != sign2) begin
            result_fraction = fraction1 + fraction2;
        end
        else begin
            if (fraction1 > fraction2)
                result_fraction = fraction1 - fraction2;
            else
                result_fraction = fraction2 - fraction1;
        end
    end
    
    // Chuẩn hóa kết quả
    always @* begin
        if (result_fraction[23] == 1) begin
            result_fraction = result_fraction >> 1;
            result_exponent = result_exponent + 1;
        end
    end
    
    // Xây dựng kết quả cuối cùng
    always @* begin
        result_sign = sign1;
        result[31] = result_sign;
        result[30:23] = result_exponent;
        result[22:0] = result_fraction[22:0];
    end

endmodule
