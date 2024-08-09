module PREFIX (
    // input port
    clk,
    rst_n,
    in_valid,
    opt,
    in_data,
    // output port
    out_valid,
    out
);

input clk;
input rst_n;
input in_valid;
input opt;
input [4:0] in_data;
output reg out_valid;
output reg signed [94:0] out;

// --------------------------------
// REG / WIRE
// opt == 0 
reg signed [5:0] data_bay [0:18] ;
reg [1:0] opt0_state_cnt ;
reg opt_q ;
reg in_valid_q ;
reg [5:0] input_save_cnt_19 ;
reg [5:0] round_cnt_9 ;
reg input_done_flag ;
reg signed [40:0] output_step [0:8] ;
integer i;
// reg [2:0] operator ;
reg [4:0] operator_idx_q , operator_idx_d ;
reg [4:0] operand_idx_q [0:1] ;
reg [4:0] operand_idx_d [0:1] ;
reg [4:0] idx_temp_0 , idx_temp_1 ;
reg signed [36:0] operand [0:1] ;
reg opt0_is_done ;


// --------------------------------
// opt == 1 
reg pop_flag ;
reg [5:0] scan_cnt_19 ;
reg [4:0] stack [0:18] ;
reg [4:0] RPE [0:18] ;
reg opt1_is_done ;
reg [4:0] RPE_idx ;
reg [4:0] stack_idx ;
reg signed [5:0] inv_data_bay [0:18] ;
// --------------------------------
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        opt0_is_done <= 0 ;
    end else begin
        if (round_cnt_9==8 && opt0_state_cnt==3) begin
            opt0_is_done <= 1 ;
        end else begin
            opt0_is_done <=0;
        end
    end
end
//* input_done_flag
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        input_done_flag <= 0 ;
    end else begin
        if (in_valid==0 && in_valid_q==1) begin
            input_done_flag <=1 ;
        end else if (out_valid) begin
            input_done_flag <= 0 ;
        end
    end
end

reg input_done_flag_delay_1T ;
//* input_done_flag_delay_1T
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        input_done_flag_delay_1T <= 0 ;
    end else begin
        if(out_valid) begin
            input_done_flag_delay_1T <= 0 ;
        end else begin
            input_done_flag_delay_1T <= input_done_flag ;
        end
    end
end



//* in_valid_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        in_valid_q <= 0 ;
    end else begin
        in_valid_q <= in_valid ;
    end
end

//* opt_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        opt_q <= 0 ;
    end else begin
        if (in_valid_q==0 && in_valid) begin
            opt_q <= opt ; 
        end
    end
end

//* input_save_cnt_19
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        input_save_cnt_19 <= 0 ;
    end else begin
        if (in_valid) begin
            if (input_save_cnt_19 == 18) begin
                input_save_cnt_19 <= 0 ;
            end else begin
                input_save_cnt_19 <= input_save_cnt_19 + 1 ; 
            end
        end
    end
end

//* data_bay
always @(posedge clk) begin
    if (in_valid) begin
        data_bay [input_save_cnt_19] <= in_data ;
    end else if (input_done_flag && opt_q==0) begin
        if (opt0_state_cnt==3) begin
            data_bay [operator_idx_q] <= 0 ;
            data_bay [operand_idx_q[0]] <= 0 ;
            data_bay [operand_idx_q[1]] <= {1'b1,round_cnt_9[4:0]} ;
        end
    end
end

// test output
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out <= 0 ;
        out_valid <= 0 ;
    end else if (opt_q == 0) begin
        if (opt0_is_done) begin
            out_valid <= 1 ;
            out <= output_step[8] ;
        end else begin
            out <= 0 ;
            out_valid <= 0 ;
        end
    end else if (opt_q == 1) begin
        if (opt1_is_done) begin
            out_valid <= 1 ;
            case (stack_idx)
                1: out <= {RPE[0], RPE[1], RPE[2], RPE[3], RPE[4], RPE[5], RPE[6], RPE[7], RPE[8], RPE[9], RPE[10], RPE[11], RPE[12], RPE[13], RPE[14], RPE[15], RPE[16], RPE[17], stack[0]} ;
                2: out <= {RPE[0], RPE[1], RPE[2], RPE[3], RPE[4], RPE[5], RPE[6], RPE[7], RPE[8], RPE[9], RPE[10], RPE[11], RPE[12], RPE[13], RPE[14], RPE[15], RPE[16], stack[1], stack[0]} ;
                3: out <= {RPE[0], RPE[1], RPE[2], RPE[3], RPE[4], RPE[5], RPE[6], RPE[7], RPE[8], RPE[9], RPE[10], RPE[11], RPE[12], RPE[13], RPE[14], RPE[15], stack[2], stack[1], stack[0]} ;
                4: out <= {RPE[0], RPE[1], RPE[2], RPE[3], RPE[4], RPE[5], RPE[6], RPE[7], RPE[8], RPE[9], RPE[10], RPE[11], RPE[12], RPE[13], RPE[14], stack[3], stack[2], stack[1], stack[0]} ;
                5: out <= {RPE[0], RPE[1], RPE[2], RPE[3], RPE[4], RPE[5], RPE[6], RPE[7], RPE[8], RPE[9], RPE[10], RPE[11], RPE[12], RPE[13], stack[4], stack[3], stack[2], stack[1], stack[0]} ;
                6: out <= {RPE[0], RPE[1], RPE[2], RPE[3], RPE[4], RPE[5], RPE[6], RPE[7], RPE[8], RPE[9], RPE[10], RPE[11], RPE[12], stack[5], stack[4], stack[3], stack[2], stack[1], stack[0]} ;
                7: out <= {RPE[0], RPE[1], RPE[2], RPE[3], RPE[4], RPE[5], RPE[6], RPE[7], RPE[8], RPE[9], RPE[10], RPE[11], stack[6], stack[5], stack[4], stack[3], stack[2], stack[1], stack[0]} ;
                8: out <= {RPE[0], RPE[1], RPE[2], RPE[3], RPE[4], RPE[5], RPE[6], RPE[7], RPE[8], RPE[9], RPE[10], stack[7], stack[6], stack[5], stack[4], stack[3], stack[2], stack[1], stack[0]} ;
                9: out <= {RPE[0], RPE[1], RPE[2], RPE[3], RPE[4], RPE[5], RPE[6], RPE[7], RPE[8], RPE[9], stack[8], stack[7], stack[6], stack[5], stack[4], stack[3], stack[2], stack[1], stack[0]} ;
                // 10: out <= {RPE[0], RPE[1], RPE[2], RPE[3], RPE[4], RPE[5], RPE[6], RPE[7], RPE[8], stack[9], stack[8], stack[7], stack[6], stack[5], stack[4], stack[3], stack[2], stack[1], stack[0]} ;
                // 11: out <= {RPE[0], RPE[1], RPE[2], RPE[3], RPE[4], RPE[5], RPE[6], RPE[7], stack[10], stack[9], stack[8], stack[7], stack[6], stack[5], stack[4], stack[3], stack[2], stack[1], stack[0]} ;
                // 12: out <= {RPE[0], RPE[1], RPE[2], RPE[3], RPE[4], RPE[5], RPE[6], stack[11], stack[10], stack[9], stack[8], stack[7], stack[6], stack[5], stack[4], stack[3], stack[2], stack[1], stack[0]} ;
                // 13: out <= {RPE[0], RPE[1], RPE[2], RPE[3], RPE[4], RPE[5], stack[12], stack[11], stack[10], stack[9], stack[8], stack[7], stack[6], stack[5], stack[4], stack[3], stack[2], stack[1], stack[0]} ;
                // 14:
                // 15:
                // 16:
                // 17:
                // 18: 
            endcase
        end else begin
            out <= 0 ;
            out_valid <= 0 ;
        end
    end
end

//* opt0_state_cnt
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        opt0_state_cnt <= 0 ;
    end else begin
        if (opt_q==0 && input_done_flag) begin
            opt0_state_cnt <= opt0_state_cnt +1 ;
        end else begin
            opt0_state_cnt <= 0 ;
        end
    end
end

//* round_cnt_9
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        round_cnt_9 <= 0 ;
    end else begin
        if (input_done_flag) begin
            if (round_cnt_9 == 8 && opt0_state_cnt==3) begin
                round_cnt_9 <= 0 ;
            end else if (opt0_state_cnt==3) begin
                round_cnt_9 <= round_cnt_9 +1 ;
            end
        end else begin
            round_cnt_9 <= 0;
        end
    end
end


// find operator_idx_q
always @(*) begin
    operator_idx_d = 0 ;
    if (opt_q==0 && input_done_flag==1 && opt0_state_cnt==0) begin
        for (i=0 ;i<=18 ;i=i+1 ) begin
            if (data_bay[i][4]==1) begin
                operator_idx_d = i ;
            end
        end
    end else begin
        operator_idx_d = operator_idx_q ;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        operator_idx_q <= 0 ;
    end else begin
        operator_idx_q <= operator_idx_d ;
    end
end

// find operand_idx_d [0]
always @(*) begin
    if (opt_q==0 && input_done_flag==1 && opt0_state_cnt==1) begin
        operand_idx_d[0] = operator_idx_q + 1 ;
        for (i =0 ;i<=15 ;i=i+1 ) begin
            if (data_bay[operand_idx_d[0]]==0) begin
                idx_temp_0 = operand_idx_d[0]+1 ;
                operand_idx_d[0] = idx_temp_0 ;
            end
        end 
    end else begin
        operand_idx_d[0] = operand_idx_q[0] ;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        operand_idx_q[0] <= 0 ;
    end else begin
        operand_idx_q[0] <= operand_idx_d[0] ;
    end
end

// find operand_idx_d [1]
always @(*) begin
    if (opt_q==0 && input_done_flag==1 && opt0_state_cnt==2) begin
        operand_idx_d[1] = operand_idx_q[0] + 1 ;
        for (i =0 ;i<=15 ;i=i+1 ) begin
            if (data_bay[operand_idx_d[1]]==0) begin
                idx_temp_1 = operand_idx_d[1]+1 ;
                operand_idx_d[1] = idx_temp_1 ;
            end
        end 
    end else begin
        operand_idx_d[1] = operand_idx_q[1] ;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        operand_idx_q[1] <= 0 ;
    end else begin
        operand_idx_q[1] <= operand_idx_d[1] ;
    end
end

// Calculate and save output in corresponding step 
//* output_step
wire test_wire ;
wire [40:0] test_data ;
wire [4:0] test_addr ;
assign test_addr = operand_idx_q[0][3:0] ;
assign test_data = output_step[operand_idx_q[0][3:0]];
assign test_wire = data_bay[operand_idx_q[0]][5]==1 ;
always @(*) begin
    if (data_bay[operand_idx_q[0]][5]==1) begin
        operand[0] = output_step[data_bay[operand_idx_q[0]][3:0]];
    end else begin
        operand[0] = data_bay[operand_idx_q[0]] ;
    end
end
always @(*) begin
    if (data_bay[operand_idx_q[1]][5]==1) begin
        operand[1] = output_step[data_bay[operand_idx_q[1]][3:0]];
    end else begin
        operand[1] = data_bay[operand_idx_q[1]] ;
    end
end
always @(posedge clk) begin
    if (input_done_flag && opt0_state_cnt==3) begin 
        case (data_bay[operator_idx_q][1:0])
            0: output_step[round_cnt_9] <= operand[0] + operand[1] ;
            1: output_step[round_cnt_9] <= operand[0] - operand[1] ;
            2: output_step[round_cnt_9] <= operand[0] * operand[1] ;
            3: output_step[round_cnt_9] <= operand[0] / operand[1] ;
        endcase
    end
end

// Update data_bay 

// //* operand , operator , and their idx
// always @(*) begin
//     idx_temp = 0 ;
//     operand = 0 ;
//     operator_idx_q = 0 ;
//     operator[0] = 0 ;
//     operator[1] = 0 ;
//     operand_0_idx = 0 ;
//     operand_1_idx = 0 ;
//     if (input_done_flag && opt_q==0) begin
//         // find operand
//         for (i=0 ;i<=18 ;i=i+1 ) begin
//             if (data_bay[i][4]==1) begin
//                 operand = data_bay[i][3:0] ;
//                 operator_idx_q = i ;
//             end
//         end
//         // find operator 0
//         operand_0_idx = operator_idx_q+1 ;
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         if (data_bay[operand_0_idx]==0) begin
//             idx_temp = operand_0_idx+1 ;
//             operand_0_idx = idx_temp ;
//         end
//         // if (data_bay[operand_0_idx]==0) begin
//         //     idx_temp = operand_0_idx+1 ;
//         //     operand_0_idx = idx_temp ;
//         // end
//         // if (data_bay[operand_0_idx]==0) begin
//         //     idx_temp = operand_0_idx+1 ;
//         //     operand_0_idx = idx_temp ;
//         // end
//         // if (data_bay[operand_0_idx]==0) begin
//         //     idx_temp = operand_0_idx+1 ;
//         //     operand_0_idx = idx_temp ;
//         // end



//         if (data_bay[operand_0_idx][5]) begin
//             operator[0] = output_step[data_bay[operand_0_idx][3:0]] ;
//         end else begin
//             operator[0] = data_bay[operand_0_idx][3:0] ;
//         end
//         // find operator 1
//         operand_1_idx = operand_0_idx+1 ;
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         if (data_bay[operand_1_idx]==0) begin
//             idx_temp = operand_1_idx+1 ;
//             operand_1_idx = idx_temp ;
//         end
//         // if (data_bay[operand_1_idx]==0) begin
//         //     idx_temp = operand_1_idx+1 ;
//         //     operand_1_idx = idx_temp ;
//         // end
//         // if (data_bay[operand_1_idx]==0) begin
//         //     idx_temp = operand_1_idx+1 ;
//         //     operand_1_idx = idx_temp ;
//         // end


//         if (data_bay[operand_1_idx][5]) begin
//             operator[1] = output_step[data_bay[operand_1_idx][3:0]] ;
//         end else begin
//             operator[1] = data_bay[operand_1_idx][3:0] ;
//         end
//     end
// end



always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        RPE_idx <= 0 ;
        stack_idx <= 0 ;
        scan_cnt_19 <= 0 ;
        pop_flag <= 0 ;
        opt1_is_done <= 0 ;
        for (i =0 ;i<=18 ;i=i+1 ) begin
            inv_data_bay[i] <= 0 ;
            RPE_idx[i] <= 0 ; 
            stack[i] <= 0 ;
        end
    end else if (input_done_flag==1 && input_done_flag_delay_1T==0 && opt_q==1) begin
        for (i =0 ;i<=18 ;i=i+1 ) begin
            inv_data_bay[i] <= data_bay[18-i] ;
        end
    end else if (input_done_flag_delay_1T&& opt_q==1) begin
        if (scan_cnt_19==18) begin
            opt1_is_done <= 1 ;
        end else begin
            opt1_is_done <= 0 ;
        end
        if (pop_flag) begin
            if(inv_data_bay[scan_cnt_19][1]==0 && stack[stack_idx-1][1]==1) begin // pop 
                RPE[RPE_idx] <= stack[stack_idx-1] ;
                stack_idx <= stack_idx - 1 ;
                RPE_idx <= RPE_idx + 1 ;
                pop_flag <= 1 ;
            end else begin
                scan_cnt_19 <= scan_cnt_19 + 1 ;
                stack[stack_idx] <= inv_data_bay[scan_cnt_19] ;
                stack_idx <= stack_idx + 1 ;
                pop_flag <= 0 ;
            end
        end else begin
            if (inv_data_bay[scan_cnt_19][4]==0) begin // number
                scan_cnt_19 <= scan_cnt_19 + 1 ;
                RPE[RPE_idx] <= inv_data_bay[scan_cnt_19] ;
                RPE_idx <= RPE_idx + 1 ;
            end else begin                              // operator + - * / 
                if (stack_idx==0) begin                 // stack is empty
                    scan_cnt_19 <= scan_cnt_19 + 1 ;            
                    stack[stack_idx] <= inv_data_bay[scan_cnt_19] ;
                    stack_idx <= stack_idx + 1 ;
                end else if (inv_data_bay[scan_cnt_19][1]==0 && stack[stack_idx-1][1]==1) begin // pop 
                    RPE[RPE_idx] <= stack[stack_idx-1] ;
                    stack_idx <= stack_idx - 1 ;
                    RPE_idx <= RPE_idx + 1 ;
                    pop_flag <= 1 ;
                end else begin
                    scan_cnt_19 <= scan_cnt_19 + 1 ;
                    stack[stack_idx] <= inv_data_bay[scan_cnt_19] ;
                    stack_idx <= stack_idx + 1 ;
                    pop_flag <= 0 ;
                end
            end
        end
    end else begin
        scan_cnt_19 <= 0 ;
        opt1_is_done <= 0 ;
        RPE_idx <= 0 ;
        stack_idx <= 0 ;
        pop_flag <= 0 ;
        for (i =0 ;i<=18 ;i=i+1 ) begin
            inv_data_bay[i] <= 0 ;
            RPE_idx[i] <= 0 ; 
            stack[i] <= 0 ;
        end
    end
end




endmodule