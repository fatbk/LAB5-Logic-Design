module Float_Add_16bit(clk, rst, start, X, Y, valid, sum);

input clk;
input rst;
input start;
input [15:0] X, Y;   // In IEEE754 half-precision format
output [15:0] sum;   // In IEEE754 half-precision format
output valid;

reg X_sign;
reg Y_sign;
reg sum_sign, next_sum_sign;
reg [4:0] X_exp;
reg [4:0] Y_exp;
reg [4:0] sum_exp, next_sum_exp;
reg [10:0] X_mant, Y_mant;
reg [10:0] X_mantissa, Y_mantissa; // 11 bits = 10 + implicit 1
reg [11:0] sum_mantissa, next_sum_mantissa; // sum is 12 bits

reg [5:0] expsub, abs_diff;
reg [11:0] sum_mantissa_temp;
reg [1:0] next_state, pres_state;
reg valid, next_valid;

parameter IDLE = 2'b00;
parameter START = 2'b01;
parameter SHIFT_MANT = 2'b10;

assign sum = {sum_sign, sum_exp, sum_mantissa[9:0]};
assign add_carry = sum_mantissa[11] & !(X_sign ^ Y_sign);   // carry during add
assign sub_borrow = sum_mantissa_temp[11] & (X_sign ^ Y_sign); // borrow during sub

always @ (posedge clk or negedge rst)
begin
    if(!rst)
    begin
        valid       <= 1'b0;
        pres_state  <= 2'd0;
        sum_exp     <= 5'd0;
        sum_mantissa <= 12'd0;
        sum_sign    <= 1'b0;
    end
    else
    begin
        valid       <= next_valid;
        pres_state  <= next_state;
        sum_exp     <= next_sum_exp;
        sum_mantissa <= next_sum_mantissa;
        sum_sign    <= next_sum_sign;
    end
end

always @ (*)
begin 
    next_valid = 1'b0;
    X_sign = X[15];
    X_exp = X[14:10];
    X_mant = {1'b1, X[9:0]};   // Implicit 1 added
    Y_sign = Y[15];
    Y_exp = Y[14:10];
    Y_mant = {1'b1, Y[9:0]};
    next_sum_sign = sum_sign;       
    next_sum_exp = 5'd0;
    next_sum_mantissa = 12'd0;
    next_state = IDLE;
    sum_mantissa_temp = 12'd0;

    case(pres_state)
    IDLE:
    begin
        next_valid = 1'b0;
        X_sign = X[15];
        X_exp = X[14:10];
        X_mant = {1'b1, X[9:0]};    // Implicit 1 added
        Y_sign = Y[15];
        Y_exp = Y[14:10];
        Y_mant = {1'b1, Y[9:0]};
        next_sum_sign = 1'b0;
        next_sum_exp = 5'd0;
        next_sum_mantissa = 12'd0;
        next_state = (start) ? START : pres_state;
    end

    START:
    begin
        expsub = X_exp - Y_exp;
        abs_diff = expsub[5] ? !(expsub[4:0])+1'b1 : expsub[4:0];  // Absolute difference
        X_mantissa = expsub[5] ? X_mant >> abs_diff : X_mant;   // X mant shifts if expsub[5]
        Y_mantissa = expsub[5] ? Y_mant : Y_mant >> abs_diff;   // Y mant shifts if !expsub[5]
        next_sum_exp = expsub[5] ? Y_exp : X_exp;           // Greater exp taken
        sum_mantissa_temp = !(X_sign ^ Y_sign) ? X_mantissa + Y_mantissa : // Add mantissas
                            (X_sign) ? Y_mantissa - X_mantissa :
                            (Y_sign) ? X_mantissa - Y_mantissa : sum_mantissa;
        next_sum_mantissa = (sub_borrow) ? ~(sum_mantissa_temp)+1'b1 : sum_mantissa_temp; // 2's complement if required
        next_sum_sign = ((X_sign & Y_sign) || sub_borrow);
        next_valid = 1'b0;    
        next_state = SHIFT_MANT;  
    end

    SHIFT_MANT:                   // State to shift Mantissa to make bit9 = 1
    begin
        next_sum_exp = sum_mantissa[10] ? sum_exp : (add_carry) ? sum_exp + 1'b1 : sum_exp - 1'b1;
        next_sum_mantissa = sum_mantissa[10] ? sum_mantissa : (add_carry) ? sum_mantissa >> 1 : sum_mantissa << 1;
        next_valid = sum_mantissa[10] ? 1'b1 : 1'b0;
        next_state = sum_mantissa[10] ? IDLE : pres_state;
    end

    endcase
end
endmodule
