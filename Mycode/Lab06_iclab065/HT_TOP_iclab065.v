//		Date		: 2024/04
//		Version		: v6.0


// TODO:共用比較器
// 把三個相依比較器，變成七個獨立比較器
// 把 always 拆解
// 把 sort 7 搬到前面做
// TODO 改用merge sort 找兩個最小值
// 解 critical path


//synopsys translate_off
`include "SORT_IP.v"
//synopsys translate_on


module HT_TOP #(
parameter A = 0,
parameter B = 1,
parameter C = 2,
parameter E = 3,
parameter I = 4,
parameter L = 5,
parameter O = 6,
parameter V = 7
)
(
// Input signals
input wire clk,
input wire rst_n,
input wire in_valid,
input wire [2:0] in_weight,  // 0 ~ 7
input wire out_mode,
/*
  mode = 0 : ILOVE
  mode = 1 : ICLAB
*/
// Output signals
output reg out_valid,
output reg out_code
);
// ===========================
// reg / wire / parameters
// ===========================
reg out_valid_d ;

integer i ; // for loop parameter
// counter 
reg [3:0] global_cnt ;  // 0 ~ 15 //FF

reg [3:0] node_q[0:7] ;  // sort node 0 ~ node 8
wire [3:0] node_d[0:7] ;

reg [4:0] weight_of_node [0:8] ;  // 9 nodes
reg mode_q; //! to save out_mode
reg [6:0] encode_char[0:7] ; 
reg [2:0] length[0:7] ;
reg [2:0] sub_node_pointer[0:7] ;
  

//* FSM_state 
reg [1:0] FSM_state ; //FF
localparam IDLE = 2'd0, Save_data = 2'd1, Calculate = 2'd2, ready_to_Output = 2'd3 ;
// ==============================================================
// Design
// ==============================================================

//* mode_q
always @(posedge clk) begin
    if (FSM_state == IDLE && in_valid) begin 
        mode_q <= out_mode ;
    end 
end

//* encode_char
always @(posedge clk) begin
    if (FSM_state == IDLE) begin
        encode_char[0] <= 8'b0;
        encode_char[1] <= 8'b0;
        encode_char[2] <= 8'b0;
        encode_char[3] <= 8'b0;
        encode_char[4] <= 8'b0;
        encode_char[5] <= 8'b0;
        encode_char[6] <= 8'b0;
        encode_char[7] <= 8'b0;
    end else if (FSM_state == Calculate) begin

        for (i = 0; i < 8; i = i + 1) begin
            // right 
            if (length[i] == length[node_d[7]]) begin 
                encode_char[i][sub_node_pointer[i]] <= 1'b1;
            end 
            // left
            // else begin 
            //     encode_char[i][sub_node_pointer[i]] <= 1'b0;
            // end
        end
    end 
end

//* weight_of_char
reg [4:0] weight_of_char [0:7] ; 
always @(posedge clk) begin
    if (global_cnt[3] == 0) 
        weight_of_char[global_cnt] <= {2'b0, in_weight} ;
    else begin
        case (global_cnt)
            8, 9, 10, 11, 12, 13: begin
                weight_of_char[node_d[7]] <= weight_of_char[node_d[6]] + weight_of_char[node_d[7]] ;
            end
        endcase
    end
end

//* global_cnt
always @(posedge clk) begin
    if (FSM_state == IDLE && !in_valid) begin
        global_cnt <= 0 ;
    end else begin 
        global_cnt <= global_cnt + 1 ;
    end
end

reg merge_node[0:7];
//* merge_node[0:7]
always @(*) begin
    merge_node[0] = (sub_node_pointer[0] == 0) ;
    merge_node[1] = (sub_node_pointer[1] == 0) ;
    merge_node[2] = (sub_node_pointer[2] == 0) ;
    merge_node[3] = (sub_node_pointer[3] == 0) ;
    merge_node[4] = (sub_node_pointer[4] == 0) ;
    merge_node[5] = (sub_node_pointer[5] == 0) ;
    merge_node[6] = (sub_node_pointer[6] == 0) ;
    merge_node[7] = (sub_node_pointer[7] == 0) ;
end

// node_q[0:7]
always @(posedge clk) begin
    if (FSM_state == IDLE) begin
        node_q[0] <= 0 ; 
        node_q[1] <= 1 ; 
        node_q[2] <= 2 ; 
        node_q[3] <= 3 ; 
        node_q[4] <= 4 ; 
        node_q[5] <= 5 ; 
        node_q[6] <= 6 ; 
        node_q[7] <= 7 ; 
    end
    else if (FSM_state == Calculate) begin 
        {node_q[0], node_q[1], node_q[2], node_q[3], node_q[4], node_q[5], node_q[6], node_q[7]} <= {
        4'd8, 
        node_d[0],node_d[1],node_d[2],node_d[3],node_d[4],node_d[5],node_d[7] 
        };
    end
end

  // weight[0:8]
always @(*) begin
    weight_of_node[0] = weight_of_char[0] ;
    weight_of_node[1] = weight_of_char[1] ;
    weight_of_node[2] = weight_of_char[2] ;
    weight_of_node[3] = weight_of_char[3] ;
    weight_of_node[4] = weight_of_char[4] ;
    weight_of_node[5] = weight_of_char[5] ;
    weight_of_node[6] = weight_of_char[6] ;
    weight_of_node[7] = weight_of_char[7] ;
    weight_of_node[8] = 31 ;
    // set to 31 let it keep rightmost .
end

//*char_quene
reg [2:0] char_quene; 
always @(posedge clk) begin
    if (FSM_state == IDLE) begin 
        char_quene <= I ; 
    end else if (char_quene == E && merge_node[E]) begin
        char_quene <= I ; 
    end else if ( char_quene == B && merge_node[B] ) begin
        char_quene <= I ; 
    end else if (FSM_state == ready_to_Output) begin
        if (char_quene == I &&  merge_node[I]==1) begin
            char_quene <= (~mode_q) ? L : C ;
        end
        if (char_quene == A && merge_node[A]==1) begin
            char_quene <= B ;
        end
        if (char_quene == C && merge_node[C]==1) begin
            char_quene <= L ;
        end
        if (char_quene == L && merge_node[L]==1) begin 
            char_quene <= (~mode_q) ? O : A ;
        end
        if (char_quene == O && merge_node[O]==1) begin
            char_quene <= V ;
        end
        if (char_quene == V && merge_node[V]==1) begin
            char_quene <= E ; 
        end
    end
end

//* [2:0] length [0:7]
always @(posedge clk) begin
    if (FSM_state == IDLE) begin
        length[0] <= 0 ;
        length[1] <= 1 ;
        length[2] <= 2 ;
        length[3] <= 3 ;
        length[4] <= 4 ;
        length[5] <= 5 ;
        length[6] <= 6 ;
        length[7] <= 7 ;
    end else begin
        case (global_cnt)
        8, 9, 10, 11, 12, 13: begin
            if (length[0] == length[node_d[6]]) begin 
                length[0] <= length[node_d[7]] ;  
            end
            if (length[1] == length[node_d[6]]) begin 
                length[1] <= length[node_d[7]] ;  
            end
            if (length[2] == length[node_d[6]]) begin 
                length[2] <= length[node_d[7]] ;  
            end
            if (length[3] == length[node_d[6]]) begin 
                length[3] <= length[node_d[7]] ;  
            end
            if (length[4] == length[node_d[6]]) begin 
                length[4] <= length[node_d[7]] ;  
            end
            if (length[5] == length[node_d[6]]) begin 
                length[5] <= length[node_d[7]] ;  
            end
            if (length[6] == length[node_d[6]]) begin 
                length[6] <= length[node_d[7]] ;  
            end 
            if (length[7] == length[node_d[6]]) begin 
                length[7] <= length[node_d[7]] ;  
            end
        end
        endcase
    end
end

//* FSM_state
always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin 
        FSM_state <= IDLE;
    end else begin
        if (FSM_state == ready_to_Output) begin
            if (char_quene == E && merge_node[E]) begin
                FSM_state <= IDLE ;
            end else if (char_quene == B && merge_node[B]) begin
                FSM_state <= IDLE ;
            end
        end
        else if (FSM_state == Calculate) begin
            if (global_cnt == 14) begin 
                FSM_state <= ready_to_Output;
            end
        end
        else if(FSM_state == Save_data) begin
                if (global_cnt == 7) begin 
                    FSM_state <= Calculate;
                end
        end
        else if (in_valid) begin 
            FSM_state <= Save_data;
        end
    end
end

//* sub_node_pointer[0:7]
always @(posedge clk) begin
    if (FSM_state == IDLE) begin
        sub_node_pointer[0] <= 0 ;
        sub_node_pointer[1] <= 0 ;
        sub_node_pointer[2] <= 0 ;
        sub_node_pointer[3] <= 0 ;
        sub_node_pointer[4] <= 0 ;
        sub_node_pointer[5] <= 0 ;
        sub_node_pointer[6] <= 0 ;
        sub_node_pointer[7] <= 0 ;
    end else if (FSM_state == ready_to_Output) begin
        if (!merge_node[char_quene]) begin 
            sub_node_pointer[char_quene] <= sub_node_pointer[char_quene] - 1;
        end
    end else if (FSM_state == Calculate) begin
        for (i = 0; i < 8; i = i + 1) begin
            if (length[i] == length[node_d[6]]) begin 
                if (global_cnt != 14) begin 
                    sub_node_pointer[i] <= sub_node_pointer[i] + 1;
                end
            end else if (length[i] == length[node_d[7]]) begin
                if (global_cnt != 14) begin 
                    sub_node_pointer[i] <= sub_node_pointer[i] + 1;
                end
            end else begin
                if (global_cnt == 14) begin
                    sub_node_pointer[i] <= sub_node_pointer[i] - 1; 
                end
            end
        end
    end
end


// ===============
// output_control
// ===============
//* out_valid
always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin 
        out_valid <= 0;
    end else begin
        out_valid <= out_valid_d ;
    end
end

//* out_valid_d
always @(*) begin
    out_valid_d = 0 ;
    if (FSM_state == Calculate) begin
        out_valid_d = (global_cnt == 14);
    end else if (char_quene == E && merge_node[E]) begin 
        out_valid_d = 0;
    end else if ( char_quene == B && merge_node[B]) begin
        out_valid_d = 0;
    end else begin
        out_valid_d = out_valid ;
    end
end

//* out_code
always @(*) begin
    if (~out_valid) begin 
        out_code = 0;
    end else begin 
        out_code = encode_char[char_quene][sub_node_pointer[char_quene]];
    end
end

// =========
// IP
// =========

// IPs
SORT_IP_demo #(8) u_8char_sort (
.IN_character({node_q[0],node_q[1],node_q[2],node_q[3],node_q[4],node_q[5],node_q[6],node_q[7]}),
.IN_weight({weight_of_node[node_q[0]],weight_of_node[node_q[1]],weight_of_node[node_q[2]],weight_of_node[node_q[3]],
            weight_of_node[node_q[4]],weight_of_node[node_q[5]],weight_of_node[node_q[6]],weight_of_node[node_q[7]]}),
.OUT_character({node_d[0],node_d[1],node_d[2],node_d[3],node_d[4],node_d[5],node_d[6],node_d[7]})
);

endmodule


module SORT_IP_demo #(parameter IP_WIDTH = 8)(
	//Input signals
	IN_character, IN_weight,
	//Output signals
	OUT_character
);

// ======================================================
// Input & Output Declaration
// ======================================================
input [IP_WIDTH*4-1:0]  IN_character;
input [IP_WIDTH*5-1:0]  IN_weight;

output [IP_WIDTH*4-1:0] OUT_character;

// ======================================================
// Soft IP
// ======================================================
SORT_IP #(.IP_WIDTH(IP_WIDTH)) I_SORT_IP(.IN_character(IN_character), .IN_weight(IN_weight), .OUT_character(OUT_character)); 

endmodule

// //* merge sorting
// module Eight_char_sort #(parameter SIZE=8) (
//     input wire [31:0] IN_character,
//     input wire [39:0] IN_weight,
//     output reg [31:0] OUT_character
// );

//     reg [31:0] character [SIZE-1:0];
//     reg [39:0] weight [SIZE-1:0];
//     integer i;

//     always @* begin
//         for(i=0; i<SIZE; i=i+1) begin
//             character[i] = IN_character[i*4 +: 4];
//             weight[i] = IN_weight[i*5 +: 5];
//         end
//     end

//     always @* begin
//         merge_sort(character, weight, 0, SIZE-1);
//         for(i=0; i<SIZE; i=i+1) begin
//             OUT_character[i*4 +: 4] = character[i];
//         end
//     end

//     task merge_sort;
//         input [31:0] character [];
//         input [39:0] weight [];
//         input integer left, right;
//         integer mid;
//         if (right > left) begin
//             mid = left + (right - left) / 2;
//             merge_sort(character, weight, left, mid);
//             merge_sort(character, weight, mid+1, right);
//             merge(character, weight, left, mid+1, right);
//         end
//     endtask

//     task merge;
//         input [31:0] character [];
//         input [39:0] weight [];
//         input integer left, mid, right;
//         integer i, end_, num, pos;
//         end_ = mid - 1;
//         pos = left;
//         num = right - left + 1;
//         while (left <= end_ && mid <= right) begin
//             if (weight[left] >= weight[mid]) begin
//                 character[pos++] = character[left++];
//             end else begin
//                 character[pos++] = character[mid++];
//             end
//         end
//         while (left <= end_) begin
//             character[pos++] = character[left++];
//         end
//         while (mid <= right) begin
//             character[pos++] = character[mid++];
//         end
//     endtask

// endmodule



// module Eight_char_sort (
//     // Input signals
//     in_char, in_weight,
//     // Output signals
//     out_char
// );

// ===============================================================
// Input & Output
// ===============================================================
// input [31:0]  in_char;
// input [39:0]  in_weight;

// output [31:0] out_char;

// ===============================================================
// Design
// ===============================================================

// reg [31:0]out_char_q;
// wire [31:0]out_char_d;

// reg [39:0]weight_q;
// wire [39:0]weight_d;

// assign out_char_d = in_char ;
// assign weight_d = in_weight ;
// assign out_char = out_char_q;

// ===============
// merge sorting 
// ===============

// stable sorting

// always@(*) begin
//     out_char_q = out_char_d;
//     weight_q = weight_d;
// 	if(weight_q[4:0] > weight_q[9:5]) begin
// 		{weight_q[4:0],  weight_q[9:5]} = {weight_q[9:5],  weight_q[4:0]};
//     {out_char_q[3:0], out_char_q[7:4]} = {out_char_q[7:4], out_char_q[3:0]};
// 	end
// 	else begin
// 		{weight_q[4:0],  weight_q[9:5]} = {weight_q[4:0],  weight_q[9:5]};
//         {out_char_q[7:4], out_char_q[3:0]} = {out_char_q[7:4], out_char_q[3:0]};
// 	end
// 	if(weight_q[14:10] > weight_q[19:15]) begin
// 		{weight_q[14:10],  weight_q[19:15]} = {weight_q[19:15],  weight_q[14:10]};
//         {out_char_q[11:8], out_char_q[15:12]} = {out_char_q[15:12], out_char_q[11:8]};
// 	end
// 	else begin
// 		{weight_q[19:15],  weight_q[14:10]} = {weight_q[19:15],  weight_q[14:10]};
//         {out_char_q[11:8], out_char_q[15:12]} = {out_char_q[11:8], out_char_q[15:12]};
// 	end
// 	if(weight_q[24:20] > weight_q[29:25]) begin
// 		{weight_q[24:20],  weight_q[29:25]} = {weight_q[29:25],  weight_q[24:20]};
//         {out_char_q[19:16], out_char_q[23:20]} = {out_char_q[23:20], out_char_q[19:16]};
// 	end
// 	else begin
// 		{weight_q[24:20],  weight_q[29:25]} = {weight_q[24:20],  weight_q[29:25]};
//         {out_char_q[19:16], out_char_q[23:20]} = {out_char_q[19:16], out_char_q[23:20]};
// 	end
// 	if(weight_q[34:30] > weight_q[39:35]) begin
// 		{weight_q[34:30],  weight_q[39:35]} = {weight_q[39:35],  weight_q[34:30]};
//         {out_char_q[27:24], out_char_q[31:28]} = {out_char_q[31:28], out_char_q[27:24]};
// 	end
// 	else begin
// 		{weight_q[34:30],  weight_q[39:35]} = {weight_q[34:30],  weight_q[39:35]};
//         {out_char_q[27:24], out_char_q[31:28]} = {out_char_q[27:24], out_char_q[31:28]};
// 	end
//     if(weight_q[9:5] > weight_q[14:10]) begin
// 		{weight_q[9:5],  weight_q[14:10]} = {weight_q[14:10],  weight_q[9:5]};
//         {out_char_q[7:4], out_char_q[11:8]} = {out_char_q[11:8], out_char_q[7:4]};
// 	end
// 	else begin
// 		{weight_q[9:5],  weight_q[14:10]} = {weight_q[9:5],  weight_q[14:10]};
//         {out_char_q[7:4], out_char_q[11:8]} = {out_char_q[7:4], out_char_q[11:8]};
// 	end
// 	if(weight_q[19:15] > weight_q[24:20]) begin
// 		{weight_q[19:15],  weight_q[24:20]} = {weight_q[24:20],  weight_q[19:15]};
//         {out_char_q[15:12], out_char_q[19:16]} = {out_char_q[19:16], out_char_q[15:12]};
// 	end
// 	else begin
// 		{weight_q[19:15],  weight_q[24:20]} = {weight_q[19:15],  weight_q[24:20]};
//         {out_char_q[15:12], out_char_q[19:16]} = {out_char_q[15:12], out_char_q[19:16]};
// 	end
// 	if(weight_q[29:25] > weight_q[34:30]) begin
// 		{weight_q[29:25],  weight_q[34:30]} = {weight_q[34:30],  weight_q[29:25]};
//         {out_char_q[23:20], out_char_q[27:24]} = {out_char_q[27:24], out_char_q[23:20]};
// 	end
// 	else begin
// 		{weight_q[29:25],  weight_q[34:30]} = {weight_q[29:25],  weight_q[34:30]};
//         {out_char_q[23:20], out_char_q[27:24]} = {out_char_q[23:20], out_char_q[27:24]};
// 	end

//     if(weight_q[4:0] > weight_q[9:5]) begin
// 		{weight_q[4:0],  weight_q[9:5]} = {weight_q[9:5],  weight_q[4:0]};
//         {out_char_q[3:0], out_char_q[7:4]} = {out_char_q[7:4], out_char_q[3:0]};
// 	end
// 	else begin
// 		{weight_q[4:0],  weight_q[9:5]} = {weight_q[4:0],  weight_q[9:5]};
//         {out_char_q[7:4], out_char_q[3:0]} = {out_char_q[7:4], out_char_q[3:0]};
// 	end
// 	if(weight_q[14:10] > weight_q[19:15]) begin
// 		{weight_q[14:10],  weight_q[19:15]} = {weight_q[19:15],  weight_q[14:10]};
//         {out_char_q[11:8], out_char_q[15:12]} = {out_char_q[15:12], out_char_q[11:8]};
// 	end
// 	else begin
// 		{weight_q[19:15],  weight_q[14:10]} = {weight_q[19:15],  weight_q[14:10]};
//         {out_char_q[11:8], out_char_q[15:12]} = {out_char_q[11:8], out_char_q[15:12]};
// 	end
// 	if(weight_q[24:20] > weight_q[29:25]) begin
// 		{weight_q[24:20],  weight_q[29:25]} = {weight_q[29:25],  weight_q[24:20]};
//         {out_char_q[19:16], out_char_q[23:20]} = {out_char_q[23:20], out_char_q[19:16]};
// 	end
// 	else begin
// 		{weight_q[24:20],  weight_q[29:25]} = {weight_q[24:20],  weight_q[29:25]};
//         {out_char_q[19:16], out_char_q[23:20]} = {out_char_q[19:16], out_char_q[23:20]};
// 	end
// 	if(
// 		{weight_q[19:15],  weight_q[24:20]} = {weight_q[19:15],  weight_q[24:20]};
//         {out_char_q[15:12], out_char_q[19:16]} = {out_char_q[15:12], out_char_q[19:16]};
// 	end
// 	if(weight_q[29:25] > weight_q[34:30]) begin
// 		{weight_q[29:25],  weight_q[34:30]} = {weight_q[34:30],  weight_q[29:25]};
//         {out_char_q[23:20], out_char_q[27:24]} = {out_char_q[27:24], out_char_q[23:20]};
// 	end
// 	else begin
// 		{weight_q[29:25],  weight_q[34:30]} = {weight_q[29:25],  weight_q[34:30]};
//         {out_char_q[23:20], out_char_q[27:24]} = {out_char_q[23:20], out_char_q[27:24]};
// 	end
	
//     if(weight_q[4:0] > weight_q[9:5]) begin
// 		{weight_q[4:0],  weight_q[9:5]} = {weight_q[9:5],  weight_q[4:0]};
//         {out_char_q[3:0], out_char_q[7:4]} = {out_char_q[7:4], out_char_q[3:0]};

//         {out_char_q[27:24], out_char_q[31:28]} = {out_char_q[27:24], out_char_q[31:28]};
// 	end
//     if(weight_q[9:5] > weight_q[14:10]) begin
// 		{weight_q[9:5],  weight_q[14:10]} = {weight_q[14:10],  weight_q[9:5]};
//         {out_char_q[7:4], out_char_q[11:8]} = {out_char_q[11:8], out_char_q[7:4]};
// 	end
// 	else begin
// 		{weight_q[9:5],  weight_q[14:10]} = {weight_q[9:5],  weight_q[14:10]};
//         {out_char_q[7:4], out_char_q[11:8]} = {out_char_q[7:4], out_char_q[11:8]};
// 	end
// 	if(weight_q[19:15] > weight_q[24:20]) begin
// 		{weight_q[19:15],  weight_q[24:20]} = {weight_q[24:20],  weight_q[19:15]};
//         {out_char_q[15:12], out_char_q[19:16]} = {out_char_q[19:16], out_char_q[15:12]};
// 	end
// 	else begin
// 		{weight_q[19:15],  weight_q[24:20]} = {weight_q[19:15],  weight_q[24:20]};
//         {out_char_q[15:12], out_char_q[19:16]} = {out_char_q[15:12], out_char_q[19:16]};
// 	end
// 	if(weight_q[29:25] > weight_q[34:30]) begin
// 		{weight_q[29:25],  weight_q[34:30]} = {weight_q[34:30],  weight_q[29:25]};
//         {out_char_q[23:20], out_char_q[27:24]} = {out_char_q[27:24], out_char_q[23:20]};
// 	end
// 	else begin
// 		{weight_q[29:25],  weight_q[34:30]} = {weight_q[29:25],  weight_q[34:30]};
//         {out_char_q[23:20], out_char_q[27:24]} = {out_char_q[23:20], out_char_q[27:24]};
// 	end
// end
// endmodule