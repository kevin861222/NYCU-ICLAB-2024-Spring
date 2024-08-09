//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2023 ICLAB Fall Course
//   Lab03      : BRIDGE
//   Author     : Tzu-Yun Huang
//	 Editor		: Wang Yu
//                
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : pseudo_DRAM.v
//   Module Name : pseudo_DRAM
//   Release version : v3.0 (Release Date: Sep-2023)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module pseudo_DRAM(
	clk, rst_n,
	AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY,
	AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP
);

input clk, rst_n;
// write address channel
input [31:0] AW_ADDR;
input AW_VALID;
output reg AW_READY;
// write data channel
input W_VALID;
input [63:0] W_DATA;
output reg W_READY;
// write response channel
output reg B_VALID;
output reg [1:0] B_RESP;
input B_READY;
// read address channel
input [31:0] AR_ADDR;
input AR_VALID;
output reg AR_READY;
// read data channel
output reg [63:0] R_DATA;
output reg R_VALID;
output reg [1:0] R_RESP;
input R_READY;

//================================================================
// parameters & integer
//================================================================

parameter DRAM_p_r = "../00_TESTBED/DRAM_init.dat";

integer request ; //! 00:IDLE , 01:READ , 10:WRITE
localparam  IDLE = 2'b00 ,
			READ = 2'b01 ,
			WRITE = 2'b10 ;

localparam OKAY = 2'b00 ;
//================================================================
// wire & registers 
//================================================================
reg [63:0] DRAM[0:8191];
initial begin
	$readmemh(DRAM_p_r, DRAM);
end

reg [31:0] addr ; 
reg [63:0] data ;
//================================================================
// DRAM Behavior
//================================================================
always @(negedge rst_n) begin
	initialize_output_signals();
end

//* main function
initial begin
	while (1) begin
		wait_for_request();
		processing_request();
		// @(posedge clk);
	end
end

//* AR_ADDR should be reset when AR_VALID is low
initial begin
	while (1) begin
		if (AR_VALID===0) begin
			check_AR_ADDR_is_rst();
		end
		if (AW_VALID===0) begin
			check_AW_ADDR_is_rst();
		end
		if (W_VALID===0) begin
			check_W_DATA_is_rst();
		end
		@(posedge clk);
	end
end

//* AR_VALID and AR_ADDR should remain stable until AR_READY goes high.
reg [31:0] AR_ADDR_temp ;
initial begin
	AR_ADDR_temp = 'b0 ;
	while (1) begin
		if (AR_VALID === 'b1) begin
			AR_ADDR_temp = AR_ADDR ;
			while (AR_READY !== 'b1) begin
				if (AR_ADDR_temp !==AR_ADDR) begin
					AR_not_stable();
				end
				if (~AR_VALID) begin
					AR_not_stable();
				end
				@(negedge clk);
			end
		end
		@(negedge clk);
	end
end

//* AW_VALID and AW_ADDR should remain stable until AW_READY goes high.
reg [31:0] AW_ADDR_temp ;
initial begin
	AW_ADDR_temp = 'b0 ;
	while (1) begin
		if (AW_VALID === 'b1) begin
			AW_ADDR_temp = AW_ADDR ;
			while (AW_READY !== 'b1) begin
				if (AW_ADDR_temp !== AW_ADDR) begin
					AW_not_stable();
				end
				if (~AW_VALID) begin
					AW_not_stable();
				end
				@(negedge clk);
			end
		end
		@(negedge clk);
	end
end

//* R_READY should remain stable until R_VALID goes high.
initial begin
	while (1) begin
		if (R_READY === 'b1) begin
			while (R_VALID !== 'b1) begin
				if (~R_READY) begin
					R_not_stable();
				end
				@(negedge clk);
			end
		end
		@(negedge clk);
	end
end

//* W_VALID and W_DATA should remain stable until W_READY goes high.
reg [63:0] W_DATA_temp ;
initial begin
	W_DATA_temp = 'b0 ;
	while (1) begin
		if (W_VALID === 'b1) begin
			W_DATA_temp = W_DATA ;
			while (W_READY !== 'b1) begin
				if (~W_VALID) begin
					W_not_stable();
				end
				if (W_DATA_temp !== W_DATA ) begin
					W_not_stable();
				end
				@(negedge clk);
			end
		end
		@(negedge clk);
	end
end

//* R_READY should be asserted within 100 cycles after AR_READY goes high.
integer R_READY_cnt ; //! 
initial begin
	while (1) begin
		wait(AR_READY===1);
		@(posedge clk);
		R_READY_cnt = 0 ;
		while (R_READY !== 'b1) begin
			@(posedge clk);
			if (R_READY_cnt >= 100) begin
				R_READY_not_assert_within_100_cycles();
			end
			R_READY_cnt = R_READY_cnt + 1 ;
		end
		@(posedge clk);
	end
end

//* W_VALID should be asserted within 100 cycles after AW_READY goes high.
integer W_VALID_cnt ; //! 
initial begin
	while (1) begin
		wait(AW_READY===1);
		@(posedge clk);
		W_VALID_cnt = 0 ;
		while (W_VALID !== 1) begin
			@(posedge clk);
			if (W_VALID_cnt >= 100) begin
				W_VALID_not_assert_within_100_cycles();
			end
			W_VALID_cnt = W_VALID_cnt + 1 ;
		end
		@(posedge clk);
	end
end

//* B_READY should be asserted within 100 cycles after B_VALID goes high.
integer B_READY_cnt ; //! 
initial begin
	while (1) begin
		wait(B_VALID===1);
		@(posedge clk);
		B_READY_cnt = 0 ;
		while (B_READY !== 1) begin
			@(posedge clk);
			B_READY_cnt = B_READY_cnt + 1 ;
			if (B_READY_cnt >= 100) begin
				B_READY_not_assert_within_100_cycles();
			end
		end
		@(posedge clk);
	end
end

//* R_READY should not be pulled high when AR_READY or AR_VALID goes high.
initial begin
	while (1) begin
		wait(AR_READY===1 || AR_VALID===1);
		check_R_READY_is_not_high();
		@(posedge clk);
	end
end

//* W_VALID should not be pulled high when AW_READY or AW_VALID goes high.
initial begin
	while (1) begin
		wait(AW_READY===1 || AW_VALID===1);
		check_W_VALID_is_not_high();
		@(posedge clk);
	end
end

//================================================================
// Task 
//================================================================
// task AW_VALID_unknown ; begin
// 	$display("*		AW_VALID_unknown !		*");
// 	DRAM_fail_task() ;
// end endtask

// task W_VALID_unknown ; begin
// 	$display("*		W_VALID_unknown !		*");
// 	DRAM_fail_task() ;
// end endtask

// task AR_VALID_unknown ; begin
// 	$display("*		AR_VALID_unknown !		*");
// 	DRAM_fail_task() ;
// end endtask

// task check_AW_rst ; begin
// 	if (AW_ADDR !== 0) begin
// 		$display("*		AW_ADDR not reset !		*");
// 		DRAM_fail_task() ;
// 	end
// end endtask

// task check_W_rst ; begin
// 	if (W_DATA !== 0) begin
// 		$display("*		W_DATA not reset !		*");
// 		DRAM_fail_task() ;
// 	end
// end endtask

// task check_AR_rst ; begin
// 	if (AR_ADDR !== 0) begin
// 		$display("*		AR_ADDR not reset !		*");
// 		DRAM_fail_task() ;
// 	end
// end endtask

task check_R_READY_is_not_high ; begin
	if (R_READY===1) begin
		$display("----------------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  R_READY should not be pulled high when AR_READY or AR_VALID goes high ");
        $display("    █  ▄▀▀▀▄                 █  ╭                            ");
        $display("    ▀▄                       █  ╭  SPEC DRAM-5 FAIL    ");
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("----------------------------------------------------------------------------------------");
        $finish;
	end
end endtask

task check_W_VALID_is_not_high ; begin
	if (W_VALID===1) begin
		$display("----------------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  W_VALID should not be pulled high when AW_READY or AW_VALID goes high");
        $display("    █  ▄▀▀▀▄                 █  ╭                            ");
        $display("    ▀▄                       █  ╭  SPEC DRAM-5 FAIL    ");
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("----------------------------------------------------------------------------------------");
        $finish;
	end
end endtask

task initialize_output_signals ; begin
	// write address channel
	AW_READY = 1'b0 ;
	// write data channel
	W_READY  = 1'b0 ;
	// write response channel
	B_VALID  = 1'b0 ;
	B_RESP   = 2'b00 ;
	// read address channel
	AR_READY = 1'b0 ;
	// read data channel
	R_DATA   = 64'd0 ;
	R_VALID  = 1'b0 ;
	R_RESP   = 1'b0 ;
	// Parameters
	request = 2'b00 ;
	addr = 0 ;
	data = 0 ;
end endtask

task wait_for_request ; begin
	if (AR_VALID===1) begin
		request = READ ;
	end else if (AW_VALID) begin
		request = WRITE ;
	end else begin
		request = IDLE ;
	end
end endtask

task processing_request ; begin
	case (request)
		IDLE: begin
			@(posedge clk);
		end 
		READ: begin
			addr = AR_ADDR ;
			check_err_dram_addr() ;
			wait_20_cycle();
			AR_READY = 1 ;
			@(posedge clk);
			AR_READY = 0 ;
			wait_20_cycle();
			wait(R_READY===1);
			R_VALID = 1 ;
			R_RESP = OKAY ;
			R_DATA = DRAM[addr];
			@(posedge clk);
			R_VALID = 0 ;
			R_DATA = 'b0;
			R_RESP = 'b0;
			addr = 'b0 ;
		end
		WRITE: begin
			addr = AW_ADDR ; 
			check_err_dram_addr() ;
			wait_20_cycle();
			AW_READY = 1 ;
			@(posedge clk);
			AW_READY = 0 ;
			wait_20_cycle();
			wait_20_cycle();
			W_READY = 1 ;
			wait(W_VALID===1); 
			data = W_DATA ;
			@(posedge clk);
			W_READY = 0 ;
			wait_20_cycle();
			wait_20_cycle();
			B_VALID = 1 ;
			wait(B_READY===1);
			DRAM[addr] = data ;
			B_RESP = OKAY ;
			@(posedge clk);
			addr = 'b0 ;
			data = 'b0 ;
			B_VALID = 0 ;
			B_RESP = 'b0 ;
		end
		default: @(posedge clk);
	endcase
end endtask

task check_W_DATA_is_rst ; begin
	if (W_DATA!== 'b0) begin
		$display("----------------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  W_DATA should be reset when AR_VALID is low ");
        $display("    █  ▄▀▀▀▄                 █  ╭                            ");
        $display("    ▀▄                       █  ╭  SPEC DRAM-1 FAIL    ");
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("----------------------------------------------------------------------------------------");
        $finish;
	end
end endtask

task check_AR_ADDR_is_rst ; begin
	if (AR_ADDR!== 'b0) begin
		$display("----------------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  AR_ADDR should be reset when AR_VALID is low ");
        $display("    █  ▄▀▀▀▄                 █  ╭                            ");
        $display("    ▀▄                       █  ╭  SPEC DRAM-1 FAIL    ");
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("----------------------------------------------------------------------------------------");
        $finish;
	end
end endtask

task check_AW_ADDR_is_rst ; begin
	if (AW_ADDR!== 'b0) begin
		$display("----------------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  AW_ADDR should be reset when AR_VALID is low ");
        $display("    █  ▄▀▀▀▄                 █  ╭                            ");
        $display("    ▀▄                       █  ╭  SPEC DRAM-1 FAIL    ");
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("----------------------------------------------------------------------------------------");
        $finish;
	end
end endtask

task AR_not_stable ; begin
	$display("----------------------------------------------------------------------------------------");
	$display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
	$display("    ▄▀            ▀▄      ▄▄                                          ");
	$display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
	$display("    █   ▀▀            ▀▀▀   ▀▄  ╭  AR_not_stable");
	$display("    █  ▄▀▀▀▄                 █  ╭                            ");
	$display("    ▀▄                       █  ╭  SPEC DRAM-3 FAIL    ");
	$display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
	$display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
	$display("----------------------------------------------------------------------------------------");
	$finish;
end endtask

task W_not_stable ; begin
	$display("----------------------------------------------------------------------------------------");
	$display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
	$display("    ▄▀            ▀▄      ▄▄                                          ");
	$display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
	$display("    █   ▀▀            ▀▀▀   ▀▄  ╭  W_not_stable");
	$display("    █  ▄▀▀▀▄                 █  ╭  Time : %t                          ",$time);
	$display("    ▀▄                       █  ╭  SPEC DRAM-3 FAIL    ");
	$display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
	$display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
	$display("----------------------------------------------------------------------------------------");
	@(posedge clk); @(posedge clk);
	$finish;
end endtask

task R_not_stable ; begin
	$display("----------------------------------------------------------------------------------------");
	$display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
	$display("    ▄▀            ▀▄      ▄▄                                          ");
	$display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
	$display("    █   ▀▀            ▀▀▀   ▀▄  ╭  R_not_stable");
	$display("    █  ▄▀▀▀▄                 █  ╭                            ");
	$display("    ▀▄                       █  ╭  SPEC DRAM-3 FAIL    ");
	$display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
	$display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
	$display("----------------------------------------------------------------------------------------");
	$finish;
end endtask

task AW_not_stable ; begin
	$display("----------------------------------------------------------------------------------------");
	$display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
	$display("    ▄▀            ▀▄      ▄▄                                          ");
	$display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
	$display("    █   ▀▀            ▀▀▀   ▀▄  ╭  AW_not_stable");
	$display("    █  ▄▀▀▀▄                 █  ╭                            ");
	$display("    ▀▄                       █  ╭  SPEC DRAM-3 FAIL    ");
	$display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
	$display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
	$display("----------------------------------------------------------------------------------------");
	$finish;
end endtask

task R_READY_not_assert_within_100_cycles ; begin
	$display("----------------------------------------------------------------------------------------");
	$display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
	$display("    ▄▀            ▀▄      ▄▄                                          ");
	$display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
	$display("    █   ▀▀            ▀▀▀   ▀▄  ╭  R_READY_not_assert_within_100_cycles");
	$display("    █  ▄▀▀▀▄                 █  ╭                            ");
	$display("    ▀▄                       █  ╭  SPEC DRAM-4 FAIL    ");
	$display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
	$display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
	$display("----------------------------------------------------------------------------------------");
	$finish;
end endtask

task W_VALID_not_assert_within_100_cycles ; begin
	$display("----------------------------------------------------------------------------------------");
	$display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
	$display("    ▄▀            ▀▄      ▄▄                                          ");
	$display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
	$display("    █   ▀▀            ▀▀▀   ▀▄  ╭  W_VALID_not_assert_within_100_cycles");
	$display("    █  ▄▀▀▀▄                 █  ╭                            ");
	$display("    ▀▄                       █  ╭  SPEC DRAM-4 FAIL    ");
	$display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
	$display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
	$display("----------------------------------------------------------------------------------------");
	$finish;
end endtask

task B_READY_not_assert_within_100_cycles ; begin
	$display("----------------------------------------------------------------------------------------");
	$display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
	$display("    ▄▀            ▀▄      ▄▄                                          ");
	$display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
	$display("    █   ▀▀            ▀▀▀   ▀▄  ╭  B_READY_not_assert_within_100_cycles");
	$display("    █  ▄▀▀▀▄                 █  ╭                            ");
	$display("    ▀▄                       █  ╭  SPEC DRAM-4 FAIL    ");
	$display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
	$display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
	$display("----------------------------------------------------------------------------------------");
	$finish;
end endtask

task DRAM_fail_task ; begin
    $display("*                              FAIL!                                    *");
    $display("*                 Error message from pseudo_DRAM.v                      *");
	$finish;
end endtask

task check_err_dram_addr ; begin
	if (addr >= 32'd8191) begin
		$display("----------------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  Address out of range ! ");
        $display("    █  ▄▀▀▀▄                 █  ╭  Address Maximun is 8191	                   ");
        $display("    ▀▄                       █  ╭  Your Address %d				*",addr  );
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █   ╭  SPEC DRAM-2 FAIL                        ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("----------------------------------------------------------------------------------------");
		$finish;
	end
end endtask

task wait_20_cycle ; begin
	repeat(20) begin
		@(posedge clk);
	end 
end endtask

endmodule
