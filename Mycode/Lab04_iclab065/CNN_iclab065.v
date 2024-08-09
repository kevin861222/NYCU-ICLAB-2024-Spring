// Last
// TODO see rnd in DW_fp_mult

// TODO 只算中間兩個 normal 
// TODO DIV pipe 
//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2023 Fall
//   Lab04 Exercise		: Convolution Neural Network 
//   Author     		: Cheng-Te Chang (chengdez.ee12@nycu.edu.tw)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CNN.v
//   Module Name : CNN
//   Release version : V1.0 (Release Date: 2024-02)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
// Wang YU
// pipe line 

module CNN
#(
    // IEEE floating point parameter
    parameter inst_sig_width = 23,
    parameter inst_exp_width = 8,
    parameter inst_ieee_compliance = 0,
    parameter inst_arch_type = 0,
    parameter inst_arch = 0,
    parameter inst_faithful_round = 0 , 
    parameter IEEE_one = 32'h3F800000 ,
    parameter IEEE_zero = 32'h00000000 ,
    parameter TANH_0 = 32'h00000000 ,
    parameter TANH_1 = 32'h3f42f7d6 ,
    parameter SIGM_0 = 32'h3f000000 ,
    parameter SIGM_1 = 32'h3f3b26a8 ,
    parameter SOFT_0 = 32'h3F317218 ,
    parameter SOFT_1 = 32'h3FA818F5 
)
(
    //Input Port
    clk,
    rst_n,
    in_valid,
    Img,
    Kernel,
	Weight,
    Opt,

    //Output Port
    out_valid,
    out
);


//---------------------------------------------------------------------
//   IN / OUT Ports
//---------------------------------------------------------------------
input rst_n, clk, in_valid;
input [inst_sig_width+inst_exp_width:0] Img, Kernel, Weight;
input [1:0] Opt;
// 2’d0 : ReLU & {Zero}
// 2’d1 : tanh & {Zero}
// 2’d2 : sigmoid & {Replication} 
// 2’d3 : softplus & {Replication}

output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//---------------------------------------------------------------------
//   reg / wire / integer / localparam / parameter
//---------------------------------------------------------------------
reg [6:0] conv_cnt ; //! 0 ~ 127
reg [inst_sig_width+inst_exp_width:0] conv_img [0:15] ;
reg [inst_sig_width+inst_exp_width:0] conv_img_padding [0:35] ;
reg [inst_sig_width+inst_exp_width:0] conv_kernel [0:26] ;
reg [inst_sig_width+inst_exp_width:0] fc_weight [0:3] ;
reg [1:0] max_pool_idx [0:3] ;

reg [inst_sig_width+inst_exp_width:0] conv_result [0:15] ;
// * port of multiplier
reg [inst_sig_width+inst_exp_width:0] multiplier_U_1 , multiplier_U_2 , multiplier_U_3 ,
                                      multiplier_M_1 , multiplier_M_2 , multiplier_M_3 ,
                                      multiplier_D_1 , multiplier_D_2 , multiplier_D_3 ;
reg [inst_sig_width+inst_exp_width:0] multiplicand_U_1 , multiplicand_U_2 , multiplicand_U_3 ,
                                      multiplicand_M_1 , multiplicand_M_2 , multiplicand_M_3 ,
                                      multiplicand_D_1 , multiplicand_D_2 , multiplicand_D_3 ;
wire [inst_sig_width+inst_exp_width:0] product_U ,
                                       product_M ,  
                                       product_D ;
wire [inst_sig_width+inst_exp_width:0] PE_result , PE_ADD_result ;
reg [inst_sig_width+inst_exp_width:0] previous_result ;

reg [inst_sig_width+inst_exp_width:0] cmp_mp_1_a , cmp_mp_1_b ;
wire cmp_mp_1_altb ;

reg [inst_sig_width+inst_exp_width:0] FC_multiplier_1 , FC_multiplier_2 , FC_multiplicand_1 , FC_multiplicand_2 ;
reg [inst_sig_width+inst_exp_width:0] FC_add_a , FC_add_b ;
wire [inst_sig_width+inst_exp_width:0] FC_product_1 , FC_product_2 , FC_sum ;

reg [inst_sig_width+inst_exp_width:0] FC_result [0:3] ; //FC_result_0 , FC_result_1 ;

reg [inst_sig_width+inst_exp_width:0] normal_result [0:3] ;


reg [inst_sig_width+inst_exp_width:0] fc_n_sub_min_q , fc_n_sub_min_d , fc_n ;
reg [inst_sig_width+inst_exp_width:0] max_sub_min_q , max_sub_min_d ;
reg [inst_sig_width+inst_exp_width:0] div_a , div_b ;
wire [inst_sig_width+inst_exp_width:0] div_out ; 

reg [inst_sig_width+inst_exp_width:0] exp_result [0:1] ;
reg [inst_sig_width+inst_exp_width:0] output_repo [0:3] ;

reg [inst_sig_width+inst_exp_width:0] exp_in , ln_in;

wire [inst_sig_width+inst_exp_width:0] cmp_n1_max , cmp_n2_max , cmp_n3_max , cmp_n4_min ;
wire [inst_sig_width+inst_exp_width:0] cmp_n3_a , cmp_n3_b , cmp_n4_a , cmp_n4_b ;
wire cmp_n2_altb , cmp_n3_altb , cmp_n4_altb ;
wire cmp_n1_altb ;
reg [inst_sig_width+inst_exp_width:0] act_suber1_a , act_suber1_b ;
wire [inst_sig_width+inst_exp_width:0] act_suber1_z ;

reg [inst_sig_width+inst_exp_width:0] act_adder2_a , act_adder2_b ;
wire [inst_sig_width+inst_exp_width:0] act_adder2_z ;

reg corridor_d ;
reg corridor[3:0] ;

reg [1:0] opt_q ;

// Flags
reg /*img_save_flag ,*/ kernel_save_flag , wieght_save_flag , opt_save_flag ;

//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------

//* out / out_valid
always @(*) begin
    if (~rst_n) begin
        out = 0 ;
        out_valid = 0 ;
    end else begin
        if (opt_q==2'd0) begin //RELU
            case (conv_cnt)
                64 : begin
                    out = normal_result[0] ;
                    out_valid = 1 ;
                end 
                65: begin
                    out = normal_result[1] ;
                    out_valid = 1 ;
                end
                66: begin
                    out = normal_result[2] ;
                    out_valid = 1 ;
                end
                67: begin
                    out = normal_result[3] ;
                    out_valid = 1 ;
                end
                default: begin
                    out = 0 ;
                    out_valid = 0 ;
                end
            endcase
        end else begin // tanh
            case (conv_cnt)
                66: begin
                    out = output_repo [0] ;
                    out_valid = 1 ;
                end 
                67: begin
                    out = output_repo [1] ;
                    out_valid = 1 ;
                end 
                68: begin
                    out = output_repo [2] ;
                    out_valid = 1 ;
                end 
                69: begin
                    out = output_repo [3] ;
                    out_valid = 1 ;
                end 
                default: begin
                    out = 0 ;
                    out_valid = 0 ;
                end
            endcase
        end 
        //  else begin
        //     out = 0 ;
        //     out_valid = 0 ;
        // end
    end
end

reg out_valid_flag ;
//* conv_cnt - 0 ~ 127
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        conv_cnt <= 1'b0 ;
    end else begin
        if (out_valid==0 && out_valid_flag==1) begin
            conv_cnt <= 1'b0 ;
        end else if (conv_cnt>=1) begin
            conv_cnt <= conv_cnt +1 ;
        end else if (in_valid) begin
            conv_cnt <= 1 ;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        out_valid_flag <= 0 ;
    end else begin
        out_valid_flag <= out_valid ;
    end
end

//* kernel_save_flag , wieght_save_flag
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        // img_save_flag    <= 1'b0 ;
        kernel_save_flag <= 1'b0 ;
        wieght_save_flag <= 1'b0 ;
        opt_save_flag <= 0 ;
    end else begin
        if (in_valid==1) begin
            opt_save_flag <= 1 ;
        end
        if (conv_cnt==3) begin
            wieght_save_flag <= 1 ;
        end
        if (conv_cnt==26) begin
            kernel_save_flag <= 1 ;
        end
        if (out_valid==1) begin
            wieght_save_flag <= 0 ;
            kernel_save_flag <= 0 ;
            opt_save_flag <= 0 ;
        end
    end
end

//* Save Img / Kernel / Weight
always @(posedge clk) begin:data_saving
    if (in_valid) begin
        conv_img[conv_cnt[3:0]]    <= Img ;
        if (kernel_save_flag==0) begin
            conv_kernel[conv_cnt] <= Kernel ;
        end
        if (wieght_save_flag==0) begin
            fc_weight[conv_cnt]   <= Weight ; 
        end 
        if (opt_save_flag==0) begin
            opt_q <= Opt ;
        end
    end
end

//* conv_img_padding
always @(*) begin //opt_q[1] == 0 -> zero  ==1 -> Replication
    conv_img_padding[ 0] = (opt_q[1])? (conv_img [ 0]):(0) ;
    conv_img_padding[ 1] = (opt_q[1])? (conv_img [ 0]):(0) ;
    conv_img_padding[ 2] = (opt_q[1])? (conv_img [ 1]):(0) ;
    conv_img_padding[ 3] = (opt_q[1])? (conv_img [ 2]):(0) ;
    conv_img_padding[ 4] = (opt_q[1])? (conv_img [ 3]):(0) ;
    conv_img_padding[ 5] = (opt_q[1])? (conv_img [ 3]):(0) ;
    conv_img_padding[ 6] = (opt_q[1])? (conv_img [ 0]):(0) ;
    conv_img_padding[ 7] = conv_img [ 0] ;
    conv_img_padding[ 8] = conv_img [ 1] ;
    conv_img_padding[ 9] = conv_img [ 2] ;
    conv_img_padding[10] = conv_img [ 3] ;
    conv_img_padding[11] = (opt_q[1])? (conv_img [ 3]):(0) ;
    conv_img_padding[12] = (opt_q[1])? (conv_img [ 4]):(0) ;
    conv_img_padding[13] = conv_img [ 4] ;
    conv_img_padding[14] = conv_img [ 5] ;
    conv_img_padding[15] = conv_img [ 6] ;
    conv_img_padding[16] = conv_img [ 7] ;
    conv_img_padding[17] = (opt_q[1])? (conv_img [ 7]):(0) ;
    conv_img_padding[18] = (opt_q[1])? (conv_img [ 8]):(0) ;
    conv_img_padding[19] = conv_img [ 8] ;
    conv_img_padding[20] = conv_img [ 9] ;
    conv_img_padding[21] = conv_img [10] ;
    conv_img_padding[22] = conv_img [11] ;
    conv_img_padding[23] = (opt_q[1])? (conv_img [11]):(0) ;
    conv_img_padding[24] = (opt_q[1])? (conv_img [12]):(0) ;
    conv_img_padding[25] = conv_img [12] ;
    conv_img_padding[26] = conv_img [13] ;
    conv_img_padding[27] = conv_img [14] ;
    conv_img_padding[28] = conv_img [15] ;
    conv_img_padding[29] = (opt_q[1])? (conv_img [15]):(0) ;
    conv_img_padding[30] = (opt_q[1])? (conv_img [12]):(0) ;
    conv_img_padding[31] = (opt_q[1])? (conv_img [12]):(0) ;
    conv_img_padding[32] = (opt_q[1])? (conv_img [13]):(0) ;
    conv_img_padding[33] = (opt_q[1])? (conv_img [14]):(0) ;
    conv_img_padding[34] = (opt_q[1])? (conv_img [15]):(0) ;
    conv_img_padding[35] = (opt_q[1])? (conv_img [15]):(0) ;
end

//-------------------------------------------
// CONVOLUTION
//-------------------------------------------
always @(*) begin
    case (conv_cnt)
        9, 25, 41 : begin//
                multiplier_U_1 = conv_img_padding[0] ; 
                multiplier_U_2 = conv_img_padding[1] ; 
                multiplier_U_3 = conv_img_padding[2] ; 
                multiplier_M_1 = conv_img_padding[6] ; 
                multiplier_M_2 = conv_img_padding[7] ; 
                multiplier_M_3 = conv_img_padding[8] ; 
                multiplier_D_1 = conv_img_padding[12] ; 
                multiplier_D_2 = conv_img_padding[13] ; 
                multiplier_D_3 = conv_img_padding[14] ; 
            end
            10, 26, 42 : begin
                multiplier_U_1 = conv_img_padding[1] ; 
                multiplier_U_2 = conv_img_padding[2] ; 
                multiplier_U_3 = conv_img_padding[3] ; 
                multiplier_M_1 = conv_img_padding[7] ; 
                multiplier_M_2 = conv_img_padding[8] ; 
                multiplier_M_3 = conv_img_padding[9] ; 
                multiplier_D_1 = conv_img_padding[13] ; 
                multiplier_D_2 = conv_img_padding[14] ; 
                multiplier_D_3 = conv_img_padding[15] ; 
            end
            11, 27, 43 : begin
                multiplier_U_1 = conv_img_padding[2] ; 
                multiplier_U_2 = conv_img_padding[3] ; 
                multiplier_U_3 = conv_img_padding[4] ; 
                multiplier_M_1 = conv_img_padding[8] ; 
                multiplier_M_2 = conv_img_padding[9] ; 
                multiplier_M_3 = conv_img_padding[10] ; 
                multiplier_D_1 = conv_img_padding[14] ; 
                multiplier_D_2 = conv_img_padding[15] ; 
                multiplier_D_3 = conv_img_padding[16] ; 
            end
            12, 28, 44 : begin
                multiplier_U_1 = conv_img_padding[3] ; 
                multiplier_U_2 = conv_img_padding[4] ; 
                multiplier_U_3 = conv_img_padding[5] ; 
                multiplier_M_1 = conv_img_padding[9] ; 
                multiplier_M_2 = conv_img_padding[10] ; 
                multiplier_M_3 = conv_img_padding[11] ; 
                multiplier_D_1 = conv_img_padding[15] ; 
                multiplier_D_2 = conv_img_padding[16] ; 
                multiplier_D_3 = conv_img_padding[17] ; 
            end
            13, 29, 45 : begin
                multiplier_U_1 = conv_img_padding[6] ; 
                multiplier_U_2 = conv_img_padding[7] ; 
                multiplier_U_3 = conv_img_padding[8] ; 
                multiplier_M_1 = conv_img_padding[12] ; 
                multiplier_M_2 = conv_img_padding[13] ; 
                multiplier_M_3 = conv_img_padding[14] ; 
                multiplier_D_1 = conv_img_padding[18] ; 
                multiplier_D_2 = conv_img_padding[19] ; 
                multiplier_D_3 = conv_img_padding[20] ; 
            end
            14, 30, 46 : begin
                multiplier_U_1 = conv_img_padding[7] ; 
                multiplier_U_2 = conv_img_padding[8] ; 
                multiplier_U_3 = conv_img_padding[9] ; 
                multiplier_M_1 = conv_img_padding[13] ; 
                multiplier_M_2 = conv_img_padding[14] ; 
                multiplier_M_3 = conv_img_padding[15] ; 
                multiplier_D_1 = conv_img_padding[19] ; 
                multiplier_D_2 = conv_img_padding[20] ; 
                multiplier_D_3 = conv_img_padding[21] ; 
            end
            15, 31, 47 : begin
                multiplier_U_1 = conv_img_padding[8] ; 
                multiplier_U_2 = conv_img_padding[9] ; 
                multiplier_U_3 = conv_img_padding[10] ; 
                multiplier_M_1 = conv_img_padding[14] ; 
                multiplier_M_2 = conv_img_padding[15] ; 
                multiplier_M_3 = conv_img_padding[16] ; 
                multiplier_D_1 = conv_img_padding[20] ; 
                multiplier_D_2 = conv_img_padding[21] ; 
                multiplier_D_3 = conv_img_padding[22] ; 
            end
            16, 32, 48 : begin
                multiplier_U_1 = conv_img_padding[9] ; 
                multiplier_U_2 = conv_img_padding[10] ; 
                multiplier_U_3 = conv_img_padding[11] ; 
                multiplier_M_1 = conv_img_padding[15] ; 
                multiplier_M_2 = conv_img_padding[16] ; 
                multiplier_M_3 = conv_img_padding[17] ; 
                multiplier_D_1 = conv_img_padding[21] ; 
                multiplier_D_2 = conv_img_padding[22] ; 
                multiplier_D_3 = conv_img_padding[23] ; 
            end
            17, 33, 49 : begin
                multiplier_U_1 = conv_img_padding[12] ; 
                multiplier_U_2 = conv_img_padding[13] ; 
                multiplier_U_3 = conv_img_padding[14] ; 
                multiplier_M_1 = conv_img_padding[18] ; 
                multiplier_M_2 = conv_img_padding[19] ; 
                multiplier_M_3 = conv_img_padding[20] ; 
                multiplier_D_1 = conv_img_padding[24] ; 
                multiplier_D_2 = conv_img_padding[25] ; 
                multiplier_D_3 = conv_img_padding[26] ; 
            end
            18, 34, 50 : begin
                multiplier_U_1 = conv_img_padding[13] ; 
                multiplier_U_2 = conv_img_padding[14] ; 
                multiplier_U_3 = conv_img_padding[15] ; 
                multiplier_M_1 = conv_img_padding[19] ; 
                multiplier_M_2 = conv_img_padding[20] ; 
                multiplier_M_3 = conv_img_padding[21] ; 
                multiplier_D_1 = conv_img_padding[25] ; 
                multiplier_D_2 = conv_img_padding[26] ; 
                multiplier_D_3 = conv_img_padding[27] ; 
            end
            19, 35, 51 : begin
                multiplier_U_1 = conv_img_padding[14] ; 
                multiplier_U_2 = conv_img_padding[15] ; 
                multiplier_U_3 = conv_img_padding[16] ; 
                multiplier_M_1 = conv_img_padding[20] ; 
                multiplier_M_2 = conv_img_padding[21] ; 
                multiplier_M_3 = conv_img_padding[22] ; 
                multiplier_D_1 = conv_img_padding[26] ; 
                multiplier_D_2 = conv_img_padding[27] ; 
                multiplier_D_3 = conv_img_padding[28] ; 
            end
            20, 36, 52 : begin
                multiplier_U_1 = conv_img_padding[15] ; 
                multiplier_U_2 = conv_img_padding[16] ; 
                multiplier_U_3 = conv_img_padding[17] ; 
                multiplier_M_1 = conv_img_padding[21] ; 
                multiplier_M_2 = conv_img_padding[22] ; 
                multiplier_M_3 = conv_img_padding[23] ; 
                multiplier_D_1 = conv_img_padding[27] ; 
                multiplier_D_2 = conv_img_padding[28] ; 
                multiplier_D_3 = conv_img_padding[29] ; 
            end
            21, 37, 53: begin
                multiplier_U_1 = conv_img_padding[18] ; 
                multiplier_U_2 = conv_img_padding[19] ; 
                multiplier_U_3 = conv_img_padding[20] ; 
                multiplier_M_1 = conv_img_padding[24] ; 
                multiplier_M_2 = conv_img_padding[25] ; 
                multiplier_M_3 = conv_img_padding[26] ; 
                multiplier_D_1 = conv_img_padding[30] ; 
                multiplier_D_2 = conv_img_padding[31] ; 
                multiplier_D_3 = conv_img_padding[32] ; 
            end
            22, 38, 54 : begin
                multiplier_U_1 = conv_img_padding[19] ; 
                multiplier_U_2 = conv_img_padding[20] ; 
                multiplier_U_3 = conv_img_padding[21] ; 
                multiplier_M_1 = conv_img_padding[25] ; 
                multiplier_M_2 = conv_img_padding[26] ; 
                multiplier_M_3 = conv_img_padding[27] ; 
                multiplier_D_1 = conv_img_padding[31] ; 
                multiplier_D_2 = conv_img_padding[32] ; 
                multiplier_D_3 = conv_img_padding[33] ; 
            end
            23, 39, 55 : begin
                multiplier_U_1 = conv_img_padding[20] ; 
                multiplier_U_2 = conv_img_padding[21] ; 
                multiplier_U_3 = conv_img_padding[22] ; 
                multiplier_M_1 = conv_img_padding[26] ; 
                multiplier_M_2 = conv_img_padding[27] ; 
                multiplier_M_3 = conv_img_padding[28] ; 
                multiplier_D_1 = conv_img_padding[32] ; 
                multiplier_D_2 = conv_img_padding[33] ; 
                multiplier_D_3 = conv_img_padding[34] ; 
            end
            24, 40, 56 : begin
                multiplier_U_1 = conv_img_padding[21] ; 
                multiplier_U_2 = conv_img_padding[22] ; 
                multiplier_U_3 = conv_img_padding[23] ; 
                multiplier_M_1 = conv_img_padding[27] ; 
                multiplier_M_2 = conv_img_padding[28] ; 
                multiplier_M_3 = conv_img_padding[29] ; 
                multiplier_D_1 = conv_img_padding[33] ; 
                multiplier_D_2 = conv_img_padding[34] ; 
                multiplier_D_3 = conv_img_padding[35] ; 
            end
        default: begin
                multiplier_U_1 = 0 ; 
                multiplier_U_2 = 0 ; 
                multiplier_U_3 = 0 ; 
                multiplier_M_1 = 0 ; 
                multiplier_M_2 = 0 ; 
                multiplier_M_3 = 0 ; 
                multiplier_D_1 = 0 ; 
                multiplier_D_2 = 0 ; 
                multiplier_D_3 = 0 ; 
        end
    endcase
end

always @(*) begin
    if ( conv_cnt >= 41 ) begin
        multiplicand_U_1 = conv_kernel[18];
        multiplicand_U_2 = conv_kernel[19];
        multiplicand_U_3 = conv_kernel[20];
        multiplicand_M_1 = conv_kernel[21];
        multiplicand_M_2 = conv_kernel[22];
        multiplicand_M_3 = conv_kernel[23];
        multiplicand_D_1 = conv_kernel[24];
        multiplicand_D_2 = conv_kernel[25];
        multiplicand_D_3 = conv_kernel[26];
    end else if ( conv_cnt >= 25 ) begin
        multiplicand_U_1 = conv_kernel[9];
        multiplicand_U_2 = conv_kernel[10];
        multiplicand_U_3 = conv_kernel[11];
        multiplicand_M_1 = conv_kernel[12];
        multiplicand_M_2 = conv_kernel[13];
        multiplicand_M_3 = conv_kernel[14];
        multiplicand_D_1 = conv_kernel[15];
        multiplicand_D_2 = conv_kernel[16];
        multiplicand_D_3 = conv_kernel[17];
    end else begin
        multiplicand_U_1 = conv_kernel[0];
        multiplicand_U_2 = conv_kernel[1];
        multiplicand_U_3 = conv_kernel[2];
        multiplicand_M_1 = conv_kernel[3];
        multiplicand_M_2 = conv_kernel[4];
        multiplicand_M_3 = conv_kernel[5];
        multiplicand_D_1 = conv_kernel[6];
        multiplicand_D_2 = conv_kernel[7];
        multiplicand_D_3 = conv_kernel[8];
    end
end


PE PE_U(.multiplier_1(multiplier_U_1),
        .multiplicand_1(multiplicand_U_1),
        .multiplier_2(multiplier_U_2),
        .multiplicand_2(multiplicand_U_2),
        .multiplier_3(multiplier_U_3),
        .multiplicand_3(multiplicand_U_3),
        .clk(clk),
        .product(product_U));

PE PE_M(.multiplier_1(multiplier_M_1),
        .multiplicand_1(multiplicand_M_1),
        .multiplier_2(multiplier_M_2),
        .multiplicand_2(multiplicand_M_2),
        .multiplier_3(multiplier_M_3),
        .multiplicand_3(multiplicand_M_3),
        .clk(clk),
        .product(product_M));

PE PE_D(.multiplier_1(multiplier_D_1),
        .multiplicand_1(multiplicand_D_1),
        .multiplier_2(multiplier_D_2),
        .multiplicand_2(multiplicand_D_2),
        .multiplier_3(multiplier_D_3),
        .multiplicand_3(multiplicand_D_3),
        .clk(clk),
        .product(product_D));

reg [inst_sig_width+inst_exp_width:0] product_U_q , product_M_q , product_D_q ; 
always @(posedge clk) begin
    product_U_q <= product_U ;
    product_M_q <= product_M ;
    product_D_q <= product_D ;
end

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
        U1_sum (.a(product_U_q),.b(product_M_q),.c(product_D_q),.rnd(3'b0),.z(PE_result),.status() );

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
        Uadd1 ( .a(PE_result), .b(previous_result), .rnd(3'b0),/*.op(1'b0),*/ .z(PE_ADD_result), .status() );

//* previous_result
always @(*) begin
    case (conv_cnt)
        27: previous_result = conv_result[0] ;
        28: previous_result = conv_result[1] ;
        29: previous_result = conv_result[2] ;
        30: previous_result = conv_result[3] ;
        31: previous_result = conv_result[4] ;
        32: previous_result = conv_result[5] ;
        33: previous_result = conv_result[6] ;
        34: previous_result = conv_result[7] ;
        35: previous_result = conv_result[8] ;
        36: previous_result = conv_result[9] ;
        37: previous_result = conv_result[10] ;
        38: previous_result = conv_result[11] ;
        39: previous_result = conv_result[12] ;
        40: previous_result = conv_result[13] ;
        41: previous_result = conv_result[14] ;
        42: previous_result = conv_result[15] ;
        43: previous_result = conv_result[0] ;
        44: previous_result = conv_result[1] ;
        45: previous_result = conv_result[2] ;
        46: previous_result = conv_result[3] ;
        47: previous_result = conv_result[4] ;
        48: previous_result = conv_result[5] ;
        49: previous_result = conv_result[6] ;
        50: previous_result = conv_result[7] ;
        51: previous_result = conv_result[8] ;
        52: previous_result = conv_result[9] ;
        53: previous_result = conv_result[10] ;
        54: previous_result = conv_result[11] ;
        55: previous_result = conv_result[12] ;
        56: previous_result = conv_result[13] ;
        57: previous_result = conv_result[14] ;
        58: previous_result = conv_result[15] ;
        default: previous_result = 0 ;
    endcase
end

//* conv_result
wire [6:0] conv_result_idx ;
assign conv_result_idx = conv_cnt - 11 ;
always @(posedge clk) begin
    if (conv_cnt>=11) begin
        if (conv_cnt <= 58) begin
            conv_result[conv_result_idx[3:0]] <= PE_ADD_result ;    
        end
    end 
end

//* maxpool
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
U_maxpool_cmp1 ( .a(cmp_mp_1_a), .b(cmp_mp_1_b), .zctr(1'b0), .aeqb(), .altb(), .agtb(cmp_mp_1_altb), .unordered(), .z0(), .z1(), .status0(), .status1() );

always @(*) begin
    case (conv_cnt)
        47: begin  // 0-0 0-1
            cmp_mp_1_a = conv_result[0] ;
            cmp_mp_1_b = conv_result[1] ;
        end
        48: begin // 1-0 1-1
            cmp_mp_1_a = conv_result[2] ;
            cmp_mp_1_b = conv_result[3] ;
        end
        49:begin // 0-2 0-max
            case (max_pool_idx[0])
                0: cmp_mp_1_a = conv_result[0] ;
                1: cmp_mp_1_a = conv_result[1] ;
                2: cmp_mp_1_a = conv_result[4] ;
                3: cmp_mp_1_a = conv_result[5] ;
                default: cmp_mp_1_a = conv_result[0] ;
            endcase
            cmp_mp_1_b = conv_result[4] ;
        end
        50: begin // 0-3 0-max
            case (max_pool_idx[0])
                0: cmp_mp_1_a = conv_result[0] ;
                1: cmp_mp_1_a = conv_result[1] ;
                2: cmp_mp_1_a = conv_result[4] ;
                3: cmp_mp_1_a = conv_result[5] ;
                default: cmp_mp_1_a = conv_result[0] ;
            endcase
            cmp_mp_1_b = conv_result[5] ;
        end
        51: begin // 1-2 1-max
            case (max_pool_idx[1])
                0: cmp_mp_1_a = conv_result[2] ;
                1: cmp_mp_1_a = conv_result[3] ;
                2: cmp_mp_1_a = conv_result[6] ;
                3: cmp_mp_1_a = conv_result[7] ;
                default: cmp_mp_1_a = conv_result[2] ;
            endcase
            cmp_mp_1_b = conv_result[6] ;
        end
        52: begin // 1-3 1-max
            case (max_pool_idx[1])
                0: cmp_mp_1_a = conv_result[2] ;
                1: cmp_mp_1_a = conv_result[3] ;
                2: cmp_mp_1_a = conv_result[6] ;
                3: cmp_mp_1_a = conv_result[7] ;
                default: cmp_mp_1_a = conv_result[2] ;
            endcase
            cmp_mp_1_b = conv_result[7] ;
        end
        //------------------------------------------
        53:begin // 2-0 2-1
            cmp_mp_1_a = conv_result[8] ;
            cmp_mp_1_b = conv_result[9] ;
        end
        // 54 : IDLE
        55 : begin// 3-0 3-1
            cmp_mp_1_a = conv_result[10] ;
            cmp_mp_1_b = conv_result[11] ;
        end
        56: begin// 2-2 2-max
            case (max_pool_idx[2])
                0: cmp_mp_1_a = conv_result[8] ;
                1: cmp_mp_1_a = conv_result[9] ;
                2: cmp_mp_1_a = conv_result[12] ;
                3: cmp_mp_1_a = conv_result[13] ;
                default: cmp_mp_1_a = conv_result[8] ;
            endcase
            cmp_mp_1_b = conv_result[12] ;
        end
        57: begin// 2-3 2-max
            case (max_pool_idx[2])
                0: cmp_mp_1_a = conv_result[8] ;
                1: cmp_mp_1_a = conv_result[9] ;
                2: cmp_mp_1_a = conv_result[12] ;
                3: cmp_mp_1_a = conv_result[13] ;
                default: cmp_mp_1_a = conv_result[8] ;
            endcase
            cmp_mp_1_b = conv_result[13] ;
        end 
        58:begin // 3-2 3-max
            case (max_pool_idx[3])
                0: cmp_mp_1_a = conv_result[10] ;
                1: cmp_mp_1_a = conv_result[11] ;
                2: cmp_mp_1_a = conv_result[14] ;
                3: cmp_mp_1_a = conv_result[15] ;
                default: cmp_mp_1_a = conv_result[10] ;
            endcase
            cmp_mp_1_b = conv_result[14] ;
        end
        59:begin // 3-3 3-max
            case (max_pool_idx[3])
                0: cmp_mp_1_a = conv_result[10] ;
                1: cmp_mp_1_a = conv_result[11] ;
                2: cmp_mp_1_a = conv_result[14] ;
                3: cmp_mp_1_a = conv_result[15] ;
                default: cmp_mp_1_a = conv_result[10] ;
            endcase
            cmp_mp_1_b = conv_result[15] ;
        end
        default: begin
            cmp_mp_1_a = 0 ;
            cmp_mp_1_b = 0 ;
        end
    endcase
end

//* max_pool_idx
always @(posedge clk) begin
    case (conv_cnt)
        47: max_pool_idx[0] <= (cmp_mp_1_altb)? (2'd0):(2'd1) ;
        48: max_pool_idx[1] <= (cmp_mp_1_altb)? (2'd0):(2'd1) ;
        49: max_pool_idx[0] <= (cmp_mp_1_altb)? (max_pool_idx[0]):(2'd2) ;
        50: max_pool_idx[0] <= (cmp_mp_1_altb)? (max_pool_idx[0]):(2'd3) ;

        51: max_pool_idx[1] <= (cmp_mp_1_altb)? (max_pool_idx[1]):(2'd2) ;
        52: max_pool_idx[1] <= (cmp_mp_1_altb)? (max_pool_idx[1]):(2'd3) ;
        
        53: max_pool_idx[2] <= (cmp_mp_1_altb)? (2'd0):(2'd1) ;
        // 52:IDLE
        55: max_pool_idx[3] <= (cmp_mp_1_altb)? (2'd0):(2'd1) ;
        56: max_pool_idx[2] <= (cmp_mp_1_altb)? (max_pool_idx[2]):(2'd2) ;
        57: max_pool_idx[2] <= (cmp_mp_1_altb)? (max_pool_idx[2]):(2'd3) ;
        58: max_pool_idx[3] <= (cmp_mp_1_altb)? (max_pool_idx[3]):(2'd2) ;
        59: max_pool_idx[3] <= (cmp_mp_1_altb)? (max_pool_idx[3]):(2'd3) ;
    endcase
end

// //* corrider ( like a shift reg )
// always @(posedge clk or negedge rst_n) begin
//     corridor[0] <= corridor_d ;
//     corridor[1] <= corridor[0] ;
//     corridor[2] <= corridor[1] ;
//     corridor[3] <= corridor[2] ;
// end
// always @(*) begin
//     if () begin
//         corridor_d = 1 ;
//     end else begin
//         corridor_d = 0 ;
//     end
// end

//-----------------
//* FC
//-----------------
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    UFC_mult1 ( .a(FC_multiplier_1), .b(FC_multiplicand_1), .rnd(3'b0), .z(FC_product_1), .status( ) );

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    UFC_mult2 ( .a(FC_multiplier_2), .b(FC_multiplicand_2), .rnd(3'b0), .z(FC_product_2), .status( ) );

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    UFC_add1 ( .a(FC_add_a), .b(FC_add_b), .rnd(3'b0),/*.op(1'b0),*/ .z(FC_sum), .status() );

always @(*) begin
    case (conv_cnt)
        58: begin
            case (max_pool_idx[0])
                2'b00: FC_multiplier_1 = conv_result[0] ;
                2'b01: FC_multiplier_1 = conv_result[1] ;
                2'b10: FC_multiplier_1 = conv_result[4] ;
                2'b11: FC_multiplier_1 = conv_result[5] ;
            endcase
            FC_multiplicand_1 = fc_weight[0] ;
            case (max_pool_idx[1])
                2'b00: FC_multiplier_2 = conv_result[2] ;
                2'b01: FC_multiplier_2 = conv_result[3] ;
                2'b10: FC_multiplier_2 = conv_result[6] ;
                2'b11: FC_multiplier_2 = conv_result[7] ;
            endcase
            FC_multiplicand_2 = fc_weight[2] ;
            FC_add_a = FC_product_1 ;
            FC_add_b = FC_product_2 ;
        end
        59: begin
            case (max_pool_idx[0])
                2'b00: FC_multiplier_1 = conv_result[0] ;
                2'b01: FC_multiplier_1 = conv_result[1] ;
                2'b10: FC_multiplier_1 = conv_result[4] ;
                2'b11: FC_multiplier_1 = conv_result[5] ;
            endcase
            FC_multiplicand_1 = fc_weight[1] ;
            case (max_pool_idx[1])
                2'b00: FC_multiplier_2 = conv_result[2] ;
                2'b01: FC_multiplier_2 = conv_result[3] ;
                2'b10: FC_multiplier_2 = conv_result[6] ;
                2'b11: FC_multiplier_2 = conv_result[7] ;
            endcase
            FC_multiplicand_2 = fc_weight[3] ;
            FC_add_a = FC_product_1 ;
            FC_add_b = FC_product_2 ;
        end
        60: begin
            case (max_pool_idx[2])
                2'b00: FC_multiplier_1 = conv_result[8] ;
                2'b01: FC_multiplier_1 = conv_result[9] ;
                2'b10: FC_multiplier_1 = conv_result[12] ;
                2'b11: FC_multiplier_1 = conv_result[13] ;
            endcase
            FC_multiplicand_1 = fc_weight[0] ;
            case (max_pool_idx[3])
                2'b00: FC_multiplier_2 = conv_result[10] ;
                2'b01: FC_multiplier_2 = conv_result[11] ;
                2'b10: FC_multiplier_2 = conv_result[14] ;
                2'b11: FC_multiplier_2 = conv_result[15] ;
            endcase
            FC_multiplicand_2 = fc_weight[2] ;
            FC_add_a = FC_product_1 ;
            FC_add_b = FC_product_2 ;
        end
        61: begin
            case (max_pool_idx[2])
                2'b00: FC_multiplier_1 = conv_result[8] ;
                2'b01: FC_multiplier_1 = conv_result[9] ;
                2'b10: FC_multiplier_1 = conv_result[12] ;
                2'b11: FC_multiplier_1 = conv_result[13] ;
            endcase
            FC_multiplicand_1 = fc_weight[1] ;
            case (max_pool_idx[3])
                2'b00: FC_multiplier_2 = conv_result[10] ;
                2'b01: FC_multiplier_2 = conv_result[11] ;
                2'b10: FC_multiplier_2 = conv_result[14] ;
                2'b11: FC_multiplier_2 = conv_result[15] ;
            endcase
            FC_multiplicand_2 = fc_weight[3] ;
            FC_add_a = FC_product_1 ;
            FC_add_b = FC_product_2 ;
        end
        default: begin
            FC_add_a = 0 ;
            FC_add_b = 0 ;
            FC_multiplier_1 = 0 ;
            FC_multiplier_2 = 0 ;
            FC_multiplicand_1 = 0 ;
            FC_multiplicand_2 = 0 ; 
        end
    endcase
end

//* FC_result
always @(posedge clk) begin
    case (conv_cnt)
        58 : FC_result[0] <= FC_sum ;
        59 : FC_result[1] <= FC_sum ;
        60 : FC_result[2] <= FC_sum ;
        61 : FC_result[3] <= FC_sum ;
    endcase
end

//* normalize

//--------------
// cmp tree
//--------------
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
U_normal_cmp1 ( .a(FC_result[0]), .b(FC_result[2]), .zctr(1'b0), .aeqb(), .altb(), .agtb(cmp_n1_altb), .unordered(), .z0(), .z1(cmp_n1_max), .status0(), .status1() );

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
U_normal_cmp2 ( .a(FC_result[1]), .b(FC_result[3]), .zctr(1'b0), .aeqb(), .altb(), .agtb(cmp_n2_altb), .unordered(), .z0(), .z1(cmp_n2_max), .status0(), .status1() );

assign cmp_n3_a = (cmp_n1_altb) ? (FC_result[0]):(FC_result[2]) ;
assign cmp_n3_b = (cmp_n2_altb) ? (FC_result[1]):(FC_result[3]) ;

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
U_normal_cmp3 ( .a(cmp_n3_a), .b(cmp_n3_b), .zctr(1'b0), .aeqb(), .altb(), .agtb(cmp_n3_altb), .unordered(), .z0(), .z1(cmp_n3_max), .status0(), .status1() );

assign cmp_n4_a = (cmp_n1_altb) ? (FC_result[2]):(FC_result[0]) ;
assign cmp_n4_b = (cmp_n2_altb) ? (FC_result[3]):(FC_result[1]) ;

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
U_normal_cmp4 ( .a(cmp_n4_a), .b(cmp_n4_b), .zctr(1'b1), .aeqb(), .altb(), .agtb(cmp_n4_altb), .unordered(), .z0(), .z1(cmp_n4_min), .status0(), .status1() );

DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
U_normal_sub1 ( .a(cmp_n3_max), .b(cmp_n4_min), .rnd(3'b0),/*.op(1'b1),*/ .z(max_sub_min_d), .status() );

DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
U_normal_sub2 ( .a(fc_n), .b(cmp_n4_min), .rnd(3'b0),/*.op(1'b1),*/ .z(fc_n_sub_min_d), .status() );

reg [1:0] normal_nonmax_min_idx_0 , normal_nonmax_min_idx_1 ,normal_max_idx , normal_min_idx ;
always @(*) begin
    case ({cmp_n4_altb ,cmp_n3_altb, cmp_n2_altb, cmp_n1_altb})
        0 : begin
            normal_nonmax_min_idx_0 = 1 ;
            normal_nonmax_min_idx_1 = 2 ;
            normal_min_idx = 0 ;
            normal_max_idx = 3 ;
        end
        1 : begin
            normal_nonmax_min_idx_0 = 0;
            normal_nonmax_min_idx_1 = 1;
            normal_min_idx = 2;
            normal_max_idx = 3;
        end
        2 : begin
            normal_nonmax_min_idx_0 = 2;
            normal_nonmax_min_idx_1 = 3;
            normal_min_idx = 0;
            normal_max_idx = 1;
        end
        3 : begin
            normal_nonmax_min_idx_0 = 0;
            normal_nonmax_min_idx_1 = 3;
            normal_min_idx = 2;
            normal_max_idx = 1;
        end
        4 : begin
            normal_nonmax_min_idx_0 = 1;
            normal_nonmax_min_idx_1 = 3;
            normal_min_idx = 0;
            normal_max_idx = 2;
        end
        5 : begin
            normal_nonmax_min_idx_0 = 1;
            normal_nonmax_min_idx_1 = 3;
            normal_min_idx = 2;
            normal_max_idx = 0;
        end
        6 : begin
            normal_nonmax_min_idx_0 = 1;
            normal_nonmax_min_idx_1 = 3;
            normal_min_idx = 0;
            normal_max_idx = 2;
        end
        7 : begin
            normal_nonmax_min_idx_0 = 1;
            normal_nonmax_min_idx_1 = 3;
            normal_min_idx = 2;
            normal_max_idx = 0;
        end
        8 : begin
            normal_nonmax_min_idx_0 = 0;
            normal_nonmax_min_idx_1 = 2;
            normal_min_idx = 1;
            normal_max_idx = 3;
        end
        9 : begin
            normal_nonmax_min_idx_0 = 0;
            normal_nonmax_min_idx_1 = 2;
            normal_min_idx = 1;
            normal_max_idx = 3;
        end
        10 : begin
            normal_nonmax_min_idx_0 = 0;
            normal_nonmax_min_idx_1 = 2;
            normal_min_idx = 3;
            normal_max_idx = 1;
        end
        11 : begin
            normal_nonmax_min_idx_0 = 0;
            normal_nonmax_min_idx_1 = 2;
            normal_min_idx = 3;
            normal_max_idx = 1;
        end
        12 : begin
            normal_nonmax_min_idx_0 = 0;
            normal_nonmax_min_idx_1 = 3;
            normal_min_idx = 1;
            normal_max_idx = 2;
        end
        13 : begin
            normal_nonmax_min_idx_0 = 2;
            normal_nonmax_min_idx_1 = 3;
            normal_min_idx = 1;
            normal_max_idx = 0;
        end
        14 : begin
            normal_nonmax_min_idx_0 = 0;
            normal_nonmax_min_idx_1 = 1;
            normal_min_idx = 3;
            normal_max_idx = 2;
        end
        15 : begin
            normal_nonmax_min_idx_0 = 1;
            normal_nonmax_min_idx_1 = 2;
            normal_min_idx = 3;
            normal_max_idx = 0;
        end
        default: begin
            normal_nonmax_min_idx_0 = 0 ;
            normal_nonmax_min_idx_1 = 0 ;
            normal_min_idx = 0 ;
            normal_max_idx = 0 ; 
        end
    endcase
end

always @(*) begin
case (conv_cnt)
    62: fc_n = FC_result[normal_nonmax_min_idx_0] ;
    63: fc_n = FC_result[normal_nonmax_min_idx_1] ;
    default: fc_n = 0 ;
endcase
end

always @(posedge clk) begin
    fc_n_sub_min_q <= fc_n_sub_min_d ;
    max_sub_min_q <= max_sub_min_d ;
end

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round)
U_div1 ( .a(div_a), .b(div_b), .rnd(3'b0), .z(div_out), .status() );

always @(*) begin
    case (conv_cnt)
    // normalize
        63: begin
            div_a = fc_n_sub_min_q ;
            div_b = max_sub_min_q ;
        end
        64: begin
            div_a = fc_n_sub_min_q ;
            div_b = max_sub_min_q ;
        end

    // tanh
        65 : begin
            if (opt_q==2'd1) begin // tanh
                div_a = act_suber1_z ;
                div_b = act_adder2_z ;
            end else begin
                div_a = exp_result[0] ;
                div_b = act_adder2_z ;
            end
        end
        66: begin
            if (opt_q==2'd1) begin //tanh 
                div_a = act_suber1_z ;
                div_b = act_adder2_z ;
            end else begin
                div_a = exp_result[1] ;
                div_b = act_adder2_z ;
            end
        end
        default: begin
            div_a = fc_n_sub_min_q ;
            div_b = max_sub_min_q ;
        end
    endcase
end

//* normal_result
always @(posedge clk) begin
    case (conv_cnt)
        62: begin
            normal_result[normal_max_idx] <= IEEE_one ;
            normal_result[normal_min_idx] <= IEEE_zero ;
        end
        63: begin
            normal_result[normal_nonmax_min_idx_0] <= div_out ;
        end 
        64: normal_result[normal_nonmax_min_idx_1] <= div_out ;
    endcase
end

//------------------
// Activate
//------------------
// SUB / ADD ------------------------------------------------------------------------------------------
reg [inst_sig_width+inst_exp_width:0] act_adder1_a , act_adder1_b ;
wire [inst_sig_width+inst_exp_width:0] act_adder1_z ;
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
U_act_adder1 ( .a(act_adder1_a), .b(act_adder1_b), .rnd(3'b0),/*.op(1'b0),*/ .z(act_adder1_z), .status() );

// reg [inst_sig_width+inst_exp_width:0] act_adder2_a , act_adder2_b ;
// wire [inst_sig_width+inst_exp_width:0] act_adder2_z ;
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
U_act_adder2 ( .a(act_adder2_a), .b(act_adder2_b), .rnd(3'b0),/*.op(1'b0),*/ .z(act_adder2_z), .status() );

// reg [inst_sig_width+inst_exp_width:0] act_suber1_a , act_suber1_b ;
// wire [inst_sig_width+inst_exp_width:0] act_suber1_z ;
DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
U_act_suber1 ( .a(act_suber1_a), .b(act_suber1_b), .rnd(3'b0),/*.op(1'b1),*/ .z(act_suber1_z), .status() );
//-----------------------------------------------------------------------------------------------------


// EXP ------------------------------------------------------------------------------------------------
reg [inst_sig_width+inst_exp_width:0] act_exp1_a ;
wire [inst_sig_width+inst_exp_width:0] act_exp1_z ;
DW_fp_exp #(inst_sig_width,inst_exp_width,inst_ieee_compliance, inst_arch)
U_act_exp1(.a(act_exp1_a), .z(act_exp1_z));
//-----------------------------------------------------------------------------------------------------

// Ln -------------------------------------------------------------------------------------------------
reg [inst_sig_width+inst_exp_width:0] act_ln1_a ;
wire [inst_sig_width+inst_exp_width:0] act_ln1_z ;
DW_fp_ln #(inst_sig_width,inst_exp_width,inst_ieee_compliance, 0, inst_arch)
U_act_ln1 (.a(act_ln1_a), .status(), .z(act_ln1_z));
//-----------------------------------------------------------------------------------------------------
always @(*) begin
    case (conv_cnt)
        64:begin
            act_adder1_a = normal_result[normal_nonmax_min_idx_0] ;
            act_adder1_b = normal_result[normal_nonmax_min_idx_0] ;
        end
        65: begin
            act_adder1_a = normal_result[normal_nonmax_min_idx_1] ;
            act_adder1_b = normal_result[normal_nonmax_min_idx_1] ;
        end
        default: begin
            act_adder1_a = 0 ;
            act_adder1_b = 0 ;
        end
    endcase
end

always @(*) begin
    case (conv_cnt)
        64: begin 
            if (opt_q==2'd1) begin //tanh
                act_exp1_a = act_adder1_z ;
            end else begin
                act_exp1_a = normal_result[normal_nonmax_min_idx_0] ;
            end
        end
        65: begin
            if (opt_q==2'd1) begin //tanh
                act_exp1_a = act_adder1_z ;
            end else begin
                act_exp1_a = normal_result[normal_nonmax_min_idx_1] ;
            end
        end
        default: act_exp1_a = 0 ;
    endcase
end

always @(posedge clk) begin
    case (conv_cnt)
        64: exp_result [0] <= act_exp1_z ;
        65: exp_result [1] <= act_exp1_z ;
    endcase
end

always @(*) begin
    case (conv_cnt)
        65: begin
            act_adder2_a = exp_result [0] ;
            act_adder2_b = IEEE_one ;
            act_suber1_a = exp_result [0] ;
            act_suber1_b = IEEE_one ;
        end
        66: begin
            act_adder2_a = exp_result [1] ;
            act_adder2_b = IEEE_one ;
            act_suber1_a = exp_result [1] ;
            act_suber1_b = IEEE_one ;
        end
        default: begin
            act_adder2_a = exp_result [0] ;
            act_adder2_b = IEEE_one ;
            act_suber1_a = exp_result [0] ;
            act_suber1_b = IEEE_one ;
        end
    endcase
end

// always @(posedge clk) begin
//     case (conv_cnt)
//         62 : begin
//             tanh_result [normal_max_idx] <= TANH_1 ;
//             tanh_result [normal_min_idx] <= TANH_0 ;
//         end
//         65 : tanh_result [normal_nonmax_min_idx_0] <= div_out ;
//         66 : tanh_result [normal_nonmax_min_idx_1] <= div_out ;
//     endcase
// end

always @(*) begin
    case (conv_cnt)
        65:act_ln1_a = act_adder2_z ;
        66:act_ln1_a = act_adder2_z ;
        default: act_ln1_a = IEEE_one ;
    endcase
end

// always @(posedge clk) begin
//     case (conv_cnt)
//         62 : begin
//             soft_plus_result [normal_max_idx] <= SOFT_1 ;
//             soft_plus_result [normal_min_idx] <= SOFT_0 ;
//         end 
//         65: begin
//             soft_plus_result [normal_nonmax_min_idx_0] <= act_ln1_z ;
//         end
//         66: begin
//             soft_plus_result [normal_nonmax_min_idx_1] <= act_ln1_z ;
//         end
//     endcase
// end

// always @(posedge clk) begin
//     case (conv_cnt)
//         62: begin
//             sigmoid_result[normal_max_idx] <= SIGM_1 ;
//             sigmoid_result[normal_min_idx] <= SIGM_0 ;
//         end 
//         65: sigmoid_result[normal_nonmax_min_idx_0] <= div_out ;
//         66: sigmoid_result[normal_nonmax_min_idx_1] <= div_out ;
//     endcase
// end

always @(posedge clk) begin
    case (conv_cnt)
     62: begin
         if (opt_q==2'd1) begin //tanh
             output_repo[normal_max_idx] <= TANH_1 ;
             output_repo[normal_min_idx] <= TANH_0 ;
         end else if (opt_q==2'd2) begin //sigmoid
             output_repo[normal_max_idx] <= SIGM_1 ;
             output_repo[normal_min_idx] <= SIGM_0 ;
         end else begin //softplus
             output_repo[normal_max_idx] <= SOFT_1 ;
             output_repo[normal_min_idx] <= SOFT_0 ;
         end
     end 
     65: begin
         if (opt_q==2'd1) begin //tanh
             output_repo[normal_nonmax_min_idx_0] <= div_out ;
         end else if (opt_q==2'd2) begin //sigmoid
             output_repo[normal_nonmax_min_idx_0] <= div_out ;
         end else begin //softplus
             output_repo[normal_nonmax_min_idx_0] <= act_ln1_z ;
         end
     end
     66:begin
         if (opt_q==2'd1) begin //tanh
             output_repo[normal_nonmax_min_idx_1] <= div_out ;
         end else if (opt_q==2'd2) begin //sigmoid
             output_repo[normal_nonmax_min_idx_1] <= div_out ;
         end else begin //softplus
             output_repo[normal_nonmax_min_idx_1] <= act_ln1_z ;
         end
     end
    endcase 
 end

// //* for debug
// reg [inst_sig_width+inst_exp_width:0] maxpool_num0 , maxpool_num1 , maxpool_num2 , maxpool_num3 ;
// always @(*) begin
//     case (max_pool_idx[0])
//         2'b00: maxpool_num0 = conv_result[0] ;
//         2'b01: maxpool_num0 = conv_result[1] ;
//         2'b10: maxpool_num0 = conv_result[4] ;
//         2'b11: maxpool_num0 = conv_result[5] ;
//         default: maxpool_num0 = 0 ;
//     endcase
//     case (max_pool_idx[1])
//         2'b00: maxpool_num1 = conv_result[2] ;
//         2'b01: maxpool_num1 = conv_result[3] ;
//         2'b10: maxpool_num1 = conv_result[6] ;
//         2'b11: maxpool_num1 = conv_result[7] ;
//         default: maxpool_num1 = 0 ;
//     endcase
//     case (max_pool_idx[2])
//         2'b00: maxpool_num2 = conv_result[8] ;
//         2'b01: maxpool_num2 = conv_result[9] ;
//         2'b10: maxpool_num2 = conv_result[12] ;
//         2'b11: maxpool_num2 = conv_result[13] ;
//         default: maxpool_num2 = 0 ;
//     endcase
//     case (max_pool_idx[3])
//         2'b00: maxpool_num3 = conv_result[10] ;
//         2'b01: maxpool_num3 = conv_result[11] ;
//         2'b10: maxpool_num3 = conv_result[14] ;
//         2'b11: maxpool_num3 = conv_result[15] ;
//         default: maxpool_num3 = 0 ;
//     endcase
// end
// 錄影教你
// 先用 TMUX 
// 然後跑01 (記得改合成時間)
// 這樣就開一個了
// 現在可以去改syn砲其他時間

endmodule

module PE 
#(
    parameter inst_sig_width = 23,
    parameter inst_exp_width = 8,
    parameter inst_ieee_compliance = 0,
    parameter inst_arch_type = 0
)
(
    input wire [inst_sig_width+inst_exp_width:0] multiplier_1 , //! 
    input wire [inst_sig_width+inst_exp_width:0] multiplicand_1 , //! 
    input wire [inst_sig_width+inst_exp_width:0] multiplier_2 , //! 
    input wire [inst_sig_width+inst_exp_width:0] multiplicand_2 , //! 
    input wire [inst_sig_width+inst_exp_width:0] multiplier_3 , //! 
    input wire [inst_sig_width+inst_exp_width:0] multiplicand_3 , //! 
    input clk ,

    output wire [inst_sig_width+inst_exp_width:0] product  //! 
);
wire [inst_sig_width+inst_exp_width:0] product_1_d , product_2_d , product_3_d ;
reg  [inst_sig_width+inst_exp_width:0] product_1_q , product_2_q , product_3_q ;

// wire [inst_sig_width+inst_exp_width:0] sum1 ;
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    U1_mult ( .a(multiplier_1), .b(multiplicand_1), .rnd(3'b0), .z(product_1_d), .status( ) );

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    U2_mult ( .a(multiplier_2), .b(multiplicand_2), .rnd(3'b0), .z(product_2_d), .status( ) );

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
    U3_mult ( .a(multiplier_3), .b(multiplicand_3), .rnd(3'b0), .z(product_3_d), .status( ) );

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch_type)
    U1_add3to1 (.a(product_1_q),.b(product_2_q),.c(product_3_q),.rnd(3'b0),.z(product),.status() );

always @(posedge clk) begin
    product_1_q <= product_1_d ;
    product_2_q <= product_2_d ;
    product_3_q <= product_3_d ;
end

// DW_fp_addsub #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
//         Uadd1 ( .a(product_1), .b(product_2), .rnd(3'b0),
//         .op(1'b0), .z(n_psum_out), .status() );
    
endmodule



// DW_fp_div_seq #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_num_cyc,
// inst_rst_mode, inst_input_mode, inst_output_mode, inst_early_start, inst_internal_reg)
// U1 (
// .a(inst_a),
// .b(inst_b),
// .rnd(inst_rnd),
// .clk(inst_clk),
// .rst_n(inst_rst_n),
// .start(inst_start),
// .z(z_inst),
// .status(status_inst),
// .complete(complete_inst) );

// DW_fp_div #(sig_width, exp_width, ieee_compliance, faithful_round) U1
// ( .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst)
// );


// DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance,
// inst_faithful_round) U1 (
// .a(inst_a),
// .rnd(inst_rnd),
// .z(z_inst),
// .status(status_inst) );


// DW_fp_sub #(sig_width, exp_width, ieee_compliance)
// U1 ( .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst) );

// DW_fp_add #(sig_width, exp_width, ieee_compliance)
// U1 ( .a(inst_a), .b(inst_b), .rnd(inst_rnd), .z(z_inst), .status(status_inst) );