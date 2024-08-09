//! wang yu
//! iclab065                 
//! version : v1
//! comments : I'm tired.
//-----------------------------------
// final _ wang yu 


// CAD
// submit
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//                        oo0oo
//                       o8888888o           _   _         ____              
//                       88" . "88          | \ | | ___   | __ ) _   _  __ _ 
//                       (| -_- |)          |  \| |/ _ \  |  _ \| | | |/ _` |
//                       0\  =  /0          | |\  | (_) | | |_) | |_| | (_| |
//                     ___/`---'\___        |_| \_|\___/  |____/ \__,_|\__, |
//                   .' \\|     |// '.                                 |___/ 
//                  / \\|||  :  |||// \
//                 / _||||| -:- |||||- \
//                |   | \\\  - /// |   |
//                | \_|  ''\---/''  |_/ |
//                \  .-\__  '-'  ___/-. /
//              ___'. .'  /--.--\  `. .'___
//           ."" '<  `.___\_<|>_/___.' >' "".
//          | | :  `- \`.;`\ _ /`;.`/ - ` : | |
//          \  \ `_.   \_ __\ /__ _/   .-` /  /
//      =====`-.____`.___ \_____/___.-`___.-'=====
//                        `=---='
// 
//############################################################################
module CAD(
    // input signals
    clk,
    rst_n,
    in_valid, 
    in_valid2,
    mode,
    matrix_size,
    matrix,
    matrix_idx,
    // output signals
    out_valid,
    out_value
    );

input [1:0] matrix_size ; 
input clk ;
input [7:0] matrix ;
input rst_n ;
input [3:0] matrix_idx ;
input in_valid2 ;

input mode ;
input in_valid ;
output reg out_valid ;
output reg out_value ;
//=======================================================
//                   Parameter
//=======================================================
parameter a8x8 = (128-1) ;
parameter a16x16 = (512-1) ;
parameter a32x32 = (2048-1) ;
reg [10:0] img_done_num ;
parameter conv_delay =25 ;
parameter deconv_delay =9 ;

//=======================================================
//                   Reg/Wire
//=======================================================
//* Input reg
reg mode_q ; // 0:conv+maxpool  1:deconv

// reg [1:0] wait_for_next_pattern ;

reg [3:0] kernel_idx , img_idx ;

//* SRAM ports
reg [10:0]  SRAM_A_img1    , SRAM_A_img2    ;
reg [31:0]  SRAM_Din_img1  , SRAM_Din_img2  ;
wire [31:0] SRAM_Dout_img1 , SRAM_Dout_img2 ;
reg         SRAM_WEB_img1  , SRAM_WEB_img2  ;
reg [6:0]   SRAM_A_k                        ; 
reg [39:0]  SRAM_Din_k                      ;
wire [39:0] SRAM_Dout_k                     ;
reg         SRAM_WEB_k                      ;
//* READ : WEB=1  WRITE : WEB=0 ; 

reg [5:0] run_time_cnt ;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        run_time_cnt <= 0 ;
    end else begin
        if (in_valid2) begin
            run_time_cnt <= 0 ; 
        end else begin
            run_time_cnt <= run_time_cnt + 1 ;
        end
    end
end

//* SRAM_reg 
reg [7:0] Img_data_0_q , Img_data_1_q , Img_data_2_q , Img_data_3_q , Img_data_4_q ;
reg [7:0] Kernel_data_0_q , Kernel_data_1_q , Kernel_data_2_q , Kernel_data_3_q , Kernel_data_4_q ; 

//* sram store counter
reg [10:0] sram_idx_cnt ; //! 0 ~ 2048-1
reg [2:0] merge_cnt ; // img : 0~3(7) or kernel : 0~4
reg [31:0] merge_data ;

reg [12:0] deconv_output_num ; // 10100010000
reg [12:0] deconv_output_last_num ; // 10100010000
//* 

//* flag 
reg img_done_flag ;
reg save_matrix_size_flag ;
reg mode_save_flag ;
// reg end_flag ;
// reg deconv_ready_to_output_flag ;
// reg deconv_start_to_output_flag ;
reg output_is_done_flag ;

reg conv_can_output_flag ;
reg deconv_can_output_flag ;

//* conv cnt/num
reg [3:0] next_row_num ; // 1 , 5 , 14
reg [2:0] row_offset ; // 1 , 2 , 4
reg [7:0] still_offset ;// 8 , 32 , 128
reg [7:0] conv_total_output_num ; // 4 , 36 , 196
reg [4:0] cnt20 ; // 0~19
reg [3:0] conv_frame_col ; // 0~13
reg [3:0] conv_frame_row ; // 0~13

reg [7:0] conv_output_numbers ;

// reg [1:0] done_first_round ;
// reg [1:0] done_final_round ;
reg [10:0] max_sram_img_idx ;

reg [2:0] conv_Img_choose ;// 0 ~ 7 
reg [6:0] deconv_Img_choose ;// 0~67
// reg [6:0] deconv_Kernel_choose ;// 0~67
reg deconv_Kernel_choose; // 0 or 1 

//* deconv cnt/num
reg [5:0] deconv_col , deconv_raw ; // 0~ 11 , 19 , 35
reg [5:0] deconv_change_raw_num ; // 11 , 19 , 35
// reg [] deconv_total_num ; // 144 , 400 , 1296

//* matrix_size
reg [1:0] matrix_size_q ;

//* PE 
wire [19:0] PE_out ;

//=======================================================
//                    Data Store
//=======================================================
//* merge_cnt
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        merge_cnt <= 0 ;
    end else begin
        if (in_valid) begin
            if (img_done_flag==0) begin // 0~3 
                if (merge_cnt==7) begin
                    merge_cnt <= 0 ;
                end else begin
                    merge_cnt <= merge_cnt+1 ;
                end
            end else begin // 0~4
                if (merge_cnt==4) begin
                    merge_cnt <= 0 ;
                end else begin
                    merge_cnt <= merge_cnt+1 ;
                end
            end
        end else begin
            merge_cnt <= 0 ;
        end
    end
end

//* merge_data
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        merge_data <= 0 ;
    end else begin
        if (in_valid) begin
            case (merge_cnt) // synopsys full_case
            0,4: merge_data[7:0] <= matrix ;
            1,5: merge_data[15:8] <= matrix ;
            2,6: merge_data[23:16] <= matrix ;
            3: merge_data[31:24] <= matrix ;
        endcase
        end
    end
end

//* img_done_flag
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        img_done_flag <= 0 ;
    end else begin
        if (in_valid) begin
            if (sram_idx_cnt==img_done_num && merge_cnt==7) begin
                img_done_flag <= 1 ;
            end
        end else begin
            img_done_flag <= 0 ;
        end
    end
end

//* sram_idx_cnt
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        sram_idx_cnt <= 0 ;
    end else begin
       if (in_valid) begin
            // if (sram_idx_cnt==img_done_num && merge_cnt==7) begin
            //     sram_idx_cnt <= 0 ;
            // end else
            if (img_done_flag==0) begin // 0~3 
                if (merge_cnt==7) begin
                    if (sram_idx_cnt==max_sram_img_idx) begin
                        sram_idx_cnt <= 0 ;
                    end else begin
                        sram_idx_cnt <= sram_idx_cnt+1 ;
                    end
                end
            end else begin // 0~4
                if (merge_cnt==4) begin
                    sram_idx_cnt <= sram_idx_cnt+1 ;
                end
            end
        end else begin
            sram_idx_cnt <= 0 ;
        end 
    end
end

//* save_matrix_size_flag
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        save_matrix_size_flag <= 0 ; 
    end else begin
        save_matrix_size_flag <= in_valid ;
    end
end

//* img_done_num , next_row_num
always @(posedge clk or negedge rst_n) begin // 03 here if invalid ...
    if (~rst_n) begin
        max_sram_img_idx <= 127 ;
        img_done_num <= a8x8;
        next_row_num <= 1;
        row_offset <= 1 ;
        still_offset <= 8 ;
        conv_total_output_num <= 4-1 ;
        deconv_change_raw_num <= 11 ; // 11 , 19 , 35
        deconv_output_last_num <= 144 ;
    end else if (save_matrix_size_flag==1) begin
        case (matrix_size_q)
            0: begin 
                max_sram_img_idx <= 127 ;
                img_done_num <= a8x8;
                next_row_num <= 1;
                row_offset <= 1 ;
                still_offset <= 8 ;
                conv_total_output_num <= 4-1 ;
                deconv_change_raw_num <= 11 ; // 11 , 19 , 35
                deconv_output_last_num <= 144 ;
            end
            1: begin 
                max_sram_img_idx <= 511;
                img_done_num <= a16x16;   
                next_row_num <= 5;   
                row_offset <= 2 ;     
                still_offset <= 32 ; 
                conv_total_output_num <= 36-1 ;
                deconv_change_raw_num<=19 ; // 11 , 19 , 35
                deconv_output_last_num <= 400 ;
            end
            2: begin 
                max_sram_img_idx <= 2047 ;
                img_done_num <= a32x32;
                next_row_num <= 13;
                row_offset <= 4 ;
                still_offset <= 128 ;
                conv_total_output_num <= 196-1 ;
                deconv_change_raw_num<=35 ; // 11 , 19 , 35
                deconv_output_last_num <= 1296 ;
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        deconv_output_num <= 0 ;
    end else begin
            if (in_valid2) begin
            deconv_output_num <= 0 ;
        end else begin
            if (mode_q==1) begin
                if (cnt20==9) begin
                    if (deconv_output_num== deconv_output_last_num && cnt20==9) begin
                        deconv_output_num <= 0 ;
                    end else begin
                        deconv_output_num <= deconv_output_num + 1 ;
                    end
                end
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        matrix_size_q <= 0 ;
    end else begin
        if (save_matrix_size_flag==0) begin
            if (in_valid) begin
                matrix_size_q <= matrix_size ;
            end
        end
    end
end


wire oddoreven ;
assign oddoreven = conv_frame_col[1];//(conv_frame_col>>1'd1);

// SRAM control
//* SRAM_A_img1
always @(*) begin
    // SRAM_A_img1 = 0 ;
    if (in_valid) begin //-------------------------- Write SRAM
        if (img_done_flag==0) begin // img
            if (merge_cnt==3) begin
                SRAM_A_img1 = sram_idx_cnt ;
            end else begin
                SRAM_A_img1 = 0 ;
            end
        end else begin
            SRAM_A_img1 = 0 ;
        end
    end else begin //------------------------------- Read SRAM
        if (mode_q==0) begin
            case (cnt20)
                0 ,5 : begin
                    SRAM_A_img1 = (conv_frame_col[3:2]) + (oddoreven) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*0);
                end
                1 ,6 : begin
                    SRAM_A_img1 = (conv_frame_col[3:2]) + (oddoreven) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*1);
                end
                10 ,15: begin
                    SRAM_A_img1 = (conv_frame_col[3:2]) + (oddoreven) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*1);
                end

                2 ,7: begin
                    SRAM_A_img1 = (conv_frame_col[3:2]) + (oddoreven) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*2);
                end
                11,16: begin
                    SRAM_A_img1 = (conv_frame_col[3:2]) + (oddoreven) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*2);
                end
                3 ,8: begin
                    SRAM_A_img1 = (conv_frame_col[3:2]) + (oddoreven) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*3);
                end
                12,17: begin
                    SRAM_A_img1 = (conv_frame_col[3:2]) + (oddoreven) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*3);
                end
                4 ,9: begin
                    SRAM_A_img1 = (conv_frame_col[3:2]) + (oddoreven) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*4);
                end
                13,18: begin
                    SRAM_A_img1 = (conv_frame_col[3:2]) + (oddoreven) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*4);
                end
                14,19: begin
                    SRAM_A_img1 = (conv_frame_col[3:2]) + (oddoreven) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*5);
                end
                default : begin
                    SRAM_A_img1 = 0 ;
                end
            endcase
        end else if (mode_q==1) begin // deconv
            case (matrix_size_q)
                0: begin //8x8
                    case (cnt20)
                        0: begin
                            case (deconv_raw)
                                0,1,2,3:begin
                                    SRAM_A_img1 = 0 ; // zero padding
                                end 
                                default : begin
                                    SRAM_A_img1 = (deconv_raw-4)+ (img_idx*still_offset); 
                                end
                            endcase
                        end
                        1:begin
                            case (deconv_raw)
                                0,1,2,11:begin
                                    SRAM_A_img1 = 0 ; // zero padding
                                end 
                                default : begin
                                    SRAM_A_img1 = (deconv_raw-3)+ (img_idx*still_offset); 
                                end
                            endcase
                        end
                        2:begin
                            case (deconv_raw)
                                0,1,11,10:begin
                                    SRAM_A_img1 = 0 ; // zero padding
                                end 
                                default : begin
                                    SRAM_A_img1 = (deconv_raw-2)+ (img_idx*still_offset); 
                                end
                            endcase
                        end
                        3:begin
                            case (deconv_raw)
                                0,11,10,9:begin
                                    SRAM_A_img1 = 0 ; // zero padding
                                end 
                                default : begin
                                    SRAM_A_img1 = (deconv_raw-1)+ (img_idx*still_offset); 
                                end
                            endcase
                        end
                        4: begin
                            case (deconv_raw)
                                11,10,9,8:begin
                                    SRAM_A_img1 = 0 ; // zero padding
                                end 
                                default : begin
                                    SRAM_A_img1 = (deconv_raw-0)+ (img_idx*still_offset); 
                                end
                            endcase
                        end
                        default : begin
                            SRAM_A_img1 = 0 ;
                        end
                    endcase
                end 
                1:begin // 16x16
                    case (deconv_col)
                        0,1,2,3,4,5,6,7: begin // Img1 =0 , Img2 = 0
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 0 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,19:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 0 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,19,18:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 0 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,19,18,17:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 0 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        19,18,17,16:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 0 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin
                                    SRAM_A_img1 = 0 ;
                                end
                            endcase
                        end
                        8,9,10,11:begin // Img1 = 1 , Img2 = 0
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,19:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,19,18:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,19,18,17:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        19,18,17,16:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin
                                    SRAM_A_img1 = 0 ;
                                end
                            endcase
                        end
                        12,13,14,15,16,17,18,19:begin // Img1 = 1 , Img2 = 1
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,19:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,19,18:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,19,18,17:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        19,18,17,16:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin
                                    SRAM_A_img1 = 0 ;
                                end
                            endcase
                        end
                        default : begin 
                            SRAM_A_img1 = 0 ;
                        end
                    endcase
                end
                2:begin // 32x32
                    case (deconv_col)
                        0,1,2,3,4,5,6,7: begin // Img1 =0 , Img2 = 0
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 0 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,35:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 0 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,35,34:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 0 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,35,34,33:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 0 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        35,34,33,32:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 0 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin
                                    SRAM_A_img1 = 0 ;
                                end
                            endcase
                        end
                        8,9,10,11:begin // Img1 = 1 , Img2 = 0
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,35:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,35,34:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,35,34,33:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        35,34,33,32:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin
                                    SRAM_A_img1 = 0 ;
                                end
                            endcase
                        end
                        12,13,14,15:begin // Img1 = 1 , Img2 = 1
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,35:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,35,34:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,35,34,33:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        35,34,33,32:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 1 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin
                                    SRAM_A_img1 = 0 ;
                                end
                            endcase
                        end
                        16,17,18,19:begin // Img1 = 2 , Img2 = 1
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 2 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,35:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 2 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,35,34:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 2 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,35,34,33:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 2 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        35,34,33,32:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 2 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin
                                    SRAM_A_img1 = 0 ;
                                end
                            endcase
                        end
                        20,21,22,23:begin // Img1 = 2 , Img2 = 2
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 2 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,35:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 2 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,35,34:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 2 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,35,34,33:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 2 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        35,34,33,32:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 2 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin
                                    SRAM_A_img1 = 0 ;
                                end
                            endcase
                        end
                        24,25,26,27:begin // Img1 = 3 , Img2 = 2
                             case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 3 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,35:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 3 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,35,34:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 3 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,35,34,33:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 3 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        35,34,33,32:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 3 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin
                                    SRAM_A_img1 = 0 ;
                                end
                            endcase
                        end
                        28,29,30,31,32,33,34,35:begin // Img1 = 3 , Img2 = 3
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 3 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,35:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 3 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,35,34:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 3 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,35,34,33:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 3 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        35,34,33,32:begin // zero padding
                                            SRAM_A_img1 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img1 = 3 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin
                                    SRAM_A_img1 = 0 ;
                                end
                            endcase
                        end
                        default : begin
                            SRAM_A_img1 = 0 ;
                        end
                    endcase
                end
                default : begin
                    SRAM_A_img1 = 0 ;
                end
            endcase
        end else begin
            SRAM_A_img1 = 0 ;
        end
    end
end

//* SRAM_Din_img1
always @(*) begin
    // SRAM_Din_img1 = 0 ;
    if (in_valid) begin //-------------------------- Write SRAM
        if (img_done_flag==0) begin // img
            if (merge_cnt==3) begin
                SRAM_Din_img1 = {matrix,merge_data[23:0]} ;
            end else begin
                SRAM_Din_img1 = 0 ;
            end
        end else begin
            SRAM_Din_img1 = 0 ;
        end
    end else begin
        SRAM_Din_img1 = 0 ;
    end
end

//* SRAM_WEB_img1
always @(*) begin
    // SRAM_WEB_img1 = 1 ;
    if (in_valid) begin //-------------------------- Write SRAM
        if (img_done_flag==0) begin // img
            if (merge_cnt==3) begin
                SRAM_WEB_img1 = 0 ; 
            end else begin
                SRAM_WEB_img1 = 1 ;
            end
        end else begin
            SRAM_WEB_img1 = 1 ;
        end
    end else begin
        SRAM_WEB_img1 = 1 ;
    end
end
    
//* SRAM_A_img2
// SRAM_A_img2 = 0 ;
always @(*) begin
    // SRAM_A_img2 = 0 ;
    if (in_valid) begin //-------------------------- Write SRAM
        if (img_done_flag==0) begin // img
            if (merge_cnt==7) begin
                SRAM_A_img2 = sram_idx_cnt ;
            end else begin
                SRAM_A_img2 = 0 ;
            end
        end else begin
            SRAM_A_img2 = 0 ;
        end
    end else begin //------------------------------- Read SRAM
        if (mode_q==0) begin
            case (cnt20)
                0 ,5 : begin
                    SRAM_A_img2 = (conv_frame_col[3:2]) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*0);
                end
                1 ,6 : begin
                    SRAM_A_img2 = (conv_frame_col[3:2]) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*1);
                end
                10 ,15: begin
                    SRAM_A_img2 = (conv_frame_col[3:2]) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*1);
                end
                2 ,7: begin
                    SRAM_A_img2 = (conv_frame_col[3:2]) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*2);
                end
                11,16: begin
                    SRAM_A_img2 = (conv_frame_col[3:2]) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*2);
                end
                3 ,8: begin
                    SRAM_A_img2 = (conv_frame_col[3:2]) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*3);
                end
                12,17: begin
                    SRAM_A_img2 = (conv_frame_col[3:2]) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*3);
                end
                4 ,9: begin
                    SRAM_A_img2 = (conv_frame_col[3:2]) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*4);
                end
                13,18: begin
                    SRAM_A_img2 = (conv_frame_col[3:2]) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*4);
                end
                14,19: begin
                    SRAM_A_img2 = (conv_frame_col[3:2]) + (conv_frame_row*row_offset*2) + (img_idx*still_offset) + (row_offset*5);
                end
                default : begin 
                    SRAM_A_img2 = 0 ;
                end
            endcase
        end else if (mode_q==1) begin // deconv
            case (matrix_size_q)
                0: begin //8x8
                    case (cnt20)
                        0: begin
                            case (deconv_raw)
                                0,1,2,3:begin
                                    SRAM_A_img2 = 0 ; // zero padding
                                end 
                                default : begin
                                    SRAM_A_img2 = (deconv_raw-4)+ (img_idx*still_offset); 
                                end
                            endcase
                        end
                        1:begin
                            case (deconv_raw)
                                0,1,2,11:begin
                                    SRAM_A_img2 = 0 ; // zero padding
                                end 
                                default : begin
                                    SRAM_A_img2 = (deconv_raw-3)+ (img_idx*still_offset); 
                                end
                            endcase
                        end
                        2:begin
                            case (deconv_raw)
                                0,1,11,10:begin
                                    SRAM_A_img2 = 0 ; // zero padding
                                end 
                                default : begin
                                    SRAM_A_img2 = (deconv_raw-2)+ (img_idx*still_offset); 
                                end
                            endcase
                        end
                        3:begin
                            case (deconv_raw)
                                0,11,10,9:begin
                                    SRAM_A_img2 = 0 ; // zero padding
                                end 
                                default : begin
                                    SRAM_A_img2 = (deconv_raw-1)+ (img_idx*still_offset); 
                                end
                            endcase
                        end
                        4: begin
                            case (deconv_raw)
                                11,10,9,8:begin
                                    SRAM_A_img2 = 0 ; // zero padding
                                end 
                                default : begin
                                    SRAM_A_img2 = (deconv_raw-0)+ (img_idx*still_offset); 
                                end
                            endcase
                        end
                        default : begin 
                            SRAM_A_img2 = 0 ;
                        end
                    endcase
                end 
                1:begin // 16x16
                    case (deconv_col)
                        0,1,2,3,4,5,6,7: begin // Img1 =0 , Img2 = 0
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,19:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,19,18:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,19,18,17:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        19,18,17,16:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin 
                                    SRAM_A_img2 = 0 ;
                                end
                            endcase
                        end
                        8,9,10,11:begin // Img1 = 1 , Img2 = 0
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,19:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,19,18:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,19,18,17:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        19,18,17,16:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin 
                                    SRAM_A_img2 = 0 ;
                                end
                            endcase
                        end
                        12,13,14,15,16,17,18,19:begin // Img1 = 1 , Img2 = 1
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,19:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,19,18:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,19,18,17:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        19,18,17,16:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin 
                                    SRAM_A_img2 = 0 ;
                                end
                            endcase
                        end
                        default : begin 
                                    SRAM_A_img2 = 0 ;
                        end
                    endcase
                end
                2:begin // 32x32
                    case (deconv_col)
                        0,1,2,3,4,5,6,7: begin // Img1 =0 , Img2 = 0
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,35:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,35,34:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,35,34,33:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        35,34,33,32:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin 
                                    SRAM_A_img2 = 0 ;
                                end
                            endcase
                        end
                        8,9,10,11:begin // Img1 = 1 , Img2 = 0
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,35:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,35,34:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,35,34,33:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        35,34,33,32:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 0 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin 
                                    SRAM_A_img2 = 0 ;
                                end
                            endcase
                        end
                        12,13,14,15:begin // Img1 = 1 , Img2 = 1
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,35:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,35,34:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,35,34,33:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        35,34,33,32:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin 
                                    SRAM_A_img2 = 0 ;
                                end
                            endcase
                        end
                        16,17,18,19:begin // Img1 = 2 , Img2 = 1
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,35:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,35,34:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,35,34,33:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        35,34,33,32:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 1 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin 
                                    SRAM_A_img2 = 0 ;
                                end
                            endcase
                        end
                        20,21,22,23:begin // Img1 = 2 , Img2 = 2
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 2 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,35:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 2 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,35,34:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 2 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,35,34,33:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 2 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        35,34,33,32:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 2 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin 
                                    SRAM_A_img2 = 0 ;
                                end
                            endcase
                        end
                        24,25,26,27:begin // Img1 = 3 , Img2 = 2
                             case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 2 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,35:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 2 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,35,34:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 2 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,35,34,33:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 2 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        35,34,33,32:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 2 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin 
                                    SRAM_A_img2 = 0 ;
                                end
                            endcase
                        end
                        28,29,30,31,32,33,34,35:begin // Img1 = 3 , Img2 = 3
                            case (cnt20)
                                0:begin
                                    case (deconv_raw)
                                        0,1,2,3:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 3 + ((deconv_raw-4)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end 
                                1:begin
                                    case (deconv_raw)
                                        0,1,2,35:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 3 + ((deconv_raw-3)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                2:begin
                                    case (deconv_raw)
                                        0,1,35,34:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 3 + ((deconv_raw-2)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                3:begin
                                    case (deconv_raw)
                                        0,35,34,33:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 3 + ((deconv_raw-1)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                4:begin
                                    case (deconv_raw)
                                        35,34,33,32:begin // zero padding
                                            SRAM_A_img2 = 0 ;
                                        end
                                        default : begin
                                            SRAM_A_img2 = 3 + ((deconv_raw-0)*row_offset) + (img_idx*still_offset) ;
                                        end
                                    endcase
                                end
                                default : begin 
                                    SRAM_A_img2 = 0 ;
                                end
                            endcase
                        end
                        default : begin 
                            SRAM_A_img2 = 0 ;
                        end
                    endcase
                end
                default : begin 
                    SRAM_A_img2 = 0 ;
                end
            endcase
        end else begin
            SRAM_A_img2 = 0 ;
        end
    end
end

//* SRAM_Din_img2
always @(*) begin
    // SRAM_Din_img2 = 0 ;
    if (in_valid) begin //-------------------------- Write SRAM
        if (img_done_flag==0) begin // img
            if (merge_cnt==7) begin
                SRAM_Din_img2 = {matrix,merge_data[23:0]} ;
            end else begin
                SRAM_Din_img2 = 0 ;
            end
        end else begin
            SRAM_Din_img2 = 0 ;
        end
    end else begin
        SRAM_Din_img2 = 0 ;
    end
end

//* SRAM_WEB_img2
always @(*) begin
    // SRAM_WEB_img2 = 1 ;
    if (in_valid) begin //-------------------------- Write SRAM
        if (img_done_flag==0) begin // img
            if (merge_cnt==7) begin
                SRAM_WEB_img2 = 0 ; 
            end else begin
                SRAM_WEB_img2 = 1 ;
            end
        end else begin
            SRAM_WEB_img2 = 1 ;
        end
    end else begin
        SRAM_WEB_img2 = 1 ;
    end
end

//* SRAM_A_k
always @(*) begin
    // SRAM_A_k = 0 ;
    if (in_valid) begin //-------------------------- Write SRAM
        if (img_done_flag==1) begin // img
            if (merge_cnt==4) begin
                SRAM_A_k = sram_idx_cnt[6:0] ;
            end else begin
                SRAM_A_k = 0 ;
            end
        end else begin // kernel
            SRAM_A_k = 0 ;
        end
    end else begin //------------------------------- Read SRAM
        if (mode_q==0) begin
            case (cnt20)
                0 ,5 : begin
                    SRAM_A_k =  (5*kernel_idx) +  (1 * 0);
                end
                1 ,6 : begin
                    SRAM_A_k = (5*kernel_idx) +  (1 * 1);
                end
                10 ,15: begin
                    SRAM_A_k =  (5*kernel_idx) +  (1 * 0);
                end
                2 ,7: begin
                    SRAM_A_k =  (5*kernel_idx) +  (1 * 2);
                end
                11,16: begin
                    SRAM_A_k =  (5*kernel_idx) +  (1 * 1);
                end
                3 ,8: begin
                    SRAM_A_k =  (5*kernel_idx) +  (1 * 3);
                end
                12,17: begin
                    SRAM_A_k =  (5*kernel_idx) +  (1 * 2);
                end
                4 ,9: begin
                    SRAM_A_k =  (5*kernel_idx) +  (1 * 4);
                end
                13,18: begin
                    SRAM_A_k =  (5*kernel_idx) +  (1 * 3);
                end
                14,19: begin
                    SRAM_A_k =  (5*kernel_idx) +  (1 * 4);
                end
                default : begin
                    SRAM_A_k = 0 ;
                end
            endcase
        end else if (mode_q==1) begin // deconv
            case (matrix_size_q)
                0: begin //8x8
                    case (cnt20)
                        0: begin
                            SRAM_A_k =  (5*kernel_idx) +  (1 * 4);
                        end
                        1:begin
                            SRAM_A_k =  (5*kernel_idx) +  (1 * 3);
                        end
                        2:begin
                            SRAM_A_k =  (5*kernel_idx) +  (1 * 2);
                        end
                        3:begin
                            SRAM_A_k =  (5*kernel_idx) +  (1 * 1);
                        end
                        4: begin
                            SRAM_A_k =  (5*kernel_idx) +  (1 * 0);
                        end
                        default : begin
                            SRAM_A_k = 0 ;
                        end
                    endcase
                end 
                1:begin // 16x16
                    case (deconv_col)
                        0,1,2,3,4,5,6,7: begin // Img1 =0 , Img2 = 0
                            case (cnt20)
                                0:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 4);
                                end 
                                1:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 3);
                                end
                                2:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 2);
                                end
                                3:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 1);
                                end
                                4:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 0);
                                end
                                default : begin
                                    SRAM_A_k = 0 ;
                                end
                            endcase
                        end
                        8,9,10,11:begin // Img1 = 1 , Img2 = 0
                            case (cnt20)
                                0:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 4);
                                end 
                                1:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 3);
                                end
                                2:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 2);
                                end
                                3:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 1);
                                end
                                4:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 0);
                                end
                                default : begin
                                    SRAM_A_k = 0 ;
                                end
                            endcase
                        end
                        12,13,14,15,16,17,18,19:begin // Img1 = 1 , Img2 = 1
                            case (cnt20)
                                0:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 4);
                                end 
                                1:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 3);
                                end
                                2:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 2);
                                end
                                3:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 1);
                                end
                                4:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 0);
                                end
                                default : begin
                                    SRAM_A_k = 0 ;
                                end
                            endcase
                        end
                        default : begin
                                    SRAM_A_k = 0 ;
                        end
                    endcase
                end
                2:begin // 32x32
                    case (deconv_col)
                        0,1,2,3,4,5,6,7: begin // Img1 =0 , Img2 = 0
                            case (cnt20)
                                0:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 4);
                                end 
                                1:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 3);
                                end
                                2:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 2);
                                end
                                3:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 1);
                                end
                                4:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 0);
                                end
                                default : begin
                                    SRAM_A_k = 0 ;
                                end
                            endcase
                        end
                        8,9,10,11:begin // Img1 = 1 , Img2 = 0
                            case (cnt20)
                                0:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 4);
                                end 
                                1:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 3);
                                end
                                2:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 2);
                                end
                                3:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 1);
                                end
                                4:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 0);
                                end
                                default : begin
                                    SRAM_A_k = 0 ;
                                end
                            endcase
                        end
                        12,13,14,15:begin // Img1 = 1 , Img2 = 1
                            case (cnt20)
                                0:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 4);
                                end 
                                1:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 3);
                                end
                                2:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 2);
                                end
                                3:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 1);
                                end
                                4:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 0);
                                end
                                default : begin
                                    SRAM_A_k = 0 ;
                                end
                            endcase
                        end
                        16,17,18,19:begin // Img1 = 2 , Img2 = 1
                            case (cnt20)
                                0:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 4);
                                end 
                                1:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 3);
                                end
                                2:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 2);
                                end
                                3:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 1);
                                end
                                4:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 0);
                                end
                                default : begin
                                    SRAM_A_k = 0 ;
                                end
                            endcase
                        end
                        20,21,22,23:begin // Img1 = 2 , Img2 = 2
                            case (cnt20)
                                0:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 4);
                                end 
                                1:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 3);
                                end
                                2:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 2);
                                end
                                3:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 1);
                                end
                                4:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 0);
                                end
                                default : begin
                                    SRAM_A_k = 0 ;
                                end
                            endcase
                        end
                        24,25,26,27:begin // Img1 = 3 , Img2 = 2
                             case (cnt20)
                                0:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 4);
                                end 
                                1:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 3);
                                end
                                2:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 2);
                                end
                                3:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 1);
                                end
                                4:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 0);
                                end
                                default : begin
                                    SRAM_A_k = 0 ;
                                end
                            endcase
                        end
                        28,29,30,31,32,33,34,35:begin // Img1 = 3 , Img2 = 3
                            case (cnt20)
                                0:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 4);
                                end 
                                1:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 3);
                                end
                                2:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 2);
                                end
                                3:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 1);
                                end
                                4:begin
                                    SRAM_A_k =  (5*kernel_idx) +  (1 * 0);
                                end
                                default : begin
                                    SRAM_A_k = 0 ;
                                end
                            endcase
                        end
                        default : begin
                            SRAM_A_k = 0 ;
                        end
                    endcase
                end
                default : begin
                    SRAM_A_k = 0 ;
                end
            endcase
        end else begin
            SRAM_A_k = 0 ;
        end
    end
end

//* SRAM_Din_k
always @(*) begin
    // SRAM_Din_k = 0 ;
    if (in_valid) begin //-------------------------- Write SRAM
        if (img_done_flag==1) begin // img
            if (merge_cnt==4) begin
                SRAM_Din_k = {matrix,merge_data[31:0]} ;
            end else begin
                SRAM_Din_k = 0 ;
            end
        end else begin
            SRAM_Din_k = 0 ;
        end
    end else begin
        SRAM_Din_k = 0 ;
    end
end

//* SRAM_WEB_k
always @(*) begin
    // SRAM_WEB_k = 1 ;
    if (in_valid) begin //-------------------------- Write SRAM
        if (img_done_flag==1) begin // img
            if (merge_cnt==4) begin
                SRAM_WEB_k = 0 ;
            end else begin
                SRAM_WEB_k = 1 ;
            end
        end else begin
            SRAM_WEB_k = 1 ;
        end
    end else begin
        SRAM_WEB_k = 1 ;
    end
end 


//* mode_save_flag
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mode_save_flag <= 0 ;
    end else begin
        mode_save_flag <= in_valid2 ;
    end
end

//* mode_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mode_q <= 0 ;
    end else begin
        if (mode_save_flag==0) begin
            if (in_valid2) begin
                mode_q <= mode ;
            end
        end
    end
end

//* img_idx , kernel_idx
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        img_idx <= 0 ;
        kernel_idx <= 0 ;
    end else begin
        if (in_valid2) begin
            if (mode_save_flag==0) begin
                img_idx <= matrix_idx ;
            end else begin
                kernel_idx <= matrix_idx ;
            end
        end
    end
end

//=======================================================
//                    Calculate & output
//=======================================================
//* cnt20
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cnt20 <= 0 ;     
    end else begin
        if (in_valid2 && mode_save_flag) begin
            cnt20 <= 0 ;
        end else begin
            if (cnt20==19) begin
                cnt20 <= 0 ;
            end else begin
                cnt20 <= cnt20+1 ;
            end
        end
    end     
end

//* conv_frame_col
always @(posedge clk or negedge rst_n ) begin
    if (~rst_n) begin
        conv_frame_col <= 4'd0 ;
    end else begin
        if (in_valid2 && mode_save_flag) begin
            conv_frame_col <= 0 ;
        end else begin
            if (cnt20==19) begin
                if (conv_frame_col == next_row_num) begin
                    conv_frame_col <= 0;
                end else begin
                    conv_frame_col <= conv_frame_col +1 ;
                end
            end
        end
    end
end

//* conv_frame_row
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        conv_frame_row <= 0 ;
    end else begin
        if (in_valid2 && mode_save_flag) begin
            conv_frame_row <= 0 ;
        end else begin
            if (cnt20==19) begin
                if (conv_frame_col == next_row_num) begin
                    conv_frame_row <= conv_frame_row + 1 ;
                end
            end
        end
    end
end

//* output_is_done_flag
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        output_is_done_flag <= 1 ;
    end else begin
        if (in_valid2) begin
            output_is_done_flag <= 0 ;
        end else if (conv_output_numbers==(conv_total_output_num) && cnt20==5) begin
            output_is_done_flag <= 1 ;
        end else if (deconv_output_num== deconv_output_last_num && cnt20==9) begin
            output_is_done_flag <= 1 ;
        end
    end
end


//======================
// Output value & valid
//======================
//* conv_can_output_flag , deconv_can_output_flag
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        conv_can_output_flag <= 0 ;
        deconv_can_output_flag <= 0 ;
    end else begin
        if (mode_q==0 && output_is_done_flag==0) begin
            deconv_can_output_flag <= 0 ;
            if (conv_output_numbers==(conv_total_output_num) && cnt20==5) begin
                conv_can_output_flag <= 0;
            end else if (run_time_cnt== conv_delay) begin
                conv_can_output_flag <= 1;
            end 
        end else if (mode_q==1 && output_is_done_flag==0) begin
            conv_can_output_flag <= 0 ;
            if (deconv_output_num== deconv_output_last_num && cnt20==9) begin
                deconv_can_output_flag <= 0;
            end else if (run_time_cnt== deconv_delay) begin
                deconv_can_output_flag <= 1;
            end 
        end else begin
            conv_can_output_flag <= 0 ;
            deconv_can_output_flag <= 0 ;
        end
    end
end

//* out_valid
always @(*) begin
    // out_valid = 0 ;
    if (mode_q==0) begin
        if (conv_can_output_flag) begin
            out_valid = 1 ;
        end else begin
            out_valid = 0 ;
        end
    end else if (mode_q==1) begin
        if (deconv_can_output_flag) begin
            out_valid = 1 ;
        end else begin
            out_valid = 0 ;
        end
    end else begin
        out_valid = 0 ;
    end
end

//* out_value
always @(*) begin
    // out_value = 0 ;
    if (mode_q==0) begin
        if (conv_can_output_flag) begin
            case (cnt20)
                19: out_value = PE_out[13] ;
                0: out_value = PE_out[14] ;
                1: out_value = PE_out[15] ;
                2: out_value = PE_out[16] ;
                3: out_value = PE_out[17] ;
                4: out_value = PE_out[18] ;
                5: out_value = PE_out[19] ;
                6: out_value = PE_out[0] ;
                7: out_value = PE_out[1] ;
                8: out_value = PE_out[2] ;
                9: out_value = PE_out[3] ;
                10: out_value = PE_out[4] ;
                11: out_value = PE_out[5] ;
                12: out_value = PE_out[6] ;
                13: out_value = PE_out[7] ;
                14: out_value = PE_out[8] ;
                15: out_value = PE_out[9] ;
                16: out_value = PE_out[10] ;
                17: out_value = PE_out[11] ;
                18: out_value = PE_out[12] ;
                default: out_value = 0 ;
            endcase
        end else begin
            out_value = 0 ;
        end
    end else if (mode_q==1) begin
        if (deconv_can_output_flag) begin
            case (cnt20)
                19: out_value = PE_out[9] ;
                0: out_value = PE_out[10] ;
                1: out_value = PE_out[11] ;
                2: out_value = PE_out[12] ;
                3: out_value = PE_out[13] ;
                4: out_value = PE_out[14] ;
                5: out_value = PE_out[15] ;
                6: out_value = PE_out[16] ;
                7: out_value = PE_out[17] ;
                8: out_value = PE_out[18] ;
                9: out_value = PE_out[19] ;
                10: out_value = PE_out[0] ;
                11: out_value = PE_out[1] ;
                12: out_value = PE_out[2] ;
                13: out_value = PE_out[3] ;
                14: out_value = PE_out[4] ;
                15: out_value = PE_out[5] ;
                16: out_value = PE_out[6] ;
                17: out_value = PE_out[7] ;
                18: out_value = PE_out[8] ;
                default: out_value = 0 ;
            endcase
        end else begin
            out_value = 0 ;
        end
    end else begin
        out_value = 0 ;
    end
end

//=======================================================
//                    PE
//=======================================================   
wire start ;
assign start = (cnt20==1) ;

PE u_PE (.clk(clk),.start(start),.mode_q(mode_q),.rst_n(rst_n),
            .Img_0(Img_data_0_q), 
            .Img_1(Img_data_1_q), 
            .Img_2(Img_data_2_q), 
            .Img_3(Img_data_3_q), 
            .Img_4(Img_data_4_q), 
            .Kernel_0(Kernel_data_0_q),
            .Kernel_1(Kernel_data_1_q), 
            .Kernel_2(Kernel_data_2_q), 
            .Kernel_3(Kernel_data_3_q), 
            .Kernel_4(Kernel_data_4_q), 
            .PE_out(PE_out) );

//=======================================================
//                    SRAM
//=======================================================   

IMG_memory_wrapper u_SRAM_1 (.A(SRAM_A_img1),
                             .Dout(SRAM_Dout_img1),
                             .Din(SRAM_Din_img1),
                             .clk(clk),
                             .WEB(SRAM_WEB_img1),
                             .OE(1'b1),
                             .CS(1'b1) );

IMG_memory_wrapper u_SRAM_2 (.A(SRAM_A_img2),
                             .Dout(SRAM_Dout_img2),
                             .Din(SRAM_Din_img2),
                             .clk(clk),
                             .WEB(SRAM_WEB_img2),
                             .OE(1'b1),
                             .CS(1'b1) ); 
                              
//* conv_Img_choose , deconv_Img_choose , deconv_Kernel_choose
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        conv_Img_choose <= 0 ;
        deconv_Img_choose <= 0 ;
        deconv_Kernel_choose <= 0 ;
    end else begin
        if (mode_q==0) begin // conv
            case (conv_frame_col[1:0])
                0: begin
                    case (cnt20)
                        0,1,2,3,4,10,11,12,13,14: begin
                            conv_Img_choose <= 0 ;
                        end
                        5,6,7,8,9,15,16,17,18,19:begin
                            conv_Img_choose <= 1 ;
                        end
                    endcase
                end
                1:begin
                    case (cnt20)
                        0,1,2,3,4,10,11,12,13,14: begin
                            conv_Img_choose <= 2 ;
                        end
                        5,6,7,8,9,15,16,17,18,19:begin
                            conv_Img_choose <= 3 ;
                        end
                    endcase
                end
                2:begin
                    case (cnt20)
                        0,1,2,3,4,10,11,12,13,14: begin
                            conv_Img_choose <= 4 ;
                        end
                        5,6,7,8,9,15,16,17,18,19:begin
                            conv_Img_choose <= 5 ;
                        end
                    endcase
                end
                3:begin
                    case (cnt20)
                        0,1,2,3,4,10,11,12,13,14: begin
                            conv_Img_choose <= 6 ;
                        end
                        5,6,7,8,9,15,16,17,18,19:begin
                            conv_Img_choose <= 7 ;
                        end
                    endcase
                end
            endcase
        end else begin // deconv
            case (matrix_size_q)
                0: begin
                    deconv_Img_choose <= deconv_col ;
                end
                1: begin
                    deconv_Img_choose <= deconv_col + 12 ;
                end
                2: begin
                    deconv_Img_choose <= deconv_col + 12 + 20 ;
                end
            endcase
            case (matrix_size_q)
                0: begin //8x8
                    // deconv_Kernel_choose <= deconv_raw ;
                    case (cnt20)
                        0: begin
                            case (deconv_raw)
                                0,1,2,3:  deconv_Kernel_choose <= 0 ; // zero padding
                                default:  deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        1:begin
                            case (deconv_raw)
                                0,1,2,11:   deconv_Kernel_choose <= 0 ; // zero padding
                                default:    deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        2:begin
                            case (deconv_raw)
                                0,1,11,10: deconv_Kernel_choose <= 0 ; // zero padding
                                default:   deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        3:begin
                            case (deconv_raw)
                                0,11,10,9: deconv_Kernel_choose <= 0 ; // zero padding
                                default:   deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        4:begin
                            case (deconv_raw)
                                11,10,9,8:deconv_Kernel_choose <= 0 ; // zero padding
                                default:  deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        default:  deconv_Kernel_choose <= 0 ; // zero padding
                    endcase
                end
                1: begin // 16x16
                    // deconv_Kernel_choose <= deconv_raw + 12 ;
                    case (cnt20)
                        0: begin
                            case (deconv_raw)
                                0,1,2,3:  deconv_Kernel_choose <= 0 ; // zero padding
                                default:  deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        1:begin
                            case (deconv_raw)
                                0,1,2,19:   deconv_Kernel_choose <= 0 ; // zero padding
                                default:    deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        2:begin
                            case (deconv_raw)
                                0,1,19,18: deconv_Kernel_choose <= 0 ; // zero padding
                                default:   deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        3:begin
                            case (deconv_raw)
                                0,19,18,17: deconv_Kernel_choose <= 0 ; // zero padding
                                default:   deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        4:begin
                            case (deconv_raw)
                                19,18,17,16:deconv_Kernel_choose <= 0 ; // zero padding
                                default:  deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        default:  deconv_Kernel_choose <= 0 ; // zero padding
                    endcase
                end
                2: begin // 32x32
                    // deconv_Kernel_choose <= deconv_raw + 12 + 20 ;
                    case (cnt20)
                        0: begin
                            case (deconv_raw)
                                0,1,2,3:  deconv_Kernel_choose <= 0 ; // zero padding
                                default:  deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        1:begin
                            case (deconv_raw)
                                0,1,2,35:   deconv_Kernel_choose <= 0 ; // zero padding
                                default:    deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        2:begin
                            case (deconv_raw)
                                0,1,35,34: deconv_Kernel_choose <= 0 ; // zero padding
                                default:   deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        3:begin
                            case (deconv_raw)
                                0,35,34,33: deconv_Kernel_choose <= 0 ; // zero padding
                                default:   deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        4:begin
                            case (deconv_raw)
                                35,34,33,32:deconv_Kernel_choose <= 0 ; // zero padding
                                default:  deconv_Kernel_choose <= 1 ;
                            endcase
                        end
                        default:  deconv_Kernel_choose <= 0 ; // zero padding
                    endcase
                end 
            endcase
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        {Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= 0 ;
    end else begin
        if (mode_q==0) begin // conv
            case (conv_Img_choose)
                0: {Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[7:0],SRAM_Dout_img1[31:0]};
                1: {Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[15:0],SRAM_Dout_img1[31:8]};
                2: {Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[23:0],SRAM_Dout_img1[31:16]};
                3: {Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[31:0],SRAM_Dout_img1[31:24]};
                4: {Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[7:0] ,SRAM_Dout_img2[31:0]};
                5: {Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[15:0],SRAM_Dout_img2[31:8]};
                6: {Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[23:0],SRAM_Dout_img2[31:16]};
                7: {Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[31:0],SRAM_Dout_img2[31:24]};
            endcase
        end else begin // deconv 
            // 看 raw 給 zero padding
            case (deconv_Img_choose)
                0:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[7:0]  ,{8{1'b0}}              ,{8{1'b0}}              ,{8{1'b0}}             ,{8{1'b0}}};
                1:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]  ,{8{1'b0}}              ,{8{1'b0}}             ,{8{1'b0}}};
                2:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]  ,{8{1'b0}}             ,{8{1'b0}}};
                3:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0] ,{8{1'b0}}};
                4:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]};
                5:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8]};
                6:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16]};
                7:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24]};
                8:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {{8{1'b0}}  ,SRAM_Dout_img2[31:24] ,SRAM_Dout_img2[23:16] ,SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0] };
                9:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {{8{1'b0}}  ,{8{1'b0}}  ,SRAM_Dout_img2[31:24] ,SRAM_Dout_img2[23:16] ,SRAM_Dout_img2[15:8]};
                10:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {{8{1'b0}}  ,{8{1'b0}}  ,{8{1'b0}}  ,SRAM_Dout_img2[31:24] ,SRAM_Dout_img2[23:16]};
                11:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {{8{1'b0}}  ,{8{1'b0}}, {8{1'b0}}, {8{1'b0}},SRAM_Dout_img2[31:24]};
                //---
                12:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[7:0]  ,{8{1'b0}}              ,{8{1'b0}}              ,{8{1'b0}}               ,{8{1'b0}}};
                13:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]  ,{8{1'b0}}              ,{8{1'b0}}               ,{8{1'b0}}};
                14:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]  ,{8{1'b0}}               ,{8{1'b0}}};
                15:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]   ,{8{1'b0}}};
                16:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8]  ,SRAM_Dout_img1[7:0]};
                17:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16] ,SRAM_Dout_img1[15:8]};
                18:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24] ,SRAM_Dout_img1[23:16]};
                19:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]   ,SRAM_Dout_img1[31:24]};
                20:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[7:0]  ,SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8]  ,SRAM_Dout_img2[7:0]};
                21:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]  ,SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16] ,SRAM_Dout_img2[15:8] };
                22:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]  ,SRAM_Dout_img2[31:24] ,SRAM_Dout_img2[23:16]};
                23:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]   ,SRAM_Dout_img2[31:24]};
                24:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8]  ,SRAM_Dout_img1[7:0] };
                25:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16] ,SRAM_Dout_img1[15:8] };
                26:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24] ,SRAM_Dout_img1[23:16]};
                27:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]   ,SRAM_Dout_img1[31:24]};
                28:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {{8{1'b0}}              ,SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8]  ,SRAM_Dout_img2[7:0] };
                29:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {{8{1'b0}}              ,{8{1'b0}}              ,SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16] ,SRAM_Dout_img2[15:8]};
                30:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {{8{1'b0}}              ,{8{1'b0}}              ,{8{1'b0}}              ,SRAM_Dout_img2[31:24] ,SRAM_Dout_img2[23:16]};
                31:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {{8{1'b0}}              ,{8{1'b0}}              ,{8{1'b0}}              ,{8{1'b0}}               ,SRAM_Dout_img2[31:24]};
                //---
                32:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[7:0]  ,{8{1'b0}}              ,{8{1'b0}}              ,{8{1'b0}}               ,{8{1'b0}}};
                33:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]  ,{8{1'b0}}              ,{8{1'b0}}               ,{8{1'b0}}};
                34:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]  ,{8{1'b0}}               ,{8{1'b0}}};
                35:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]   ,{8{1'b0}}};
                36:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8]  ,SRAM_Dout_img1[7:0]};
                37:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16] ,SRAM_Dout_img1[15:8]};
                38:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24] ,SRAM_Dout_img1[23:16]};
                39:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]   ,SRAM_Dout_img1[31:24]};
                40:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[7:0]  ,SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8]  ,SRAM_Dout_img2[7:0]};
                41:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]  ,SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16] ,SRAM_Dout_img2[15:8] };
                42:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]  ,SRAM_Dout_img2[31:24] ,SRAM_Dout_img2[23:16]};
                43:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]   ,SRAM_Dout_img2[31:24]};
                44:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8]  ,SRAM_Dout_img1[7:0] };
                45:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16] ,SRAM_Dout_img1[15:8] };
                46:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24] ,SRAM_Dout_img1[23:16]};
                47:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]   ,SRAM_Dout_img1[31:24]};
                48:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[7:0]  ,SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8]  ,SRAM_Dout_img2[7:0]  };
                49:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]  ,SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16] ,SRAM_Dout_img2[15:8]  };
                50:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]  ,SRAM_Dout_img2[31:24] ,SRAM_Dout_img2[23:16] };
                51:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]   ,SRAM_Dout_img2[31:24] };
                52:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8]  ,SRAM_Dout_img1[7:0]   };
                53:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16] ,SRAM_Dout_img1[15:8]  };
                54:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24] ,SRAM_Dout_img1[23:16] };
                55:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]   ,SRAM_Dout_img1[31:24] };
                56:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[7:0]  ,SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8]  ,SRAM_Dout_img2[7:0]   };
                57:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]  ,SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16] ,SRAM_Dout_img2[15:8]   };
                58:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]  ,SRAM_Dout_img2[31:24] ,SRAM_Dout_img2[23:16]  };
                59:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8] ,SRAM_Dout_img1[7:0]   ,SRAM_Dout_img2[31:24]};
                60:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16],SRAM_Dout_img1[15:8]  ,SRAM_Dout_img1[7:0] };
                61:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24],SRAM_Dout_img1[23:16] ,SRAM_Dout_img1[15:8] };
                62:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]  ,SRAM_Dout_img1[31:24] ,SRAM_Dout_img1[23:16]};
                63:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8] ,SRAM_Dout_img2[7:0]   ,SRAM_Dout_img1[31:24]};
                64:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {{8{1'b0}}              ,SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16],SRAM_Dout_img2[15:8]  ,SRAM_Dout_img2[7:0] };
                65:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {{8{1'b0}}              ,{8{1'b0}}              ,SRAM_Dout_img2[31:24],SRAM_Dout_img2[23:16] ,SRAM_Dout_img2[15:8]};
                66:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {{8{1'b0}}              ,{8{1'b0}}              ,{8{1'b0}}              ,SRAM_Dout_img2[31:24] ,SRAM_Dout_img2[23:16]};
                67:{Img_data_4_q,Img_data_3_q,Img_data_2_q,Img_data_1_q,Img_data_0_q} <= {{8{1'b0}}              ,{8{1'b0}}              ,{8{1'b0}}              ,{8{1'b0}}               ,SRAM_Dout_img2[31:24]};
            endcase
        end
    end
end
                             
Kernel_memory_wrapper u_SRAM_k (.A(SRAM_A_k),
                                .Dout(SRAM_Dout_k),
                                .Din(SRAM_Din_k),
                                .clk(clk),
                                .WEB(SRAM_WEB_k),
                                .OE(1'b1),
                                .CS(1'b1)) ;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        {Kernel_data_4_q,Kernel_data_3_q,Kernel_data_2_q,Kernel_data_1_q,Kernel_data_0_q} <= 40'd0 ;
    end else begin
        if (mode_q==0) begin
            Kernel_data_0_q <= SRAM_Dout_k[7:0] ;
            Kernel_data_1_q <= SRAM_Dout_k[15:8] ;
            Kernel_data_2_q <= SRAM_Dout_k[23:16] ;
            Kernel_data_3_q <= SRAM_Dout_k[31:24] ;
            Kernel_data_4_q <= SRAM_Dout_k[39:32] ;
        end else begin // switch and zero padding
            case (deconv_Kernel_choose)
                0: {Kernel_data_4_q,Kernel_data_3_q,Kernel_data_2_q,Kernel_data_1_q,Kernel_data_0_q} <= 40'd0 ;
                1: {Kernel_data_4_q,Kernel_data_3_q,Kernel_data_2_q,Kernel_data_1_q,Kernel_data_0_q} <= {SRAM_Dout_k[7:0],SRAM_Dout_k[15:8],SRAM_Dout_k[23:16],SRAM_Dout_k[31:24],SRAM_Dout_k[39:32]} ;
            endcase
        end
    end
end

//* conv_output_numbers
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        conv_output_numbers <= 0 ;
    end else begin
        if (mode_q==0) begin
            if (conv_output_numbers==(conv_total_output_num) && cnt20==5) begin
                conv_output_numbers <= 0 ;
            end
            else if (cnt20==5 && out_valid) begin
                conv_output_numbers <= conv_output_numbers + 1 ;
            end
        end else begin
            conv_output_numbers <= 0 ;
        end
    end
end
//==================================
// deconv
//==================================

//* deconv_col
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        deconv_col <= 0 ;
    end else begin
        if (in_valid2 && mode_save_flag) begin
            deconv_col <= 0 ;
        end else begin
            if (cnt20==19) begin
                if (deconv_col == deconv_change_raw_num) begin
                    deconv_col <= 0;
                end else begin
                    deconv_col <= deconv_col +1 ;
                end
            end
        end
    end
end

//* deconv_raw
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        deconv_raw <= 0;
    end else begin
        if (in_valid2 && mode_save_flag) begin
            deconv_raw <= 0 ;
        end else begin
            if (cnt20==19 && deconv_col == deconv_change_raw_num) begin
                if (deconv_col == deconv_change_raw_num) begin
                    deconv_raw <= deconv_raw + 1 ;
                end
            end
        end
    end
end


// Test code 
wire [7:0] IMG_1_data_check [0:3] ;
wire [7:0] IMG_2_data_check [0:3] ;
wire [7:0] Kernel_data_check [0:4] ;
assign IMG_1_data_check[0] = SRAM_Dout_img1[7:0];
assign IMG_1_data_check[1] = SRAM_Dout_img1[15:8];
assign IMG_1_data_check[2] = SRAM_Dout_img1[23:16];
assign IMG_1_data_check[3] = SRAM_Dout_img1[31:24];
assign IMG_2_data_check[0] = SRAM_Dout_img2[7:0];
assign IMG_2_data_check[1] = SRAM_Dout_img2[15:8];
assign IMG_2_data_check[2] = SRAM_Dout_img2[23:16];
assign IMG_2_data_check[3] = SRAM_Dout_img2[31:24];
assign Kernel_data_check[0]= SRAM_Dout_k[7:0];
assign Kernel_data_check[1]= SRAM_Dout_k[15:8];
assign Kernel_data_check[2]= SRAM_Dout_k[23:16];
assign Kernel_data_check[3]= SRAM_Dout_k[31:24];
assign Kernel_data_check[4]= SRAM_Dout_k[39:32];

reg [10:0] SRAM_A_img1_q , SRAM_A_img2_q ;
always @(posedge clk) begin
    SRAM_A_img1_q <= SRAM_A_img1 ;
    SRAM_A_img2_q <= SRAM_A_img2 ;
end

endmodule

module IMG_memory_wrapper (
    input wire [10:0] A ,
    output wire [31:0] Dout ,
    input wire [31:0] Din ,
    input wire clk ,
    input wire WEB ,
    input wire OE ,
    input wire CS 
);
SP_2048W_32B_1M memory (.A0(A[0]),         .A1(A[1]),           .A2(A[2]),           .A3(A[3]),
                        .A4(A[4]),         .A5(A[5]),           .A6(A[6]),           .A7(A[7]),
                        .A8(A[8]),         .A9(A[9]),           .A10(A[10]),
                        .DO0(Dout[0]),     .DO1(Dout[1]),       .DO2(Dout[2]),       .DO3(Dout[3]),
                        .DO4(Dout[4]),     .DO5(Dout[5]),       .DO6(Dout[6]),       .DO7(Dout[7]),
                        .DO8(Dout[8]),     .DO9(Dout[9]),       .DO10(Dout[10]),     .DO11(Dout[11]),
                        .DO12(Dout[12]),   .DO13(Dout[13]),     .DO14(Dout[14]),     .DO15(Dout[15]),
                        .DO16(Dout[16]),   .DO17(Dout[17]),     .DO18(Dout[18]),     .DO19(Dout[19]),
                        .DO20(Dout[20]),   .DO21(Dout[21]),     .DO22(Dout[22]),     .DO23(Dout[23]),
                        .DO24(Dout[24]),   .DO25(Dout[25]),     .DO26(Dout[26]),     .DO27(Dout[27]),
                        .DO28(Dout[28]),   .DO29(Dout[29]),     .DO30(Dout[30]),     .DO31(Dout[31]),
                        .DI0(Din[0]),      .DI1(Din[1]),        .DI2(Din[2]),        .DI3(Din[3]),
                        .DI4(Din[4]),      .DI5(Din[5]),        .DI6(Din[6]),        .DI7(Din[7]),
                        .DI8(Din[8]),      .DI9(Din[9]),        .DI10(Din[10]),      .DI11(Din[11]),
                        .DI12(Din[12]),    .DI13(Din[13]),      .DI14(Din[14]),      .DI15(Din[15]),
                        .DI16(Din[16]),    .DI17(Din[17]),      .DI18(Din[18]),      .DI19(Din[19]),
                        .DI20(Din[20]),    .DI21(Din[21]),      .DI22(Din[22]),      .DI23(Din[23]),
                        .DI24(Din[24]),    .DI25(Din[25]),      .DI26(Din[26]),      .DI27(Din[27]),
                        .DI28(Din[28]),    .DI29(Din[29]),      .DI30(Din[30]),      .DI31(Din[31]),
                        .CK(clk),          .WEB(WEB),           .OE(OE),             .CS(CS)      );
endmodule

module Kernel_memory_wrapper (
    input wire [6:0] A ,
    output wire [39:0] Dout ,//Q
    input wire [39:0] Din ,
    input wire clk ,
    input wire WEB ,
    input wire OE ,
    input wire CS 
);
SP_80W_40B_1M memory (.A0(A[0]),       .A1(A[1]),       .A2(A[2]),       .A3(A[3]),
                        .A4(A[4]),       .A5(A[5]),       .A6(A[6]),
                        .DO0(Dout[0]),   .DO1(Dout[1]),   .DO2(Dout[2]),   .DO3(Dout[3]), 
                        .DO4(Dout[4]),   .DO5(Dout[5]),   .DO6(Dout[6]),   .DO7(Dout[7]), 
                        .DO8(Dout[8]),   .DO9(Dout[9]),   .DO10(Dout[10]), .DO11(Dout[11]), 
                        .DO12(Dout[12]), .DO13(Dout[13]), .DO14(Dout[14]), .DO15(Dout[15]), 
                        .DO16(Dout[16]), .DO17(Dout[17]), .DO18(Dout[18]), .DO19(Dout[19]), 
                        .DO20(Dout[20]), .DO21(Dout[21]), .DO22(Dout[22]), .DO23(Dout[23]), 
                        .DO24(Dout[24]), .DO25(Dout[25]), .DO26(Dout[26]), .DO27(Dout[27]), 
                        .DO28(Dout[28]), .DO29(Dout[29]), .DO30(Dout[30]), .DO31(Dout[31]), 
                        .DO32(Dout[32]), .DO33(Dout[33]), .DO34(Dout[34]), .DO35(Dout[35]), 
                        .DO36(Dout[36]), .DO37(Dout[37]), .DO38(Dout[38]), .DO39(Dout[39]),
                        .DI0(Din[0]),    .DI1(Din[1]),    .DI2(Din[2]),    .DI3(Din[3]), 
                        .DI4(Din[4]),    .DI5(Din[5]),    .DI6(Din[6]),    .DI7(Din[7]), 
                        .DI8(Din[8]),    .DI9(Din[9]),    .DI10(Din[10]),  .DI11(Din[11]), 
                        .DI12(Din[12]),  .DI13(Din[13]),  .DI14(Din[14]),  .DI15(Din[15]), 
                        .DI16(Din[16]),  .DI17(Din[17]),  .DI18(Din[18]),  .DI19(Din[19]), 
                        .DI20(Din[20]),  .DI21(Din[21]),  .DI22(Din[22]),  .DI23(Din[23]), 
                        .DI24(Din[24]),  .DI25(Din[25]),  .DI26(Din[26]),  .DI27(Din[27]), 
                        .DI28(Din[28]),  .DI29(Din[29]),  .DI30(Din[30]),  .DI31(Din[31]), 
                        .DI32(Din[32]),  .DI33(Din[33]),  .DI34(Din[34]),  .DI35(Din[35]), 
                        .DI36(Din[36]),  .DI37(Din[37]),  .DI38(Din[38]),  .DI39(Din[39]),
                        .CK(clk),        .WEB(WEB),       .OE(OE),         .CS(CS)      );
endmodule

module PE (
    input mode_q ,
    input start ,
    input clk ,
    input rst_n ,
    input wire signed [7:0] Img_0 , 
    input wire signed [7:0] Img_1 , 
    input wire signed [7:0] Img_2 , 
    input wire signed [7:0] Img_3 , 
    input wire signed [7:0] Img_4 , 
    input wire signed [7:0] Kernel_0 , 
    input wire signed [7:0] Kernel_1 , 
    input wire signed [7:0] Kernel_2 , 
    input wire signed [7:0] Kernel_3 , 
    input wire signed [7:0] Kernel_4 , 
    output wire signed [19:0] PE_out 
);
reg [2:0] cnt5 ;
reg [1:0] cnt4 ;

reg signed [19:0] PE_out_q  ;
assign PE_out = PE_out_q ;

// 5 multplier
reg signed [19:0] product [0:4] ;
always @(posedge clk or negedge rst_n) begin
if (~rst_n) begin
    product[0] <= 0 ;
    product[1] <= 0 ;
    product[2] <= 0 ;
    product[3] <= 0 ;
    product[4] <= 0 ;
end else begin
    product[0] <= (Img_0) * (Kernel_0) ;
    product[1] <= (Img_1) * (Kernel_1) ;
    product[2] <= (Img_2) * (Kernel_2) ;
    product[3] <= (Img_3) * (Kernel_3) ;
    product[4] <= (Img_4) * (Kernel_4) ;
end
end
// Adder tree
reg signed [18:0] total_sum ;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        total_sum <= 0 ;
    end else begin
        total_sum <= product[0] + product[1] + product[2] + product[3] + product[4] ;
    end
end

reg signed [19:0] accumulator ;
always @(posedge clk or negedge rst_n) begin
 if (~rst_n) begin
    accumulator <= 0 ;
 end else begin
       if (cnt5==2) begin
        accumulator <= total_sum ;
    end else begin
        accumulator <= accumulator + total_sum;
    end
 end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cnt4 <= 0 ;
    end else begin
        if (start) begin
        cnt4 <= 0 ;
    end else if (cnt5==4) begin
        cnt4 <= cnt4 + 1 ;
    end
    end
end

// count 0~4
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cnt5 <= 0 ; 
    end else begin
        if (start) begin
        cnt5 <= 0 ; 
    end else begin
        if (cnt5==4) begin
            cnt5 <= 0 ;
        end else begin
            cnt5 <= cnt5 + 1 ;
        end
    end 
    end
end

reg signed [19:0] comparator ;
wire cmp_result ;
assign cmp_result = (accumulator>=comparator) ;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        comparator <= 0 ;
    end else begin
        if (cnt5==2) begin
        case (cnt4)
            0:comparator <= cmp_result? (accumulator):(comparator);
            1:comparator <= accumulator;
            2:comparator <= cmp_result? (accumulator):(comparator);
            3:comparator <= cmp_result? (accumulator):(comparator);
        endcase
    end
    end
end

//====================
// Only for Testing
reg [19:0] comparator_check_0 ,comparator_check_1 , comparator_check_2 , comparator_check_3;
always @(posedge clk) begin
    if (cnt5==2) begin
        case (cnt4)
            0:comparator_check_0 <= accumulator;
            1:comparator_check_1 <= accumulator;
            2:comparator_check_2 <= accumulator;
            3:comparator_check_3 <= accumulator;
        endcase
    end
end
// reg [7:0] Img_check [0:4];
// reg [7:0] Kernel_check [0:4];
// always @(*) begin
//     Img_check[0]= Img_0 ;
//     Img_check[1]= Img_1 ;
//     Img_check[2]= Img_2 ;
//     Img_check[3]= Img_3 ;
//     Img_check[4]= Img_4 ;
//     Kernel_check[0] = Kernel_0 ;
//     Kernel_check[1] = Kernel_1 ;
//     Kernel_check[2] = Kernel_2 ;
//     Kernel_check[3] = Kernel_3 ;
//     Kernel_check[4] = Kernel_4 ;
// end
//====================

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        PE_out_q <= 0 ;
    end else begin
        if (mode_q==0) begin // conv + maxpool
            if (cnt4==0 && cnt5==3) begin
                PE_out_q <= comparator ;
            end
        end else begin // deconv
            if (cnt4==1 && cnt5==2) begin   // may wrong
                PE_out_q <= accumulator ;
            end
        end
    end
end
    
endmodule