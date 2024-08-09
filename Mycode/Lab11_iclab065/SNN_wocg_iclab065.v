
module SNN(
	// Input signals
	clk,
	rst_n,
	in_valid,
	img,
	ker,
	weight,
	// Output signals
	out_valid,
	out_data
);

input clk;
input rst_n;
input in_valid;
input [7:0] img;
input [7:0] ker;
input [7:0] weight;

output reg out_valid;
output reg [9:0] out_data;

//==============================================//
//       	parameter declaration               //
//==============================================//
//* control
reg working_flag ;
reg [6:0] global_cnt ; //! 0 ~ 71

//* data storage
reg [7:0] img_buffer [0:2][0:5] ;
reg [7:0] ker_buffer [0:8] ;
reg [7:0] weight_buffer [0:3] ;
reg weight_buffer_done_flag , ker_buffer_done_flag ;

//* conv_ip
reg [7:0] conv_img [0:2][0:2];
reg [7:0] conv_ker [0:2][0:2];
reg [19:0] conv_out ;

//* floor2295
reg [7:0] floor2295_out ;

//* max pooling
reg max_pool_working_flag ;
reg [7:0] cmp_a , cmp_b , larger_num ;
reg [7:0] max_pool_out [0:1] ;
reg max_pool_right , max_pool_left ;

//* fully connect
reg [7:0] mult_in , mult_weight_a , mult_weight_b ;
reg [15:0] mult_out_q_a , mult_out_q_b , mult_out_a , mult_out_b ;
reg [16:0] fc_out_a , fc_out_b ;

//* floor510
reg [7:0] floor510_out_a , floor510_out_b ;

//* L1
reg [7:0] L1_buffer [0:4] ;
reg [8:0] sub_out_a , sub_out_b , abs_out_a , abs_out_b ;
reg [9:0] acc_out ;

//* activate
reg [9:0] activate_out ;


//* output control




//==============================================//
//       	 global control                     //
//==============================================//
//* working_flag
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) working_flag <= 0 ;
	else if (in_valid) working_flag <= 1 ;
	else if (out_valid) working_flag <= 0 ;
end

//* global_cnt
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		global_cnt <= 0 ;
	end else begin
		if (working_flag) begin
			global_cnt <= global_cnt + 1 ;
		end else begin
			global_cnt <= 0 ;
		end
	end
end


//==============================================//
//       	 data storage                       //
//==============================================//

//* weight_buffer_done_flag
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		weight_buffer_done_flag <= 0 ;
	end else begin
		if (global_cnt == 2) begin
			weight_buffer_done_flag <= 1 ;
		end 
		else if (out_valid) begin
			weight_buffer_done_flag <= 0 ;
		end
	end
end

//* ker_buffer_done_flag
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		ker_buffer_done_flag <= 0 ;
	end else begin
		if (global_cnt == 7) begin
			ker_buffer_done_flag <= 1 ;
		end 
		else if (out_valid) begin
			ker_buffer_done_flag <= 0 ;
		end
	end
end

//* ker_buffer
always @(posedge clk) begin
	// shift register
	if (~ker_buffer_done_flag) begin // no in_valid
		ker_buffer[8] <= ker;
		ker_buffer[7] <= ker_buffer[8];
		ker_buffer[6] <= ker_buffer[7];
		ker_buffer[5] <= ker_buffer[6];
		ker_buffer[4] <= ker_buffer[5];
		ker_buffer[3] <= ker_buffer[4];
		ker_buffer[2] <= ker_buffer[3];
		ker_buffer[1] <= ker_buffer[2];
		ker_buffer[0] <= ker_buffer[1];
	end
end

//* weight_buffer
always @(posedge clk) begin
	// shift register 
	if (~weight_buffer_done_flag) begin // no in_valid
		weight_buffer[3] <= weight;
		weight_buffer[2] <= weight_buffer[3];
		weight_buffer[1] <= weight_buffer[2];
		weight_buffer[0] <= weight_buffer[1];
	end
end

//* img_buffer
always @(posedge clk) begin
	case (global_cnt+working_flag)
		0,6,12,18,24,30,36,42,48,54,60,66: begin
			img_buffer [2][0] <= img ;
			
			img_buffer [1][0] <= img_buffer [2][0] ;
			img_buffer [1][1] <= img_buffer [2][1] ;
			img_buffer [1][2] <= img_buffer [2][2] ;
			img_buffer [1][3] <= img_buffer [2][3] ;
			img_buffer [1][4] <= img_buffer [2][4] ;	
			img_buffer [1][5] <= img_buffer [2][5] ;
			img_buffer [0][0] <= img_buffer [1][0] ;
			img_buffer [0][1] <= img_buffer [1][1] ;
			img_buffer [0][2] <= img_buffer [1][2] ;
			img_buffer [0][3] <= img_buffer [1][3] ;
			img_buffer [0][4] <= img_buffer [1][4] ;
			img_buffer [0][5] <= img_buffer [1][5] ;
		end
		1,7,13,19,25,31,37,43,49,55,61,67 : begin
			img_buffer [2][1] <= img ;
		end
		2,8,14,20,26,32,38,44,50,56,62,68 : begin
			img_buffer [2][2] <= img ;
		end
		3,9,15,21,27,33,39,45,51,57,63,69 : begin
			img_buffer [2][3] <= img ;
		end
		4,10,16,22,28,34,40,46,52,58,64,70 : begin
			img_buffer [2][4] <= img ;
		end
		5,11,17,23,29,35,41,47,53,59,65,71 : begin
			img_buffer [2][5] <= img ;
		end
		// default: 
	endcase
end

//==============================================//
//                  conv	IP                  //
//==============================================//

//* conv_ker
always @(*) begin
	conv_ker[0][0] = ker_buffer[0];
	conv_ker[0][1] = ker_buffer[1];
	conv_ker[0][2] = ker_buffer[2];
	conv_ker[1][0] = ker_buffer[3];
	conv_ker[1][1] = ker_buffer[4];
	conv_ker[1][2] = ker_buffer[5];
	conv_ker[2][0] = ker_buffer[6];
	conv_ker[2][1] = ker_buffer[7];
	conv_ker[2][2] = ker_buffer[8];
end

//* conv_img
always @(*) begin
	case (global_cnt)
		13,19,25,31,49,55,61,67 : begin
			conv_img[0][0] = img_buffer[0][0];
			conv_img[0][1] = img_buffer[0][1];
			conv_img[0][2] = img_buffer[0][2];
			conv_img[1][0] = img_buffer[1][0];
			conv_img[1][1] = img_buffer[1][1];
			conv_img[1][2] = img_buffer[1][2];
			conv_img[2][0] = img_buffer[2][0];
			conv_img[2][1] = img_buffer[2][1];
			conv_img[2][2] = img;
		end 
		14,20,26,32,50,56,62,68 : begin
			conv_img[0][0] = img_buffer[0][1];
			conv_img[0][1] = img_buffer[0][2];
			conv_img[0][2] = img_buffer[0][3];
			conv_img[1][0] = img_buffer[1][1];
			conv_img[1][1] = img_buffer[1][2];
			conv_img[1][2] = img_buffer[1][3];
			conv_img[2][0] = img_buffer[2][1];
			conv_img[2][1] = img_buffer[2][2];
			conv_img[2][2] = img;
		end
		15,21,27,33,51,57,63,69 : begin
			conv_img[0][0] = img_buffer[0][2];
			conv_img[0][1] = img_buffer[0][3];
			conv_img[0][2] = img_buffer[0][4];
			conv_img[1][0] = img_buffer[1][2];
			conv_img[1][1] = img_buffer[1][3];
			conv_img[1][2] = img_buffer[1][4];
			conv_img[2][0] = img_buffer[2][2];
			conv_img[2][1] = img_buffer[2][3];
			conv_img[2][2] = img;
		end
		16,22,28,34,52,58,64,70 : begin
			conv_img[0][0] = img_buffer[0][3];
			conv_img[0][1] = img_buffer[0][4];
			conv_img[0][2] = img_buffer[0][5];
			conv_img[1][0] = img_buffer[1][3];
			conv_img[1][1] = img_buffer[1][4];
			conv_img[1][2] = img_buffer[1][5];
			conv_img[2][0] = img_buffer[2][3];
			conv_img[2][1] = img_buffer[2][4];
			conv_img[2][2] = img;
		end
		default: begin
			// conv_img[0][0] = img_buffer[0][0];
			// conv_img[0][1] = img_buffer[0][1];
			// conv_img[0][2] = img_buffer[0][2];
			// conv_img[1][0] = img_buffer[1][0];
			// conv_img[1][1] = img_buffer[1][1];
			// conv_img[1][2] = img_buffer[1][2];
			// conv_img[2][0] = img_buffer[2][0];
			// conv_img[2][1] = img_buffer[2][1];
			// conv_img[2][2] = img;
			conv_img[0][0] = 0;
			conv_img[0][1] = 0;
			conv_img[0][2] = 0;
			conv_img[1][0] = 0;
			conv_img[1][1] = 0;
			conv_img[1][2] = 0;
			conv_img[2][0] = 0;
			conv_img[2][1] = 0;
			conv_img[2][2] = 0;
		end
	endcase
end

always @(posedge clk) begin
	conv_out <= conv_img[0][0] * conv_ker[0][0] +
				conv_img[0][1] * conv_ker[0][1] +
				conv_img[0][2] * conv_ker[0][2] +
				conv_img[1][0] * conv_ker[1][0] +
				conv_img[1][1] * conv_ker[1][1] +
				conv_img[1][2] * conv_ker[1][2] +
				conv_img[2][0] * conv_ker[2][0] +
				conv_img[2][1] * conv_ker[2][1] +
				conv_img[2][2] * conv_ker[2][2] ;
end

//==============================================//
//             floor     2295       		    //
//==============================================//

always @(*) begin
	floor2295_out = conv_out / 'd2295 ;
end

//==============================================//
//             Max pooling        	      	    //
//==============================================//
always @(*) begin
	case (global_cnt)
		15: cmp_b = max_pool_out[0] ;
		17: cmp_b = max_pool_out[1] ;
		20: cmp_b = max_pool_out[0] ;
		21: cmp_b = max_pool_out[0] ;
		22: cmp_b = max_pool_out[1] ;
		23: cmp_b = max_pool_out[1] ;
		27: cmp_b = max_pool_out[0] ;
		29: cmp_b = max_pool_out[1] ;
		32: cmp_b = max_pool_out[0] ;
		33: cmp_b = max_pool_out[0] ;
		34: cmp_b = max_pool_out[1] ;
		35: cmp_b = max_pool_out[1] ;

		51: cmp_b = max_pool_out[0] ;
		53: cmp_b = max_pool_out[1] ;
		56: cmp_b = max_pool_out[0] ;
		57: cmp_b = max_pool_out[0] ;
		58: cmp_b = max_pool_out[1] ;
		59: cmp_b = max_pool_out[1] ;
		63: cmp_b = max_pool_out[0] ;
		65: cmp_b = max_pool_out[1] ;
		68: cmp_b = max_pool_out[0] ;
		69: cmp_b = max_pool_out[0] ;
		70: cmp_b = max_pool_out[1] ;
		71: cmp_b = max_pool_out[1] ;
		default: cmp_b = 0 ;
	endcase
end

always @(*) begin
	cmp_a = floor2295_out ;
end

always @(*) begin
	larger_num = (cmp_a >= cmp_b) ? cmp_a : cmp_b ;
end

always @(posedge clk) begin
	case (global_cnt)
		14: max_pool_out[0] <= floor2295_out ;
		15: max_pool_out[0] <= larger_num ;
		16: max_pool_out[1] <= floor2295_out ;
		17: max_pool_out[1] <= larger_num ;
		20: max_pool_out[0] <= larger_num ;
		21: max_pool_out[0] <= larger_num ;
		22: max_pool_out[1] <= larger_num ;
		23: max_pool_out[1] <= larger_num ;
		26: max_pool_out[0] <= floor2295_out ;
		27: max_pool_out[0] <= larger_num ;
		28: max_pool_out[1] <= floor2295_out ;
		29: max_pool_out[1] <= larger_num ;
		32: max_pool_out[0] <= larger_num ;
		33: max_pool_out[0] <= larger_num ;
		34: max_pool_out[1] <= larger_num ;
		35: max_pool_out[1] <= larger_num ;
		
		50: max_pool_out[0] <= floor2295_out ;
		51: max_pool_out[0] <= larger_num ;
		52: max_pool_out[1] <= floor2295_out ;
		53: max_pool_out[1] <= larger_num ;
		56: max_pool_out[0] <= larger_num ;
		57: max_pool_out[0] <= larger_num ;
		58: max_pool_out[1] <= larger_num ;
		59: max_pool_out[1] <= larger_num ;
		62: max_pool_out[0] <= floor2295_out ;
		63: max_pool_out[0] <= larger_num ;
		64: max_pool_out[1] <= floor2295_out ;
		65: max_pool_out[1] <= larger_num ;
		68: max_pool_out[0] <= larger_num ;
		69: max_pool_out[0] <= larger_num ;
		70: max_pool_out[1] <= larger_num ;
		71: max_pool_out[1] <= larger_num ;
		// default: 
	endcase
end

//==============================================//
//             Fully connect       	      	    //
//==============================================//

always @(*) begin
	case (global_cnt)
		23,35,59,71 : mult_in = max_pool_out[0] ;
		24,36,60,72 : mult_in = max_pool_out[1] ;
		default: mult_in = 0 ;
	endcase
end

always @(*) begin
	case (global_cnt)
		23,35,59,71 : begin 
			mult_weight_a = weight_buffer[0] ;
			mult_weight_b = weight_buffer[1] ;
		end
		24,36,60,72 : begin 
			mult_weight_a = weight_buffer[2] ;
			mult_weight_b = weight_buffer[3] ;
		end
		default: begin 
			mult_weight_a = weight_buffer[2] ;
			mult_weight_b = weight_buffer[3] ;
		end
	endcase
end

always @(*) begin //ip
	mult_out_a = mult_in * mult_weight_a ;
	mult_out_b = mult_in * mult_weight_b ;
end

always @(posedge clk) begin
	case (global_cnt)
		23,35,59,71: begin
			mult_out_q_a <= mult_out_a ;
			mult_out_q_b <= mult_out_b ;
		end
		// default: 
	endcase
end

always @(*) begin
	fc_out_a = mult_out_q_a + mult_out_a ;
	fc_out_b = mult_out_q_b + mult_out_b ;
end

//==============================================//
//             	floor 510       		        //
//==============================================//

always @(posedge clk) begin // may gate
	floor510_out_a <= fc_out_a / 'd510 ;
	floor510_out_b <= fc_out_b / 'd510 ;
end

//==============================================//
//                 L1 distance         		    //
//==============================================//

always @(posedge clk) begin
	case (global_cnt)
		25 , 37 ,61 : begin
			L1_buffer[2] <= floor510_out_a ;
			L1_buffer[3] <= floor510_out_b ;
			L1_buffer[0] <= L1_buffer[2] ;
			L1_buffer[1] <= L1_buffer[3] ;
		end
		// default: 
	endcase
end

always @(*) begin
	sub_out_a = floor510_out_a - L1_buffer[0] ;
	sub_out_b = floor510_out_b - L1_buffer[1] ;
end

always @(*) begin
	abs_out_a = (sub_out_a[8]) ? -sub_out_a : sub_out_a ;
	abs_out_b = (sub_out_b[8]) ? -sub_out_b : sub_out_b ;
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		acc_out <= 0 ;
	end else if (out_valid) begin
		acc_out <= 0 ;
	end else begin
		case (global_cnt)
			61: begin
				acc_out <= acc_out + abs_out_a + abs_out_b ;
			end 
			// default: 
		endcase
	end
end

//==============================================//
//                      activate        	    //
//==============================================//
//* activate_out
wire [9:0] acc_out_imd = acc_out + abs_out_a + abs_out_b ;
always @(*) begin
	activate_out = acc_out_imd >= 'd16 ?  acc_out_imd : 0;
end


//==============================================//
//                 output control      			//
//==============================================//

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		out_valid <= 0 ;
	end else begin
		if (global_cnt == 72) begin
			out_valid <= 1 ;
		end else begin  
			out_valid <= 0 ;
		end
	end
end

always @(*) begin
	if (out_valid) begin
		out_data = activate_out ;
	end else begin
		out_data = 0 ;
	end
end

endmodule
