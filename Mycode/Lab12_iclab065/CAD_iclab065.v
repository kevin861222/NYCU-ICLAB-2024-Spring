// 5.26 submit version
// Cycle: 5.50 
// Area: 1150844.438332
module CAD
#(
parameter param_I8_0010 = 4'b0010,    
parameter param_I16_0110 = 4'b0110,   
parameter param_I32_1110 = 4'b1110,  
parameter param_I8_1100 = 6'b1100,    
parameter param_I16_10100 = 6'b10100,   
parameter param_I32_100100 = 6'b100100,
parameter reg_length_two = 2 ,
parameter reg_length_three = 3 ,
parameter reg_length_five = 5 ,
parameter reg_length_six = 6 ,
parameter reg_length_seven = 7 ,
parameter reg_length_fifteen = 15 ,
parameter reg_length_nineteen = 19 ,
parameter reg_length_thirty_nine = 39 ,
parameter reg_length_forty_eight = 48 ,
parameter reg_length_63 = 63
)(
    input wire clk,
    input wire rst_n,
    input wire in_valid,
    input wire in_valid2,
    input wire [1:0] matrix_size,
    input wire [7:0] matrix,
    input wire [3:0] matrix_idx,
    input wire mode,
    output reg out_valid,
    output reg out_value
);

localparam FSM_state_q_IDLE        = 3'b000;
localparam FSM_state_q_READ_IMG    = 3'b001;
localparam FSM_state_q_READ_WEI    = 3'b010;
localparam FSM_state_q_WAIT        = 3'b011;
localparam FSM_state_q_GET_IDX   = 3'b100;
localparam FSM_state_q_CAL   = 3'b101;
localparam FSM_state_q_OUTPUT      = 3'b110;

localparam IMG_SIZE_8X8   = 2'b00;
localparam IMG_SIZE_16X16 = 2'b01;
localparam IMG_SIZE_32X32 = 2'b10;

localparam conv_mode_q = 1'b0;
localparam deconv_mode_q    = 1'b1;

localparam global_cnt_nextum_of_cal_m0 = 3'b110; 
localparam global_cnt_nextum_of_cal_m1 = 3'b001;
localparam global_cnt_nextum_of_output = 5'b10100;
localparam global_cnt_nextum_of_save_m0 = 5'b1110;
localparam global_cnt_nextum_of_save_m1 = 5'b1110;

localparam global_cnt_nextum_I8_m0_out  = 'b100 - 1; 
localparam global_cnt_nextum_I16_m0_out = 'b100100 - 1;
localparam global_cnt_nextum_I32_m0_out = 'b11000100 - 1;
localparam global_cnt_nextum_I8_m1_out  = 'b10010000 - 1;
localparam global_cnt_nextum_I16_m1_out = 'b110010000 - 1;
localparam global_cnt_nextum_I32_m1_out = 'b10100010000 - 1;

int i ;





reg [reg_length_three:0] img_idx_q;
reg [reg_length_three:0] img_idx_q_next;
reg [reg_length_three:0] kernel_idx_q;
reg [reg_length_three:0] kernel_idx_q_next;

reg out_value_next;
reg out_valid_next;

reg [10:0] img_addr_q;
reg [reg_length_63:0] img_data_in;
reg [reg_length_63:0] img_data_out;
reg img_SRAM_we;

reg A0;
reg A1;
reg A2;
reg A3;
reg A4;
reg A5;
reg A6;
reg A7;
reg A8;
reg A9;
reg A10;
always @(*) {A10, A9, A8, A7, A6, A5, A4, A3, A2, A1, A0} = img_addr_q;

reg DI0;
reg DI1;
reg DI2;
reg DI3;
reg DI4;
reg DI5;
reg DI6;
reg DI7;
reg DI8;
reg DI9;
reg DI10;
reg DI11;
reg DI12;
reg DI13;
reg DI14;
reg DI15;
reg DI16;
reg DI17;
reg DI18;
reg DI19;
reg DI20;
reg DI21;
reg DI22;
reg DI23;
reg DI24;
reg DI25;
reg DI26;
reg DI27;
reg DI28;
reg DI29;
reg DI30;
reg DI31;
reg DI32;
reg DI33;
reg DI34;
reg DI35;
reg DI36;
reg DI37;
reg DI38;
reg DI39;
reg DI40;
reg DI41;
reg DI42;
reg DI43;
reg DI44;
reg DI45;
reg DI46;
reg DI47;
reg DI48;
reg DI49;
reg DI50;
reg DI51;
reg DI52;  
reg DI53;  
reg DI54;  
reg DI55;  
reg DI56;  
reg DI57;      
reg DI58;      
reg DI59;      
reg DI60;      
reg DI61;      
reg DI62;          
reg DI63; 
always @(*) {DI63, DI62, DI61, DI60, DI59, DI58, DI57, DI56, DI55, DI54, DI53, DI52, DI51, DI50, DI49, DI48, DI47, DI46, DI45, DI44, DI43, DI42, DI41, DI40, DI39, DI38, DI37, DI36, DI35, DI34, DI33, DI32, DI31, DI30, DI29, DI28, DI27, DI26, DI25, DI24, DI23, DI22, DI21, DI20, DI19, DI18, DI17, DI16, DI15, DI14, DI13, DI12, DI11, DI10, DI9, DI8, DI7, DI6, DI5, DI4, DI3, DI2, DI1, DI0} = img_data_in;

reg mode_q;
wire DO0;
wire DO1;
wire DO2;
wire DO3;
wire DO4;
wire DO5;
wire DO6;
wire DO7;
wire DO8;
wire DO9;
wire DO10;
wire DO11;
wire DO12;
wire DO13;
wire DO14;
wire DO15;
wire DO16;
wire DO17;
wire DO18;
wire DO19;
wire DO20;
wire DO21;
wire DO22;
wire DO23;
wire DO24;
wire DO25;
wire DO26;
wire DO27;
wire DO28;
wire DO29;
wire DO30;
wire DO31;
wire DO32;
wire DO33;
wire DO34;
wire DO35;
wire DO36;
wire DO37;
wire DO38;
wire DO39;
wire DO40;
wire DO41;
wire DO42;
wire DO43;
wire DO44;
wire DO45;
wire DO46;
wire DO47;
wire DO48;
wire DO49;
wire DO50;
wire DO51;
wire DO52;  
wire DO53;  
wire DO54;  
wire DO55;  
wire DO56;  
wire DO57;      
wire DO58;      
wire DO59;      
wire DO60;      
wire DO61;      
wire DO62;          
wire DO63;  
always @(*)  img_data_out = {DO63, DO62, DO61, DO60, DO59, DO58, DO57, DO56, DO55, DO54, DO53, DO52, DO51, DO50, DO49, DO48, DO47, DO46, DO45, DO44, DO43, DO42, DO41, DO40, DO39, DO38, DO37, DO36, DO35, DO34, DO33, DO32, DO31, DO30, DO29, DO28, DO27, DO26, DO25, DO24, DO23, DO22, DO21, DO20, DO19, DO18, DO17, DO16, DO15, DO14, DO13, DO12, DO11, DO10, DO9, DO8, DO7, DO6, DO5, DO4, DO3, DO2, DO1, DO0 };       

reg [reg_length_six:0] weight_addr;
reg [reg_length_thirty_nine:0] weight_data_in;

reg weight_SRAM_we;


reg WA0; 
reg WA1;
reg WA2;
reg WA3;
reg WA4;
reg WA5;
reg WA6;
always @(*) begin
    {WA6, WA5, WA4, WA3, WA2, WA1, WA0} = weight_addr;
end

wire WDI0 ;
wire WDI1 ;
wire WDI2 ;
wire WDI3 ;
wire WDI4 ;
wire WDI5 ;
wire WDI6 ;
wire WDI7 ;
wire WDI8 ;
wire WDI9 ;
wire WDI10;
wire WDI11;
wire WDI12;
wire WDI13;
wire WDI14;
wire WDI15;
wire WDI16;
wire WDI17;
wire WDI18;
wire WDI19;
wire WDI20;
wire WDI21;
wire WDI22;
wire WDI23;
wire WDI24;
wire WDI25;
wire WDI26;
wire WDI27;
wire WDI28;
wire WDI29;
wire WDI30;
wire WDI31;
wire WDI32;
wire WDI33;
wire WDI34;
wire WDI35;
wire WDI36;
reg mode_next;
wire WDI37;
reg [1:0] matrix_size_q;
wire WDI38;
reg [1:0] matrix_size_q_next;
wire WDI39;
assign {WDI39, WDI38, WDI37, WDI36, WDI35, WDI34, WDI33, WDI32, WDI31, WDI30, WDI29, WDI28, WDI27, WDI26, WDI25, WDI24, WDI23, WDI22, WDI21, WDI20, WDI19, WDI18, WDI17, WDI16, WDI15, WDI14, WDI13, WDI12, WDI11, WDI10, WDI9, WDI8, WDI7, WDI6, WDI5, WDI4, WDI3, WDI2, WDI1, WDI0 } = weight_data_in;

wire WDO0 ;
wire WDO1 ;
wire WDO2 ;
wire WDO3 ;
wire WDO4 ;
wire WDO5 ;
wire WDO6 ;
wire WDO7 ;
wire WDO8 ;
wire WDO9 ;
wire WDO10;
wire WDO11;
wire WDO12;
wire WDO13;
wire WDO14;
wire WDO15;
wire WDO16;
wire WDO17;
wire WDO18;
wire WDO19;
wire WDO20;
wire WDO21;
wire WDO22;
wire WDO23;
wire WDO24;
wire WDO25;
wire WDO26;
wire WDO27;
wire WDO28;
wire WDO29;
wire WDO30;
wire WDO31;
wire WDO32;
wire WDO33;
wire WDO34;
wire WDO35;
wire WDO36;
wire WDO37;
wire WDO38;
wire WDO39;
wire [39:0] weight_data_out = {WDO39, WDO38, WDO37, WDO36, WDO35, WDO34, WDO33, WDO32, WDO31, WDO30, WDO29, WDO28, WDO27, WDO26, WDO25, WDO24, WDO23, WDO22, WDO21, WDO20, WDO19, WDO18, WDO17, WDO16, WDO15, WDO14, WDO13, WDO12, WDO11, WDO10, WDO9, WDO8, WDO7, WDO6, WDO5, WDO4, WDO3, WDO2, WDO1, WDO0 };




reg [reg_length_two:0] FSM_state_q;
reg [reg_length_two:0] FSM_state_q_next;
reg [reg_length_two:0] cycle_calc_1st_value_sub1;

reg [10:0] global_cnt;
reg [10:0] global_cnt_next;
reg [10:0] global_cnt_plus1;

reg [6:0] addr_SRAM_cnt;
reg [6:0] addr_SRAM_cnt_next;
wire [6:0] addr_SRAM_cnt_plus1;
reg [6:0] addr_SRAM_cnt_bound;

reg [3:0] set_num_cnt;
reg [3:0] set_num_cnt_next;
wire [3:0] set_num_cnt_plus1;

reg [10:0] num_out_values_sub1;

reg [6:0] kernel_addr_SRAM_cnt;
reg [6:0] kernel_addr_SRAM_cnt_next;
wire [6:0] kernel_addr_SRAM_cnt_plus1 = kernel_addr_SRAM_cnt + 7'b1; ;
wire [6:0] kernel_addr_SRAM_cnt_dec = kernel_addr_SRAM_cnt - 7'b1;;
reg [6:0] kernel_addr_start_point;

reg [4:0] calc_global_cnt;
reg [4:0] calc_global_cnt_next;
wire [4:0] calc_global_cnt_plus1 = calc_global_cnt + 5'b1;

reg [3:0] skip_rows;

reg [reg_length_five:0] global_cnt_out_row;
reg [reg_length_five:0] global_cnt_out_row_next;
reg [reg_length_five:0] row_cnt_sub1;
wire [reg_length_five:0] rows_cnt_sub1_next = row_cnt_sub1;
reg [6:0] img_addr_q_base;
reg [6:0] img_addr_q_base_next;
wire [6:0] img_addr_q_base_inc;
reg [4:0] img_addr_q_shift;
reg [4:0] img_addr_q_shift_next;
wire [4:0] img_addr_q_shift_skip = img_addr_q_shift + skip_rows;
reg img_addr_q_2row_flag;
reg [6:0] img_addr_q_output_stage;

reg [reg_length_five:0] global_cnt_complete_rows;
reg [reg_length_five:0] global_cnt_complete_rows_next;

wire [reg_length_five:0] num_remaing_rows;
wire [reg_length_five:0] num_remaing_out_this_row;

reg [reg_length_seven:0] in_data_buf [0:11]; 
reg [reg_length_seven:0] in_data_buf_next [0:11]; 

reg [reg_length_seven:0] kernel [0:4];
reg [reg_length_seven:0] kernel_next [0:4];
reg [reg_length_seven:0] kernel_temp [0:4];

reg signed [reg_length_seven:0] mul_in_a [0:3][0:4];
reg signed [reg_length_seven:0] mul_in_b [0:3][0:4];
reg signed [reg_length_fifteen:0] product [0:3][0:4];
reg signed [reg_length_nineteen:0] prev_partial_sum [0:3];

reg signed [reg_length_nineteen:0] hidden_map [0:3];
reg signed [reg_length_nineteen:0] hidden_map_next [0:3];

reg signed [reg_length_nineteen:0] cmp_max_num_0;
reg signed [reg_length_nineteen:0] cmp_max_num_1;
reg signed [reg_length_nineteen:0] cmp_max_num;

reg [reg_length_nineteen:0] output_result_q;
reg [reg_length_nineteen:0] output_result_q_next;
reg [reg_length_nineteen:0] next_output_result_q;
reg [reg_length_nineteen:0] next_output_result_q_next;


SUMA180_2048X64X1BM1 IMG_MEM (
    .A0(A0), .A1(A1), .A2(A2), .A3(A3), .A4(A4), 
    .A5(A5), .A6(A6), .A7(A7), .A8(A8), .A9(A9), 
    .A10(A10),
    .DO0(DO0), .DO1(DO1), .DO2(DO2), .DO3(DO3), 
    .DO4(DO4), .DO5(DO5), .DO6(DO6), .DO7(DO7), .DO8(DO8), .DO9(DO9),
    .DO10(DO10), .DO11(DO11), .DO12(DO12), .DO13(DO13), .DO14(DO14), 
    .DO15(DO15), .DO16(DO16), .DO17(DO17), .DO18(DO18), .DO19(DO19),
    .DO20(DO20), .DO21(DO21), .DO22(DO22), .DO23(DO23), 
    .DO24(DO24), .DO25(DO25), .DO26(DO26), .DO27(DO27), .DO28(DO28), .DO29(DO29),
    .DO30(DO30), .DO31(DO31), .DO32(DO32), 
    .DO33(DO33), .DO34(DO34), .DO35(DO35), .DO36(DO36), .DO37(DO37), .DO38(DO38), .DO39(DO39),
    .DO40(DO40), .DO41(DO41), .DO42(DO42), .DO43(DO43), 
    .DO44(DO44), .DO45(DO45), .DO46(DO46), .DO47(DO47), .DO48(DO48), .DO49(DO49),
    .DO50(DO50), .DO51(DO51), .DO52(DO52), 
    .DO53(DO53), .DO54(DO54), .DO55(DO55), .DO56(DO56), .DO57(DO57), .DO58(DO58), .DO59(DO59),
    .DO60(DO60), .DO61(DO61), .DO62(DO62), .DO63(DO63),
    .DI0(DI0), .DI1(DI1), .DI2(DI2), .DI3(DI3), .DI4(DI4), .DI5(DI5), .
    DI6(DI6), .DI7(DI7), .DI8(DI8), .DI9(DI9),
    .DI10(DI10), .DI11(DI11), .DI12(DI12), .DI13(DI13), .DI14(DI14), 
    .DI15(DI15), .DI16(DI16), .DI17(DI17), .DI18(DI18), .DI19(DI19),
    .DI20(DI20), .DI21(DI21), .DI22(DI22), .DI23(DI23), 
    .DI24(DI24), .DI25(DI25), .DI26(DI26), .DI27(DI27), .DI28(DI28), .DI29(DI29),
    .DI30(DI30), .DI31(DI31), .DI32(DI32), .DI33(DI33), .DI34(DI34), .DI35(DI35), .DI36(DI36), 
    .DI37(DI37), .DI38(DI38), .DI39(DI39),
    .DI40(DI40), .DI41(DI41), .DI42(DI42), .DI43(DI43), 
    .DI44(DI44), .DI45(DI45), .DI46(DI46), .DI47(DI47), .DI48(DI48), .DI49(DI49),
    .DI50(DI50), .DI51(DI51), .DI52(DI52), 
    .DI53(DI53), .DI54(DI54), .DI55(DI55), .DI56(DI56), .DI57(DI57), .DI58(DI58), .DI59(DI59),
    .DI60(DI60), .DI61(DI61), .DI62(DI62), .DI63(DI63),
    .CK(clk), .WEB(img_SRAM_we), .OE(1'b1), .CS(1'b1)
    );

SUMA180_80X40X1BM1 WEIGHT_MEM ( 
    .A0(WA0), .A1(WA1), .A2(WA2), .A3(WA3), 
    .A4(WA4), .A5(WA5), .A6(WA6),
    .DO0(WDO0), .DO1(WDO1), 
    .DO2(WDO2), .DO3(WDO3), .DO4(WDO4), .DO5(WDO5), .DO6(WDO6), 
    .DO7(WDO7), .DO8(WDO8), .DO9(WDO9), .DO10(WDO10),
    .DO11(WDO11), .DO12(WDO12), .DO13(WDO13), 
    .DO14(WDO14), .DO15(WDO15), .DO16(WDO16), .DO17(WDO17), .DO18(WDO18), .DO19(WDO19), .DO20(WDO20),
    .DO21(WDO21), .DO22(WDO22), .DO23(WDO23), 
    .DO24(WDO24), .DO25(WDO25), .DO26(WDO26), .DO27(WDO27), .DO28(WDO28), .DO29(WDO29), .DO30(WDO30),
    .DO31(WDO31), .DO32(WDO32), .DO33(WDO33), .DO34(WDO34), 
    .DO35(WDO35), .DO36(WDO36), .DO37(WDO37), .DO38(WDO38), .DO39(WDO39),
    .DI0(WDI0), .DI1(WDI1), .DI2(WDI2), .DI3(WDI3), .DI4(WDI4), 
    .DI5(WDI5), .DI6(WDI6), .DI7(WDI7), .DI8(WDI8), .DI9(WDI9), .DI10(WDI10),
    .DI11(WDI11), .DI12(WDI12), .DI13(WDI13), .DI14(WDI14), .DI15(WDI15), 
    .DI16(WDI16), .DI17(WDI17), .DI18(WDI18), .DI19(WDI19), .DI20(WDI20),
    .DI21(WDI21), .DI22(WDI22), .DI23(WDI23), .DI24(WDI24), .DI25(WDI25), .DI26(WDI26), 
    .DI27(WDI27), .DI28(WDI28), .DI29(WDI29), .DI30(WDI30),
    .DI31(WDI31), .DI32(WDI32), .DI33(WDI33), .DI34(WDI34), 
    .DI35(WDI35), .DI36(WDI36), .DI37(WDI37), .DI38(WDI38), .DI39(WDI39),
    .CK(clk), .WEB(weight_SRAM_we), .OE(1'b1), .CS(1'b1)
    );

always@(posedge clk or negedge rst_n) 
begin
    if (~rst_n) begin 
        FSM_state_q[0] <= 0;
        FSM_state_q[1] <= 0;
        FSM_state_q[2] <= 0;
    end
    else FSM_state_q <= FSM_state_q_next;
end

always@(*) 
begin
    case (1)
        FSM_state_q == FSM_state_q_IDLE:begin 
            FSM_state_q_next = (in_valid)? FSM_state_q_READ_IMG : FSM_state_q_IDLE;
        end
        FSM_state_q == FSM_state_q_READ_IMG:begin 
            if (set_num_cnt == 4'd15 && addr_SRAM_cnt == addr_SRAM_cnt_bound && global_cnt[2:0] == 3'd7) begin 
                FSM_state_q_next = FSM_state_q_READ_WEI ;
            end else begin
                FSM_state_q_next = FSM_state_q_READ_IMG ;
            end
        end
        FSM_state_q == FSM_state_q_READ_WEI:begin 
            FSM_state_q_next = (addr_SRAM_cnt == 7'd79 && global_cnt[2:0] == 3'd4)? FSM_state_q_WAIT : FSM_state_q_READ_WEI;
        end
        FSM_state_q == FSM_state_q_WAIT:begin 
            FSM_state_q_next = (in_valid2)? FSM_state_q_GET_IDX : FSM_state_q_WAIT;
        end
        FSM_state_q == FSM_state_q_GET_IDX:begin 
            FSM_state_q_next = (global_cnt[0] == 1'd1)? FSM_state_q_CAL : FSM_state_q_GET_IDX;
        end
        FSM_state_q == FSM_state_q_CAL:begin 
            FSM_state_q_next = (global_cnt[2:0] == cycle_calc_1st_value_sub1) ? FSM_state_q_OUTPUT : FSM_state_q_CAL;
        end
        FSM_state_q == FSM_state_q_OUTPUT:begin 
            if ((calc_global_cnt == global_cnt_nextum_of_output - 1) && (global_cnt[10:0] == num_out_values_sub1)) begin 
                FSM_state_q_next = ((set_num_cnt == 4'd15) ? FSM_state_q_IDLE : FSM_state_q_WAIT);
            end else begin 
                FSM_state_q_next = FSM_state_q_OUTPUT ;
            end 
        end
        default:begin 
            FSM_state_q_next = FSM_state_q_IDLE;
        end
    endcase
end

always@(*) 
begin
    if (mode_q == conv_mode_q)
    begin
        cycle_calc_1st_value_sub1 = global_cnt_nextum_of_cal_m0 - 1 ;
    end
    else 
    begin
        cycle_calc_1st_value_sub1 = global_cnt_nextum_of_cal_m1 - 1;
    end

end

always@(posedge clk) 
begin
    matrix_size_q <= matrix_size_q_next;
end

always@(*)
begin
    if (FSM_state_q == FSM_state_q_IDLE && in_valid) 
    begin
        matrix_size_q_next = matrix_size ;
    end
    else 
    begin
        matrix_size_q_next = matrix_size_q ;
    end
end

always@(posedge clk) 
begin
    kernel_idx_q <= kernel_idx_q_next;
end

always@(posedge clk) 
begin
    img_idx_q <= img_idx_q_next;
end

always@(*) 
begin
    img_idx_q_next = (FSM_state_q == FSM_state_q_WAIT) ? matrix_idx : img_idx_q;
end

always@(*) 
begin
    kernel_idx_q_next = (FSM_state_q == FSM_state_q_GET_IDX && global_cnt[0] == 1'd0) ? matrix_idx : kernel_idx_q;
end

always@(posedge clk) 
begin
    mode_q <= mode_next;
end

always@(*)
begin
    if (FSM_state_q == FSM_state_q_WAIT) 
    begin
        mode_next = mode ;
    end
    else 
    begin
        mode_next = mode_q ;
    end
end

always@(posedge clk) 
begin
    global_cnt <= global_cnt_next;
end

always@(posedge clk) 
begin
    addr_SRAM_cnt <= addr_SRAM_cnt_next;
end

always@(posedge clk) 
begin
    set_num_cnt <= set_num_cnt_next;
end

always@(posedge clk) 
begin
    calc_global_cnt <= calc_global_cnt_next;
end

always @(*) 
begin
    global_cnt_plus1 = global_cnt + 1'b1;
end

always@(*) 
begin
    case (1)
        FSM_state_q == FSM_state_q_IDLE:         global_cnt_next = 0;
        FSM_state_q == FSM_state_q_READ_IMG:     global_cnt_next = global_cnt_plus1;
        FSM_state_q == FSM_state_q_READ_WEI:     global_cnt_next = (global_cnt[2:0] == 3'd4) ? 0 : global_cnt_plus1;
        FSM_state_q == FSM_state_q_GET_IDX:    global_cnt_next = (global_cnt[0] == 1'b1) ? 0 : global_cnt_plus1;
        FSM_state_q == FSM_state_q_CAL:    global_cnt_next = (global_cnt[2:0] == cycle_calc_1st_value_sub1) ? 0 : global_cnt_plus1;
        FSM_state_q == FSM_state_q_OUTPUT:       global_cnt_next = (calc_global_cnt == global_cnt_nextum_of_output - 1) ? global_cnt_plus1 : global_cnt;
        default:        global_cnt_next = 0;
    endcase
end

always@(*) 
begin
    case (1)
        FSM_state_q == FSM_state_q_OUTPUT:       calc_global_cnt_next = (calc_global_cnt == global_cnt_nextum_of_output - 1) ? 0 : calc_global_cnt_plus1;
        default:        calc_global_cnt_next = 0;
    endcase
end

always@(*) 
begin
    case (1)
        matrix_size_q == IMG_SIZE_8X8:   num_out_values_sub1 = (mode_q == conv_mode_q) ? global_cnt_nextum_I8_m0_out : global_cnt_nextum_I8_m1_out;
        matrix_size_q == IMG_SIZE_16X16: num_out_values_sub1 = (mode_q == conv_mode_q) ? global_cnt_nextum_I16_m0_out : global_cnt_nextum_I16_m1_out;
        matrix_size_q == IMG_SIZE_32X32: num_out_values_sub1 = (mode_q == conv_mode_q) ? global_cnt_nextum_I32_m0_out : global_cnt_nextum_I32_m1_out;
        default: num_out_values_sub1 = 0;
    endcase
end


always@(*) 
begin
    case (1)
        matrix_size_q == IMG_SIZE_8X8:   addr_SRAM_cnt_bound = 7'd7;     
        matrix_size_q == IMG_SIZE_16X16: addr_SRAM_cnt_bound = 7'd31;     
        matrix_size_q == IMG_SIZE_32X32: addr_SRAM_cnt_bound = 7'd127;    
        default: addr_SRAM_cnt_bound = 7'd127;
    endcase
end

always@(*) 
begin
    case (1)
        matrix_size_q == IMG_SIZE_8X8:   skip_rows = 4'd1;
        matrix_size_q == IMG_SIZE_16X16: skip_rows = 4'd2;
        matrix_size_q == IMG_SIZE_32X32: skip_rows = 4'd4;
        default: skip_rows = 4'd1;
    endcase
end

always@(posedge clk) global_cnt_out_row <= global_cnt_out_row_next;


always@(posedge clk) img_addr_q_shift <= img_addr_q_shift_next;

always@(posedge clk) img_addr_q_base <= img_addr_q_base_next;


always@(*) 
begin    
    case (1)
        matrix_size_q == IMG_SIZE_8X8:begin 
            row_cnt_sub1 = (mode_q == conv_mode_q) ? param_I8_0010 - 4'd1 : param_I8_1100 - 4'd1;
        end
        matrix_size_q == IMG_SIZE_16X16: begin
            row_cnt_sub1 = (mode_q == conv_mode_q) ? param_I16_0110 - 4'd1 : param_I16_10100 - 4'd1;
        end
        matrix_size_q == IMG_SIZE_32X32:begin 
            row_cnt_sub1 = (mode_q == conv_mode_q) ? param_I32_1110 - 4'd1 : param_I32_100100 - 4'd1;
        end
        default:begin 
            row_cnt_sub1 = param_I8_0010 - 4'd1;
        end
    endcase
end

always@(*) 
begin 
    if (FSM_state_q == FSM_state_q_CAL) begin 
        global_cnt_out_row_next = 6'b0000_01; 
    end
    else if (FSM_state_q == FSM_state_q_OUTPUT) begin
        if (calc_global_cnt == global_cnt_nextum_of_output - 1)
            if (global_cnt_out_row == row_cnt_sub1) begin
                global_cnt_out_row_next = 0;
            end
            else begin 
                global_cnt_out_row_next = global_cnt_out_row + 1;
            end
        else begin 
            global_cnt_out_row_next = global_cnt_out_row;
        end
    end
    else begin 
        global_cnt_out_row_next = 0;
    end
end

always@(posedge clk) global_cnt_complete_rows <= global_cnt_complete_rows_next;

always@(*) 
begin
    if (FSM_state_q == FSM_state_q_OUTPUT) begin 
        if ((calc_global_cnt == global_cnt_nextum_of_output - 1)) begin 
            if ((global_cnt_out_row == row_cnt_sub1)) begin 
                global_cnt_complete_rows_next = global_cnt_complete_rows + 1;
            end 
            else begin
                global_cnt_complete_rows_next = global_cnt_complete_rows;
            end
        end
        else begin
            global_cnt_complete_rows_next = global_cnt_complete_rows;
        end
    end
    else begin
        global_cnt_complete_rows_next = 0;
    end
end

assign img_addr_q_base_inc = img_addr_q_base + 7'd1;
always@(*) begin
    if (FSM_state_q != FSM_state_q_OUTPUT) img_addr_q_base_next = 7'd0;
    else begin
        if (mode_q == conv_mode_q) begin
            if (calc_global_cnt == global_cnt_nextum_of_output - 1) begin
                case (1)
                    global_cnt_out_row == row_cnt_sub1 : img_addr_q_base_next = img_addr_q_base_inc + skip_rows;
                    global_cnt_out_row[1:0] == 2'b11 : img_addr_q_base_next = img_addr_q_base_inc;
                    default: img_addr_q_base_next = img_addr_q_base;
                endcase
            end
            else img_addr_q_base_next = img_addr_q_base;
        end
        else begin
            if (calc_global_cnt == global_cnt_nextum_of_output - 1) begin
                if ((global_cnt_out_row == 6'd11)) begin
                    if (global_cnt_complete_rows < 6'd4) img_addr_q_base_next = (global_cnt_out_row == row_cnt_sub1) ? 0 : img_addr_q_base_inc;
                    else img_addr_q_base_next = img_addr_q_base_inc;
                end
                else if ((global_cnt_out_row == 6'd19)) begin
                    if (global_cnt_complete_rows < 6'd4) img_addr_q_base_next = (global_cnt_out_row == row_cnt_sub1) ? 0 : img_addr_q_base_inc;
                    else img_addr_q_base_next = img_addr_q_base_inc;
                end
                else if ((global_cnt_out_row == 6'd27)) begin
                    if (global_cnt_complete_rows < 6'd4) img_addr_q_base_next = (global_cnt_out_row == row_cnt_sub1) ? 0 : img_addr_q_base_inc;
                    else img_addr_q_base_next = img_addr_q_base_inc;
                end
                else if ((global_cnt_out_row == 6'd35)) begin
                    if (global_cnt_complete_rows < 6'd4) begin 
                        img_addr_q_base_next = (global_cnt_out_row == row_cnt_sub1) ? 0 : img_addr_q_base_inc;
                    end
                    else begin 
                        img_addr_q_base_next = img_addr_q_base_inc;
                    end
                end
                else begin 
                    img_addr_q_base_next = img_addr_q_base;
                end
            end
            else begin
                img_addr_q_base_next = img_addr_q_base;
            end
        end
    end
end

always@(*) begin
    if (FSM_state_q != FSM_state_q_OUTPUT) img_addr_q_shift_next = 'd0;
    else begin
        if (calc_global_cnt == global_cnt_nextum_of_output - 1) begin 
            img_addr_q_shift_next = 0;
        end
        else if (calc_global_cnt[0]) begin
            if (mode_q == conv_mode_q)  begin 
                img_addr_q_shift_next = img_addr_q_shift_skip;
            end
            else begin
                if (global_cnt_complete_rows < 6'd4) begin
                    case (1)
                        global_cnt_complete_rows[1:0] == 2'd0: img_addr_q_shift_next = img_addr_q_shift;
                        global_cnt_complete_rows[1:0] == 2'd1: img_addr_q_shift_next = (calc_global_cnt == 5'd7)? img_addr_q_shift_skip : img_addr_q_shift;
                        global_cnt_complete_rows[1:0] == 2'd2: img_addr_q_shift_next = (calc_global_cnt == 5'd5 || calc_global_cnt == 5'd7)? img_addr_q_shift_skip : img_addr_q_shift;
                        global_cnt_complete_rows[1:0] == 2'd3: begin 
                            if (calc_global_cnt == 5'd3 || calc_global_cnt == 5'd5 || calc_global_cnt == 5'd7) begin 
                                img_addr_q_shift_next = img_addr_q_shift_skip ;
                            end else begin
                                img_addr_q_shift_next = img_addr_q_shift ;
                            end
                        end
                    endcase
                end
                else if (num_remaing_rows < 6'd4) begin
                    case (1)
                        num_remaing_rows[1:0] == 2'd3: begin 
                            if (calc_global_cnt == 5'd1 || calc_global_cnt == 5'd3 || calc_global_cnt == 5'd5) begin 
                                img_addr_q_shift_next = img_addr_q_shift_skip ;
                            end else begin
                                img_addr_q_shift_next = img_addr_q_shift ;
                            end
                        end
                        num_remaing_rows[1:0] == 2'd2: img_addr_q_shift_next = (calc_global_cnt == 5'd1 || calc_global_cnt == 5'd3)? img_addr_q_shift_skip : img_addr_q_shift;
                        num_remaing_rows[1:0] == 2'd1: img_addr_q_shift_next = (calc_global_cnt == 5'd1)? img_addr_q_shift_skip : img_addr_q_shift;
                        num_remaing_rows[1:0] == 2'd0: img_addr_q_shift_next = img_addr_q_shift;
                    endcase
                end
                else  img_addr_q_shift_next = img_addr_q_shift_skip;
            end
        end
        else img_addr_q_shift_next = img_addr_q_shift;
    end
end

always@(*) begin
    if (FSM_state_q != FSM_state_q_OUTPUT) begin 
        img_addr_q_2row_flag = 0;
    end
    else begin
        if (mode_q == conv_mode_q) begin
            if ((global_cnt_out_row[1] == 1'b1) && (calc_global_cnt[0])) begin 
                img_addr_q_2row_flag = 1'b1;
            end
            else begin 
                img_addr_q_2row_flag = 1'b0;
            end
        end
        else begin
            case (1)
                matrix_size_q == IMG_SIZE_8X8:   begin 
                    img_addr_q_2row_flag = 1'b0;
                end
                matrix_size_q == IMG_SIZE_16X16: begin 
                    img_addr_q_2row_flag = ((calc_global_cnt[0]) && (global_cnt_out_row[3:2] == 2'b10));
                end
                matrix_size_q ==  IMG_SIZE_32X32: begin 
                    img_addr_q_2row_flag = ((calc_global_cnt[0]) && (global_cnt_out_row[2] == 1'b0) && (global_cnt_out_row[3] || global_cnt_out_row[4]));
                end
                default: begin 
                    img_addr_q_2row_flag = 1'b0;
                end
            endcase
        end
    end
end

assign addr_SRAM_cnt_plus1 = addr_SRAM_cnt + 7'd1;
always@(*) begin
    case(1)
        FSM_state_q == FSM_state_q_IDLE:                     addr_SRAM_cnt_next = 0;
        FSM_state_q == FSM_state_q_READ_IMG:                 addr_SRAM_cnt_next = (global_cnt[2:0] == 3'd7) ? ((addr_SRAM_cnt == addr_SRAM_cnt_bound) ? 0 : addr_SRAM_cnt_plus1) : addr_SRAM_cnt;
        FSM_state_q == FSM_state_q_READ_WEI:                 addr_SRAM_cnt_next = (global_cnt[2:0] == 3'd4) ? addr_SRAM_cnt_plus1 : addr_SRAM_cnt;
        FSM_state_q == FSM_state_q_WAIT:                     addr_SRAM_cnt_next = skip_rows;                
        FSM_state_q == FSM_state_q_GET_IDX:   addr_SRAM_cnt_next = (global_cnt[2:0] >= 3'd2) ? addr_SRAM_cnt : addr_SRAM_cnt + skip_rows;      
        FSM_state_q == FSM_state_q_CAL: begin 
            if (global_cnt[2:0] >= 3'd2) begin 
                addr_SRAM_cnt_next = addr_SRAM_cnt ;
            end else begin
                addr_SRAM_cnt_next = addr_SRAM_cnt + skip_rows;
            end
        end
        default: begin 
            addr_SRAM_cnt_next = 0;
        end
    endcase
end

assign set_num_cnt_plus1 = set_num_cnt + 4'd1;
always@(*) begin
    case (1)
        FSM_state_q == FSM_state_q_IDLE:     set_num_cnt_next = 0;
        FSM_state_q == FSM_state_q_READ_IMG: set_num_cnt_next = (addr_SRAM_cnt == addr_SRAM_cnt_bound && global_cnt[2:0] == 3'd7) ? set_num_cnt_plus1 : set_num_cnt;  
        FSM_state_q == FSM_state_q_WAIT: set_num_cnt_next = set_num_cnt;
        FSM_state_q == FSM_state_q_GET_IDX: set_num_cnt_next = set_num_cnt;
        FSM_state_q == FSM_state_q_CAL: set_num_cnt_next = set_num_cnt;
        FSM_state_q == FSM_state_q_OUTPUT: set_num_cnt_next = ((calc_global_cnt == global_cnt_nextum_of_output - 1) && (global_cnt[10:0] == num_out_values_sub1)) ? set_num_cnt_plus1 : set_num_cnt;
        default:    set_num_cnt_next = 0;
    endcase
end

always @(*) begin
    img_addr_q_output_stage = img_addr_q_2row_flag + img_addr_q_shift + img_addr_q_base;
end

always@(*) begin
    case (1)
        FSM_state_q == FSM_state_q_READ_IMG:     img_addr_q = {set_num_cnt, addr_SRAM_cnt};
        FSM_state_q == FSM_state_q_READ_WEI:     img_addr_q = {set_num_cnt, addr_SRAM_cnt};
        FSM_state_q == FSM_state_q_WAIT: begin
            if (in_valid2) img_addr_q = {matrix_idx, 7'd0};              
            else img_addr_q = 0;
        end
        FSM_state_q == FSM_state_q_GET_IDX:    img_addr_q = {img_idx_q, addr_SRAM_cnt};
        FSM_state_q == FSM_state_q_CAL:    img_addr_q = {img_idx_q, addr_SRAM_cnt};
        FSM_state_q == FSM_state_q_OUTPUT: begin                                     
            if (global_cnt[10:0] == num_out_values_sub1) img_addr_q = 0;
            else if (calc_global_cnt <= 5'd11) begin       
                img_addr_q = {img_idx_q, img_addr_q_output_stage};
            end
            else img_addr_q = 0;
        end
        default: img_addr_q = 0;
    endcase
end


always@(posedge clk) begin
    in_data_buf[0] <= in_data_buf_next[0];
    in_data_buf[1] <= in_data_buf_next[1];
    in_data_buf[2] <= in_data_buf_next[2];
    in_data_buf[3] <= in_data_buf_next[3];
    in_data_buf[4] <= in_data_buf_next[4];
    in_data_buf[5] <= in_data_buf_next[5];
    in_data_buf[6] <= in_data_buf_next[6];
    in_data_buf[7] <= in_data_buf_next[7];
    in_data_buf[8] <= in_data_buf_next[8];
    in_data_buf[9] <= in_data_buf_next[9];
    in_data_buf[10] <= in_data_buf_next[10];
    in_data_buf[11] <= in_data_buf_next[11];
end

always@(*) begin
    case (1) 
        FSM_state_q == FSM_state_q_IDLE: begin
            in_data_buf_next[7] = matrix;               
            in_data_buf_next[0] = in_data_buf[1];
            in_data_buf_next[1] = in_data_buf[2];
            in_data_buf_next[2] = in_data_buf[3];
            in_data_buf_next[3] = in_data_buf[4];
            in_data_buf_next[4] = in_data_buf[5];
            in_data_buf_next[5] = in_data_buf[6];
            in_data_buf_next[6] = in_data_buf[7];

            in_data_buf_next[8] = in_data_buf[8];
            in_data_buf_next[9] = in_data_buf[9];
            in_data_buf_next[10] = in_data_buf[10];
            in_data_buf_next[11] = in_data_buf[11];
        end
        FSM_state_q == FSM_state_q_READ_IMG: begin
            in_data_buf_next[7] = matrix;               
            in_data_buf_next[0] = in_data_buf[1];
            in_data_buf_next[1] = in_data_buf[2];
            in_data_buf_next[2] = in_data_buf[3];
            in_data_buf_next[3] = in_data_buf[4];
            in_data_buf_next[4] = in_data_buf[5];
            in_data_buf_next[5] = in_data_buf[6];
            in_data_buf_next[6] = in_data_buf[7];
            
            in_data_buf_next[8] = in_data_buf[8];
            in_data_buf_next[9] = in_data_buf[9];
            in_data_buf_next[10] = in_data_buf[10];
            in_data_buf_next[11] = in_data_buf[11];
        end
        FSM_state_q == FSM_state_q_READ_WEI: begin
            in_data_buf_next[7] = matrix;               
            in_data_buf_next[0] = in_data_buf[1];
            in_data_buf_next[1] = in_data_buf[2];
            in_data_buf_next[2] = in_data_buf[3];
            in_data_buf_next[3] = in_data_buf[4];
            in_data_buf_next[4] = in_data_buf[5];
            in_data_buf_next[5] = in_data_buf[6];
            in_data_buf_next[6] = in_data_buf[7];
            
            in_data_buf_next[8] = in_data_buf[8];
            in_data_buf_next[9] = in_data_buf[9];
            in_data_buf_next[10] = in_data_buf[10];
            in_data_buf_next[11] = in_data_buf[11];
        end

        FSM_state_q == FSM_state_q_WAIT: begin
            in_data_buf_next[0] = in_data_buf[0];
            in_data_buf_next[1] = in_data_buf[1];
            in_data_buf_next[2] = in_data_buf[2];
            in_data_buf_next[3] = in_data_buf[3];
            in_data_buf_next[4] = in_data_buf[4];
            in_data_buf_next[5] = in_data_buf[5];
            in_data_buf_next[6] = in_data_buf[6];
            in_data_buf_next[7] = in_data_buf[7];
            in_data_buf_next[8] = in_data_buf[8];
            in_data_buf_next[9] = in_data_buf[9];
            in_data_buf_next[10] = in_data_buf[10];
            in_data_buf_next[11] = in_data_buf[11];
        end

        FSM_state_q == FSM_state_q_GET_IDX: begin
            in_data_buf_next[0] = in_data_buf[6];
            in_data_buf_next[1] = in_data_buf[7];
            in_data_buf_next[2] = in_data_buf[8];
            in_data_buf_next[3] = in_data_buf[9];
            in_data_buf_next[4] = in_data_buf[10];
            in_data_buf_next[5] = in_data_buf[11];

            {in_data_buf_next[6], in_data_buf_next[7], in_data_buf_next[8], in_data_buf_next[9], in_data_buf_next[10], in_data_buf_next[11]} = img_data_out[63-:48];
        end
        
        FSM_state_q == FSM_state_q_CAL: begin
            in_data_buf_next[0] = in_data_buf[6];
            in_data_buf_next[1] = in_data_buf[7];
            in_data_buf_next[2] = in_data_buf[8];
            in_data_buf_next[3] = in_data_buf[9];
            for (i = 4;i<=5 ;i=i+1 ) begin
                in_data_buf_next [i] = in_data_buf[i+6] ;
            end
            {in_data_buf_next[6], in_data_buf_next[7], in_data_buf_next[8], in_data_buf_next[9], in_data_buf_next[10], in_data_buf_next[11]} = img_data_out[63-:48];
        end

        FSM_state_q == FSM_state_q_OUTPUT: begin
            if (calc_global_cnt[0]) begin
                in_data_buf_next[0] = in_data_buf[6];
                in_data_buf_next[1] = in_data_buf[7];
                in_data_buf_next[2] = in_data_buf[8];
                in_data_buf_next[3] = in_data_buf[9];
                in_data_buf_next[4] = in_data_buf[10];
                in_data_buf_next[5] = in_data_buf[11];
            end
            else begin
                in_data_buf_next[0] = in_data_buf[0];
                in_data_buf_next[1] = in_data_buf[1];
                in_data_buf_next[2] = in_data_buf[2];
                in_data_buf_next[3] = in_data_buf[3];
                in_data_buf_next[4] = in_data_buf[4];
                in_data_buf_next[5] = in_data_buf[5];
            end
            if (mode_q == conv_mode_q) begin
                case (1)
                    global_cnt_out_row[1:0] == 2'd0: begin
                        {in_data_buf_next[6], in_data_buf_next[7], in_data_buf_next[8], in_data_buf_next[9], in_data_buf_next[10], in_data_buf_next[11]} = img_data_out[63-:reg_length_forty_eight];
                    end
                    global_cnt_out_row[1:0] == 2'd1: begin
                        {in_data_buf_next[6], in_data_buf_next[7], in_data_buf_next[8], in_data_buf_next[9], in_data_buf_next[10], in_data_buf_next[11]} = img_data_out[reg_length_forty_eight-1:0];
                    end

                    global_cnt_out_row[1:0] == 2'd2: begin
                        if (calc_global_cnt[0]) begin
                            {in_data_buf_next[6], in_data_buf_next[7], in_data_buf_next[8], in_data_buf_next[9]} = img_data_out[31:0];
                            for (i = 10;i<=11 ;i=i+1 ) begin
                                in_data_buf_next[i] = in_data_buf[i] ;
                            end
                        end
                        else begin
                            for (i = 6; i<=9;i=i+1 ) in_data_buf_next[i] = in_data_buf[i];
                            {in_data_buf_next[10], in_data_buf_next[11]} = img_data_out[63-:16];
                        end
                    end
                    global_cnt_out_row[1:0] == 2'd3: begin
                        if (calc_global_cnt[0]) begin
                            {in_data_buf_next[6], in_data_buf_next[7]} = img_data_out[(8*2)-1:0];
                            {in_data_buf_next[8],in_data_buf_next[9],in_data_buf_next[10],in_data_buf_next[11]} = {in_data_buf[8],in_data_buf[9],in_data_buf[10],in_data_buf[11]};
                        end
                        else begin
                            for (i = 6; i<=7;i=i+1 ) begin
                                in_data_buf_next[i] = in_data_buf[i];
                            end
                            {in_data_buf_next[8], in_data_buf_next[9], in_data_buf_next[10], in_data_buf_next[11]} = img_data_out[63-:32];
                        end
                    end
                endcase
            end

            else begin
                for (i = 11;i<=11 ;i=i+1 ) begin
                    in_data_buf_next[i] = in_data_buf[i] ;
                end
                case (1)
                    global_cnt_out_row[2:0] == 3'd0: begin 
                        if (calc_global_cnt[0]) begin
                            {in_data_buf_next[6], in_data_buf_next[7], in_data_buf_next[8], in_data_buf_next[9]} = img_data_out[31:0];
                            for (i = 10;i<=10 ;i=i+1 ) begin
                                in_data_buf_next[i] = in_data_buf[i] ;
                            end
                        end
                        else begin
                            for (i = 6; i<=9;i=i+1 ) begin
                                in_data_buf_next[i] = in_data_buf[i];
                            end
                            in_data_buf_next[10] = img_data_out[63-:(8*1)];
                        end
                    end

                    global_cnt_out_row[2:0] == 3'd1: begin 
                        if (calc_global_cnt[0]) begin
                            {in_data_buf_next[6], in_data_buf_next[7], in_data_buf_next[8]} = img_data_out[23:0];
                            for (i = 9;i<=10 ;i=i+1 ) begin
                                in_data_buf_next[i] = in_data_buf[i] ;
                            end
                        end
                        else begin
                            for (i = 6;i<=8 ;i=i+1 ) begin
                                in_data_buf_next[i] = in_data_buf[i] ;
                            end
                            {in_data_buf_next[9], in_data_buf_next[10]} = img_data_out[63-:(8*2)];
                        end
                    end

                    global_cnt_out_row[2:0] == 3'd2: begin 
                        if (calc_global_cnt[0]) begin
                            {in_data_buf_next[6], in_data_buf_next[7]} = img_data_out[(8*2)-1:0];
                            for (i = 8;i<=10 ;i=i+1 ) begin
                                in_data_buf_next[i] = in_data_buf[i] ;
                            end
                        end
                        else begin
                            for (i =6;i<=7 ;i=i+1 ) begin
                                in_data_buf_next[i] = in_data_buf[i] ;
                            end
                            {in_data_buf_next[8], in_data_buf_next[9], in_data_buf_next[10]} = img_data_out[63-:24];
                        end
                    end

                    global_cnt_out_row[2:0] == 3'd3: begin 
                        if (calc_global_cnt[0]) begin 
                            in_data_buf_next[6] = img_data_out[(8*1)-1:0];
                            for (i = 7;i<=10 ;i=i+1 ) begin
                                in_data_buf_next[i] = in_data_buf[i] ;
                            end
                        end
                        else begin
                            in_data_buf_next[6] = in_data_buf[6];
                            {in_data_buf_next[7], in_data_buf_next[8], in_data_buf_next[9], in_data_buf_next[10]} = img_data_out[63-:32];
                        end
                    end

                    global_cnt_out_row[2:0] == 3'd4: begin 
                        {in_data_buf_next[6], in_data_buf_next[7], in_data_buf_next[8], in_data_buf_next[9], in_data_buf_next[10]} = img_data_out[(63)-:(40)];
                    end
                    global_cnt_out_row[2:0] == 3'd5: begin 
                        {in_data_buf_next[6], in_data_buf_next[7], in_data_buf_next[8], in_data_buf_next[9], in_data_buf_next[10]} = img_data_out[(55)-:(40)];
                    end
                    global_cnt_out_row[2:0] == 3'd6: begin 
                        {in_data_buf_next[6], in_data_buf_next[7], in_data_buf_next[8], in_data_buf_next[9], in_data_buf_next[10]} = img_data_out[(47)-:(40)];
                    end
                    global_cnt_out_row[2:0] == 3'd7: begin 
                        {in_data_buf_next[6], in_data_buf_next[7], in_data_buf_next[8], in_data_buf_next[9], in_data_buf_next[10]} = img_data_out[(39)-:(40)];
                    end
                    default: begin 
                        {in_data_buf_next[6], in_data_buf_next[7], in_data_buf_next[8], in_data_buf_next[9], in_data_buf_next[10]} = img_data_out[63-:(40)];
                    end
                endcase
            end
        end

        default: begin
            in_data_buf_next[0] = in_data_buf[0];
            in_data_buf_next[1] = in_data_buf[1];
            in_data_buf_next[2] = in_data_buf[2];
            in_data_buf_next[3] = in_data_buf[3];
            in_data_buf_next[4] = in_data_buf[4];
            in_data_buf_next[5] = in_data_buf[5];
            in_data_buf_next[6] = in_data_buf[6];
            in_data_buf_next[7] = in_data_buf[7];
            in_data_buf_next[8] = in_data_buf[8];
            in_data_buf_next[9] = in_data_buf[9];
            in_data_buf_next[10] = in_data_buf[10];
            in_data_buf_next[11] = in_data_buf[11];
        end

    endcase
end

always @(*) begin 
    img_data_in [7:0] = in_data_buf[7] ;
    img_data_in [15:8] = in_data_buf[6] ;
    img_data_in [23:16] = in_data_buf[5] ;
    img_data_in [31:24] = in_data_buf[4] ;
    img_data_in [39:32] = in_data_buf[3] ;
    img_data_in [47:40] = in_data_buf[2] ;
    img_data_in [55:48] = in_data_buf[1] ;
    img_data_in [63:56] = in_data_buf[0] ;
end


always @(*) begin
    weight_data_in = {in_data_buf[3], in_data_buf[4], in_data_buf[5], in_data_buf[6], in_data_buf[7]}; 
end

always@(posedge clk) kernel_addr_SRAM_cnt <= kernel_addr_SRAM_cnt_next;

always @(*) begin
    if (mode_q == conv_mode_q) begin 
        kernel_addr_start_point = (kernel_idx_q * 3'd5) ;
    end else begin
        kernel_addr_start_point = (kernel_idx_q * 3'd5 + 3'd4);
    end
end

always@(*) begin
    case (1)
        FSM_state_q == FSM_state_q_GET_IDX: begin
            if (global_cnt[0] == 0) begin 
                kernel_addr_SRAM_cnt_next = (matrix_idx * 3'd5) + 7'b1;
            end 
            else begin 
                kernel_addr_SRAM_cnt_next = kernel_addr_SRAM_cnt_plus1;
            end
        end

        FSM_state_q == FSM_state_q_CAL: begin
            if (global_cnt[2:0] == cycle_calc_1st_value_sub1) begin 
                kernel_addr_SRAM_cnt_next = kernel_addr_start_point;
            end
            else if (global_cnt[2:0] >= 3'd2) begin 
                kernel_addr_SRAM_cnt_next = kernel_addr_SRAM_cnt;
            end
            else begin 
                kernel_addr_SRAM_cnt_next = kernel_addr_SRAM_cnt_plus1;
            end
        end

        FSM_state_q == FSM_state_q_OUTPUT: begin
            if (calc_global_cnt == global_cnt_nextum_of_output - 1) begin 
                kernel_addr_SRAM_cnt_next = kernel_addr_start_point;
            end
            else if (calc_global_cnt >= 5'd12) begin                           
                kernel_addr_SRAM_cnt_next = 0;
            end
            else if ((~calc_global_cnt[0]) && (calc_global_cnt > 5'd3)) begin 
                if (mode_q == conv_mode_q) begin 
                    kernel_addr_SRAM_cnt_next = kernel_addr_SRAM_cnt_plus1 ;
                end else begin
                    kernel_addr_SRAM_cnt_next = kernel_addr_SRAM_cnt_dec ;
                end
            end
            else begin 
                kernel_addr_SRAM_cnt_next = kernel_addr_SRAM_cnt;
            end
        end
        default: begin 
            kernel_addr_SRAM_cnt_next = 0;
        end
    endcase
end


always@(*) begin
    case (1)
        FSM_state_q == FSM_state_q_READ_WEI: weight_addr = addr_SRAM_cnt;

        FSM_state_q == FSM_state_q_GET_IDX: begin
            if (global_cnt[0] == 1'b0)
                weight_addr = matrix_idx * 3'd5;
            else
                weight_addr = kernel_addr_SRAM_cnt;
        end

        FSM_state_q == FSM_state_q_CAL : begin         
            weight_addr = kernel_addr_SRAM_cnt;
        end
        FSM_state_q ==  FSM_state_q_OUTPUT: begin         
            weight_addr = kernel_addr_SRAM_cnt;
        end
        default:    weight_addr = 0;
    endcase
end

always@(posedge clk) begin
    kernel[0] <= kernel_next[0];
    kernel[1] <= kernel_next[1];
    kernel[2] <= kernel_next[2];
    kernel[3] <= kernel_next[3];
    kernel[4] <= kernel_next[4];
end

assign num_remaing_rows = rows_cnt_sub1_next - global_cnt_complete_rows;
assign num_remaing_out_this_row = row_cnt_sub1 - global_cnt_out_row;


always@(*) begin
    case (1)
        FSM_state_q == FSM_state_q_GET_IDX: begin
            if (global_cnt[2:0] >= global_cnt_nextum_of_cal_m0 - 2) begin  
                kernel_next[0] = 0;
                kernel_next[1] = 0;
                kernel_next[2] = 0;
                kernel_next[3] = 0;
                kernel_next[4] = 0;
            end
            else begin
                {kernel_next[0], kernel_next[1], kernel_next[2], kernel_next[3], kernel_next[4]} = weight_data_out;
            end
        end

        FSM_state_q == FSM_state_q_CAL: begin
            if (global_cnt[2:0] >= global_cnt_nextum_of_cal_m0 - 2) begin   
                kernel_next[0] = 0;
                kernel_next[1] = 0;
                kernel_next[2] = 0;
                kernel_next[3] = 0;
                kernel_next[4] = 0;
            end
            else begin
                {kernel_next[0], kernel_next[1], kernel_next[2], kernel_next[3], kernel_next[4]} = weight_data_out;
            end
        end

        FSM_state_q == FSM_state_q_OUTPUT: begin
            if (mode_q == conv_mode_q) begin
                if (calc_global_cnt == 4'd4) begin
                    {kernel_next[0], kernel_next[1], kernel_next[2], kernel_next[3], kernel_next[4]} = weight_data_out;
                end
                else if (calc_global_cnt == 4'd6) begin
                    {kernel_next[0], kernel_next[1], kernel_next[2], kernel_next[3], kernel_next[4]} = weight_data_out;
                end
                else if (calc_global_cnt == 4'd8) begin
                    {kernel_next[0], kernel_next[1], kernel_next[2], kernel_next[3], kernel_next[4]} = weight_data_out;
                end
                else if (calc_global_cnt == 4'd10) begin
                    {kernel_next[0], kernel_next[1], kernel_next[2], kernel_next[3], kernel_next[4]} = weight_data_out;
                end
                else if (calc_global_cnt == 4'd12) begin
                    {kernel_next[0], kernel_next[1], kernel_next[2], kernel_next[3], kernel_next[4]} = weight_data_out;
                end
                else begin
                    kernel_next[0] = 0;
                    kernel_next[1] = 0;
                    kernel_next[2] = 0;
                    kernel_next[3] = 0;
                    kernel_next[4] = 0;
                end
            end

            else begin
                if (global_cnt_complete_rows < 6'd4) begin
                    case (1)
                        global_cnt_complete_rows[1:0] == 2'd0: begin 
                            if (calc_global_cnt == 4'd12) begin
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = weight_data_out ;
                            end else begin
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = 40'b0 ;
                            end
                        end
                        global_cnt_complete_rows[1:0] == 2'd1: begin 
                            if (calc_global_cnt == 4'd10 || calc_global_cnt == 4'd12) begin 
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = weight_data_out ;
                            end else begin
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = 40'b0 ;
                            end
                        end
                        global_cnt_complete_rows[1:0] == 2'd2: begin 
                            if (calc_global_cnt == 4'd8 || calc_global_cnt == 4'd10 || calc_global_cnt == 4'd12) begin 
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = weight_data_out ;
                            end else begin
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = 40'b0 ;
                            end
                        end
                        global_cnt_complete_rows[1:0] == 2'd3: begin 
                            if (calc_global_cnt == 4'd6 || calc_global_cnt == 4'd8 || calc_global_cnt == 4'd10 || calc_global_cnt == 4'd12) begin
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = weight_data_out ;
                            end else begin
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = 40'b0 ;
                            end
                        end
                    endcase
                end
                else if (num_remaing_rows < 6'd4) begin
                    case (1)
                        num_remaing_rows[1:0] == 2'd3: begin 
                            if (calc_global_cnt == 4'd4 || calc_global_cnt == 4'd6 || calc_global_cnt == 4'd8 || calc_global_cnt == 4'd10) begin 
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = weight_data_out ;
                            end else begin
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = 40'b0 ;
                            end
                        end
                        num_remaing_rows[1:0] == 2'd2: begin 
                            if (calc_global_cnt == 4'd4 || calc_global_cnt == 4'd6 || calc_global_cnt == 4'd8) begin
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = weight_data_out ;
                            end else begin
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = 40'b0 ;
                            end
                        end
                        num_remaing_rows[1:0] == 2'd1: begin 
                            if (calc_global_cnt == 4'd4 || calc_global_cnt == 4'd6) begin 
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = weight_data_out ;
                            end else begin 
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = 40'b0 ;
                            end 
                        end
                        num_remaing_rows[1:0] == 2'd0: begin 
                            if (calc_global_cnt == 4'd4) begin
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = weight_data_out ;
                            end else begin
                                {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = 40'b0 ;
                            end
                        end
                    endcase
                end
                else begin
                    if ((calc_global_cnt == 4'd4)) begin
                        {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = weight_data_out ;
                    end
                    else if (calc_global_cnt == 4'd6) begin
                        {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = weight_data_out ;
                    end
                    else if (calc_global_cnt == 4'd8) begin
                        {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = weight_data_out ;
                    end
                    else if (calc_global_cnt == 4'd10) begin
                        {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = weight_data_out ;
                    end 
                    else if (calc_global_cnt == 4'd12) begin
                        {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = weight_data_out ;
                    end
                    else begin
                        {kernel_temp[4], kernel_temp[3], kernel_temp[2], kernel_temp[1], kernel_temp[0]} = 40'b0 ;
                    end
                end

                if (global_cnt_out_row < 6'd4) begin
                    case (1)
                        global_cnt_out_row[1:0] == 2'd0: begin 
                            kernel_next[0] = 8'b0;
                            kernel_next[1] = 8'b0;
                            kernel_next[2] = 8'b0;
                            kernel_next[3] = 8'b0;
                            kernel_next[4] = kernel_temp[4];
                        end
                        global_cnt_out_row[1:0] == 2'd1: begin 
                            kernel_next[0] = 8'b0;
                            kernel_next[1] = 8'b0;
                            kernel_next[2] = 8'b0;
                            kernel_next[3] = kernel_temp[3];
                            kernel_next[4] = kernel_temp[4];
                        end
                        global_cnt_out_row[1:0] == 2'd2: begin 
                            kernel_next[0] = 8'b0;
                            kernel_next[1] = 8'b0;
                            kernel_next[2] = kernel_temp[2];
                            kernel_next[3] = kernel_temp[3];
                            kernel_next[4] = kernel_temp[4];
                        end
                        global_cnt_out_row[1:0] == 2'd3: begin 
                            kernel_next[0] = 8'b0;
                            kernel_next[1] = kernel_temp[1];
                            kernel_next[2] = kernel_temp[2];
                            kernel_next[3] = kernel_temp[3];
                            kernel_next[4] = kernel_temp[4];
                        end
                    endcase
                end
                else if (num_remaing_out_this_row < 6'd4) begin
                    case (1)
                        num_remaing_out_this_row[1:0] == 2'd3: begin 
                            kernel_next[0] = kernel_temp[0];
                            kernel_next[1] = kernel_temp[1];
                            kernel_next[2] = kernel_temp[2];
                            kernel_next[3] = kernel_temp[3];
                            kernel_next[4] = 0;
                        end
                        num_remaing_out_this_row[1:0] == 2'd2: begin 
                            kernel_next[0] = kernel_temp[0];
                            kernel_next[1] = kernel_temp[1];
                            kernel_next[2] = kernel_temp[2];
                            kernel_next[3] = 8'b0;
                            kernel_next[4] = 8'b0;
                        end
                        num_remaing_out_this_row[1:0] == 2'd1: begin 
                            kernel_next[0] = kernel_temp[0];
                            kernel_next[1] = kernel_temp[1];
                            kernel_next[2] = 8'b0;
                            kernel_next[3] = 8'b0;
                            kernel_next[4] = 8'b0;
                        end
                        num_remaing_out_this_row[1:0] == 2'd0: begin 
                            kernel_next[0] = kernel_temp[0];
                            kernel_next[1] = 8'b0;
                            kernel_next[2] = 8'b0;
                            kernel_next[3] = 8'b0;
                            kernel_next[4] = 8'b0;
                        end
                    endcase
                end
                else for (i = 0; i <= 4; i = i + 1) kernel_next[i] = kernel_temp[i];
            end
        end

        default: begin
            kernel_next[0] = 0;
            kernel_next[1] = 0;
            kernel_next[2] = 0;
            kernel_next[3] = 0;
            kernel_next[4] = 0;
        end
    endcase
end


always@(posedge clk) begin
    output_result_q <= output_result_q_next;
end

always@(posedge clk) begin
    hidden_map[0] <= hidden_map_next[0];
    hidden_map[1] <= hidden_map_next[1];
    hidden_map[2] <= hidden_map_next[2];
    hidden_map[3] <= hidden_map_next[3];
end

always@(*) begin
    mul_in_a[0][0] = in_data_buf[0];
    mul_in_a[0][1] = in_data_buf[1];
    mul_in_a[0][2] = in_data_buf[2];
    mul_in_a[0][3] = in_data_buf[3];
    mul_in_a[0][4] = in_data_buf[4];
    mul_in_a[1][0] = in_data_buf[1];
    mul_in_a[1][1] = in_data_buf[2];
    mul_in_a[1][2] = in_data_buf[3];
    mul_in_a[1][3] = in_data_buf[4];
    mul_in_a[1][4] = in_data_buf[5];
    mul_in_a[2][0] = in_data_buf[6];
    mul_in_a[2][1] = in_data_buf[7];
    mul_in_a[2][2] = in_data_buf[8];
    mul_in_a[2][3] = in_data_buf[9];
    mul_in_a[2][4] = in_data_buf[10];
    mul_in_a[3][0] = in_data_buf[7];
    mul_in_a[3][1] = in_data_buf[8];
    mul_in_a[3][2] = in_data_buf[9];
    mul_in_a[3][3] = in_data_buf[10];
    mul_in_a[3][4] = in_data_buf[11];

    mul_in_b[0][0] = kernel[0];
    mul_in_b[0][1] = kernel[1];
    mul_in_b[0][2] = kernel[2];
    mul_in_b[0][3] = kernel[3];
    mul_in_b[0][4] = kernel[4];
    mul_in_b[1][0] = kernel[0];
    mul_in_b[1][1] = kernel[1];
    mul_in_b[1][2] = kernel[2];
    mul_in_b[1][3] = kernel[3];
    mul_in_b[1][4] = kernel[4];
    mul_in_b[2][0] = kernel[0];
    mul_in_b[2][1] = kernel[1];
    mul_in_b[2][2] = kernel[2];
    mul_in_b[2][3] = kernel[3];
    mul_in_b[2][4] = kernel[4];
    mul_in_b[3][0] = kernel[0];
    mul_in_b[3][1] = kernel[1];
    mul_in_b[3][2] = kernel[2];
    mul_in_b[3][3] = kernel[3];
    mul_in_b[3][4] = kernel[4];

    product[0][0] = mul_in_a[0][0] * mul_in_b[0][0];
    product[0][1] = mul_in_a[0][1] * mul_in_b[0][1];
    product[0][2] = mul_in_a[0][2] * mul_in_b[0][2];
    product[0][3] = mul_in_a[0][3] * mul_in_b[0][3];
    product[0][4] = mul_in_a[0][4] * mul_in_b[0][4];
    product[1][0] = mul_in_a[1][0] * mul_in_b[1][0];
    product[1][1] = mul_in_a[1][1] * mul_in_b[1][1];
    product[1][2] = mul_in_a[1][2] * mul_in_b[1][2];
    product[1][3] = mul_in_a[1][3] * mul_in_b[1][3];
    product[1][4] = mul_in_a[1][4] * mul_in_b[1][4];
    product[2][0] = mul_in_a[2][0] * mul_in_b[2][0];
    product[2][1] = mul_in_a[2][1] * mul_in_b[2][1];
    product[2][2] = mul_in_a[2][2] * mul_in_b[2][2];
    product[2][3] = mul_in_a[2][3] * mul_in_b[2][3];
    product[2][4] = mul_in_a[2][4] * mul_in_b[2][4];
    product[3][0] = mul_in_a[3][0] * mul_in_b[3][0];
    product[3][1] = mul_in_a[3][1] * mul_in_b[3][1];
    product[3][2] = mul_in_a[3][2] * mul_in_b[3][2];
    product[3][3] = mul_in_a[3][3] * mul_in_b[3][3];
    product[3][4] = mul_in_a[3][4] * mul_in_b[3][4];

end

always@(*) begin
    if (FSM_state_q == FSM_state_q_CAL) begin
        prev_partial_sum[0] = (global_cnt[2:0] == cycle_calc_1st_value_sub1) ? 0 : hidden_map[0];
        prev_partial_sum[1] = (global_cnt[2:0] == cycle_calc_1st_value_sub1) ? 0 : hidden_map[1];
        prev_partial_sum[2] = (global_cnt[2:0] == cycle_calc_1st_value_sub1) ? 0 : hidden_map[2];
        prev_partial_sum[3] = (global_cnt[2:0] == cycle_calc_1st_value_sub1) ? 0 : hidden_map[3];
    end
    else begin
        prev_partial_sum[0] = (calc_global_cnt < 6'd5 || calc_global_cnt == global_cnt_nextum_of_output - 1) ? 0 : hidden_map[0];
        prev_partial_sum[1] = (calc_global_cnt < 6'd5 || calc_global_cnt == global_cnt_nextum_of_output - 1) ? 0 : hidden_map[1];
        prev_partial_sum[2] = (calc_global_cnt < 6'd5 || calc_global_cnt == global_cnt_nextum_of_output - 1) ? 0 : hidden_map[2];
        prev_partial_sum[3] = (calc_global_cnt < 6'd5 || calc_global_cnt == global_cnt_nextum_of_output - 1) ? 0 : hidden_map[3];
    end
end

always@(*) begin
    if (FSM_state_q == FSM_state_q_CAL) begin
        hidden_map_next[0] = product[0][0] + product[0][1] + product[0][2] + product[0][3] + product[0][4] + prev_partial_sum[0];
        hidden_map_next[1] = product[1][0] + product[1][1] + product[1][2] + product[1][3] + product[1][4] + prev_partial_sum[1];
        hidden_map_next[2] = product[2][0] + product[2][1] + product[2][2] + product[2][3] + product[2][4] + prev_partial_sum[2];
        hidden_map_next[3] = product[3][0] + product[3][1] + product[3][2] + product[3][3] + product[3][4] + prev_partial_sum[3];
    end
    else if (FSM_state_q == FSM_state_q_OUTPUT) begin
        hidden_map_next[0] = product[0][0] + product[0][1] + product[0][2] + product[0][3] + product[0][4] + prev_partial_sum[0];
        hidden_map_next[1] = product[1][0] + product[1][1] + product[1][2] + product[1][3] + product[1][4] + prev_partial_sum[1];
        hidden_map_next[2] = product[2][0] + product[2][1] + product[2][2] + product[2][3] + product[2][4] + prev_partial_sum[2];
        hidden_map_next[3] = product[3][0] + product[3][1] + product[3][2] + product[3][3] + product[3][4] + prev_partial_sum[3];
    end
    else begin
        hidden_map_next[0] = 0;
        hidden_map_next[1] = 0;
        hidden_map_next[2] = 0;
        hidden_map_next[3] = 0;
    end
end

always@(posedge clk) begin
    next_output_result_q <= next_output_result_q_next;
end

always@(*) begin
    if (mode_q == conv_mode_q) 
    begin
        if (calc_global_cnt == global_cnt_nextum_of_save_m0)
        begin 
            next_output_result_q_next = cmp_max_num ;
        end
        else 
        begin 
            next_output_result_q_next = next_output_result_q ;
        end
    end
    else
    begin
        if (calc_global_cnt == global_cnt_nextum_of_save_m1) 
        begin 
            next_output_result_q_next = hidden_map[0] ;
        end 
        else 
        begin 
            next_output_result_q_next = next_output_result_q ;
        end
    end
end

always@(*) begin
    if (hidden_map[0] > hidden_map[1]) begin
        cmp_max_num_0 = hidden_map[0];
    end else begin
        cmp_max_num_0 = hidden_map[1];
    end
end

always@(*) begin
    if (hidden_map[2] > hidden_map[3]) begin
        cmp_max_num_1 = hidden_map[2];
    end else begin
        cmp_max_num_1 = hidden_map[3];
    end
end

always@(*) begin
    if (cmp_max_num_0 > cmp_max_num_1) begin
        cmp_max_num = cmp_max_num_0;
    end else begin
        cmp_max_num = cmp_max_num_1;
    end
end

always@(*) 
begin
    case (1) 
        FSM_state_q == FSM_state_q_CAL :
        begin
            if (mode_q == conv_mode_q) 
            begin
                output_result_q_next = cmp_max_num;      
            end
            else
            begin
                output_result_q_next = product[0][0];
            end
        end
        FSM_state_q == FSM_state_q_OUTPUT : 
        begin
            if (calc_global_cnt == global_cnt_nextum_of_output - 1) 
            begin 
                output_result_q_next = next_output_result_q ;
            end 
            else 
            begin
                output_result_q_next = output_result_q;
            end
        end
        default : 
        begin
            output_result_q_next = 0;
        end
    endcase
end

always@(*) 
begin
    case (1) 
        FSM_state_q == FSM_state_q_READ_IMG : img_SRAM_we = (global_cnt[2:0] == 3'd7) ? 1'b0 : 1'b1;
        default : img_SRAM_we = 1'b1;
    endcase
end

always@(*) 
begin
    case (1) 
        FSM_state_q == FSM_state_q_READ_WEI : weight_SRAM_we = (global_cnt[2:0] == 3'd4) ? 1'b0 : 1'b1;
        default : weight_SRAM_we = 1'b1;
    endcase
end

always@(posedge clk or negedge rst_n) 
begin
    if (~rst_n) 
    begin 
        out_valid <= 'b0;
        out_value <= 'b0;
    end 
    else 
    begin
        out_valid <= out_valid_next;
        out_value <= out_value_next;
    end
end

always@(*) begin
    if (FSM_state_q == FSM_state_q_CAL) begin
        if (global_cnt[2:0] == cycle_calc_1st_value_sub1) begin
            out_value_next = output_result_q_next[0] ;
        end else begin
            out_value_next = 0;
        end
    end
    else if (FSM_state_q == FSM_state_q_OUTPUT) begin
        if ((calc_global_cnt == global_cnt_nextum_of_output - 1) ) begin
            if ((global_cnt[10:0] == num_out_values_sub1)) begin
                out_value_next = 0;
            end else begin
                case (1)
                    calc_global_cnt[4:0] == 5'd0: out_value_next = output_result_q[1];
                    calc_global_cnt[4:0] == 5'd1: out_value_next = output_result_q[2];
                    calc_global_cnt[4:0] == 5'd2: out_value_next = output_result_q[3];
                    calc_global_cnt[4:0] == 5'd3: out_value_next = output_result_q[4];
                    calc_global_cnt[4:0] == 5'd4: out_value_next = output_result_q[5];
                    calc_global_cnt[4:0] == 5'd5: out_value_next = output_result_q[6];
                    calc_global_cnt[4:0] == 5'd6: out_value_next = output_result_q[7];
                    calc_global_cnt[4:0] == 5'd7: out_value_next = output_result_q[8];
                    calc_global_cnt[4:0] == 5'd8: out_value_next = output_result_q[9];
                    calc_global_cnt[4:0] == 5'd9: out_value_next = output_result_q[10];
                    calc_global_cnt[4:0] == 5'd10: out_value_next = output_result_q[11];
                    calc_global_cnt[4:0] == 5'd11: out_value_next = output_result_q[12];
                    calc_global_cnt[4:0] == 5'd12: out_value_next = output_result_q[13];
                    calc_global_cnt[4:0] == 5'd13: out_value_next = output_result_q[14];
                    calc_global_cnt[4:0] == 5'd14: out_value_next = output_result_q[15];
                    calc_global_cnt[4:0] == 5'd15: out_value_next = output_result_q[16];
                    calc_global_cnt[4:0] == 5'd16: out_value_next = output_result_q[17];
                    calc_global_cnt[4:0] == 5'd17: out_value_next = output_result_q[18];
                    calc_global_cnt[4:0] == 5'd18: out_value_next = output_result_q[19];
                    calc_global_cnt[4:0] == 5'd19: out_value_next = next_output_result_q[0];
                    default: out_value_next = 0;
                endcase
            end
        end else begin
            case (1)
                calc_global_cnt[4:0] == 5'd0: out_value_next = output_result_q[1];
                calc_global_cnt[4:0] == 5'd1: out_value_next = output_result_q[2];
                calc_global_cnt[4:0] == 5'd2: out_value_next = output_result_q[3];
                calc_global_cnt[4:0] == 5'd3: out_value_next = output_result_q[4];
                calc_global_cnt[4:0] == 5'd4: out_value_next = output_result_q[5];
                calc_global_cnt[4:0] == 5'd5: out_value_next = output_result_q[6];
                calc_global_cnt[4:0] == 5'd6: out_value_next = output_result_q[7];
                calc_global_cnt[4:0] == 5'd7: out_value_next = output_result_q[8];
                calc_global_cnt[4:0] == 5'd8: out_value_next = output_result_q[9];
                calc_global_cnt[4:0] == 5'd9: out_value_next = output_result_q[10];
                calc_global_cnt[4:0] == 5'd10: out_value_next = output_result_q[11];
                calc_global_cnt[4:0] == 5'd11: out_value_next = output_result_q[12];
                calc_global_cnt[4:0] == 5'd12: out_value_next = output_result_q[13];
                calc_global_cnt[4:0] == 5'd13: out_value_next = output_result_q[14];
                calc_global_cnt[4:0] == 5'd14: out_value_next = output_result_q[15];
                calc_global_cnt[4:0] == 5'd15: out_value_next = output_result_q[16];
                calc_global_cnt[4:0] == 5'd16: out_value_next = output_result_q[17];
                calc_global_cnt[4:0] == 5'd17: out_value_next = output_result_q[18];
                calc_global_cnt[4:0] == 5'd18: out_value_next = output_result_q[19];
                calc_global_cnt[4:0] == 5'd19: out_value_next = next_output_result_q[0];
                default: out_value_next = 0;
            endcase
        end
    end
    else out_value_next = 0;
end

always@(*) begin
    case (1)
        FSM_state_q == FSM_state_q_CAL: out_valid_next = (global_cnt[2:0] == cycle_calc_1st_value_sub1) ? 1'b1 : 1'b0;
        FSM_state_q == FSM_state_q_OUTPUT: begin
            if ((calc_global_cnt == global_cnt_nextum_of_output - 1))begin
                if ((global_cnt[10:0] == num_out_values_sub1)) out_valid_next = 0;
                else out_valid_next = 1;
            end
            else out_valid_next = 1;
        end
        default:    out_valid_next = 0;
    endcase
end

endmodule