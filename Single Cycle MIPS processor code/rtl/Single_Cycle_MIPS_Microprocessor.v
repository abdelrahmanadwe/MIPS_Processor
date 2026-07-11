module Single_Cycle_MIPS_Microprocessor(
	output [15:0] TestValue,
	input reset,
	input clock
);
	wire [31:0] PCCurrentInstruction,PCPlus4, PCNextInstruction, PCBranch, PCBranchOrNot, PCJump ;
	wire [31:0] instruction;
	wire [31:0] readData1Reg, readData2Reg, writeDataReg, readDataRam, WriteDataRam, ALUResult, SignImm, SrcA, SrcB;
	wire [31:0] beqshiftout;
	wire MemWrite, Branch, ALUSrc, RegWrite, MemRead;
	wire [1:0] MemToReg, RegDst, Jump;
	wire Bne;
	wire [4:0] Address1ReadReg, Address2ReadReg, Address3WriteReg;

    wire [5:0] opcode;
    wire [5:0] funct;
    wire [3:0] ALUControl;
    wire [1:0] ALUOp;
	wire zero;
	wire is_signed;
	wire [4:0] shamt;
	wire [1:0] MemSize;
	wire MemUnsigned;
	wire [1:0] ExtOp;
	
	ProgramCounter pc(
		.ProgramCounterOut(PCCurrentInstruction),
		.ProgramCounterIn(PCNextInstruction),
		.clock(clock),
		.reset(reset)
	);
	
	Adder_32_bits add4(
		.out(PCPlus4),
		.in1(PCCurrentInstruction),
		.in2(32'b100)
	);
	
	InstructionMemory ROM(
		.instruction(instruction), 
		.Address(PCCurrentInstruction)       
	);
	
	assign Address1ReadReg = instruction[25:21];
	assign Address2ReadReg = instruction[20:16];
	
	// Select Write Register index: rt (00), rd (01), or $ra (10)
	assign Address3WriteReg = (RegDst == 2'b10) ? 5'd31 :
	                          (RegDst == 2'b01) ? instruction[15:11] :
	                          instruction[20:16];

	RegisterFile registers(
		.ReadData1(readData1Reg),
		.ReadData2(readData2Reg),  
		.Clock(clock),
		.reset(reset),
		.RegWrite(RegWrite),          
		.Address1Read(Address1ReadReg), 
		.Address2Read(Address2ReadReg), 
		.Address3Write(Address3WriteReg),
		.WriteData(writeDataReg)  
	);
	Sign_Extand sign_extand(
		.out(SignImm),
		.in(instruction[15:0]),
		.ExtOp(ExtOp)
	);
	
	Shift_Left_Twice #(.in_width(32),.out_width(32)) beqshift(
		.out(beqshiftout),
		.in(SignImm)
	);
	
	Adder_32_bits addbranch(
		.out(PCBranch),
		.in1(beqshiftout),
		.in2(PCPlus4)
	);

	// Branch logic: branch if (Branch and equal condition met) OR (Branch and not equal condition met)
	wire branch_taken = Branch & (zero ^ Bne);
	assign PCBranchOrNot = branch_taken ? PCBranch : PCPlus4;
	
	Shift_Left_Twice #(.in_width(26),.out_width(32)) jumpshift(
		.out(PCJump),
		.in(instruction[25:0])
	);
	
	// Next PC: Jump Register (10), Standard Jump (01), or branch/default (00)
	assign PCNextInstruction = (Jump == 2'b10) ? readData1Reg :
	                           (Jump == 2'b01) ? {PCPlus4[31:28], PCJump[27:0]} :
	                           PCBranchOrNot;
	
	mux_2x1 #(.N(32)) SrcBmux(
		.MuxOut(SrcB),
		.MuxIn1(readData2Reg),
		.MuxIn2(SignImm),
		.sel(ALUSrc)
	);
	
	assign SrcA = readData1Reg;
	assign shamt = instruction[10:6];
	ALU_32_bits ALU(
		.ALUResult(ALUResult),
		.Zero(zero),
		.SrcA(SrcA),
		.SrcB(SrcB),
		.ALUControl(ALUControl),
		.is_signed(is_signed),
		.shamt(shamt)
	);
	
	// Extract opcode and funct fields from instruction
    assign opcode = instruction[31:26];
    assign funct  = instruction[5:0];
	ControlUnit controlunit(
		.RegDst(RegDst),       
		.ALUSrc(ALUSrc),       
		.MemToReg(MemToReg),   
		.RegWrite(RegWrite),        
		.MemWrite(MemWrite),   
		.Branch(Branch),        
		.Jump(Jump),         
		.ALUControl(ALUControl),
		.is_signed(is_signed),
		.MemSize(MemSize),
		.MemUnsigned(MemUnsigned),
		.ExtOp(ExtOp),
		.Bne(Bne),
		.opcode(opcode),      
		.funct(funct)    
	);
	
	assign WriteDataRam = readData2Reg;
	Data_Memory RAM(
		.ReadData(readDataRam),     
		.TestValue(TestValue),    
		.Clock(clock),
		.Reset(reset),
		.Address(ALUResult),      
		.WriteData(WriteDataRam),    
		.WriteEnable(MemWrite),
		.MemSize(MemSize),
		.MemUnsigned(MemUnsigned)
	);
	
	// Select register write data: ALUResult (00), readDataRam (01), or PCPlus4 (10)
	assign writeDataReg = (MemToReg == 2'b10) ? PCPlus4 :
	                      (MemToReg == 2'b01) ? readDataRam :
	                      ALUResult;

endmodule
