module Single_Cycle_MIPS_Microprocessor #(
    parameter IM_START_ADDR = 32'h0000_0000,
    parameter IM_END_ADDR   = 32'h0000_0FFF,
    parameter DM_START_ADDR = 32'h0000_1000,
    parameter DM_END_ADDR   = 32'h0000_7FFF
)(
	output [15:0] TestValue,
	input reset,
	input clock
);
	wire [31:0] PCCurrentInstruction,PCPlus4, PCNextInstruction, PCBranch, PCBranchOrNot, PCJump ;
	wire [31:0] instruction;
	wire [31:0] readData1Reg, readData2Reg, writeDataReg, readDataRam, WriteDataRam, ALUResult, SignImm, SrcA, SrcB;
	wire [31:0] beqshiftout;
	wire MemWrite, Branch, ALUSrc, RegWrite, MemRead;
	wire [1:0] RegDst, Jump;
	wire [2:0] MemToReg;
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
	wire hi_write, lo_write;
	wire [1:0] HILOSrc;
	
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
	
	InstructionMemory #(
		.START_ADDR(IM_START_ADDR),
		.END_ADDR(IM_END_ADDR)
	) ROM(
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

	// Opcode and rt decoding for branches
	wire is_beq  = (opcode == 6'b000100);
	wire is_bne  = (opcode == 6'b000101);
	wire is_blez = (opcode == 6'b000110);
	wire is_bgtz = (opcode == 6'b000111);
	wire is_regimm = (opcode == 6'b000001);
	wire is_bltz = is_regimm && (instruction[20:16] == 5'b00000);
	wire is_bgez = is_regimm && (instruction[20:16] == 5'b00001);

	// Branch condition evaluations
	wire rs_zero = (readData1Reg == 32'b0);
	wire rs_negative = readData1Reg[31];

	reg branch_condition_met;
	always @(*) begin
		if (is_beq)
			branch_condition_met = zero;
		else if (is_bne)
			branch_condition_met = !zero;
		else if (is_blez)
			branch_condition_met = (rs_negative || rs_zero);
		else if (is_bgtz)
			branch_condition_met = (!rs_negative && !rs_zero);
		else if (is_bltz)
			branch_condition_met = rs_negative;
		else if (is_bgez)
			branch_condition_met = !rs_negative;
		else
			branch_condition_met = 1'b0;
	end

	wire branch_taken = Branch & branch_condition_met;
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

	// Multiplication Unit (Modular, external block)
	wire [63:0] mul_product;
	multiplier multiplier_inst(
		.a(SrcA),
		.b(readData2Reg),
		.is_signed(is_signed),
		.product(mul_product)
	);

	// Division Unit (Modular, external block)
	wire [31:0] div_quotient;
	wire [31:0] div_remainder;
	divider divider_inst(
		.a(SrcA),
		.b(readData2Reg),
		.is_signed(is_signed),
		.quotient(div_quotient),
		.remainder(div_remainder)
	);

	// Select inputs for special HI and LO registers
	wire [31:0] hi_in = (HILOSrc == 2'b10) ? SrcA :
	                    (HILOSrc == 2'b01) ? div_remainder :
	                    mul_product[63:32];
	wire [31:0] lo_in = (HILOSrc == 2'b10) ? SrcA :
	                    (HILOSrc == 2'b01) ? div_quotient :
	                    mul_product[31:0];

	// Special HI and LO registers
	reg [31:0] HI, LO;
	always @(posedge clock or negedge reset) begin
		if (!reset) begin
			HI <= 32'b0;
			LO <= 32'b0;
		end
		else begin
			if (hi_write) HI <= hi_in;
			if (lo_write) LO <= lo_in;
		end
	end
	
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
		.hi_write(hi_write),
		.lo_write(lo_write),
		.HILOSrc(HILOSrc),
		.opcode(opcode),      
		.funct(funct)    
	);
	
	assign WriteDataRam = readData2Reg;
	Data_Memory #(
		.START_ADDR(DM_START_ADDR),
		.END_ADDR(DM_END_ADDR)
	) RAM(
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
	
	// Select register write data: ALUResult (000), readDataRam (001), PCPlus4 (010), HI (011), LO (100)
	assign writeDataReg = (MemToReg == 3'b100) ? LO :
	                      (MemToReg == 3'b011) ? HI :
	                      (MemToReg == 3'b010) ? PCPlus4 :
	                      (MemToReg == 3'b001) ? readDataRam :
	                      ALUResult;

endmodule
