module Float_Mult(
    input logic clk,
    input logic rst,
    input logic start,
    input logic [15:0] A,
    input logic [15:0] B,
    output logic [15:0] product,
    output logic valid,
    output logic underflag,overflag
);

    logic [4:0] A_exp, B_exp, product_exp;
    logic [10:0] A_mant, B_mant;
    logic A_sign, B_sign, product_sign;
    logic [21:0] product_mant; // 11 + 11
    logic [5:0] exp_sum;
    logic [10:0] norm_mant;
    logic [4:0] norm_exp;
    logic norm_mant_bit;
    logic [1:0] state ;
	initial begin
	state =2'b00;
	overflag =1;
	underflag=1;
	end
	   assign A_sign = A[15];
           assign B_sign = B[15];
	   assign A_exp = A[14:10];
           assign B_exp = B[14:10];
	   assign A_mant = {1'b1, A[9:0]}; 
           assign B_mant = {1'b1, B[9:0]};
    // Extract fields from inputs
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            valid <= 0;
            product <= 16'b0;
            state <=2'b00;
        end else if (start) begin
            // Sign calculation
            case(state)
		
	2'b00:
		begin
            product_sign = A_sign ^ B_sign;

            // Exponent calculation
           
            exp_sum = A_exp + B_exp - 4'd15; // Subtract bias

            // Mantissa calculation
            
            product_mant = A_mant * B_mant;
	    norm_mant_bit = product_mant[21];
	    state<= 2'b01;
		end		
	2'b01:
		begin
            norm_exp = norm_mant_bit ? exp_sum + 1 : exp_sum;            
            norm_mant = norm_mant_bit ? product_mant[21:11] : product_mant[20:10];
           	state<= 2'b10;
		end

        2'b10:
		begin
            if (norm_exp >= 31) begin //overflow
                product_exp = 5'b11111; 
                norm_mant = 11'b0;
		overflag <=1;
            end else if (norm_exp <= 0) begin//underflow
                product_exp = 5'b0; 
                norm_mant = 11'b0;
		underflag<=1;
            end else begin
                product_exp = norm_exp[4:0];
            end
		state<= 2'b11;
		end
       2'b11:
		begin
            product = {product_sign, product_exp, norm_mant[9:0]};
            valid <= 1;
        	end
		endcase
    end
end
endmodule
