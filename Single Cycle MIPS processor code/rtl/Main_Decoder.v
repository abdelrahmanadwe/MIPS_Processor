module MainDecoder(
    output reg [2:0] ALUOp,  // Control signal for the ALU operation
    output reg [2:0] MemToReg, // Control signal to select register write data: 000=ALUResult, 001=ReadDataRam, 010=PCPlus4, 011=HI, 100=LO
    output reg MemWrite,     // Control signal to enable memory write
    output reg Branch,       // Control signal to indicate a branch
    output reg ALUSrc,       // Control signal to select ALU source
    output reg [1:0] RegDst, // Control signal to select write register: 00=rt, 01=rd, 10=$31 (ra)
    output reg RegWrite,     // Control signal to enable register write
    output reg [1:0] Jump,   // Control signal to indicate jump: 00=no jump, 01=jump target, 10=jump register
    output reg [1:0] MemSize, // Memory access size: 00=byte, 01=half, 10=word
    output reg MemUnsigned,   // Memory load sign: 0=signed, 1=unsigned
    output reg [1:0] ExtOp,   // Extension operation: 00=zero, 01=sign, 10=upper imm
    output reg Bne,           // Control signal for branch on not equal
    output reg hi_write,      // Write enable for special HI register
    output reg lo_write,      // Write enable for special LO register
    output reg [1:0] HILOSrc, // Select HI/LO input source: 00=multiplier, 01=divider, 10=rs (ReadData1)
	input [5:0] opcode,      // Opcode field from the instruction
	input [5:0] funct        // Funct field from the instruction (for jr and jalr R-type)
);

    always @(*) begin
        // Default control signal values to prevent latches
        Jump        = 2'b00;
        ALUOp       = 3'b000;
        MemWrite    = 1'b0;
        RegWrite    = 1'b0;
        RegDst      = 2'b00;
        ALUSrc      = 1'b0;
        MemToReg    = 3'b000;
        Branch      = 1'b0;
        MemSize     = 2'b10; // Default Word
        MemUnsigned = 1'b0;  // Default Signed
        ExtOp       = 2'b01;  // Default Sign-extend
        Bne         = 1'b0;
        hi_write    = 1'b0;
        lo_write    = 1'b0;
        HILOSrc     = 2'b00;

        case(opcode)
            6'b000000: begin // R-type instructions
                if (funct == 6'b001000) begin // jr (Jump Register)
                    Jump     = 2'b10;
                    RegWrite = 1'b0;
                end
                else if (funct == 6'b001001) begin // jalr (Jump and Link Register)
                    Jump     = 2'b10;
                    RegWrite = 1'b1;
                    RegDst   = 2'b10; // Save return address to $ra (register 31)
                    MemToReg = 3'b010; // Write PCPlus4
                end
                else if (funct == 6'b010000) begin // mfhi (Move From HI)
                    RegWrite = 1'b1;
                    RegDst   = 2'b01; // Write to rd
                    MemToReg = 3'b011; // Select HI
                end
                else if (funct == 6'b010010) begin // mflo (Move From LO)
                    RegWrite = 1'b1;
                    RegDst   = 2'b01; // Write to rd
                    MemToReg = 3'b100; // Select LO
                end
                else if (funct == 6'b010001) begin // mthi (Move To HI)
                    hi_write = 1'b1;
                    HILOSrc  = 2'b10; // From rs
                end
                else if (funct == 6'b010011) begin // mtlo (Move To LO)
                    lo_write = 1'b1;
                    HILOSrc  = 2'b10; // From rs
                end
                else if (funct == 6'b011000) begin // mult (Multiply)
                    hi_write = 1'b1;
                    lo_write = 1'b1;
                    HILOSrc  = 2'b00; // From multiplier
                end
                else if (funct == 6'b011001) begin // multu (Multiply Unsigned)
                    hi_write = 1'b1;
                    lo_write = 1'b1;
                    HILOSrc  = 2'b00; // From multiplier
                end
                else if (funct == 6'b011010) begin // div (Divide)
                    hi_write = 1'b1;
                    lo_write = 1'b1;
                    HILOSrc  = 2'b01; // From divider
                end
                else if (funct == 6'b011011) begin // divu (Divide Unsigned)
                    hi_write = 1'b1;
                    lo_write = 1'b1;
                    HILOSrc  = 2'b01; // From divider
                end
                else begin // Standard R-type
                    ALUOp    = 3'b010;
                    RegWrite = 1'b1;
                    RegDst   = 2'b01;
                end
            end
            6'b100011: begin // lw
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemToReg = 3'b001;
            end
            6'b101011: begin // sw
                MemWrite = 1'b1;
                ALUSrc   = 1'b1;
            end
            6'b000100: begin // beq
                ALUOp    = 3'b001;
                Branch   = 1'b1;
            end
            6'b000101: begin // bne (Branch on Not Equal)
                ALUOp    = 3'b001;
                Branch   = 1'b1;
                Bne      = 1'b1;
            end
            6'b001000: begin // addi
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
            end
            6'b001001: begin // addiu
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
            end
            6'b000010: begin // j
                Jump     = 2'b01;
            end
            6'b000011: begin // jal (Jump and Link)
                Jump     = 2'b01;
                RegWrite = 1'b1;
                RegDst   = 2'b10; // Save return address to $ra (register 31)
                MemToReg = 3'b010; // Write PCPlus4
            end
            6'b100000: begin // lb (Load Byte)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemToReg = 3'b001;
                MemSize  = 2'b00;
            end
            6'b100100: begin // lbu (Load Byte Unsigned)
                RegWrite    = 1'b1;
                ALUSrc      = 1'b1;
                MemToReg    = 3'b001;
                MemSize     = 2'b00;
                MemUnsigned = 1'b1;
            end
            6'b100001: begin // lh (Load Halfword)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemToReg = 3'b001;
                MemSize  = 2'b01;
            end
            6'b100101: begin // lhu (Load Halfword Unsigned)
                RegWrite    = 1'b1;
                ALUSrc      = 1'b1;
                MemToReg    = 3'b001;
                MemSize     = 2'b01;
                MemUnsigned = 1'b1;
            end
            6'b101000: begin // sb (Store Byte)
                MemWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemSize  = 2'b00;
            end
            6'b101001: begin // sh (Store Halfword)
                MemWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemSize  = 2'b01;
            end
            6'b001010: begin // slti (Set Less Than Immediate)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 3'b110;
            end
            6'b001011: begin // sltiu (Set Less Than Immediate Unsigned)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 3'b110;
            end
            6'b001100: begin // andi (AND Immediate)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 3'b011;
                ExtOp    = 2'b00; // Zero-extend
            end
            6'b001101: begin // ori (OR Immediate)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 3'b100;
                ExtOp    = 2'b00; // Zero-extend
            end
            6'b001110: begin // xori (XOR Immediate)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 3'b101;
                ExtOp    = 2'b00; // Zero-extend
            end
            6'b001111: begin // lui (Load Upper Immediate)
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 3'b111;
                ExtOp    = 2'b10; // Upper Immediate
            end
            default: ;
        endcase
    end
	
endmodule
