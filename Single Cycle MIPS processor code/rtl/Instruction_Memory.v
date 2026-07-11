module InstructionMemory(
	output [31:0] instruction, // Instruction output
    input [31:0] Address       // Address input
    
);

    // ROM with 256 32-bit entries
    reg [31:0] memory [0:255];
    
    // Initialize instruction memory with a sample program
    // Initialize memory by loading instructions from an external file
    initial begin
        $readmemh("tests/instructions1.txt", memory); // Load the instructions from a file
    end

    // Fetch instruction
    assign instruction = memory[Address[9:2]];

endmodule



















