`timescale 1ns/100ps

module pow_tb();
	parameter nbits = 256;
	reg clk;
	reg start;
	wire [nbits-1:0] a0;
	reg [nbits-1:0] a1;
	reg [nbits-1:0] a2;
	reg [nbits-1:0] a3;
	wire done;

	initial begin
		$dumpfile("testpow.dump");
		$dumpvars(0, pow_tb.p1);
		#100000;
		$finish;
	end
	
	initial begin
		clk = 1'b0;
		a1 = 256'h412820616369726641206874756F53202C48544542415A494C452054524F50;
		a2 = 256'h10001;
		a3 = 256'hE07122F2A4A9E81141ADE518A2CD7574DCB67060B005E24665EF532E0CCA73E1;
		#1
		start = 1'b1;
		#1
		start = 1'b0;
	end

	always begin
		#1 clk = ~clk;
	end

	power p1(
		// inputs
		.clk(clk),
		.start(start),
		.a1(a1),
		.a2(a2),
		.a3(a3),
		// outputs
		.done(done),
		// inout
		.a0(a0)
	);
endmodule
