module InstructionMemory #(
    parameter START_ADDR = 32'h0000_0000,
    parameter END_ADDR   = 32'h0000_0FFF
)(
	output [31:0] instruction, // Instruction output
    input [31:0] Address       // Address input
);

    localparam MEM_SIZE_BYTES = END_ADDR - START_ADDR + 1;

    // ROM with parameterized 8-bit entries
    reg [7:0] memory [0:MEM_SIZE_BYTES-1];

    // Fetch instruction
    // Address must be in the range START_ADDR to END_ADDR.
    wire in_range = (Address >= START_ADDR && Address <= END_ADDR);
    wire [31:0] byte_addr = in_range ? (Address - START_ADDR) : 32'b0;

    assign instruction = in_range ? {memory[byte_addr+3], memory[byte_addr+2], memory[byte_addr+1], memory[byte_addr]} : 32'b0;

endmodule



















