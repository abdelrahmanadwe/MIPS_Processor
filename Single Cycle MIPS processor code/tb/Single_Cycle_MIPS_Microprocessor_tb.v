`timescale 1ns/1ps
module Single_Cycle_MIPS_Microprocessor_tb();

	reg clock ,reset;
	wire [15:0] TestValue;
	
	Single_Cycle_MIPS_Microprocessor MIPS(
		.TestValue(TestValue),
		.reset(reset),
		.clock(clock)
	);
	
	initial begin
		clock = 0;
		forever #10 clock = ~clock;
	end
	initial begin
		reset = 0;
		# 20 reset = 1;
	end
	initial begin
		#1000;
		$display("Simulation Finished! TestValue = %0d", TestValue);
		$finish;
	end
endmodule
