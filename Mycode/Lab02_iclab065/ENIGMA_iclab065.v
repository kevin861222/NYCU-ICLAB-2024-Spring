//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2024 Spring
//   Lab02 Exercise		: Enigma
//   Author     		: Wang Yu
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//!  File Name   : ENIGMA.v
//!
//!  Module Name : ENIGMA
//!
//!  Release version : V1.0 (Release Date: 2024-02)
//!
//!	 Execution Cycle: 100.00 
//!
//!	 Area: 126063.910006 
//!
//!	 Gate count: 12633 
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
 
module ENIGMA(
	// Input Ports
	clk, 
	rst_n, 
	in_valid, 
	in_valid_2, 
	crypt_mode, 
	code_in, 

	// Output Ports
	out_code, 
	out_valid
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk;              //! clock input
input rst_n;            //! asynchronous reset (active low)
input in_valid;         //! code_in valid signal for rotor (level sensitive). 0/1: inactive/active
reg in_valid_q ;		//! in_valid_q <= in_valid ;
input in_valid_2;       //! code_in valid signal for code  (level sensitive). 0/1: inactive/active
reg in_valid_2_q ;		//! in_valid_2_q <= in_valid_2 ;
input crypt_mode;       //! 0: encrypt; 1:decrypt; only valid for 1 cycle when in_valid is active
reg crypt_mode_q ; 		//! reg to save crypt_mode
reg whether_stored ;    //! Whether crypt_mode has been stored in crypt_mode_q .

input [6-1:0] code_in;	//! When in_valid   is active, then code_in is input of rotors. ; When in_valid_2 is active, then code_in is input of code words.
reg [6-1:0] code_in_q ; //! code_in_q <= code_in ;
							
output reg out_valid ; //! 0: out_code is not valid; 1: out_code is valid
reg out_valid_d ; //! out_valid <= out_valid_d ;

output reg [6-1:0] out_code; //! encrypted/decrypted code word
reg [6-1:0] out_code_d ; //! out_code <= out_code_d ;

reg [6:0] rotor_cnt ; //! counter from 0 ~ 127
reg [6-1:0] rotor_A [0:63] ; //! rotor A
reg [6-1:0] rotor_B [0:63] ; //! rotor B

reg [5:0] shift_num_of_A ; //! Shift num of rotor A , from 0 to 63
wire [1:0] LSB_A ; //! The least significant two bits of the 6-bit code of the rotor A output symbol
wire [2:0] LSB_B ; //! The least significant three bits of the 6-bit code of the rotor B output symbol
reg [6-1:0] rotor_A_out ; //! rotor A out
reg [6-1:0] rotor_B_out ; //! rotor B out
reg [6-1:0] inv_rotor_A_out ; //! inv rotor A out
reg [6-1:0] inv_rotor_B_out ; //! inv rotor B out
reg [6-1:0] inv_rotor_B_out_temp ; //! inv rotor B out ( Middle Product )
reg [6-1:0] index_S_to_A ; //! Index of Symbol map to A under shifts .
reg [6-1:0] index_A_to_B ; //! Index of A map to B in different modes .
reg [6-1:0] reflactor_out ; //! Reflact out .
reg [6-1:0] reflactor_out_mod ; //! Reflact out modified (mode).
reg [2:0] mode_map [0:7]; //! The map to modify index of A cause by differ mode of rotor B.

// ===============================================================
// Design
// ===============================================================
//* in_valid_q - sequential
always @(posedge clk or negedge rst_n) begin:In_valid_q
	if (~rst_n) begin
		in_valid_q <= 1'b0 ;
	end else begin
		in_valid_q <= in_valid ;
	end
end

//* in_valid_2_q - sequential
always @(posedge clk or negedge rst_n) begin:In_valid_2_q
	if (~rst_n) begin
		in_valid_2_q <= 1'b0 ;
	end else begin
		in_valid_2_q <= in_valid_2 ;
	end
end

//* code_in_q - sequential
always @(posedge clk or negedge rst_n) begin:Code_in_q
	if (~rst_n) begin
		code_in_q <= 0 ;
	end else begin
		code_in_q <= code_in ;
	end
end

//* index_S_to_A - combinational
always @(*) begin:Index_S_to_A
	index_S_to_A = code_in_q - shift_num_of_A ;
end

//* rotor_A_out - combinational
always @(*) begin:Rotor_A_out
	rotor_A_out = rotor_A [index_S_to_A] ;
end

//* LSB_B - combinational
assign LSB_B = (crypt_mode_q)?(reflactor_out[2:0]):(rotor_B_out[2:0]) ;

//* mode_map - sequential
integer k ; //! int in for loop to reset mode map .
always @(posedge clk) begin:Mode_map
		if (in_valid_2_q) begin
			case (LSB_B)
				0:begin
					mode_map[0] <= mode_map[0] ;
					mode_map[1] <= mode_map[1] ;
					mode_map[2] <= mode_map[2] ;
					mode_map[3] <= mode_map[3] ;
					mode_map[4] <= mode_map[4] ;
					mode_map[5] <= mode_map[5] ;
					mode_map[6] <= mode_map[6] ;
					mode_map[7] <= mode_map[7] ;
				end 
				1:begin
					mode_map[0] <= mode_map[1] ;
					mode_map[1] <= mode_map[0] ;
					mode_map[2] <= mode_map[3] ;
					mode_map[3] <= mode_map[2] ;
					mode_map[4] <= mode_map[5] ;
					mode_map[5] <= mode_map[4] ;
					mode_map[6] <= mode_map[7] ;
					mode_map[7] <= mode_map[6] ;
				end 
				2:begin
					mode_map[0] <= mode_map[2] ;
					mode_map[1] <= mode_map[3] ;
					mode_map[2] <= mode_map[0] ;
					mode_map[3] <= mode_map[1] ;
					mode_map[4] <= mode_map[6] ;
					mode_map[5] <= mode_map[7] ;
					mode_map[6] <= mode_map[4] ;
					mode_map[7] <= mode_map[5] ;
				end 
				3:begin
					mode_map[0] <= mode_map[0] ;
					mode_map[1] <= mode_map[4] ;
					mode_map[2] <= mode_map[5] ;
					mode_map[3] <= mode_map[6] ;
					mode_map[4] <= mode_map[1] ;
					mode_map[5] <= mode_map[2] ;
					mode_map[6] <= mode_map[3] ;
					mode_map[7] <= mode_map[7] ;
				end 
				4:begin
					mode_map[0] <= mode_map[4] ;
					mode_map[1] <= mode_map[5] ;
					mode_map[2] <= mode_map[6] ;
					mode_map[3] <= mode_map[7] ;
					mode_map[4] <= mode_map[0] ;
					mode_map[5] <= mode_map[1] ;
					mode_map[6] <= mode_map[2] ;
					mode_map[7] <= mode_map[3] ;
				end 
				5:begin
					mode_map[0] <= mode_map[5] ;
					mode_map[1] <= mode_map[6] ;
					mode_map[2] <= mode_map[7] ;
					mode_map[3] <= mode_map[3] ;
					mode_map[4] <= mode_map[4] ;
					mode_map[5] <= mode_map[0] ;
					mode_map[6] <= mode_map[1] ;
					mode_map[7] <= mode_map[2] ;
				end 
				6:begin
					mode_map[0] <= mode_map[6] ;
					mode_map[1] <= mode_map[7] ;
					mode_map[2] <= mode_map[3] ;
					mode_map[3] <= mode_map[2] ;
					mode_map[4] <= mode_map[5] ;
					mode_map[5] <= mode_map[4] ;
					mode_map[6] <= mode_map[0] ;
					mode_map[7] <= mode_map[1] ;
				end 
				7:begin
					mode_map[0] <= mode_map[7] ;
					mode_map[1] <= mode_map[6] ;
					mode_map[2] <= mode_map[5] ;
					mode_map[3] <= mode_map[4] ;
					mode_map[4] <= mode_map[3] ;
					mode_map[5] <= mode_map[2] ;
					mode_map[6] <= mode_map[1] ;
					mode_map[7] <= mode_map[0] ;
				end 
				default: begin
					mode_map[0] <= 0 ;
					mode_map[1] <= 1 ;
					mode_map[2] <= 2 ;
					mode_map[3] <= 3 ;
					mode_map[4] <= 4 ;
					mode_map[5] <= 5 ;
					mode_map[6] <= 6 ;
					mode_map[7] <= 7 ;
				end
			endcase
		end else begin
			for ( k=0 ; k<=7 ; k=k+1 ) begin
			mode_map[k] <= k ;
			end
		end
	end

//* index_A_to_B - combinational
always @(*) begin:Index_A_to_B
	index_A_to_B = {rotor_A_out[5:3],mode_map[rotor_A_out[2:0]]} ;
end

//* rotor_B_out - combinational
always @(*) begin:Rotor_B_out
	rotor_B_out = rotor_B[index_A_to_B] ;
end

//* reflactor_out - combinational
always @(*) begin:Reflactor_out
	reflactor_out = 6'h3f - rotor_B_out ;
end

//* inv_rotor_B_out_temp - combinational
integer lp_irbt ; //! for loop Parameter
always @(*) begin:Inv_rotor_B_out_temp
	inv_rotor_B_out_temp = 0 ;
	for (lp_irbt = 0;lp_irbt<=63 ;lp_irbt = lp_irbt+1 ) begin
		if (rotor_B[lp_irbt]==reflactor_out) begin
			inv_rotor_B_out_temp = lp_irbt ;
		end
	end
end

//* inv_rotor_B_out - combinational
integer lp_irb ; //! for loop Parameter
always @(*) begin:Inv_rotor_B_out
	inv_rotor_B_out = 0 ;
	for (lp_irb = 0;lp_irb<=7 ;lp_irb=lp_irb+1 ) begin
		if (mode_map[lp_irb]==inv_rotor_B_out_temp[2:0]) begin
			inv_rotor_B_out = {inv_rotor_B_out_temp[5:3],lp_irb[2:0]};
		end
	end
end

//* inv_rotor_A_out - combinational
integer lp_ira ; //! for loop Parameter
always @(*) begin:Inv_rotor_A_out
	inv_rotor_A_out = 0;
	for (lp_ira = 0;lp_ira<=63 ;lp_ira = lp_ira+1 ) begin
		if (rotor_A[lp_ira]==inv_rotor_B_out) begin
			inv_rotor_A_out = lp_ira + shift_num_of_A ;
		end
	end
end

//* out_code_d - combinational
always @(*) begin:Out_code_d
	out_code_d = (out_valid_d)?(inv_rotor_A_out):(0) ;
end


//* LSB_A - combinational
assign LSB_A = (crypt_mode_q)?(inv_rotor_B_out[1:0]):(rotor_A_out[1:0]) ;

//* shift_num_of_A - sequential
always @(posedge clk) begin:Shift_num_of_A
	if (in_valid_2_q) begin
		shift_num_of_A <= shift_num_of_A + LSB_A ;
	end else begin
		shift_num_of_A <= 1'b0 ;
	end
end

//* Counter for rotor - sequential
always @(posedge clk or negedge rst_n) begin:Rotor_cnt
	if (~rst_n) begin
		rotor_cnt <= 1'b0 ;
	end else begin
		rotor_cnt <= rotor_cnt + in_valid_q ;
	end
end

//* Initialize rotor A - sequential
//* Initialize rotor B - sequential
always @(posedge clk) begin:Rotor_AB
	if (in_valid_q) begin
		if (rotor_cnt[6]) begin
			rotor_B[rotor_cnt[5:0]] <= code_in_q ;
		end else begin
			rotor_A[rotor_cnt[5:0]] <= code_in_q ;
		end
	end
end

//* out_valid - sequential
always @(posedge clk or negedge rst_n) begin:Out_valid
	if (~rst_n) begin
		out_valid <= 1'b0 ;
	end else begin
		out_valid <= out_valid_d ;
	end
end

//* out_valid_d - combinational
always @(*) begin:Out_valid_d
	out_valid_d = in_valid_2_q ;
end

//* out_code - sequential
always @(posedge clk or negedge rst_n) begin:Out_code
	if (~rst_n) begin
		out_code <= 1'b0 ;
	end else begin
		out_code <= out_code_d ;
	end
end

//* crypt_mode_q - combinational
// always @(posedge in_valid_q) begin:Crypt_mode_q
// 	crypt_mode_q = crypt_mode ;
// end
always @(posedge clk) begin
	if (in_valid) begin
		if (~whether_stored) begin
			crypt_mode_q <= crypt_mode ;
		end 
		whether_stored <= 1 ;
	end else begin
		whether_stored <= 0 ;
	end
end

endmodule