// TODO : reuse cnt of inst and data 
// TODO data_addr_idx less one bit
//! READ : WEB=1  WRITE : WEB=0 ; 
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//                           o
//                        oo000oo
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

module CPU(
    clk,
    rst_n,

    IO_stall,

    awid_m_inf,
    awaddr_m_inf,
    awsize_m_inf,
    awburst_m_inf,
    awlen_m_inf,
    awvalid_m_inf,
    awready_m_inf,

    wdata_m_inf,
    wlast_m_inf,
    wvalid_m_inf,
    wready_m_inf,

    bid_m_inf,
    bresp_m_inf,
    bvalid_m_inf,
    bready_m_inf,

    arid_m_inf,
    araddr_m_inf,
    arlen_m_inf,
    arsize_m_inf,
    arburst_m_inf,
    arvalid_m_inf,

    arready_m_inf, 
    rid_m_inf,
    rdata_m_inf,
    rresp_m_inf,
    rlast_m_inf,
    rvalid_m_inf,
    rready_m_inf 
);
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
therefore I declared output of AXI as wire in CPU
*/

// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  reg [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf; // 32 bits only for data DRAM 
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  reg [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  reg [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel 
output  reg [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  reg [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  reg [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf; // no use
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
//! ARADDR [63:32] is the address port for DRAM_inst
//! ARADDR [31:0 ] is the address port for DRAM_data
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf; // 64 bits 
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf; // 14 bits
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf; // 6 bits
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf; // 4 bits
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
// ! rdata_m_inf [31:16] is the data port for DRAM_inst
// ! rdata_m_inf [15:0 ] is the data port for DRAM_data
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf; // 32 bits
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------
reg rlast_inst , rlast_data ;
always @(*) begin
    {rlast_inst , rlast_data} = rlast_m_inf ;
end

reg rlast_inst_q , rlast_data_q ;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rlast_inst_q <= 0 ;
        rlast_data_q <= 0 ;
    end else begin 
        rlast_inst_q <= rlast_inst ;
        rlast_data_q <= rlast_data ;
    end
end

reg [15:0] rdata_inst , rdata_data ;
always @(*) begin
    {rdata_inst , rdata_data} = rdata_m_inf;
end

reg [15:0] rdata_inst_q , rdata_data_q ;
always @(posedge clk or negedge rst_n) begin // TODO : reuse DFF 
    if (~rst_n) begin
        rdata_inst_q <= 0 ;
        rdata_data_q <= 0 ;
    end else begin 
        rdata_inst_q <= rdata_inst ;
        rdata_data_q <= rdata_data ;
    end
end

reg [11:0] araddr_inst , araddr_data ;
// TODO : frame num decode , and reduce bits num of araddr_inst and araddr_data
assign araddr_m_inf = {20'b0000_0000_0000_0000_0001 , araddr_inst , 20'b0000_0000_0000_0000_0001 , araddr_data} ;

reg arvalid_inst , arvalid_data ;
assign arvalid_m_inf = {arvalid_inst , arvalid_data} ;

reg arready_inst , arready_data ;
always @(*) begin
    {arready_inst , arready_data} = arready_m_inf ;
end

reg rvalid_inst , rvalid_data ;
always @(*) begin
    {rvalid_inst , rvalid_data} = rvalid_m_inf ;
end

reg rready_inst , rready_data ;
assign rready_m_inf = {rready_inst , rready_data} ;

reg rready_inst_q , rready_data_q ;
always @(posedge clk or negedge rst_n) begin //! can't move rst_n
    if (~rst_n) begin 
        rready_inst_q <= 0 ;
        rready_data_q <= 0 ;
    end else begin 
        rready_inst_q <= (rready_inst && rvalid_inst);
        rready_data_q <= (rready_data && rvalid_data);
    end
end

//! addr range is 0x0000_1000 ~ 0x0000_1FFF
//! start from 0000_0000_0000_0000_0001_0000_0000_0000
//! end   to   0000_0000_0000_0000_0001_1111_1111_1111



/*
0: 0b0000_0000
128 : 0b00_1000_0000
256 : 0b01_0000_0000 
512 : 0b10_0000_0000
*/
// Register in each core:
//   There are sixteen registers in your CPU. You should not change the name of those registers.
//   TA will check the value in each register when your core is not busy.
//   If you change the name of registers below, you must get the fail in this lab.

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;

// reg signed [15:0] core_r0_next , core_r1_next , core_r2_next , core_r3_next ;
// reg signed [15:0] core_r4_next , core_r5_next , core_r6_next , core_r7_next ;
// reg signed [15:0] core_r8_next , core_r9_next , core_r10_next, core_r11_next;
// reg signed [15:0] core_r12_next, core_r13_next, core_r14_next, core_r15_next;

//-------------------
// Declare parameters
//-------------------
//* flags
reg first_inst_read_request_flag , first_data_read_request_flag ;
reg inst_cache_is_empty_flag , data_cache_is_empty_flag ;
reg AW_request_flag ; 
reg store_miss_flag ;
reg load_miss_flag ;

//* parameter
parameter READ_WEB=1'b1 , WRITE_WEB=1'b0 ;

//* SRAM ports
reg [7:0] SRAM_addr_d ; // 0 ~ 256
reg [15:0] SRAM_data_in_d ;
reg [15:0] SRAM_data_out_q ;
wire [15:0] SRAM_data_out_d ;
reg SRAM_WEB_q ;
reg valid_inst_flag ;
reg [15:0] valid_inst_q ;
reg [10:0] single_WB_addr_idx ;
reg [10:0] single_WB_addr_idx_store_miss ;

//* cache info
reg [3:0] inst_frame , data_frame ; // 0 ~ 15 , total 16 frames
reg [6:0] inst_cache_addr_cnt ; // 0 ~ 127 
reg [6:0] data_cache_addr_cnt ; // 0 ~ 127
reg cache_delay_cnt ;

//* control signals
reg [10:0] program_counter; // 0 ~ 2047
reg [10:0] program_counter_minus_1 ; // 0 ~ 2047
reg [10:0] program_counter_next_start ; // 0 ~ 2047

//* inst_decode signals
reg signed [4:0] immediate ;

//* decode 
reg signed [15:0] ALU_register_RS , ALU_register_RT , ALU_register_RD ;
reg [2:0] uniqle_opcode ;
reg [3:0] ALU_register_RD_idx ;
reg [3:0] ten_inst_cnt ; //! 0 ~ 9 
reg [3:0] coeff_A ;
reg [3:0] coeff_B_upper_4_bits ;
reg [8:0] coeff_B ;

//* ALU
reg [6:0] data_addr_idx_q ;
reg data_cache_HIT ;
reg inst_cache_HIT ;
reg [10:0] data_addr_idx ;
reg signed [68:0] det_temp_d , det_temp_d2 ;
reg signed [15:0] det_temp_q ;
reg signed [15:0] ADDER_out_d ;//, ADDER_out_q ;
reg signed [15:0] SUBTRACTOR_out_d ;//, SUBTRACTOR_out_q ;
wire signed [31:0] multiplier_out_dwip ;
reg signed [15:0] multiplier_out_d ;//, multiplier_out_q ;
// reg signed [15:0] CMP_in1 /*rs*/, CMP_in2 /*rt*/;
reg CMP_out_d ;

reg signed [15:0] det_g1_in1 , det_g1_in2 , det_g1_in3 , det_g1_in4 ;
wire signed [31:0] det_g1_out_1_d , det_g1_out_2_d ;
reg signed [31:0] det_g1_out_1_q , det_g1_out_2_q ;
wire signed [63:0] det_g1_out_dwip ;
reg signed [15:0] det_g2_in1 , det_g2_in2 , det_g2_in3 , det_g2_in4 ;
wire signed [31:0] det_g2_out_1_d , det_g2_out_2_d ;
reg signed [31:0] det_g2_out_1_q , det_g2_out_2_q ;
wire signed [63:0] det_g2_out_dwip ;
reg signed [63:0] det_sub_a_q , det_sub_b_q ;
reg signed [64:0] det_sub_out_q ;
reg signed [68:0] det_accumulator_q ;

reg [10:0] branch_pc ;
reg branch_has_jump_flag ;

//* State switch 
reg dirty_flag ;
reg multi_dirty_flag ;
reg branch_equal_flag ;

localparam  Opcode_ADD              = 3'd0 , 
            Opcode_SUB              = 3'd1 ,
            Opcode_LOAD             = 3'd2 ,
            Opcode_STORE            = 3'd3 ,
            Opcode_BRANCH           = 3'd4 ,
            Opcode_Set_less_than    = 3'd5 ,
            Opcode_MULT             = 3'd6 ,
            Opcode_DET              = 3'd7 ;

reg [4:0] det_cal_cnt ; // 0 ~ 11

//-------------------
// AXI constants
//-------------------
// write
assign awid_m_inf = 'd0;
assign awsize_m_inf = 3'b001;
assign awburst_m_inf = 2'b01;
// assign awlen_m_inf = 7'd0;

// read
assign arid_m_inf = 'd0;
assign arlen_m_inf = {7'b111_1111,7'b111_1111}; // 128 burst
assign arsize_m_inf = {3'b001,3'b001};
assign arburst_m_inf = {2'b01,2'b01};

//-------------------
// Finit State Machine 
//-------------------
reg [3:0] CPU_state_q , CPU_state_d ; // 0 ~ 15
localparam  S_cache_empty_and_fetch_first_inst  = 4'd0 ,
            S_inst_burst_write                  = 4'd1 ,
            S_data_burst_write                  = 4'd2 ,
            S_stall_or_write_inst               = 4'd3 ,
            S_decode_and_prefetch               = 4'd4 ,
            S_determinant_exe                   = 4'd5 ,
            S_exe                               = 4'd6 ,
            S_read_data_cache                   = 4'd7 ,
            S_write_data_cache                  = 4'd8 ,
            S_write_back_single                 = 4'd9 ,
            S_write_back_burst                  = 4'd10,
            S_memory_access                     = 4'd11,
            S_load_miss                         = 4'd12,
            S_update_pc                         = 4'd13,
            S_inst_miss                         = 4'd14,
            S_mult_stall                        = 4'd15;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        CPU_state_q <= S_cache_empty_and_fetch_first_inst ;
    end else begin
        CPU_state_q <= CPU_state_d ;
    end
end 

always @(*) begin
    case (CPU_state_q)
        S_cache_empty_and_fetch_first_inst: begin
            if (rvalid_inst) begin
                CPU_state_d = S_inst_burst_write ;
            end else if (rvalid_data) begin 
                CPU_state_d = S_data_burst_write ;
            end else if (~inst_cache_is_empty_flag && ~data_cache_is_empty_flag) begin 
                CPU_state_d = S_stall_or_write_inst ;
            end else begin
                CPU_state_d = S_cache_empty_and_fetch_first_inst ;
            end
        end
        S_inst_burst_write : begin 
            if (rlast_inst_q/*inst_cache_addr_cnt == 127*/) begin 
                CPU_state_d = S_cache_empty_and_fetch_first_inst ;
            end else begin
                CPU_state_d = S_inst_burst_write ;
            end
        end
        S_data_burst_write : begin 
            if (rlast_data_q/*data_cache_addr_cnt == 127*/) begin 
                CPU_state_d = S_cache_empty_and_fetch_first_inst ;
            end else begin
                CPU_state_d = S_data_burst_write ;
            end
        end
        S_stall_or_write_inst : begin
            CPU_state_d = S_decode_and_prefetch ;
        end
        S_decode_and_prefetch : begin //4
            if (valid_inst_q[15:13]==Opcode_DET) begin
                CPU_state_d = S_determinant_exe ;
            end else begin
                CPU_state_d = S_exe ;
            end
        end
        S_determinant_exe : begin //5
            if (det_cal_cnt == 19) begin 
                CPU_state_d = S_memory_access ;
            end else begin 
                CPU_state_d = S_determinant_exe ;
            end
        end
        S_exe : begin //6
            case (uniqle_opcode)
                Opcode_BRANCH: begin
                    // if (branch_equal_flag) begin
                        CPU_state_d = S_update_pc ;
                    // end else begin
                    //     CPU_state_d = S_memory_access ;
                    // end
                end
                Opcode_LOAD: begin
                    if (data_cache_HIT) begin
                        CPU_state_d = S_read_data_cache ; 
                    end else begin
                        if (multi_dirty_flag) begin // S_write_back_burst -> S_load_miss -> S_read_data_cache
                            CPU_state_d = S_write_back_burst ;
                        end else if (dirty_flag) begin // S_write_back_single -> S_load_miss -> S_read_data_cache
                            CPU_state_d = S_write_back_single ;
                        end else begin // no dirty , 
                            CPU_state_d = S_load_miss ;
                        end
                    end
                end
                Opcode_STORE: begin 
                    if (data_cache_HIT) begin
                        CPU_state_d = S_write_data_cache ; //8 
                    end else begin
                        CPU_state_d = S_write_back_single ; 
                    end
                end
                Opcode_MULT: begin 
                    CPU_state_d = S_mult_stall ;
                end
                default: CPU_state_d = S_memory_access ;
            endcase
        end
        S_read_data_cache : begin
            if (cache_delay_cnt) begin 
                CPU_state_d = S_memory_access ;
            end else begin 
                CPU_state_d = S_read_data_cache ;
            end
        end
        S_memory_access : begin //11
            if (ten_inst_cnt == 9 && multi_dirty_flag) begin //WB burst
                CPU_state_d = S_write_back_burst ;
            end else if ( ten_inst_cnt == 9 && dirty_flag )begin // WB single
                CPU_state_d = S_write_back_single ;
            end else if (~inst_cache_HIT) begin
                CPU_state_d = S_inst_miss ;
            end else begin
                CPU_state_d = S_decode_and_prefetch ;
            end
        end
        S_mult_stall : begin 
            CPU_state_d = S_memory_access ;
        end
        S_write_data_cache : begin
            if (ten_inst_cnt == 9 && multi_dirty_flag) begin //WB burst
                CPU_state_d = S_write_back_burst ;
            end else if (ten_inst_cnt == 9 && dirty_flag) begin//WB single
                CPU_state_d = S_write_back_single ;
            end else if (~inst_cache_HIT) begin // inst miss
                CPU_state_d = S_inst_miss ;
            end else begin
                CPU_state_d = S_decode_and_prefetch ;
            end
        end
        S_load_miss : begin 
            if (rlast_data_q) begin //*rlast_m_inf
                CPU_state_d = S_read_data_cache ;
            end else begin
                CPU_state_d = S_load_miss ;
            end
        end
        S_inst_miss : begin
            if (rlast_inst_q) begin //*rlast_m_inf
                CPU_state_d = S_cache_empty_and_fetch_first_inst ;
            end else begin
                CPU_state_d = S_inst_miss ;
            end
        end
        S_write_back_burst : begin
            if (bvalid_m_inf) begin
                if (load_miss_flag) begin
                    CPU_state_d = S_load_miss ;
                end else if (~inst_cache_HIT) begin
                    CPU_state_d = S_inst_miss ;
                end else begin
                    CPU_state_d = S_decode_and_prefetch ;
                end
            end else begin
                CPU_state_d = S_write_back_burst ;
            end
        end
        S_write_back_single : begin
            if (bvalid_m_inf) begin
                if (ten_inst_cnt == 9 && multi_dirty_flag) begin //WB burst
                    CPU_state_d = S_write_back_burst ;
                end else if ( ten_inst_cnt == 9 && dirty_flag )begin // WB single
                    CPU_state_d = S_write_back_single ;
                end else if (load_miss_flag) begin
                    CPU_state_d = S_load_miss ;
                end else if (~inst_cache_HIT) begin 
                    CPU_state_d = S_inst_miss ;
                end else begin
                    CPU_state_d = S_decode_and_prefetch ;
                end
            end else begin
                CPU_state_d = S_write_back_single ;
            end
        end
        S_update_pc : begin 
            if (branch_has_jump_flag) begin 
                CPU_state_d = S_update_pc ;
            end else if (ten_inst_cnt == 9 && multi_dirty_flag) begin //WB burst
                CPU_state_d = S_write_back_burst ;
            end else if ( ten_inst_cnt == 9 && dirty_flag )begin // WB single
                CPU_state_d = S_write_back_single ;
            end else if (~inst_cache_HIT) begin
                CPU_state_d = S_inst_miss ;            
            end else begin
                CPU_state_d = S_decode_and_prefetch ;
            end
        end
        default: CPU_state_d = CPU_state_q ; // S_cache_empty_and_fetch_first_inst ;
    endcase
end

//-------------------
// Core control 
//-------------------

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        core_r0  <= 0;
        core_r1  <= 0;
        core_r2  <= 0;
        core_r3  <= 0;  
        core_r4  <= 0;
        core_r5  <= 0;
        core_r6  <= 0;
        core_r7  <= 0;
        core_r8  <= 0;
        core_r9  <= 0;
        core_r10 <= 0;
        core_r11 <= 0;
        core_r12 <= 0;
        core_r13 <= 0;
        core_r14 <= 0;
        core_r15 <= 0;
    end else begin
        if (CPU_state_q == S_determinant_exe) begin // shift 
            core_r0 <= core_r1 ;
            core_r1 <= core_r2 ;
            core_r2 <= core_r3 ;
            core_r3 <= core_r0 ;
            core_r4 <= core_r5 ;
            core_r5 <= core_r6 ;
            core_r6 <= core_r7 ;
            core_r7 <= core_r4 ;
            core_r8 <= core_r9 ;
            core_r9 <= core_r10 ;
            core_r10 <= core_r11 ;
            core_r11 <= core_r8 ;
            core_r12 <= core_r13 ;
            core_r13 <= core_r14 ;
            core_r14 <= core_r15 ;
            core_r15 <= core_r12 ;
        end else if (CPU_state_q == S_memory_access) begin
            if (uniqle_opcode == Opcode_LOAD) begin 
                case (ALU_register_RD_idx)
                    4'd0: core_r0 <= SRAM_data_out_q ;
                    4'd1: core_r1 <= SRAM_data_out_q ;
                    4'd2: core_r2 <= SRAM_data_out_q ;
                    4'd3: core_r3 <= SRAM_data_out_q ;
                    4'd4: core_r4 <= SRAM_data_out_q ;
                    4'd5: core_r5 <= SRAM_data_out_q ;
                    4'd6: core_r6 <= SRAM_data_out_q ;
                    4'd7: core_r7 <= SRAM_data_out_q ;
                    4'd8: core_r8 <= SRAM_data_out_q ;
                    4'd9: core_r9 <= SRAM_data_out_q ;
                    4'd10: core_r10 <= SRAM_data_out_q ;
                    4'd11: core_r11 <= SRAM_data_out_q ;
                    4'd12: core_r12 <= SRAM_data_out_q ;
                    4'd13: core_r13 <= SRAM_data_out_q ;
                    4'd14: core_r14 <= SRAM_data_out_q ;
                    4'd15: core_r15 <= SRAM_data_out_q ;
                endcase
            end else if (uniqle_opcode == Opcode_DET) begin
                core_r0 <= det_temp_q ;
            end else begin 
                case (ALU_register_RD_idx)
                    4'd0: core_r0 <= ALU_register_RD ;
                    4'd1: core_r1 <= ALU_register_RD ;
                    4'd2: core_r2 <= ALU_register_RD ;
                    4'd3: core_r3 <= ALU_register_RD ;
                    4'd4: core_r4 <= ALU_register_RD ;
                    4'd5: core_r5 <= ALU_register_RD ;
                    4'd6: core_r6 <= ALU_register_RD ;
                    4'd7: core_r7 <= ALU_register_RD ;
                    4'd8: core_r8 <= ALU_register_RD ;
                    4'd9: core_r9 <= ALU_register_RD ;
                    4'd10: core_r10 <= ALU_register_RD ;
                    4'd11: core_r11 <= ALU_register_RD ;
                    4'd12: core_r12 <= ALU_register_RD ;
                    4'd13: core_r13 <= ALU_register_RD ;
                    4'd14: core_r14 <= ALU_register_RD ;
                    4'd15: core_r15 <= ALU_register_RD ;
                endcase
            end
        end
    end
end

//-------------------
// CPU calculation 
//-------------------

//* ------ decode ------

//* uniqle_opcode 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uniqle_opcode <= Opcode_ADD ;
    end else begin 
        if (CPU_state_q == S_decode_and_prefetch) begin
            case (valid_inst_q[15:13])
                3'b000 : begin
                    if (~valid_inst_q[0]) begin
                        uniqle_opcode <= Opcode_ADD ; // ADD 0
                    end else begin
                        uniqle_opcode <= Opcode_SUB ; // SUB 1
                    end
                end 
                3'b001 : begin
                    if (~valid_inst_q[0]) begin
                        uniqle_opcode <= Opcode_Set_less_than ; // Set less than 5
                    end else begin
                        uniqle_opcode <= Opcode_MULT ; // MULT 6
                    end
                end
                3'b010 : begin
                    uniqle_opcode <= Opcode_LOAD ; // LOAD 2
                end 
                3'b011 : begin
                    uniqle_opcode <= Opcode_STORE ; // STORE 3
                end
                3'b100 : begin
                    uniqle_opcode <= Opcode_BRANCH ; // BRANCH 4
                end
                3'b111 : begin
                    uniqle_opcode <= Opcode_DET ; // DET 7
                end
                default: uniqle_opcode <= Opcode_ADD ; // NOP 
            endcase
        end
    end
end

//* ALU_register_RS
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        ALU_register_RS <= 0 ;
    end else begin
        if (CPU_state_q == S_decode_and_prefetch) begin
            case (valid_inst_q[12:9])
                4'd0 : ALU_register_RS <= core_r0 ;
                4'd1 : ALU_register_RS <= core_r1 ;
                4'd2 : ALU_register_RS <= core_r2 ;
                4'd3 : ALU_register_RS <= core_r3 ;
                4'd4 : ALU_register_RS <= core_r4 ;
                4'd5 : ALU_register_RS <= core_r5 ;
                4'd6 : ALU_register_RS <= core_r6 ;
                4'd7 : ALU_register_RS <= core_r7 ;
                4'd8 : ALU_register_RS <= core_r8 ;
                4'd9 : ALU_register_RS <= core_r9 ;
                4'd10: ALU_register_RS <= core_r10;
                4'd11: ALU_register_RS <= core_r11;
                4'd12: ALU_register_RS <= core_r12;
                4'd13: ALU_register_RS <= core_r13;
                4'd14: ALU_register_RS <= core_r14;
                4'd15: ALU_register_RS <= core_r15;
            endcase
        end
    end
end

//* ALU_register_RT
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        ALU_register_RT <= 0 ;
    end else begin 
        if (CPU_state_q == S_decode_and_prefetch) begin
            case (valid_inst_q[8:5])
                4'd0 : ALU_register_RT <= core_r0 ;
                4'd1 : ALU_register_RT <= core_r1 ;
                4'd2 : ALU_register_RT <= core_r2 ;
                4'd3 : ALU_register_RT <= core_r3 ;
                4'd4 : ALU_register_RT <= core_r4 ;
                4'd5 : ALU_register_RT <= core_r5 ;
                4'd6 : ALU_register_RT <= core_r6 ;
                4'd7 : ALU_register_RT <= core_r7 ;
                4'd8 : ALU_register_RT <= core_r8 ;
                4'd9 : ALU_register_RT <= core_r9 ;
                4'd10: ALU_register_RT <= core_r10;
                4'd11: ALU_register_RT <= core_r11;
                4'd12: ALU_register_RT <= core_r12;
                4'd13: ALU_register_RT <= core_r13;
                4'd14: ALU_register_RT <= core_r14;
                4'd15: ALU_register_RT <= core_r15;
            endcase
        end
    end 
end

//* ALU_register_RD 
//! add/sub/set_less_than/mult/det
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin  
        ALU_register_RD <= 0 ;
    end else begin 
        case (uniqle_opcode)
            Opcode_ADD:  ALU_register_RD <= ADDER_out_d ;
            Opcode_SUB:  ALU_register_RD <= SUBTRACTOR_out_d ;
            Opcode_Set_less_than : ALU_register_RD <= CMP_out_d ;
            Opcode_MULT: ALU_register_RD <= multiplier_out_d ; 
            default: ALU_register_RD <= ADDER_out_d  ;
        endcase
    end
end

//* ALU_register_RD_idx
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ALU_register_RD_idx <= 4'b0000 ;
    end else begin 
        if (CPU_state_q == S_decode_and_prefetch) begin
            if (valid_inst_q[14]) begin // load and (store)
                ALU_register_RD_idx <= valid_inst_q [8:5] ;
            // end else if (valid_inst_q[15]) begin  // det and (branch) 
            //     ALU_register_RD_idx <= 4'b0000 ;
            end else begin
                ALU_register_RD_idx <= valid_inst_q[4:1] ;
            end
        end
    end
end

//* immediate
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        immediate <= 0 ;
    end else begin
        if (CPU_state_q == S_decode_and_prefetch) begin
            immediate <= valid_inst_q[4:0] ;
        end
    end
end

//* coeff_A 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        coeff_A <= 0 ;
    end else begin
        if (CPU_state_q == S_decode_and_prefetch) begin
            coeff_A <= valid_inst_q[12:9] ;
        end
    end
end

//* coeff_B 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        coeff_B_upper_4_bits <= 0 ;
    end else begin 
        if (CPU_state_q == S_decode_and_prefetch) begin
            coeff_B_upper_4_bits <= valid_inst_q[8:5] ;
        end
    end
end

always @(*) begin
    coeff_B = {coeff_B_upper_4_bits , immediate} ;
end

//-------------------
// SRAM / Cache control 
//-------------------

//* SRAM_WEB_q
always @(posedge clk or negedge rst_n) begin
    // case (CPU_state_q)
    //     S_inst_burst_write , S_data_burst_write : SRAM_WEB_q <= WRITE_WEB ;
    //     default: SRAM_WEB_q <= READ_WEB ;
    // endcase
    if (!rst_n) begin 
        SRAM_WEB_q <= READ_WEB ;
    end else begin 
        if ((rready_data && rvalid_data) || (rready_inst && rvalid_inst)) begin
            SRAM_WEB_q <= WRITE_WEB ;
        end else if ((CPU_state_q == S_exe) && data_cache_HIT && (uniqle_opcode == Opcode_STORE)) begin
            SRAM_WEB_q <= WRITE_WEB ;
        end else begin
            SRAM_WEB_q <= READ_WEB ;
        end
    end
end

//* SRAM_addr_d
always @(*) begin
    case (CPU_state_q) // TODO addr -> reg - > SRAM_addr_d except for PC  
        S_inst_burst_write , S_inst_miss: SRAM_addr_d = {1'b1,inst_cache_addr_cnt} ;
        S_data_burst_write , S_load_miss , S_write_back_burst: SRAM_addr_d = {1'b0,data_cache_addr_cnt} ;
        // S_write_back_burst : SRAM_addr_d = {1'b0,data_cache_addr_cnt} ;
        S_write_back_single : SRAM_addr_d = {1'b0,single_WB_addr_idx[6:0]};
        S_read_data_cache , S_write_data_cache: SRAM_addr_d = {1'b0,data_addr_idx_q} ; // TODO save one stage ? 
        // S_write_data_cache : SRAM_addr_d = {1'b0,data_addr_idx_q} ;
        default: SRAM_addr_d = {1'b1,program_counter[6:0]};//8'b0 ;
    endcase
end

//* SRAM_data_in_d
always @(*) begin
    case (CPU_state_q)
        S_inst_burst_write , S_inst_miss : SRAM_data_in_d = rdata_inst_q ;
        S_data_burst_write , S_load_miss : SRAM_data_in_d = rdata_data_q ;
        S_write_data_cache : SRAM_data_in_d = ALU_register_RT ;
        default: SRAM_data_in_d = 16'b0 ; //TODO save defalat 
    endcase
end

//* SRAM_data_out_q 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        SRAM_data_out_q <= 16'b0 ;
    end else begin
        SRAM_data_out_q <= SRAM_data_out_d ;
    end
end

//* cache_delay_cnt
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cache_delay_cnt <= 0;
    end else begin
        if (CPU_state_q==S_read_data_cache) begin 
            cache_delay_cnt <= ~cache_delay_cnt ;
        end else begin 
            cache_delay_cnt <= 0 ; // TODO
        end 
    end
end 

//* first_inst_read_request_flag 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        first_inst_read_request_flag <= 1'b1;
    end else if (arready_inst) begin
        first_inst_read_request_flag <= 0 ;
    end 
end

//* first_data_read_request_flag 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        first_data_read_request_flag <= 1'b1;
    end else if (arready_data) begin
        first_data_read_request_flag <= 0 ;
    end 
end
//* ------------- INST PART -------------
//* inst_cache_is_empty_flag
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        inst_cache_is_empty_flag <= 1'b1;
    end else begin
        if (rvalid_inst) begin 
            inst_cache_is_empty_flag <= 1'b0;
        end
    end
end

//* ------------- DATA PART -------------

//* data_cache_is_empty_flag
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_cache_is_empty_flag <= 1'b1;
    end else begin
        if (rvalid_inst) begin 
            data_cache_is_empty_flag <= 1'b0;
        end
    end
end

//-------------------
// Other control 
//-------------------

//* ten_inst_cnt
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ten_inst_cnt <= 4'd9;
    end else begin
        if (CPU_state_q == S_decode_and_prefetch) begin
            if (ten_inst_cnt == 4'd9) begin 
                ten_inst_cnt <= 4'd0 ; 
            end else begin 
                ten_inst_cnt <= ten_inst_cnt + 1 ;
            end 
        end
    end
end

//* store_miss_flag
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        store_miss_flag <= 0 ;
    end else begin
        if (CPU_state_q == S_exe && uniqle_opcode == Opcode_STORE ) begin
            store_miss_flag <= ~(data_cache_HIT) ;
        end else if (bvalid_m_inf) begin
            store_miss_flag <= 0 ;
        end
    end
end

//* load_miss_flag
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        load_miss_flag <= 0 ;
    end else begin
        if (CPU_state_q == S_exe && uniqle_opcode == Opcode_LOAD ) begin
            load_miss_flag <= ~(data_cache_HIT) ;
        end else if (rlast_data_q) begin
            load_miss_flag <= 0 ;
        end
    end
end 

//-------------------
// ALU 
//-------------------
//* det_cal_cnt
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        det_cal_cnt <= 0 ;
    end else begin 
        if (CPU_state_q == S_decode_and_prefetch) begin 
            det_cal_cnt <= 0 ;
        end else begin 
            det_cal_cnt <= det_cal_cnt + 1 ; 
        end 
    end
end

//* ADDER
always @(*) ADDER_out_d = ALU_register_RS + ALU_register_RT ;

//* SUBTRACTOR
always @(*) SUBTRACTOR_out_d = ALU_register_RS - ALU_register_RT ;

//* Multiplier (DW_IP)
always @(*) multiplier_out_d = multiplier_out_dwip[15:0] ;

DW02_mult_2_stage #(16, 16) u_multiplier_2stage ( 
.A(ALU_register_RS),
.B(ALU_register_RT),
.TC(1'd1),
.CLK(clk),
.PRODUCT(multiplier_out_dwip) );

//* CMP (set less than)
always @(*) CMP_out_d = (ALU_register_RS/*rs*/ < ALU_register_RT/*rt*/) ;

//* determinant (DW_IP)
// * det input control 
always @(*) begin
    // if (CPU_state_q == S_determinant_exe) begin 
    case (det_cal_cnt[3:2])
        2'd0: begin 
            det_g1_in1 = core_r0 ;
            det_g1_in2 = core_r5 ;
            det_g1_in3 = core_r10 ;
            det_g1_in4 = core_r15 ;

            det_g2_in1 = core_r0 ;
            det_g2_in2 = core_r13 ;
            det_g2_in3 = core_r10 ;
            det_g2_in4 = core_r7 ;
        end
        2'd1: begin 
            det_g1_in1 = core_r0 ;
            det_g1_in2 = core_r13 ;
            det_g1_in3 = core_r6 ;
            det_g1_in4 = core_r11 ;

            det_g2_in1 = core_r0 ;
            det_g2_in2 = core_r9 ;
            det_g2_in3 = core_r6 ;
            det_g2_in4 = core_r15 ;
        end
        2'd2: begin 
            det_g1_in1 = core_r0 ;
            det_g1_in2 = core_r9 ;
            det_g1_in3 = core_r14 ;
            det_g1_in4 = core_r7 ;

            det_g2_in1 = core_r0 ;
            det_g2_in2 = core_r5 ;
            det_g2_in3 = core_r14 ;
            det_g2_in4 = core_r11 ;
        end
        default: begin 
            det_g1_in1 = core_r0 ;
            det_g1_in2 = core_r5 ;
            det_g1_in3 = core_r10 ;
            det_g1_in4 = core_r15 ;
            
            det_g2_in1 = core_r0 ;
            det_g2_in2 = core_r13 ;
            det_g2_in3 = core_r10 ;
            det_g2_in4 = core_r7 ;
        end
    endcase
    // end else begin 
    //     det_g1_in1 = 0 ;
    //     det_g1_in2 = 0 ;
    //     det_g1_in3 = 0 ;
    //     det_g1_in4 = 0 ;
    //     det_g2_in1 = 0 ;
    //     det_g2_in2 = 0 ;
    //     det_g2_in3 = 0 ;
    //     det_g2_in4 = 0 ;
    // end
end

//* group 1 (3 mults)
DW02_mult_2_stage #(16, 16) u_detmult_2stage_0 ( 
.A(det_g1_in1),
.B(det_g1_in2),
.TC(1'd1),
.CLK(clk),
.PRODUCT(det_g1_out_1_d) );

DW02_mult_2_stage #(16, 16) u_detmult_2stage_1 ( 
.A(det_g1_in3),
.B(det_g1_in4),
.TC(1'd1),
.CLK(clk),
.PRODUCT(det_g1_out_2_d) );

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        det_g1_out_1_q <= 0 ;
        det_g1_out_2_q <= 0 ;
    end else begin
        det_g1_out_1_q <= det_g1_out_1_d ;
        det_g1_out_2_q <= det_g1_out_2_d ;
    end
end

DW02_mult_4_stage #(32, 32) u_detmult_4stage_0 ( 
.A(det_g1_out_1_q),
.B(det_g1_out_2_q),
.TC(1'd1),
.CLK(clk),
.PRODUCT(det_g1_out_dwip) );

//* group 2 (3 mults)
DW02_mult_2_stage #(16, 16) u_detmult_2stage_2 ( 
.A(det_g2_in1),
.B(det_g2_in2),
.TC(1'd1),
.CLK(clk),
.PRODUCT(det_g2_out_1_d) );

DW02_mult_2_stage #(16, 16) u_detmult_2stage_3 ( 
.A(det_g2_in3),
.B(det_g2_in4),
.TC(1'd1),
.CLK(clk),
.PRODUCT(det_g2_out_2_d) );

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        det_g2_out_1_q <= 0 ;
        det_g2_out_2_q <= 0 ;
    end else begin
        det_g2_out_1_q <= det_g2_out_1_d ;
        det_g2_out_2_q <= det_g2_out_2_d ;
    end
end

DW02_mult_4_stage #(32, 32) u_detmult_4stage_1 ( 
.A(det_g2_out_1_q),
.B(det_g2_out_2_q),
.TC(1'd1),
.CLK(clk),
.PRODUCT(det_g2_out_dwip) );

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        det_sub_a_q <= 0 ;
        det_sub_b_q <= 0 ;
    end else begin 
        if (det_cal_cnt[0]) begin
            det_sub_a_q <= det_g1_out_dwip ;
            det_sub_b_q <= det_g2_out_dwip ;
        end else begin
            det_sub_b_q <= det_g1_out_dwip ;
            det_sub_a_q <= det_g2_out_dwip ;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)  det_sub_out_q <= 0 ;
    else det_sub_out_q <= det_sub_a_q - det_sub_b_q ;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        det_accumulator_q <= 0 ;
    end else begin 
        if (det_cal_cnt == 4'd6) begin
            det_accumulator_q <= 0 ; 
        end else begin
            det_accumulator_q <= det_accumulator_q + det_sub_out_q ;
        end
    end
end

always @(*) begin
    // det_temp_d = (det_accumulator_q >>> {coeff_A,1'b0}) + coeff_B ;
    det_temp_d = (det_accumulator_q >>> {coeff_A,1'b0}) + $signed({1'b0, coeff_B}) ;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        det_temp_q <= 0 ;
    end else begin 
        if (det_temp_d >= 32767) begin
            det_temp_q <= 16'd32767 ;
        end else if (det_temp_d <= -32768) begin
            det_temp_q <= -16'd32768 ;
        end else begin
            det_temp_q <= det_temp_d[15:0] ;
        end
    end
end

//* dirty_flag 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dirty_flag <= 1'b0 ;
    end else begin
        // if (CPU_state_q == S_decode_and_prefetch && valid_inst_q[15:13]==3'b011 && data_cache_HIT) begin
        if (CPU_state_q == S_exe && uniqle_opcode == Opcode_STORE && data_cache_HIT) begin
            dirty_flag <= 1'b1 ;
        end else if ( CPU_state_q == S_write_back_burst) begin 
            dirty_flag <= 1'b0 ;
        end else if (CPU_state_q == S_write_back_single && (~store_miss_flag)) begin
            dirty_flag <= 1'b0 ;
        end
    end
end

//* multi_dirty_flag 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        multi_dirty_flag <= 1'b0 ;
    end else begin
        // if (CPU_state_q == S_decode_and_prefetch && valid_inst_q[15:13]==3'b011 && dirty_flag && data_cache_HIT) begin
        if (CPU_state_q == S_exe && uniqle_opcode == Opcode_STORE && dirty_flag && data_cache_HIT) begin    
            multi_dirty_flag <= 1'b1 ;
        end else if (CPU_state_q == S_write_back_burst) begin
            multi_dirty_flag <= 1'b0 ;
        end else if (CPU_state_q == S_write_back_single && (~store_miss_flag)) begin
            multi_dirty_flag <= 1'b0 ;
        end
    end
end

//* Adder for branch // might error here 
// reg [10:0] program_counter; // 0 ~ 2047
// reg signed [4:0] immediate ;
always @(*) branch_pc = {/*1'b0,*/program_counter_minus_1} + {{7{immediate[4]}},immediate[3:0]} ;//immediate ; //{{6{immediate[4]}},immediate[3:0]} ;
// reg branch_equal_flag ;
always @(*) branch_equal_flag = (ALU_register_RS == ALU_register_RT) && (!(immediate == 0));

//* DATA Cache HIT/MISS
// might error here 
always @(*) begin
    data_addr_idx = ALU_register_RS[10:0] + {{7{immediate[4]}},immediate[3:0]};
end
//! data_addr_idx * 2 is the actual address in the DATA DRAM
always @(*) begin
    data_cache_HIT = (data_frame == data_addr_idx[10:7]) ; 
end

//* single_WB_addr_idx 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        single_WB_addr_idx <= 0 ;
    end else begin 
        if (uniqle_opcode == Opcode_STORE && data_cache_HIT) begin 
            single_WB_addr_idx <= data_addr_idx ;
        end
    end
end

//* single_WB_addr_idx_store_miss 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        single_WB_addr_idx_store_miss <= 0 ; 
    end else begin 
        if (uniqle_opcode == Opcode_STORE && ~data_cache_HIT) begin 
            single_WB_addr_idx_store_miss <= data_addr_idx ;
        end
    end
end

//* data_addr_idx_q 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) data_addr_idx_q <= 0 ;
    else data_addr_idx_q <= data_addr_idx[6:0] ;
end

//* INST Cache HIT / MISS
//* inst_cache_HIT 
always @(*) begin
    program_counter_minus_1 = program_counter - 1 ;
end
always @(*) begin 
    inst_cache_HIT = (inst_frame == program_counter_minus_1[10:7]) ; 
end
// always @(*) begin 
//     inst_cache_HIT = inst_frame == program_counter[10:7] ; 
// end

//-------------------
// Cache IP
//-------------------
//! READ : WEB=1  WRITE : WEB=0 ; 
SUMA180_256X16X1BM1 data_and_inst_cache (
    .A0(SRAM_addr_d[0]),        .A1(SRAM_addr_d[1]),        .A2(SRAM_addr_d[2]),        .A3(SRAM_addr_d[3]),        .A4(SRAM_addr_d[4]),        .A5(SRAM_addr_d[5]),
    .A6(SRAM_addr_d[6]),        .A7(SRAM_addr_d[7]),
    .DO0(SRAM_data_out_d[0]),   .DO1(SRAM_data_out_d[1]),   .DO2(SRAM_data_out_d[2]),   .DO3(SRAM_data_out_d[3]),   .DO4(SRAM_data_out_d[4]),   .DO5(SRAM_data_out_d[5]),
    .DO6(SRAM_data_out_d[6]),   .DO7(SRAM_data_out_d[7]),   .DO8(SRAM_data_out_d[8]),   .DO9(SRAM_data_out_d[9]),   .DO10(SRAM_data_out_d[10]), .DO11(SRAM_data_out_d[11]),
    .DO12(SRAM_data_out_d[12]), .DO13(SRAM_data_out_d[13]), .DO14(SRAM_data_out_d[14]), .DO15(SRAM_data_out_d[15]),
    .DI0(SRAM_data_in_d[0]),    .DI1(SRAM_data_in_d[1]),    .DI2(SRAM_data_in_d[2]),    .DI3(SRAM_data_in_d[3]),    .DI4(SRAM_data_in_d[4]),    .DI5(SRAM_data_in_d[5]),
    .DI6(SRAM_data_in_d[6]),    .DI7(SRAM_data_in_d[7]),    .DI8(SRAM_data_in_d[8]),    .DI9(SRAM_data_in_d[9]),    .DI10(SRAM_data_in_d[10]),  .DI11(SRAM_data_in_d[11]),
    .DI12(SRAM_data_in_d[12]),  .DI13(SRAM_data_in_d[13]),  .DI14(SRAM_data_in_d[14]),  .DI15(SRAM_data_in_d[15]),
    .CK(clk),                   .WEB(SRAM_WEB_q),           .OE(1'b1),                  .CS(1'b1));

//* DATA DRAM WRITE -------------------------------------------
//-------------------
// AXI - AW Channel
//-------------------
//* AW_request_flag
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        AW_request_flag <= 1'b0 ;
    end else begin
        if (awvalid_m_inf) begin //might error 
            AW_request_flag <= 1'b1 ;
        end else if (bvalid_m_inf) begin
            AW_request_flag <= 1'b0 ;
        end
    end
end

//* awaddr_m_inf
// always @(*) awaddr_m_inf = {20'b0000_0000_0000_0000_0001 , data_frame , 8'd0} ;
always @(*) begin 
    case (CPU_state_q)
        S_write_back_burst : awaddr_m_inf = {20'b0000_0000_0000_0000_0001 , data_frame , 8'd0} ;
        S_write_back_single : begin 
            if (~store_miss_flag) begin 
                awaddr_m_inf = {20'b0000_0000_0000_0000_0001 , single_WB_addr_idx , 1'd0} ;
            end else begin
                awaddr_m_inf = {20'b0000_0000_0000_0000_0001 , single_WB_addr_idx_store_miss , 1'd0} ; 
            end
        end
        default: awaddr_m_inf = {20'b0000_0000_0000_0000_0001 , 12'd0 } ;
    endcase
end

//* awvalid_m_inf
always @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin
        awvalid_m_inf <= 0 ;
    end else begin 
        case (CPU_state_q)
            S_write_back_burst , S_write_back_single : begin
                if (AW_request_flag == 0) begin
                    awvalid_m_inf <= 1 ;
                end else begin
                    awvalid_m_inf <= 0 ;
                end
            end
            default: awvalid_m_inf <= 0 ;
        endcase
    end
end

//* awready_m_inf (input)

//-------------------
// AXI - W Channel
//-------------------
//* awlen_m_inf 
always @(*) begin
    case (CPU_state_q)
        S_write_back_burst: awlen_m_inf = 7'b111_1111 ;
        S_write_back_single : awlen_m_inf = 7'd0 ;
        default: awlen_m_inf = 7'd0 ;
    endcase
end

//* wdata_m_inf
// TODO chang FF
always @(*) begin
    if (store_miss_flag) begin 
        wdata_m_inf = ALU_register_RT ;
    end else begin 
        wdata_m_inf = SRAM_data_out_q ;
    end
end 

reg wvalid_m_inf_low_flag ;
//* wvalid_m_inf_low_flag
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wvalid_m_inf_low_flag <= 1'b0 ;
    end else begin
        if (~wvalid_m_inf) begin
            wvalid_m_inf_low_flag <= 1 ;
        end else if (wlast_m_inf) begin
            wvalid_m_inf_low_flag <= 0 ;
        end
    end
end

//* wvalid_m_inf
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wvalid_m_inf <= 1 ;
    end else begin
        case (CPU_state_q)
            S_write_back_burst : begin
                if (wlast_m_inf) begin
                    wvalid_m_inf <= 0 ;
                end else if (wvalid_m_inf_low_flag) begin
                    wvalid_m_inf <= 1 ;
                end else if (wready_m_inf) begin 
                    wvalid_m_inf <= 0 ;
                end 
            end
            S_write_back_single: begin 
                if (wready_m_inf) begin
                    wvalid_m_inf <= 0 ;
                end 
                else begin
                    wvalid_m_inf <= 1 ;
                end
            end
            default: wvalid_m_inf <= 1 ;
        endcase
    end
end

//* wlast_m_inf (must)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wlast_m_inf <= 1'b0 ;
    end else begin
        case (CPU_state_q)
            S_write_back_burst: wlast_m_inf <= (data_cache_addr_cnt==0) && (wvalid_m_inf_low_flag==1) ;
            S_write_back_single: begin
                if (wready_m_inf) begin
                    wlast_m_inf <= 0 ;
                end else begin
                    wlast_m_inf <= 1 ;
                end
            end
            default: wlast_m_inf <= 0 ;
        endcase

    end
end
//-------------------
// AXI - B Channel
//-------------------
//* bready_m_inf
assign bready_m_inf = 1'b1 ;

//* inst DRAM READ ------------------------------------------------------------------------------------
//* inst_frame 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        inst_frame <= 0;
    end else if (CPU_state_q == S_inst_miss) begin
        inst_frame <= program_counter[10:7] ;
    end
end

//* inst_cache_addr_cnt
// TODO remove default
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        inst_cache_addr_cnt <= 0;
    end else begin
        case (CPU_state_q)
            S_inst_burst_write , S_inst_miss: begin 
                inst_cache_addr_cnt <= inst_cache_addr_cnt + rready_inst_q ;
            end
            default: inst_cache_addr_cnt <= 0 ;
        endcase
    end
end
//-------------------
// AXI - AR Channel
//-------------------
reg inst_miss_arvalid ;
reg inst_miss_request_flag ;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        inst_miss_request_flag <= 0 ;
    end else begin
        if (arready_inst) begin
            inst_miss_request_flag <= 1 ;
        end else if (rlast_inst_q) begin
            inst_miss_request_flag <= 0 ;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        inst_miss_arvalid <= 0 ;
    end else begin
        if (CPU_state_q == S_inst_miss) begin
            if (arready_inst) begin 
                inst_miss_arvalid <= 0 ;
            end else if (~inst_miss_request_flag) begin 
                inst_miss_arvalid <= 1 ;
            end
        end
    end
end

//* arvalid_inst
always @(*) begin
    case (CPU_state_q)
        S_cache_empty_and_fetch_first_inst :  arvalid_inst = first_inst_read_request_flag ;
        S_inst_miss : arvalid_inst = inst_miss_arvalid ;
        default: begin
            arvalid_inst = 1'b0 ;
        end
    endcase
end

//* araddr_inst 
always @(*) begin
    case (CPU_state_q)
        S_cache_empty_and_fetch_first_inst , S_inst_burst_write , S_data_burst_write: begin 
            araddr_inst = { inst_frame , 8'd0} ;
        end
        S_inst_miss: araddr_inst = { inst_frame , 8'd0} ;
        default: begin
            araddr_inst = { inst_frame , 8'd0} ;
        end
    endcase
end

//-------------------
// AXI - R Channel
//-------------------
//* rready_inst
always @(*) begin
    case (CPU_state_q)
        S_inst_burst_write :  rready_inst = 1'b1 ; 
        S_inst_miss :         rready_inst = 1'b1 ; 
        default:              rready_inst = 1'b0 ;
    endcase
end

//* DATA DRAM READ ------------------------------------------------------------------------------------
//* data_frame 
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_frame <= 0;
    end else if (CPU_state_q == S_load_miss) begin
        data_frame <= data_addr_idx[10:7] ;
    end
end
//* data_cache_addr_cnt
// TODO remove default
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_cache_addr_cnt <= 0;
    end else begin
        case (CPU_state_q)
            S_data_burst_write , S_load_miss: data_cache_addr_cnt <= data_cache_addr_cnt + rready_data_q ;
            S_write_back_burst: begin 
                if (bvalid_m_inf) begin 
                    data_cache_addr_cnt <= 0 ;
                end else begin 
                    data_cache_addr_cnt <= data_cache_addr_cnt + (wready_m_inf) ;
                end
            end
            default: data_cache_addr_cnt <= 0 ;
        endcase
    end
end


//-------------------
// AXI - AR Channel
//-------------------
reg load_miss_arvalid ;
reg load_miss_request_flag ;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        load_miss_request_flag <= 0 ;
    end else begin
        if (arready_data) begin
            load_miss_request_flag <= 1 ;
        end else if (rlast_data_q) begin
            load_miss_request_flag <= 0 ;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        load_miss_arvalid <= 0 ;
    end else begin
        if (CPU_state_q == S_load_miss) begin
            if (arready_data) begin 
                load_miss_arvalid <= 0 ;
            end else if (~load_miss_request_flag) begin 
                load_miss_arvalid <= 1 ;
            end
        end
    end
end

//* arvalid_data
always @(*) begin
    case (CPU_state_q)
        S_cache_empty_and_fetch_first_inst : begin 
            arvalid_data = first_data_read_request_flag ;
        end
        S_load_miss : arvalid_data = load_miss_arvalid ;
        default: begin
            arvalid_data = 1'b0 ;
        end
    endcase
end

//* araddr_data 
always @(*) begin
    case (CPU_state_q)
        S_cache_empty_and_fetch_first_inst , S_inst_burst_write , S_data_burst_write : begin 
            araddr_data = { data_frame , 8'd0} ;
        end
        default: begin
            araddr_data = { data_frame , 8'd0} ;
        end
    endcase
end

//-------------------
// AXI - R Channel
//-------------------
//* rready_data
always @(*) begin
    case (CPU_state_q)
        S_data_burst_write :  rready_data = 1'b1 ;
        S_load_miss :         rready_data = 1'b1 ; 
        default:              rready_data = 1'b0 ;
    endcase
end

//* ----------------------------------------------------------------------------------------------------
//-------------------
// PC inst control 
//-------------------

//* program_counter
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        program_counter <= 0;
    end else begin
        if (CPU_state_q == S_decode_and_prefetch || CPU_state_q == S_stall_or_write_inst || (branch_has_jump_flag)) begin  //CPU_state_q == S_update_pc && branch_has_jump_flag
            program_counter <= program_counter + 1;
        end else if (CPU_state_q == S_exe && branch_equal_flag && (uniqle_opcode == Opcode_BRANCH)) begin
            program_counter <= branch_pc ;
        end else if (CPU_state_q == S_inst_miss && rlast_inst_q) begin
            program_counter <= program_counter_next_start ;
        end
    end
end

//* program_counter_next_start
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        program_counter_next_start <= 0;
    end else begin 
        if (CPU_state_q == S_inst_miss) begin
            program_counter_next_start <= program_counter_minus_1 ;
        end
    end
end

//* valid_inst_flag
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        valid_inst_flag <= 0 ;
    end else begin 
    valid_inst_flag <=  (CPU_state_q == S_cache_empty_and_fetch_first_inst) ||
                        (CPU_state_q == S_decode_and_prefetch) ||
                        (branch_has_jump_flag) ; //CPU_state_q == S_update_pc && branch_has_jump_flag
    end
end

//* valid_inst_q
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        valid_inst_q <= 0 ;
    end else begin 
        if (valid_inst_flag) begin 
            valid_inst_q <= SRAM_data_out_d ;
        end 
    end
end

//* branch_has_jump_flag
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        branch_has_jump_flag <= 0 ;
    end else begin 
        if (CPU_state_q == S_exe && uniqle_opcode == Opcode_BRANCH) begin 
            branch_has_jump_flag <= branch_equal_flag ; 
        end else begin  //else if (CPU_state_q == S_update_pc)
            branch_has_jump_flag <= 0 ;
        end
    end
end


//-------------------
// Output control 
//-------------------

//* IO_stall
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        IO_stall <= 1'b1;
    end else begin
        if (ten_inst_cnt == 4'd9 && dirty_flag) begin 
            IO_stall <= 1'b1;
        end else begin 
            IO_stall <= !(  (CPU_state_q == S_memory_access)    ||
                            (CPU_state_q == S_update_pc && ~branch_has_jump_flag) ||
                            (CPU_state_q == S_write_data_cache) ||
                            (CPU_state_q == S_write_back_burst && bvalid_m_inf && ~ load_miss_flag) ||
                            (CPU_state_q == S_write_back_single && bvalid_m_inf && ~ load_miss_flag) 
                        );
        end
    end
end



// //-------------------
// // Only for testing
// //-------------------
// reg [10:0] pat_num ;
// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         pat_num <= 11'd0 ;
//     end else begin
//         if (~IO_stall) begin
//             pat_num <= pat_num + 1 ;
//         end
//     end
// end

// reg [10:0] valid_write_cnt ; 
// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n) begin
//         valid_write_cnt <= 11'd0 ;
//     end else begin
//         if (wvalid_m_inf&&wready_m_inf) begin
//             valid_write_cnt <= valid_write_cnt + 1 ;
//         end
//     end
// end


endmodule
