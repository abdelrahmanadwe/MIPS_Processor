module ControlUnit(
    output [1:0] RegDst,   // Register destination: 00=rt, 01=rd, 10=$31
    output ALUSrc,       // ALU source
    output [1:0] MemToReg, // Memory to register: 00=ALUResult, 01=ReadDataRam, 10=PCPlus4
    output RegWrite,     // Register write enable
    output MemWrite,     // Memory write enable
    output Branch,       // Branch signal
    output [1:0] Jump,   // Jump signal: 00=no jump, 01=jump target, 10=jump register
    output [3:0] ALUControl, // ALU control signal
    output is_signed,    // Sign control for ALU
    output [1:0] MemSize, // Memory access size: 00=byte, 01=half, 10=word
    output MemUnsigned,   // Memory load sign: 0=signed, 1=unsigned
    output [1:0] ExtOp,   // Extension operation: 00=zero, 01=sign, 10=upper imm
    output Bne,           // Control signal for branch on not equal
	input [5:0] opcode,      // Opcode field from the instruction
    input [5:0] funct        // Function field from the instruction (for R-type)
);

    wire [2:0] ALUOp;  // ALU operation (expanded to 3 bits)
    // Instantiate Main Decoder
    MainDecoder maindecoder(
		.ALUOp(ALUOp),  
		.MemToReg(MemToReg),    
		.MemWrite(MemWrite),    
		.Branch(Branch),      
		.ALUSrc(ALUSrc),      
		.RegDst(RegDst),      
		.RegWrite(RegWrite),    
		.Jump(Jump),        
		.MemSize(MemSize),
		.MemUnsigned(MemUnsigned),
		.ExtOp(ExtOp),
		.Bne(Bne),
		.opcode(opcode),
		.funct(funct)
	);

    // Instantiate ALU Decoder
    ALUDecoder aluDecoder (
        .ALUOp(ALUOp),
        .Funct(funct),
        .ALUControl(ALUControl)
    );

    // Determine is_signed
    assign is_signed = (opcode == 6'b000000) ? 
                       (funct == 6'b100000 || funct == 6'b100010 || funct == 6'b101010) : // add, sub, slt
                       (opcode == 6'b001000 || opcode == 6'b100011 || opcode == 6'b101011 || opcode == 6'b000100 || opcode == 6'b001010); // addi, lw, sw, beq, slti

endmodule
