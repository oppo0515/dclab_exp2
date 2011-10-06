`define nbits 256

module Cal2_512(
	// input
	clk,
	start,
	a3,
	// output
	p2_512,
	done
);
	input wire clk;
	input wire start;
	input wire [`nbits-1:0] a3;
	output wire done;
	output reg [`nbits-1:0] p2_512;
	reg [`nbits:0] p2_512_next;
`define counter_bits 9
	reg [`counter_bits-1:0] counter, counter_next;
	reg prevStart, prevStart_next;
	wire startCalc;
	assign done = &counter;
	assign startCalc = (prevStart == 1'b1 && start == 1'b0);
	
	always @(*) begin
		if (startCalc) begin
			counter_next = `counter_bits'd0;
		end else begin
			counter_next = counter + {{(`counter_bits-1){1'b0}}, !done};
		end
		prevStart_next = start;
	end

	reg [`nbits:0] p2_512_next_tmp0;
	reg [`nbits:0] p2_512_next_tmp1;
	always @(*) begin
		if (startCalc) begin
			p2_512_next_tmp0 = {{(`nbits-1){1'b0}}, {2'b10}};
		end else begin
			p2_512_next_tmp0 = {p2_512, 1'b0};
		end

		if (p2_512_next_tmp0 > {1'b0, a3}) begin
			p2_512_next_tmp1 = p2_512_next_tmp0 - {1'b0, a3};
		end else begin
			p2_512_next_tmp1 = p2_512_next_tmp0;
		end

		if (done) begin
			p2_512_next = p2_512;
		end else begin
			p2_512_next = p2_512_next_tmp1;
		end
	end

	always @(posedge clk) begin
		p2_512 <= p2_512_next[`nbits-1:0];
		prevStart <= prevStart_next;
		counter <= counter_next;
	end
`undef counter_bits
endmodule

module power(
	// inputs
	clk,
	start,
	a1,
	a2,
	a3,
	// outputs
	done,
	a0
);
	// inputs
	input wire clk;
	input wire start;
	input wire [`nbits-1:0] a1;
	input wire [`nbits-1:0] a2;
	input wire [`nbits-1:0] a3;
	// outputs
	output wire done;
	reg done_next;
	output reg [`nbits-1:0] a0, a0_next;
	// assign
	reg [`nbits-1:0] a2Buf, a2Buf_next;
	assign done = ~(&(a2Buf));

	wire done512;
	wire [`nbits-1:0] p2_512;
	Cal2_512 c1(
		.clk(clk),
		.start(start),
		.a3(a3),
		.p2_512(p2_512),
		.done(done512)
	);

	reg [`nbits-1:0] x2, x2_next;
	wire [`nbits-1:0] x2_ret;
	wire [`nbits-1:0] a0_ret;
	wire done_m1, done_m2;
	reg start_m1, start_m1_next;
	reg start_m2, start_m2_next;
	reg waitMul, waitMul_next;
	reg prevStart, prevStart_next;
	reg prevDone512, prevDone512_next;
	assign negStart = (prevStart)&(~start);
	assign posDone512 = (~prevDone512)&(done512);

	Mul256 m1(
		.clk(clk),
		.start(start_m1),
		.done(done_m1),
		.x(x2),
		.y(p2_512),
		.n(a3),
		.result(a0_ret)
	);

	Mul256 m2(
		.clk(clk),
		.start(start_m2),
		.done(done_m2),
		.x(x2),
		.y(x2),
		.n(a3),
		.result(x2_ret)
	);

	always @(*) begin
		if (posDone512 | start_m2 & done_m1 & done_m2) begin
			start_m1_next = ~(a2Buf[0]);
			start_m2_next = 1'b0;
		end else begin
			start_m1_next = 1'b1;
			start_m2_next = 1'b1;
		end
		/*
		if (done512) begin
			if (start_m1) begin
				if (a2Buf[0] & ~waitMul) begin
					start_m1_next = 1'b0;
				end else begin
					start_m1_next = 1'b1;
				end
			end else begin
				start_m1_next = 1'b1;
			end

			if (start_m2 & ~waitMul) begin
				start_m2_next = 1'b0;
			end else begin
				start_m2_next = 1'b1;
			end
		end else begin
			start_m1_next = 1'b1;
			start_m2_next = 1'b1;
		end

		if (start_m1_next == 1'b0 || start_m2_next == 1'b0) begin
			waitMul_next = 1'b1;
		end else begin
			if ((~done512)|(done_m1 & done_m2)) begin
				waitMul_next = 1'b0;
			end else begin
				waitMul_next = 1'b1;
			end
		end
		*/

		if (negStart) begin
			a2Buf_next = a2;
		end else begin
			if (~start_m2) begin
				a2Buf_next = {1'b0, a2Buf[`nbits-1:1]};
			end else begin
				a2Buf_next = a2Buf;
			end
		end

		if (negStart) begin
			x2_next = a1;
			a0_next = `nbits'b1;
		end else begin
			if (done_m1) begin
				a0_next = a0_ret;
			end else begin
				a0_next = a0;
			end
			if (done_m2) begin
				x2_next = x2_ret;
			end else begin
				x2_next = x2;
			end
		end

		prevStart_next = start;
		prevDone512_next = done512;
	end

	always @(posedge clk) begin
		x2 <= x2_next;
		a0 <= a0_next;
		a2Buf <= a2Buf_next;
		start_m1 <= start_m1_next;
		start_m2 <= start_m2_next;
		waitMul <= waitMul_next;
		prevStart <= prevStart_next;
		prevDone512 <= prevDone512_next;
	end
endmodule
