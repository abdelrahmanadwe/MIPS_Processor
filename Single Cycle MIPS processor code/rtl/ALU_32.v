module ALU_32_bits(
	output reg [31:0]ALUResult,
	output reg Zero,
	input [31:0]SrcA,SrcB,
	input [3:0] ALUControl,
	input is_signed,
	input [4:0] shamt
);

	parameter AND  = 4'b0000,
			  OR   = 4'b0001,
			  ADD  = 4'b0010,
			  SLL  = 4'b0011,
			  SUB  = 4'b0100,
			  MULT = 4'b0101,
			  SLT  = 4'b0110,
			  SRL  = 4'b0111,
			  SRA  = 4'b1000,
			  SLLV = 4'b1001,
			  SRLV = 4'b1010,
			  SRAV = 4'b1011,
			  XOR  = 4'b1100,
			  LUI  = 4'b1101,
			  NOR  = 4'b1110;

	wire [32:0] adder_sub_sum;
	wire is_sub = (ALUControl == SUB || ALUControl == SLT);

	adder_sub #(.WIDTH(32)) adder_sub_inst (
		.a(SrcA),
		.b(SrcB),
		.is_signed(is_signed),
		.is_sub(is_sub),
		.sum(adder_sub_sum)
	);

	always @(*)begin
		case (ALUControl)
			AND  : ALUResult = SrcA & SrcB ;
			OR   : ALUResult = SrcA | SrcB ;
			ADD  : ALUResult = adder_sub_sum[31:0] ;
			SLL  : ALUResult = SrcB << shamt ;
			SUB  : ALUResult = adder_sub_sum[31:0] ;
			MULT : ALUResult = SrcA * SrcB ;
			SLT  : ALUResult = ((SrcA[31] == SrcB[31]) ? adder_sub_sum[31] : (is_signed ? SrcA[31] : SrcB[31])) ? 32'b1 : 32'b0;
			SRL  : ALUResult = SrcB >> shamt ;
			SRA  : ALUResult = $signed(SrcB) >>> shamt ;
			SLLV : ALUResult = SrcB << SrcA[4:0] ;
			SRLV : ALUResult = SrcB >> SrcA[4:0] ;
			SRAV : ALUResult = $signed(SrcB) >>> SrcA[4:0] ;
			XOR  : ALUResult = SrcA ^ SrcB ;
			LUI  : ALUResult = SrcB ;
			NOR  : ALUResult = ~(SrcA | SrcB) ;
			default: ALUResult = 32'b0;
		endcase
		if(ALUResult == 0) Zero = 1'b1; else Zero = 1'b0;
	
	end

endmodule