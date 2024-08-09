//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : SORT_IP.v
//   	Module Name : SORT_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module SORT_IP #(parameter IP_WIDTH = 8) (
    // Input signals
    IN_character, IN_weight,
    // Output signals
    OUT_character
);

// ===============================================================
// Input & Output
// ===============================================================
input wire [IP_WIDTH*4-1:0] IN_character;  //4bits
input wire [IP_WIDTH*5-1:0]  IN_weight;    //5bits

output wire [IP_WIDTH*4-1:0] OUT_character;
// ===============================================================
// wire / reg 
// ===============================================================

// ===============================================================
// Design
// ===============================================================


integer i ;
generate
    case (IP_WIDTH)
        2: begin :u_IP_WIDTH2
        reg [3:0] ary0[0:1];
        reg [4:0] w0[0:1];
        reg [IP_WIDTH*4-1:0] OUT_character_q ;
        always @(*) begin
          for (i = 0; i < 2; i = i + 1) begin
            ary0[i] = IN_character[4*(1-i)+:4];
            w0[i]   = IN_weight[5*(1-i)+:5];
          end
          if (w0[0] < w0[1]) OUT_character_q = {ary0[1], ary0[0]};
          else OUT_character_q = {ary0[0], ary0[1]};
        end
        assign OUT_character = OUT_character_q ;
            // CMP2to1 u_CMP2to12to1(  .char_in0(IN_character[7:4]),
            //                 .char_in1(IN_character[3:0]),
            //                 .cmp2to1_a(IN_weight[9:5]),
            //                 .cmp2to1_b(IN_weight[4:0]),
            //                 // .b_large_than_a(OUT_character[0])
            //                 .char1(OUT_character[7:4]) ,
            //                 .char2(OUT_character[3:0]) 
            //                 );
            // eight_weights_sorting u_W2_sort (   .char_in0(IN_character[7:4]),
            //                                     .char_in1(IN_character[3:0]),
            //                                     .char_in2(0),
            //                                     .char_in3(0),
            //                                     .char_in4(0),
            //                                     .char_in5(0),
            //                                     .char_in6(0),
            //                                     .char_in7(0),
            //                                     .weight0(IN_weight[9:5]),
            //                                     .weight1(IN_weight[4:0]),
            //                                     .weight2(0),
            //                                     .weight3(0),
            //                                     .weight4(0),
            //                                     .weight5(0),
            //                                     .weight6(0),
            //                                     .weight7(0),
            //                                     .char0(OUT_character[7:4]) ,
            //                                     .char1(OUT_character[3:0]) ,
            //                                     .char2() ,
            //                                     .char3() ,
            //                                     .char4() ,
            //                                     .char5() ,
            //                                     .char6() ,
            //                                     .char7() );
        end
        3: begin  :u_IP_WIDTH3
            eight_weights_sorting u_W3_sort (   .char_in0(IN_character[11:8]),
                                                .char_in1(IN_character[7:4]),
                                                .char_in2(IN_character[3:0]),
                                                .char_in3(0),
                                                .char_in4(0),
                                                .char_in5(0),
                                                .char_in6(0),
                                                .char_in7(0),
                                                .weight0(IN_weight[14:10]),
                                                .weight1(IN_weight[9:5]),
                                                .weight2(IN_weight[4:0]),
                                                .weight3(0),
                                                .weight4(0),
                                                .weight5(0),
                                                .weight6(0),
                                                .weight7(0),
                                                .char0(OUT_character[11:8]) ,
                                                .char1(OUT_character[7:4]) ,
                                                .char2(OUT_character[3:0]) ,
                                                .char3() ,
                                                .char4() ,
                                                .char5() ,
                                                .char6() ,
                                                .char7() );
        end
        4 : begin :u_IP_WIDTH4
            eight_weights_sorting u_W4_sort (   .char_in0(IN_character[15:12]),
                                                .char_in1(IN_character[11:8]),
                                                .char_in2(IN_character[7:4]),
                                                .char_in3(IN_character[3:0]),
                                                .char_in4(0),
                                                .char_in5(0),
                                                .char_in6(0),
                                                .char_in7(0),
                                                .weight0(IN_weight[19:15]),
                                                .weight1(IN_weight[14:10]),
                                                .weight2(IN_weight[9:5]),
                                                .weight3(IN_weight[4:0]),
                                                .weight4(0),
                                                .weight5(0),
                                                .weight6(0),
                                                .weight7(0),
                                                .char0(OUT_character[15:12]) ,
                                                .char1(OUT_character[11:8]) ,
                                                .char2(OUT_character[7:4]) ,
                                                .char3(OUT_character[3:0]) ,
                                                .char4() ,
                                                .char5() ,
                                                .char6() ,
                                                .char7() );
        end
        5 : begin :u_IP_WIDTH5
            eight_weights_sorting u_W5_sort (   .char_in0(IN_character[19:16]),
                                                .char_in1(IN_character[15:12]),
                                                .char_in2(IN_character[11:8]),
                                                .char_in3(IN_character[7:4]),
                                                .char_in4(IN_character[3:0]),
                                                .char_in5(0),
                                                .char_in6(0),
                                                .char_in7(0),
                                                .weight0(IN_weight[24:20]),
                                                .weight1(IN_weight[19:15]),
                                                .weight2(IN_weight[14:10]),
                                                .weight3(IN_weight[9:5]),
                                                .weight4(IN_weight[4:0]),
                                                .weight5(0),
                                                .weight6(0),
                                                .weight7(0),
                                                .char0(OUT_character[19:16]) ,
                                                .char1(OUT_character[15:12]) ,
                                                .char2(OUT_character[11:8]) ,
                                                .char3(OUT_character[7:4]) ,
                                                .char4(OUT_character[3:0]) ,
                                                .char5() ,
                                                .char6() ,
                                                .char7() );
        end
        6 : begin :u_IP_WIDTH6
            eight_weights_sorting u_W6_sort (   .char_in0(IN_character[23:20]),
                                                .char_in1(IN_character[19:16]),
                                                .char_in2(IN_character[15:12]),
                                                .char_in3(IN_character[11:8]),
                                                .char_in4(IN_character[7:4]),
                                                .char_in5(IN_character[3:0]),
                                                .char_in6(0),
                                                .char_in7(0),
                                                .weight0(IN_weight[29:25]),
                                                .weight1(IN_weight[24:20]),
                                                .weight2(IN_weight[19:15]),
                                                .weight3(IN_weight[14:10]),
                                                .weight4(IN_weight[9:5]),
                                                .weight5(IN_weight[4:0]),
                                                .weight6(0),
                                                .weight7(0),
                                                .char0(OUT_character[23:20]) ,
                                                .char1(OUT_character[19:16]) ,
                                                .char2(OUT_character[15:12]) ,
                                                .char3(OUT_character[11:8]) ,
                                                .char4(OUT_character[7:4]) ,
                                                .char5(OUT_character[3:0]) ,
                                                .char6() ,
                                                .char7() );
        end
        7 : begin :u_IP_WIDTH7
            eight_weights_sorting u_W7_sort (   .char_in0(IN_character[27:24]),
                                                .char_in1(IN_character[23:20]),
                                                .char_in2(IN_character[19:16]),
                                                .char_in3(IN_character[15:12]),
                                                .char_in4(IN_character[11:8]),
                                                .char_in5(IN_character[7:4]),
                                                .char_in6(IN_character[3:0]),
                                                .char_in7(0),
                                                .weight0(IN_weight[34:30]),
                                                .weight1(IN_weight[29:25]),
                                                .weight2(IN_weight[24:20]),
                                                .weight3(IN_weight[19:15]),
                                                .weight4(IN_weight[14:10]),
                                                .weight5(IN_weight[9:5]),
                                                .weight6(IN_weight[4:0]),
                                                .weight7(0),
                                                .char0(OUT_character[27:24]) ,
                                                .char1(OUT_character[23:20]) ,
                                                .char2(OUT_character[19:16]) ,
                                                .char3(OUT_character[15:12]) ,
                                                .char4(OUT_character[11:8]) ,
                                                .char5(OUT_character[7:4]) ,
                                                .char6(OUT_character[3:0]) ,
                                                .char7() );
        end
        8 : begin :u_IP_WIDTH8
            eight_weights_sorting u_W8_sort (   .char_in0(IN_character[31:28]),
                                                .char_in1(IN_character[27:24]),
                                                .char_in2(IN_character[23:20]),
                                                .char_in3(IN_character[19:16]),
                                                .char_in4(IN_character[15:12]),
                                                .char_in5(IN_character[11:8]),
                                                .char_in6(IN_character[7:4]),
                                                .char_in7(IN_character[3:0]),
                                                .weight0(IN_weight[39:35]),
                                                .weight1(IN_weight[34:30]),
                                                .weight2(IN_weight[29:25]),
                                                .weight3(IN_weight[24:20]),
                                                .weight4(IN_weight[19:15]),
                                                .weight5(IN_weight[14:10]),
                                                .weight6(IN_weight[9:5]),
                                                .weight7(IN_weight[4:0]),
                                                .char0(OUT_character[31:28]) ,
                                                .char1(OUT_character[27:24]) ,
                                                .char2(OUT_character[23:20]) ,
                                                .char3(OUT_character[19:16]) ,
                                                .char4(OUT_character[15:12]) ,
                                                .char5(OUT_character[11:8]) ,
                                                .char6(OUT_character[7:4]) ,
                                                .char7(OUT_character[3:0]) );
        end
    endcase
endgenerate




endmodule


module eight_weights_sorting (
    input wire [3:0] char_in0 , 
    input wire [3:0] char_in1 , 
    input wire [3:0] char_in2 , 
    input wire [3:0] char_in3 , 
    input wire [3:0] char_in4 , 
    input wire [3:0] char_in5 , 
    input wire [3:0] char_in6 , 
    input wire [3:0] char_in7 , 
    input wire [4:0] weight0 , 
    input wire [4:0] weight1 ,
    input wire [4:0] weight2 ,
    input wire [4:0] weight3 ,
    input wire [4:0] weight4 ,
    input wire [4:0] weight5 ,
    input wire [4:0] weight6 ,
    input wire [4:0] weight7 ,
    output reg [3:0] char0 ,
    output reg [3:0] char1 ,
    output reg [3:0] char2 ,
    output reg [3:0] char3 ,
    output reg [3:0] char4 ,
    output reg [3:0] char5 ,
    output reg [3:0] char6 ,
    output reg [3:0] char7 
);

reg [31:0]  in_char;
reg [39:0]  in_weight;
wire [31:0] out_char;

always @(*) begin
    in_char = {char_in0 , char_in1 , char_in2 , char_in3 , char_in4 , char_in5 , char_in6 , char_in7} ;
    in_weight = {weight0 , weight1 , weight2 , weight3 , weight4 , weight5 , weight6 , weight7 } ;
    {char0 , char1 , char2 , char3 , char4 , char5 , char6 , char7} = out_char ;
end

// ===============================================================
// Design
// ===============================================================

reg [31:0]out_char_q;
wire [31:0]out_char_d;

reg [39:0]weight_q;
wire [39:0]weight_d;

assign out_char_d = in_char ;
assign weight_d = in_weight ;
assign out_char = out_char_q;

// ===============
// merge sorting 
// ===============

// stable sorting

always@(*) begin
    out_char_q = out_char_d;
    weight_q = weight_d;
	if(weight_q[4:0] > weight_q[9:5]) begin
		{weight_q[4:0],  weight_q[9:5]} = {weight_q[9:5],  weight_q[4:0]};
    {out_char_q[3:0], out_char_q[7:4]} = {out_char_q[7:4], out_char_q[3:0]};
	end
	else begin
		{weight_q[4:0],  weight_q[9:5]} = {weight_q[4:0],  weight_q[9:5]};
        {out_char_q[7:4], out_char_q[3:0]} = {out_char_q[7:4], out_char_q[3:0]};
	end
	if(weight_q[14:10] > weight_q[19:15]) begin
		{weight_q[14:10],  weight_q[19:15]} = {weight_q[19:15],  weight_q[14:10]};
        {out_char_q[11:8], out_char_q[15:12]} = {out_char_q[15:12], out_char_q[11:8]};
	end
	else begin
		{weight_q[19:15],  weight_q[14:10]} = {weight_q[19:15],  weight_q[14:10]};
        {out_char_q[11:8], out_char_q[15:12]} = {out_char_q[11:8], out_char_q[15:12]};
	end
	if(weight_q[24:20] > weight_q[29:25]) begin
		{weight_q[24:20],  weight_q[29:25]} = {weight_q[29:25],  weight_q[24:20]};
        {out_char_q[19:16], out_char_q[23:20]} = {out_char_q[23:20], out_char_q[19:16]};
	end
	else begin
		{weight_q[24:20],  weight_q[29:25]} = {weight_q[24:20],  weight_q[29:25]};
        {out_char_q[19:16], out_char_q[23:20]} = {out_char_q[19:16], out_char_q[23:20]};
	end
	if(weight_q[34:30] > weight_q[39:35]) begin
		{weight_q[34:30],  weight_q[39:35]} = {weight_q[39:35],  weight_q[34:30]};
        {out_char_q[27:24], out_char_q[31:28]} = {out_char_q[31:28], out_char_q[27:24]};
	end
	else begin
		{weight_q[34:30],  weight_q[39:35]} = {weight_q[34:30],  weight_q[39:35]};
        {out_char_q[27:24], out_char_q[31:28]} = {out_char_q[27:24], out_char_q[31:28]};
	end
    if(weight_q[9:5] > weight_q[14:10]) begin
		{weight_q[9:5],  weight_q[14:10]} = {weight_q[14:10],  weight_q[9:5]};
        {out_char_q[7:4], out_char_q[11:8]} = {out_char_q[11:8], out_char_q[7:4]};
	end
	else begin
		{weight_q[9:5],  weight_q[14:10]} = {weight_q[9:5],  weight_q[14:10]};
        {out_char_q[7:4], out_char_q[11:8]} = {out_char_q[7:4], out_char_q[11:8]};
	end
	if(weight_q[19:15] > weight_q[24:20]) begin
		{weight_q[19:15],  weight_q[24:20]} = {weight_q[24:20],  weight_q[19:15]};
        {out_char_q[15:12], out_char_q[19:16]} = {out_char_q[19:16], out_char_q[15:12]};
	end
	else begin
		{weight_q[19:15],  weight_q[24:20]} = {weight_q[19:15],  weight_q[24:20]};
        {out_char_q[15:12], out_char_q[19:16]} = {out_char_q[15:12], out_char_q[19:16]};
	end
	if(weight_q[29:25] > weight_q[34:30]) begin
		{weight_q[29:25],  weight_q[34:30]} = {weight_q[34:30],  weight_q[29:25]};
        {out_char_q[23:20], out_char_q[27:24]} = {out_char_q[27:24], out_char_q[23:20]};
	end
	else begin
		{weight_q[29:25],  weight_q[34:30]} = {weight_q[29:25],  weight_q[34:30]};
        {out_char_q[23:20], out_char_q[27:24]} = {out_char_q[23:20], out_char_q[27:24]};
	end

    if(weight_q[4:0] > weight_q[9:5]) begin
		{weight_q[4:0],  weight_q[9:5]} = {weight_q[9:5],  weight_q[4:0]};
        {out_char_q[3:0], out_char_q[7:4]} = {out_char_q[7:4], out_char_q[3:0]};
	end
	else begin
		{weight_q[4:0],  weight_q[9:5]} = {weight_q[4:0],  weight_q[9:5]};
        {out_char_q[7:4], out_char_q[3:0]} = {out_char_q[7:4], out_char_q[3:0]};
	end
	if(weight_q[14:10] > weight_q[19:15]) begin
		{weight_q[14:10],  weight_q[19:15]} = {weight_q[19:15],  weight_q[14:10]};
        {out_char_q[11:8], out_char_q[15:12]} = {out_char_q[15:12], out_char_q[11:8]};
	end
	else begin
		{weight_q[19:15],  weight_q[14:10]} = {weight_q[19:15],  weight_q[14:10]};
        {out_char_q[11:8], out_char_q[15:12]} = {out_char_q[11:8], out_char_q[15:12]};
	end
	if(weight_q[24:20] > weight_q[29:25]) begin
		{weight_q[24:20],  weight_q[29:25]} = {weight_q[29:25],  weight_q[24:20]};
        {out_char_q[19:16], out_char_q[23:20]} = {out_char_q[23:20], out_char_q[19:16]};
	end
	else begin
		{weight_q[24:20],  weight_q[29:25]} = {weight_q[24:20],  weight_q[29:25]};
        {out_char_q[19:16], out_char_q[23:20]} = {out_char_q[19:16], out_char_q[23:20]};
	end
	if(weight_q[34:30] > weight_q[39:35]) begin
		{weight_q[34:30],  weight_q[39:35]} = {weight_q[39:35],  weight_q[34:30]};
        {out_char_q[27:24], out_char_q[31:28]} = {out_char_q[31:28], out_char_q[27:24]};
	end
	else begin
		{weight_q[34:30],  weight_q[39:35]} = {weight_q[34:30],  weight_q[39:35]};
        {out_char_q[27:24], out_char_q[31:28]} = {out_char_q[27:24], out_char_q[31:28]};
	end
    if(weight_q[9:5] > weight_q[14:10]) begin
		{weight_q[9:5],  weight_q[14:10]} = {weight_q[14:10],  weight_q[9:5]};
        {out_char_q[7:4], out_char_q[11:8]} = {out_char_q[11:8], out_char_q[7:4]};
	end
	else begin
		{weight_q[9:5],  weight_q[14:10]} = {weight_q[9:5],  weight_q[14:10]};
        {out_char_q[7:4], out_char_q[11:8]} = {out_char_q[7:4], out_char_q[11:8]};
	end
	if(weight_q[19:15] > weight_q[24:20]) begin
		{weight_q[19:15],  weight_q[24:20]} = {weight_q[24:20],  weight_q[19:15]};
        {out_char_q[15:12], out_char_q[19:16]} = {out_char_q[19:16], out_char_q[15:12]};
	end
	else begin
		{weight_q[19:15],  weight_q[24:20]} = {weight_q[19:15],  weight_q[24:20]};
        {out_char_q[15:12], out_char_q[19:16]} = {out_char_q[15:12], out_char_q[19:16]};
	end
	if(weight_q[29:25] > weight_q[34:30]) begin
		{weight_q[29:25],  weight_q[34:30]} = {weight_q[34:30],  weight_q[29:25]};
        {out_char_q[23:20], out_char_q[27:24]} = {out_char_q[27:24], out_char_q[23:20]};
	end
	else begin
		{weight_q[29:25],  weight_q[34:30]} = {weight_q[29:25],  weight_q[34:30]};
        {out_char_q[23:20], out_char_q[27:24]} = {out_char_q[23:20], out_char_q[27:24]};
	end
	
    if(weight_q[4:0] > weight_q[9:5]) begin
		{weight_q[4:0],  weight_q[9:5]} = {weight_q[9:5],  weight_q[4:0]};
        {out_char_q[3:0], out_char_q[7:4]} = {out_char_q[7:4], out_char_q[3:0]};
	end
	else begin
		{weight_q[4:0],  weight_q[9:5]} = {weight_q[4:0],  weight_q[9:5]};
        {out_char_q[7:4], out_char_q[3:0]} = {out_char_q[7:4], out_char_q[3:0]};
	end
	if(weight_q[14:10] > weight_q[19:15]) begin
		{weight_q[14:10],  weight_q[19:15]} = {weight_q[19:15],  weight_q[14:10]};
        {out_char_q[11:8], out_char_q[15:12]} = {out_char_q[15:12], out_char_q[11:8]};
	end
	else begin
		{weight_q[19:15],  weight_q[14:10]} = {weight_q[19:15],  weight_q[14:10]};
        {out_char_q[11:8], out_char_q[15:12]} = {out_char_q[11:8], out_char_q[15:12]};
	end
	if(weight_q[24:20] > weight_q[29:25]) begin
		{weight_q[24:20],  weight_q[29:25]} = {weight_q[29:25],  weight_q[24:20]};
        {out_char_q[19:16], out_char_q[23:20]} = {out_char_q[23:20], out_char_q[19:16]};
	end
	else begin
		{weight_q[24:20],  weight_q[29:25]} = {weight_q[24:20],  weight_q[29:25]};
        {out_char_q[19:16], out_char_q[23:20]} = {out_char_q[19:16], out_char_q[23:20]};
	end
	if(weight_q[34:30] > weight_q[39:35]) begin
		{weight_q[34:30],  weight_q[39:35]} = {weight_q[39:35],  weight_q[34:30]};
        {out_char_q[27:24], out_char_q[31:28]} = {out_char_q[31:28], out_char_q[27:24]};
	end
	else begin
		{weight_q[34:30],  weight_q[39:35]} = {weight_q[34:30],  weight_q[39:35]};
        {out_char_q[27:24], out_char_q[31:28]} = {out_char_q[27:24], out_char_q[31:28]};
	end
    if(weight_q[9:5] > weight_q[14:10]) begin
		{weight_q[9:5],  weight_q[14:10]} = {weight_q[14:10],  weight_q[9:5]};
        {out_char_q[7:4], out_char_q[11:8]} = {out_char_q[11:8], out_char_q[7:4]};
	end
	else begin
		{weight_q[9:5],  weight_q[14:10]} = {weight_q[9:5],  weight_q[14:10]};
        {out_char_q[7:4], out_char_q[11:8]} = {out_char_q[7:4], out_char_q[11:8]};
	end
	if(weight_q[19:15] > weight_q[24:20]) begin
		{weight_q[19:15],  weight_q[24:20]} = {weight_q[24:20],  weight_q[19:15]};
        {out_char_q[15:12], out_char_q[19:16]} = {out_char_q[19:16], out_char_q[15:12]};
	end
	else begin
		{weight_q[19:15],  weight_q[24:20]} = {weight_q[19:15],  weight_q[24:20]};
        {out_char_q[15:12], out_char_q[19:16]} = {out_char_q[15:12], out_char_q[19:16]};
	end
	if(weight_q[29:25] > weight_q[34:30]) begin
		{weight_q[29:25],  weight_q[34:30]} = {weight_q[34:30],  weight_q[29:25]};
        {out_char_q[23:20], out_char_q[27:24]} = {out_char_q[27:24], out_char_q[23:20]};
	end
	else begin
		{weight_q[29:25],  weight_q[34:30]} = {weight_q[29:25],  weight_q[34:30]};
        {out_char_q[23:20], out_char_q[27:24]} = {out_char_q[23:20], out_char_q[27:24]};
	end

    if(weight_q[4:0] > weight_q[9:5]) begin
		{weight_q[4:0],  weight_q[9:5]} = {weight_q[9:5],  weight_q[4:0]};
        {out_char_q[3:0], out_char_q[7:4]} = {out_char_q[7:4], out_char_q[3:0]};
	end
	else begin
		{weight_q[4:0],  weight_q[9:5]} = {weight_q[4:0],  weight_q[9:5]};
        {out_char_q[7:4], out_char_q[3:0]} = {out_char_q[7:4], out_char_q[3:0]};
	end
	if(weight_q[14:10] > weight_q[19:15]) begin
		{weight_q[14:10],  weight_q[19:15]} = {weight_q[19:15],  weight_q[14:10]};
        {out_char_q[11:8], out_char_q[15:12]} = {out_char_q[15:12], out_char_q[11:8]};
	end
	else begin
		{weight_q[19:15],  weight_q[14:10]} = {weight_q[19:15],  weight_q[14:10]};
        {out_char_q[11:8], out_char_q[15:12]} = {out_char_q[11:8], out_char_q[15:12]};
	end
	if(weight_q[24:20] > weight_q[29:25]) begin
		{weight_q[24:20],  weight_q[29:25]} = {weight_q[29:25],  weight_q[24:20]};
        {out_char_q[19:16], out_char_q[23:20]} = {out_char_q[23:20], out_char_q[19:16]};
	end
	else begin
		{weight_q[24:20],  weight_q[29:25]} = {weight_q[24:20],  weight_q[29:25]};
        {out_char_q[19:16], out_char_q[23:20]} = {out_char_q[19:16], out_char_q[23:20]};
	end
	if(weight_q[34:30] > weight_q[39:35]) begin
		{weight_q[34:30],  weight_q[39:35]} = {weight_q[39:35],  weight_q[34:30]};
        {out_char_q[27:24], out_char_q[31:28]} = {out_char_q[31:28], out_char_q[27:24]};
	end
	else begin
		{weight_q[34:30],  weight_q[39:35]} = {weight_q[34:30],  weight_q[39:35]};
        {out_char_q[27:24], out_char_q[31:28]} = {out_char_q[27:24], out_char_q[31:28]};
	end
    if(weight_q[9:5] > weight_q[14:10]) begin
		{weight_q[9:5],  weight_q[14:10]} = {weight_q[14:10],  weight_q[9:5]};
        {out_char_q[7:4], out_char_q[11:8]} = {out_char_q[11:8], out_char_q[7:4]};
	end
	else begin
		{weight_q[9:5],  weight_q[14:10]} = {weight_q[9:5],  weight_q[14:10]};
        {out_char_q[7:4], out_char_q[11:8]} = {out_char_q[7:4], out_char_q[11:8]};
	end
	if(weight_q[19:15] > weight_q[24:20]) begin
		{weight_q[19:15],  weight_q[24:20]} = {weight_q[24:20],  weight_q[19:15]};
        {out_char_q[15:12], out_char_q[19:16]} = {out_char_q[19:16], out_char_q[15:12]};
	end
	else begin
		{weight_q[19:15],  weight_q[24:20]} = {weight_q[19:15],  weight_q[24:20]};
        {out_char_q[15:12], out_char_q[19:16]} = {out_char_q[15:12], out_char_q[19:16]};
	end
	if(weight_q[29:25] > weight_q[34:30]) begin
		{weight_q[29:25],  weight_q[34:30]} = {weight_q[34:30],  weight_q[29:25]};
        {out_char_q[23:20], out_char_q[27:24]} = {out_char_q[27:24], out_char_q[23:20]};
	end
	else begin
		{weight_q[29:25],  weight_q[34:30]} = {weight_q[29:25],  weight_q[34:30]};
        {out_char_q[23:20], out_char_q[27:24]} = {out_char_q[23:20], out_char_q[27:24]};
	end
end
endmodule

// module eight_weights_sorting (
//     input wire [3:0] char_in0 , 
//     input wire [3:0] char_in1 , 
//     input wire [3:0] char_in2 , 
//     input wire [3:0] char_in3 , 
//     input wire [3:0] char_in4 , 
//     input wire [3:0] char_in5 , 
//     input wire [3:0] char_in6 , 
//     input wire [3:0] char_in7 , 
//     input wire [4:0] weight0 , 
//     input wire [4:0] weight1 ,
//     input wire [4:0] weight2 ,
//     input wire [4:0] weight3 ,
//     input wire [4:0] weight4 ,
//     input wire [4:0] weight5 ,
//     input wire [4:0] weight6 ,
//     input wire [4:0] weight7 ,
//     output reg [3:0] char0 ,
//     output reg [3:0] char1 ,
//     output reg [3:0] char2 ,
//     output reg [3:0] char3 ,
//     output reg [3:0] char4 ,
//     output reg [3:0] char5 ,
//     output reg [3:0] char6 ,
//     output reg [3:0] char7 
// );

// reg [4:0] weight[0:7] ;
// reg [4:0] temp_weight ;

// reg [3:0] char [0:7] ;
// reg [3:0] temp_char ;

// // test ---------------------
// reg [4:0] weight_init [0:7] ;
// reg [3:0] char_layer0 [0:7] ;
// reg [3:0] char_layer1 [0:7] ;
// reg [3:0] char_layer2 [0:7] ;
// reg [3:0] char_layer3 [0:7] ;
// reg [3:0] char_layer4 [0:7] ;
// reg [3:0] char_layer5 [0:7] ;
// // reg [3:0] char_layer6 [0:7] ;
// // --------------------------

// always @(*) begin
//     // initial 
//     weight[0] = weight0 ;
//     weight[1] = weight1 ;
//     weight[2] = weight2 ;
//     weight[3] = weight3 ;
//     weight[4] = weight4 ;
//     weight[5] = weight5 ;
//     weight[6] = weight6 ;
//     weight[7] = weight7 ;
//     char[0] = char_in0 ;
//     char[1] = char_in1 ;
//     char[2] = char_in2 ;
//     char[3] = char_in3 ;
//     char[4] = char_in4 ;
//     char[5] = char_in5 ;
//     char[6] = char_in6 ;
//     char[7] = char_in7 ;
//     // test --------------------------
//     weight_init[0] = weight[0] ;
//     weight_init[1] = weight[1] ;
//     weight_init[2] = weight[2] ;
//     weight_init[3] = weight[3] ;
//     weight_init[4] = weight[4] ;
//     weight_init[5] = weight[5] ;
//     weight_init[6] = weight[6] ;
//     weight_init[7] = weight[7] ;

//     char_layer0[0] = char[0];
//     char_layer0[1] = char[1];
//     char_layer0[2] = char[2];
//     char_layer0[3] = char[3];
//     char_layer0[4] = char[4];
//     char_layer0[5] = char[5];
//     char_layer0[6] = char[6];
//     char_layer0[7] = char[7];
//     // -------------------------------
//     // layer 1 
//     if (weight[0] < weight[2]) begin
//         temp_weight = weight[0] ;
//         weight[0] = weight[2] ;
//         weight[2] = temp_weight ; 
//         temp_char = char[0] ;
//         char[0] = char[2] ;
//         char[2] = temp_char ;
//     end
//     if (weight[1] < weight[3]) begin
//         temp_weight = weight[1] ;
//         weight[1] = weight[3] ;
//         weight[3] = temp_weight ; 
//         temp_char = char[1] ;
//         char[1] = char[3] ;
//         char[3] = temp_char ;
//     end
//     if (weight[4] < weight[6]) begin
//         temp_weight = weight[4] ;
//         weight[4] = weight[6] ;
//         weight[6] = temp_weight ; 
//         temp_char = char[4] ;
//         char[4] = char[6] ;
//         char[6] = temp_char ;
//     end
//     if (weight[5] < weight[7]) begin
//         temp_weight = weight[5] ;
//         weight[5] = weight[7] ;
//         weight[7] = temp_weight ; 
//         temp_char = char[5] ;
//         char[5] = char[7] ;
//         char[7] = temp_char ;
//     end
//     // test --------------------------
//     char_layer1[0] = char[0];
//     char_layer1[1] = char[1];
//     char_layer1[2] = char[2];
//     char_layer1[3] = char[3];
//     char_layer1[4] = char[4];
//     char_layer1[5] = char[5];
//     char_layer1[6] = char[6];
//     char_layer1[7] = char[7];
//     // -------------------------------

//     // layer 2
//     if (weight[0] < weight[4]) begin
//         temp_weight = weight[0] ;
//         weight[0] = weight[4] ;
//         weight[4] = temp_weight ; 
//         temp_char = char[0] ;
//         char[0] = char[4] ;
//         char[4] = temp_char ;
//     end
//     if (weight[1] < weight[5]) begin
//         temp_weight = weight[1] ;
//         weight[1] = weight[5] ;
//         weight[5] = temp_weight ; 
//         temp_char = char[1] ;
//         char[1] = char[5] ;
//         char[5] = temp_char ;
//     end
//     if (weight[2] < weight[6]) begin
//         temp_weight = weight[2] ;
//         weight[2] = weight[6] ;
//         weight[6] = temp_weight ; 
//         temp_char = char[2] ;
//         char[2] = char[6] ;
//         char[6] = temp_char ;
//     end
//     if (weight[3] < weight[7]) begin
//         temp_weight = weight[3] ;
//         weight[3] = weight[7] ;
//         weight[7] = temp_weight ; 
//         temp_char = char[3] ;
//         char[3] = char[7] ;
//         char[7] = temp_char ;
//     end
//     // test --------------------------
//     char_layer2[0] = char[0];
//     char_layer2[1] = char[1];
//     char_layer2[2] = char[2];
//     char_layer2[3] = char[3];
//     char_layer2[4] = char[4];
//     char_layer2[5] = char[5];
//     char_layer2[6] = char[6];
//     char_layer2[7] = char[7];
//     // -------------------------------

//     // layer 3 
//     if (weight[0] < weight[1]) begin
//         temp_weight = weight[0] ;
//         weight[0] = weight[1] ;
//         weight[1] = temp_weight ; 
//         temp_char = char[0] ;
//         char[0] = char[1] ;
//         char[1] = temp_char ;
//     end
//     if (weight[2] < weight[3]) begin
//         temp_weight = weight[2] ;
//         weight[2] = weight[3] ;
//         weight[3] = temp_weight ; 
//         temp_char = char[2] ;
//         char[2] = char[3] ;
//         char[3] = temp_char ;
//     end
//     if (weight[4] < weight[5]) begin
//         temp_weight = weight[4] ;
//         weight[4] = weight[5] ;
//         weight[5] = temp_weight ; 
//         temp_char = char[4] ;
//         char[4] = char[5] ;
//         char[5] = temp_char ;
//     end
//     if (weight[6] < weight[7]) begin
//         temp_weight = weight[6] ;
//         weight[6] = weight[7] ;
//         weight[7] = temp_weight ; 
//         temp_char = char[6] ;
//         char[6] = char[7] ;
//         char[7] = temp_char ;
//     end
//     // test --------------------------
//     char_layer3[0] = char[0];
//     char_layer3[1] = char[1];
//     char_layer3[2] = char[2];
//     char_layer3[3] = char[3];
//     char_layer3[4] = char[4];
//     char_layer3[5] = char[5];
//     char_layer3[6] = char[6];
//     char_layer3[7] = char[7];
//     // -------------------------------

//     // layer 4
//     if (weight[2] < weight[4]) begin
//         temp_weight = weight[2] ;
//         weight[2] = weight[4] ;
//         weight[4] = temp_weight ; 
//         temp_char = char[2] ;
//         char[2] = char[4] ;
//         char[4] = temp_char ;
//     end
//     if (weight[3] < weight[5]) begin
//         temp_weight = weight[3] ;
//         weight[3] = weight[5] ;
//         weight[5] = temp_weight ; 
//         temp_char = char[3] ;
//         char[3] = char[5] ;
//         char[5] = temp_char ;
//     end
//     // test --------------------------
//     char_layer4[0] = char[0];
//     char_layer4[1] = char[1];
//     char_layer4[2] = char[2];
//     char_layer4[3] = char[3];
//     char_layer4[4] = char[4];
//     char_layer4[5] = char[5];
//     char_layer4[6] = char[6];
//     char_layer4[7] = char[7];
//     // -------------------------------

//     // layer 5 
//     if (weight[1] < weight[4]) begin
//         temp_weight = weight[1] ;
//         weight[1] = weight[4] ;
//         weight[4] = temp_weight ; 
//         temp_char = char[1] ;
//         char[1] = char[4] ;
//         char[4] = temp_char ;
//     end
//     if (weight[3] < weight[6]) begin
//         temp_weight = weight[3] ;
//         weight[3] = weight[6] ;
//         weight[6] = temp_weight ; 
//         temp_char = char[3] ;
//         char[3] = char[6] ;
//         char[6] = temp_char ;
//     end
//     // test --------------------------
//     char_layer5[0] = char[0];
//     char_layer5[1] = char[1];
//     char_layer5[2] = char[2];
//     char_layer5[3] = char[3];
//     char_layer5[4] = char[4];
//     char_layer5[5] = char[5];
//     char_layer5[6] = char[6];
//     char_layer5[7] = char[7];
//     // -------------------------------

//     // layer 6
//     if (weight[1] < weight[2]) begin
//         temp_weight = weight[1] ;
//         weight[1] = weight[2] ;
//         weight[2] = temp_weight ; 
//         temp_char = char[1] ;
//         char[1] = char[2] ;
//         char[2] = temp_char ;
//     end
//     if (weight[3] < weight[4]) begin
//         temp_weight = weight[3] ;
//         weight[3] = weight[4] ;
//         weight[4] = temp_weight ;
//         temp_char = char[3] ;
//         char[3] = char[4] ;
//         char[4] = temp_char ; 
//     end
//     if (weight[5] < weight[6]) begin
//         temp_weight = weight[5] ;
//         weight[5] = weight[6] ;
//         weight[6] = temp_weight ; 
//         temp_char = char[5] ;
//         char[5] = char[6] ;
//         char[6] = temp_char ;
//     end
//     // bubble sort 
//     if (weight[0]==weight[1]) begin
//         if (char[0] < char[1]) begin
//             temp_char = char[0] ;
//             char[0] = char[1] ;
//             char[1] = temp_char ;
//         end
//     end
//     if (weight[1]==weight[2]) begin
//         if (char[1] < char[2]) begin
//             temp_char = char[1] ;
//             char[1] = char[2] ;
//             char[2] = temp_char ;
//         end
//     end
//     if (weight[2]==weight[3]) begin
//         if (char[2] < char[3]) begin
//             temp_char = char[2] ;
//             char[2] = char[3] ;
//             char[3] = temp_char ;
//         end
//     end
//     if (weight[3]==weight[4]) begin
//         if (char[3] < char[4]) begin
//             temp_char = char[3] ;
//             char[3] = char[4] ;
//             char[4] = temp_char ;
//         end
//     end
//     if (weight[4]==weight[5]) begin
//         if (char[4] < char[5]) begin
//             temp_char = char[4] ;
//             char[4] = char[5] ;
//             char[5] = temp_char ;
//         end
//     end
//     if (weight[5]==weight[6]) begin
//         if (char[5] < char[6]) begin
//             temp_char = char[5] ;
//             char[5] = char[6] ;
//             char[6] = temp_char ;
//         end
//     end
//     if (weight[6]==weight[7]) begin
//         if (char[6] < char[7]) begin
//             temp_char = char[6] ;
//             char[6] = char[7] ;
//             char[7] = temp_char ;
//         end
//     end

//     // output
//     char0 = char[0] ;
//     char1 = char[1] ;
//     char2 = char[2] ;
//     char3 = char[3] ;
//     char4 = char[4] ;
//     char5 = char[5] ;
//     char6 = char[6] ;
//     char7 = char[7] ;
// end
    
// endmodule

// module CMP2to1 (
//     input wire [3:0] char_in0 , 
//     input wire [3:0] char_in1 , 
//     input wire [4:0] cmp2to1_a , 
//     input wire [4:0] cmp2to1_b ,
//     // output wire b_large_than_a ,
//     output reg [3:0] char0 ,
//     output reg [3:0] char1
// );
// wire b_large_than_a ;
// assign b_large_than_a = (cmp2to1_b > cmp2to1_a) ;
// always @(*) begin
//     if (b_large_than_a) begin
//         char0 = char_in0 ;
//         char1 = char_in1 ;
//     end else begin
//         char0 = char_in1 ;
//         char1 = char_in0 ;
//     end
// end
// endmodule