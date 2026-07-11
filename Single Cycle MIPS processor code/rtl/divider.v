module divider(
    input [31:0] a,
    input [31:0] b,
    input is_signed,
    output reg [31:0] quotient,
    output reg [31:0] remainder
);
    always @(*) begin
        if (b == 32'b0) begin
            quotient = 32'b0;
            remainder = 32'b0;
        end
        else begin
            if (is_signed) begin
                quotient = $signed(a) / $signed(b);
                remainder = $signed(a) % $signed(b);
            end
            else begin
                quotient = a / b;
                remainder = a % b;
            end
        end
    end
endmodule
