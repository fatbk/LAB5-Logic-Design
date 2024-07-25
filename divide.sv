module Float_Div(
    input logic clk,
    input logic rst,
    input logic start,
    input logic [15:0] A,
    input logic [15:0] B,
    output logic [15:0] quotient,
    output logic valid,
output logic underflag,overflag
);

    // Extracting fields from inputs
    logic A_sign, B_sign, quotient_sign;
    logic [4:0] A_exp, B_exp, quotient_exp;
    logic [10:0] A_mant, B_mant;
    logic [11:0] quotient_mant;
    logic [5:0] exp_diff;
    logic [10:0] norm_mant;
    logic [4:0] norm_exp;
    logic norm_mant_bit;
    logic [11:0] mant_div;
    logic [1:0] state;
    initial 
	begin
		state=2'b00;
		underflag=1;
		overflag=1;
	end

    	   assign A_sign = A[15];
           assign B_sign = B[15];
	   assign A_exp = A[14:10];
           assign B_exp = B[14:10];
	   assign  A_mant = {1'b1, A[9:0]}; 
           assign  B_mant = {1'b1, B[9:0]};

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            valid <= 0;
            quotient <= 16'b0;
        end else if (start) begin
            case(state)
	2'b00: begin
            quotient_sign = A_sign ^ B_sign;
            exp_diff = A_exp - B_exp + 15; // Add bias
	    state <=2'b01;
		end
	2'b01:
		begin
            mant_div = A_mant % B_mant;
            quotient_mant = mant_div;
		state<=2'b10;
		end
	2'b10:begin
            // Normalization
            norm_mant_bit = quotient_mant[11];
            norm_mant = norm_mant_bit ? quotient_mant[11:2] : quotient_mant[10:1];
            norm_exp = norm_mant_bit ? exp_diff : exp_diff-1;
		
            // Handle overflow and underflow
            if (norm_exp >= 31) begin
                quotient_exp = 5'b11111; // Overflow
                norm_mant = 11'b0;
		overflag =1;
            end else if (norm_exp <= 0) begin
                quotient_exp = 5'b0; // Underflow
                norm_mant = 11'b0;
		underflag=1;
            end else begin
                quotient_exp = norm_exp[4:0];
            end
		state<=2'b11;
		end
        2'b11: begin
            quotient = {quotient_sign, quotient_exp, norm_mant[9:0]};
            valid <= 1;
        	end
		endcase
        end
    end
endmodule
