module ALUDecoder(
    output reg [3:0] ALUControl, // ALU control signal
    input [2:0] ALUOp,           // ALU operation control from main decoder (expanded to 3 bits)
    input [5:0] Funct            // Function field from the instruction
);

	parameter AND  = 4'b0000,
			  OR   = 4'b0001,
			  ADD  = 4'b0010,
			  SLL  = 4'b0011,
			  SUB  = 4'b0100,
			  MUL  = 4'b0101,
			  SLT  = 4'b0110,
			  SRL  = 4'b0111,
			  SRA  = 4'b1000,
			  SLLV = 4'b1001,
			  SRLV = 4'b1010,
			  SRAV = 4'b1011,
			  XOR  = 4'b1100,
			  LUI  = 4'b1101,
			  NOR  = 4'b1110;

    always @(*) begin
        case(ALUOp)
            3'b000: ALUControl = ADD; // Load/Store/addi/addiu operations use ADD
            3'b001: ALUControl = SUB; // Branch operations use SUB
            3'b010: begin // R-type
                case(Funct)
                    6'b100000: ALUControl = ADD;  // ADD
                    6'b100001: ALUControl = ADD;  // ADDU
                    6'b100010: ALUControl = SUB;  // SUB
                    6'b100011: ALUControl = SUB;  // SUBU
                    6'b100100: ALUControl = AND;  // AND
                    6'b100101: ALUControl = OR;   // OR
                    6'b101010: ALUControl = SLT;  // SLT
                    6'b101011: ALUControl = SLT;  // SLTU
                    6'b100110: ALUControl = XOR;  // XOR
                    6'b100111: ALUControl = NOR;  // NOR
                    6'b011100: ALUControl = MUL;  // MUL
                    6'b000000: ALUControl = SLL;  // SLL
                    6'b000010: ALUControl = SRL;  // SRL
                    6'b000011: ALUControl = SRA;  // SRA
                    6'b000100: ALUControl = SLLV; // SLLV
                    6'b000110: ALUControl = SRLV; // SRLV
                    6'b000111: ALUControl = SRAV; // SRAV
                    default:   ALUControl = 4'bxxxx; // Undefined function
                endcase
            end
            3'b011:  ALUControl = AND; // andi
            3'b100:  ALUControl = OR;  // ori
            3'b101:  ALUControl = XOR; // xori
            3'b110:  ALUControl = SLT; // slti / sltiu
            3'b111:  ALUControl = LUI; // lui
            default: ALUControl = ADD; // default add
        endcase
    end

endmodule
