module Data_Memory(
	output [31:0] ReadData,      // Data output
	output [15:0] TestValue,     // test value
    input Clock,Reset,           // Clock and reset signals
    input [31:0] Address,        // Address input
    input [31:0] WriteData,      // Data to be written
    input WriteEnable,           // Memory write enable
    input [1:0] MemSize,         // Memory access size: 00=byte, 01=half, 10=word
    input MemUnsigned            // Memory load sign: 0=signed, 1=unsigned
);
	wire [31:0] WordAddress;
    // 1KB- RAM 
    reg [7:0] memory [0:1023];

	assign WordAddress = {Address[31:2],2'b00}; 

    // Read data (Combinational)
    reg [31:0] read_data_mux;
    always @(*) begin
        if (MemSize == 2'b00) begin // Byte read (lb/lbu)
            if (MemUnsigned)
                read_data_mux = {24'b0, memory[Address[9:0]]};
            else
                read_data_mux = {{24{memory[Address[9:0]][7]}}, memory[Address[9:0]]};
        end
        else if (MemSize == 2'b01) begin // Halfword read (lh/lhu)
            if (MemUnsigned)
                read_data_mux = {16'b0, memory[Address[9:0]+1], memory[Address[9:0]]};
            else
                read_data_mux = {{16{memory[Address[9:0]+1][7]}}, memory[Address[9:0]+1], memory[Address[9:0]]};
        end
        else begin // Word read (lw)
            read_data_mux = {memory[WordAddress[9:0]+3], memory[WordAddress[9:0]+2], memory[WordAddress[9:0]+1], memory[WordAddress[9:0]]};
        end
    end
    assign ReadData = read_data_mux;

	assign TestValue = {memory[1],memory[0]};

    // Write data
    always @(posedge Clock or negedge Reset) begin
        if(!Reset) begin : reset_memory
            integer i;
            for (i = 0; i < 1024; i = i + 1) begin
                memory[i] <= 8'b0;
            end
        end
        else if (WriteEnable) begin
            if (MemSize == 2'b00) begin // Byte write (sb)
                memory[Address[9:0]] <= WriteData[7:0];
            end
            else if (MemSize == 2'b01) begin // Halfword write (sh)
                memory[Address[9:0]]   <= WriteData[7:0];
                memory[Address[9:0]+1] <= WriteData[15:8];
            end
            else begin // Word write (sw)
                memory[WordAddress[9:0]]   <= WriteData[7:0];
                memory[WordAddress[9:0]+1] <= WriteData[15:8];
                memory[WordAddress[9:0]+2] <= WriteData[23:16];
                memory[WordAddress[9:0]+3] <= WriteData[31:24];
            end
        end
    end

endmodule
