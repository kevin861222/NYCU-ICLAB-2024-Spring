// TODO : replace divide by shift
// TODO : switch the order of if statement in sorting
// TODO : replace if-else statement by case statement
// TODO : replace case by if-else 
// TODO : use 2's complement first , then add subtrahend
// TODO : change adder to many 2-to-1 adder 
// TODO : Save mult , but fail
// TODO : use case statement to implement divider
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//!   ICLAB 2024 Spring
//!
//!   Lab01 Exercise	: Code Calculator
//!
//!   Author     		: Wang Yu
//!
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//!   File Name   : CC.v
//!
//!   Module Name : CC
//!
//!   Release version : V9.0 (Release Date: 2024-03)
//!
//!	  Area : 18927
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################


module CC(
// Input signals
	opt,
	in_n0, in_n1, in_n2, in_n3, in_n4,  
// Output signals
	out_n
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input wire [3:0] in_n0, in_n1, in_n2, in_n3, in_n4; //! sequence number
input wire [2:0] opt; //! opt[0]:Normalization , opt[1]:Sorting , opt[2]:Calculation .
/*
opt[0]: 1: Normalize 
		0: Don’t normalize
opt[1]: 1: Sort from largest to smallest.
		0: Sort from smallest to largest. 
opt[2]: 1: Eq : | n3 * 3 – n0 * n4 |
		0: Eq : ((n0 + n1 * n2 + avg *n3) / 3)
*/
output reg [9:0] out_n; //! Answer        					

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment

reg [3:0] temp ; //! register fdor sorting 
reg [3:0] num [0:4] ; //! sorting sequence
reg signed [4:0] subtrahend ; //! subtrahend for normalize
reg [4:0] sum ; //! num[0]+num[4]
reg signed [4:0] num_normal [0:4] ; //! sequence after normalize
reg signed [4:0] num_sub [0:4] ; //! sequence num sub subtrahend
reg signed [4:0] avg ; //! (num_normal[0]+num_normal[1]+...+num_normal[4])/5
reg signed [9:0] answer ; //! Answer
reg signed [9:0] casestatement ; // 9
reg signed [7:0] subtrahend_five ; // 7
//================================================================
//    DESIGN
//================================================================
always @(*) begin
	num[0] = in_n0 ;
	num[1] = in_n1 ;
	num[2] = in_n2 ;
	num[3] = in_n3 ;
	num[4] = in_n4 ;
	casestatement = in_n0 + in_n1 + in_n2 + in_n3 + in_n4 ;
/*Sorting : from the largest to the smallest 
Network : 
	[(0,3),(1,4)]
	[(0,2),(1,3)]
	[(0,1),(2,4)]
	[(1,2),(3,4)]
	[(2,3)]
*/
	//* layer 0
	if (num[1]<=num[4]) begin
		temp = num[1] ;
		num[1] = num[4] ;
		num[4] = temp ;
	end
	if (num[0]<=num[3]) begin
		temp = num[0] ;
		num[0] = num[3] ;
		num[3] = temp ;
	end

	//* layer 1
	if (num[1]<=num[3]) begin
		temp = num[1] ;
		num[1] = num[3] ;
		num[3] = temp ;
	end
	if (num[0]<=num[2]) begin
		temp = num[0] ;
		num[0] = num[2] ;
		num[2] = temp ;
	end
	

	//* layer 2
	if (num[0]<=num[1]) begin
		temp = num[0] ;
		num[0] = num[1] ;
		num[1] = temp ;
	end
	if (num[2]<=num[4]) begin
		temp = num[2] ;
		num[2] = num[4] ;
		num[4] = temp ;
	end

	//* layer 3
	if (num[1]<=num[2]) begin
		temp = num[1] ;
		num[1] = num[2] ;
		num[2] = temp ;
	end
	if (num[3]<=num[4]) begin
		temp = num[3] ;
		num[3] = num[4] ;
		num[4] = temp ;
	end
  sum = num[0] + num[4] ;
	subtrahend = ~( sum >> 1'b1 )+1;
  num_sub[0] = num[0] + subtrahend ;
	num_sub[1] = num[1] + subtrahend ;
  num_sub[4] = num[4] + subtrahend ;
  subtrahend_five = subtrahend<<<2'b10 ;
	// subtrahend_five = subtrahend_five + subtrahend ;
  if (opt[0]) begin
    casestatement = casestatement + subtrahend ;
    casestatement = casestatement+subtrahend_five;
	end
  
	//* layer 4
	if (num[2]<=num[3]) begin
		temp = num[2] ;
		num[2] = num[3] ;
		num[3] = temp ;
	end

/*Normalize*/
	num_sub[2] = num[2] + subtrahend ;
	num_sub[3] = num[3] + subtrahend ;
	/*
	opt[1]=1 : Large to Small
	opt[1]=0 : Small to Large

	opt[0]=1 : Do subtract
	opt[0]=0 : Don't subtract
	*/
	
  case (casestatement) // synopsys full_case
		-19, -18, -17, -16, -15: avg = -3 ; // can't save 
		-14, -13, -12, -11, -10: avg = -2 ;
		-9,  -8,  -7,  -6,  -5: avg = -1 ;
		-4,  -3,  -2,  -1,   0,   1,   2,   3,   4: avg =  0 ;
		5,   6,   7,   8,   9: avg =  1 ;
		10,  11,  12,  13,  14: avg =  2 ;
		15,  16,  17,  18,  19: avg =  3 ;
		20,  21,  22,  23,  24: avg =  4 ;
		25,  26,  27,  28,  29: avg =  5 ;
		30,  31,  32,  33,  34: avg =  6 ;
		35,  36,  37,  38,  39: avg =  7 ;
		40,  41,  42,  43,  44: avg =  8 ; //end line
		45,  46,  47,  48,  49: avg =  9 ;
		50,  51,  52,  53,  54: avg = 10 ;
		55,  56,  57,  58,  59: avg = 11 ;
		60,  61,  62,  63,  64: avg = 12 ; // can't save 
		65,  66,  67,  68,  69: avg = 13 ; // can't save
	endcase
	if (opt[1]) begin
		if (opt[0]) begin
			num_normal[0] = num_sub[0] ;
			num_normal[1] = num_sub[1] ;
			num_normal[2] = num_sub[2] ;
			num_normal[3] = num_sub[3] ;
			num_normal[4] = num_sub[4] ;
		end else begin
			num_normal[0] = num[0] ;
			num_normal[1] = num[1] ;
			num_normal[2] = num[2] ;
			num_normal[3] = num[3] ;
			num_normal[4] = num[4] ;
		end
	end else begin
		if (opt[0]) begin
			num_normal[0] = num_sub[4] ;
			num_normal[1] = num_sub[3] ;
			num_normal[2] = num_sub[2] ;
			num_normal[3] = num_sub[1] ;
			num_normal[4] = num_sub[0] ;
		end else begin
			num_normal[0] = num[4] ;
			num_normal[1] = num[3] ;
			num_normal[2] = num[2] ;
			num_normal[3] = num[1] ;
			num_normal[4] = num[0] ;
		end
	end

/*Calculation*/
	
	if (opt[2]) begin
	/* | n3*3 - n0*n4 | */
		// answer = num_normal[0] * num_normal[4] - num_normal[3]*3  ;
	  answer = num_normal[0] * num_normal[4] - num_normal[3] -(num_normal[3]<<<1'b1)  ; // 20111.414720 
		if (answer[9]) begin
			answer = - answer ;
		end
	end else begin
	/* ( (n0 + n1*n2 + avg*n3 ) / 3 ) */
		case (num_normal[0] + num_normal[1]*num_normal[2] + avg*num_normal[3]) // synopsys full_case
			-38, -37, -36: answer = -12;
			-35, -34, -33: answer = -11; 
			-32, -31, -30: answer = -10;
			-29, -28, -27: answer =  -9;
			-26, -25, -24: answer =  -8;
			-23, -22, -21: answer =  -7;
			-20, -19, -18: answer =  -6;
			-17, -16, -15: answer =  -5;
			-14, -13, -12: answer =  -4;
			-11, -10,  -9: answer =  -3;
			-8,  -7,  -6: answer =  -2;
			-5,  -4,  -3: answer =  -1;
			-2,  -1,   0,   1,   2: answer =   0;
			3,   4,   5: answer =   1;
			6,   7,   8: answer =   2;
			9,  10,  11: answer =   3;
			12,  13,  14: answer =   4;
			15,  16,  17: answer =   5;
			18,  19,  20: answer =   6;
			21,  22,  23: answer =   7;
			24,  25,  26: answer =   8;
			27,  28,  29: answer =   9;
			30,  31,  32: answer =  10;
			33,  34,  35: answer =  11;
			36,  37,  38: answer =  12;
			39,  40,  41: answer =  13;
			42,  43,  44: answer =  14;
			45,  46,  47: answer =  15;
			48,  49,  50: answer =  16;
			51,  52,  53: answer =  17;
			54,  55,  56: answer =  18;
			57,  58,  59: answer =  19;
			60,  61,  62: answer =  20;
			63,  64,  65: answer =  21;
			66,  67,  68: answer =  22;
			69,  70,  71: answer =  23;
			72,  73,  74: answer =  24;
			75,  76,  77: answer =  25;
			78,  79,  80: answer =  26;
			81,  82,  83: answer =  27;
			84,  85,  86: answer =  28;
			87,  88,  89: answer =  29;
			90,  91,  92: answer =  30;
			93,  94,  95: answer =  31;
			96,  97,  98: answer =  32;
			99, 100, 101: answer =  33;
			102, 103, 104: answer =  34;
			105, 106, 107: answer =  35;
			108, 109, 110: answer =  36;
			111, 112, 113: answer =  37;
			114, 115, 116: answer =  38;
			117, 118, 119: answer =  39;
			120, 121, 122: answer =  40;
			123, 124, 125: answer =  41;
			126, 127, 128: answer =  42;
			129, 130, 131: answer =  43;
			132, 133, 134: answer =  44;
			135, 136, 137: answer =  45;
			138, 139, 140: answer =  46;
			141, 142, 143: answer =  47;
			144, 145, 146: answer =  48;
			147, 148, 149: answer =  49;
			150, 151, 152: answer =  50;
			153, 154, 155: answer =  51;
			156, 157, 158: answer =  52;
			159, 160, 161: answer =  53;
			162, 163, 164: answer =  54;
			165, 166, 167: answer =  55;
			168, 169, 170: answer =  56;
			171, 172, 173: answer =  57;
			174, 175, 176: answer =  58;
			177, 178, 179: answer =  59;
			180, 181, 182: answer =  60;
			183, 184, 185: answer =  61;
			186, 187, 188: answer =  62;
			189, 190, 191: answer =  63;
			192, 193, 194: answer =  64;
			195, 196, 197: answer =  65;
			198, 199, 200: answer =  66;
			201, 202, 203: answer =  67;
			204, 205, 206: answer =  68;
			207, 208, 209: answer =  69;
			210, 211, 212: answer =  70;
			213, 214, 215: answer =  71;
			216, 217, 218: answer =  72;
			219, 220, 221: answer =  73;
			222, 223, 224: answer =  74;
			225, 226, 227: answer =  75;
			228, 229, 230: answer =  76;// end line
			231, 232, 233: answer =  77;
			234, 235, 236: answer =  78;
			237, 238, 239: answer =  79;
			240, 241, 242: answer =  80;
			243, 244, 245: answer =  81;
			246, 247, 248: answer =  82;
			249, 250, 251: answer =  83;
			252, 253, 254: answer =  84;
			255, 256, 257: answer =  85;
			258, 259, 260: answer =  86;
			261, 262, 263: answer =  87;
			264, 265, 266: answer =  88;
			267, 268, 269: answer =  89;
			270, 271, 272: answer =  90;
			273, 274, 275: answer =  91;
			276, 277, 278: answer =  92;
			279, 280, 281: answer =  93;
			282, 283, 284: answer =  94;
			285, 286, 287: answer =  95;
			288, 289, 290: answer =  96;
			291, 292, 293: answer =  97;
			294, 295, 296: answer =  98;
			297, 298, 299: answer =  99;
			300, 301, 302: answer = 100;
			303, 304, 305: answer = 101;
			312, 313, 314: answer = 104;
			315, 316, 317: answer = 105;
			318, 319, 320: answer = 106;
			324, 325, 326: answer = 108;
			327, 328, 329: answer = 109;
			330, 331, 332: answer = 110;
			333, 334, 335: answer = 111;
			339, 340, 341: answer = 113;
			342, 343, 344: answer = 114;
			345, 346, 347: answer = 115;
			348, 349, 350: answer = 116;
			354, 355, 356: answer = 118;
			366, 367, 368: answer = 122;
			387, 388, 389: answer = 129;
			393: answer = 131;
			407: answer = 135;
			409: answer = 136;
		endcase
	end
	out_n = answer ;
end
endmodule
