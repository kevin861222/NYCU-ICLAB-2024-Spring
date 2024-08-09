//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2023 ICLAB Fall Course
//   Lab03      : BRIDGE
//   Author     : Wang Yu
//                
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : BRIDGE_encrypted.v
//   Module Name : BRIDGE
//   Release version : v1.0 (Release Date: Sep-2023)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module BRIDGE(
    // Input Signals
    clk,
    rst_n,
    in_valid,
    direction,
    addr_dram,
    addr_sd,
    // Output Signals
    out_valid,
    out_data,
    // DRAM Signals
    AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY,
	AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP,
    // SD Signals
    MISO,
    MOSI
);

// Input Signals
input clk, rst_n;
input in_valid;
input direction; //! 1: SD -> DRAM ; 0: DRAM -> SD
input [12:0] addr_dram;
input [15:0] addr_sd;

// Output Signals
output reg out_valid;
output [7:0] out_data;
reg [7:0] out_data_d;
assign out_data = (out_valid) ? (out_data_d) : (0) ;
// DRAM Signals
// write address channel
output reg [31:0] AW_ADDR;
output reg AW_VALID;
input AW_READY;
// write data channel
output reg W_VALID;
output reg [63:0] W_DATA;
input W_READY;
// write response channel
input B_VALID;
input [1:0] B_RESP;
output reg B_READY;
// read address channel
output reg [31:0] AR_ADDR;
output reg AR_VALID;
input AR_READY;
// read data channel
input [63:0] R_DATA;
input R_VALID;
input [1:0] R_RESP;
output reg R_READY;

// SD Signals
input MISO;
output reg MOSI;

//==============================================//
//       parameter & integer declaration        //
//==============================================//
//* States of FSM
localparam  IDLE        = 3'd0 ,
            SD_READ     = 3'd1 ,
            DRAM_READ   = 3'd2 ,
            SD_WRITE    = 3'd3 ,
            DRAM_WRITE  = 3'd4 ,
            YIELD       = 3'd5 ;

//* Parameter of SD READ
parameter SD_READ_START_BIT = 1'b0 ; //! 
parameter SD_READ_transmission_bit = 1'b1 ; //! 
parameter SD_READ_COMMAND = 6'd17 ; //! CMD17
parameter SD_READ_END_BIT = 1'b1 ; //! 

//* Parameter of SD READ
parameter SD_WRITE_START_BIT = 1'b0 ; //! 
parameter SD_WRITE_transmission_bit = 1'b1 ; //! 
parameter SD_WRITE_COMMAND = 6'd24 ; //! CMD17
parameter SD_WRITE_END_BIT = 1'b1 ; //! 

//* counter of SD READ
integer SD_READ_cnt ; //! 
integer SD_R_DATA_cnt ;

//* counter of SD WRITE 
integer SD_WRITE_cnt ; //! 
integer SD_W_DATA_cnt ;

//* counter of YIELD
integer Y_cnt ; //! 

//==============================================//
//           reg & wire declaration             //
//==============================================//
//* FSM
//   ┌-------------------------------------┐ 
//   |                                     |
//   ↓      SD READ        DRAM WRITE      ↑
// IDLE ->             ->             -> YIELD
//          DRAM READ      SD WRITE     (output)

reg [2:0] bridge_state_q , bridge_state_d ;


//* Flag_s
reg SD_READ_flag_q      , SD_READ_flag_d    ,
    DRAM_READ_flag_q    , DRAM_READ_flag_d  ,
    SD_WRITE_flag_q     , SD_WRITE_flag_d   ,
    DRAM_WRITE_flag_q   , DRAM_WRITE_flag_d ,
    YIELD_flag_q        , YIELD_flag_d      ;

//* DRAM flags
reg AR_done_q   , AR_done_d ;
reg R_done_q    , R_done_d ;
reg AW_done_q   , AW_done_d ;
reg W_done_q    , W_done_d ;
reg B_done_q    , B_done_d ;

//* SD flags
reg SD_R_cmd_done_q , SD_R_cmd_done_d ;
reg SD_R_DATA_start_flag_q , SD_R_DATA_start_flag_d ;
reg SD_R_data_block_done_q , SD_R_data_block_done_d ; 

reg SD_W_cmd_done_q , SD_W_cmd_done_d ;
reg SD_W_response_done_q , SD_W_response_done_d ;
reg SD_W_data_response_done_q , SD_W_data_response_done_d ;
reg SD_W_DATA_done_q , SD_W_DATA_done_d ;

reg buzy_flag_q , buzy_flag_d ;

//* SD READ Data start token
reg [7:0] SD_R_start_token ;

//* SD WRITE Response token
reg [7:0] SD_W_Response_token ;

//* SD WRITE data response Buzy token
reg [7:0] Buzy_token ;

//* SD_R_CRC7_result
reg [6:0] SD_R_CRC7_result , SD_W_CRC7_result ;
reg [15:0] SD_W_CRC16_result ;

//* ADDR reg
reg [31:0] addr_dram_q ;
reg [31:0] addr_sd_q ;

//* direction reg
reg direction_q ;

//* DATA reg
reg [63:0] DRAM_READ_DATA_repo , SD_READ_DATA_repo ;

// token reg
reg SD_R_start_token_0 ,
    SD_R_start_token_1 ,
    SD_R_start_token_2 ,
    SD_R_start_token_3 ,
    SD_R_start_token_4 ,
    SD_R_start_token_5 ,
    SD_R_start_token_6 ,
    SD_R_start_token_7 ;

reg SD_W_Response_token_0 ,
    SD_W_Response_token_1 ,
    SD_W_Response_token_2 ,
    SD_W_Response_token_3 ,
    SD_W_Response_token_4 ,
    SD_W_Response_token_5 ,
    SD_W_Response_token_6 ,
    SD_W_Response_token_7 ;

reg Buzy_token_0 ,
    Buzy_token_1 ,
    Buzy_token_2 ,
    Buzy_token_3 ,
    Buzy_token_4 ,
    Buzy_token_5 ,
    Buzy_token_6 ,
    Buzy_token_7 ;

//==============================================//
//*                    FSM                      //
//==============================================//
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        bridge_state_q <= IDLE ;
    end else begin
        bridge_state_q <= bridge_state_d ;
    end
end

always @(*) begin
    case (bridge_state_q)
        IDLE : begin
            if (in_valid==1) begin
                if (direction==1) begin
                    // SD -> DRAM
                    bridge_state_d = SD_READ ;
                end else begin
                    // DRAM -> SD
                    bridge_state_d = DRAM_READ ;
                end
            end else begin
                bridge_state_d = bridge_state_q ;
            end
        end 
        SD_READ : begin
            if (SD_READ_flag_q == 1) begin
                bridge_state_d = DRAM_WRITE ;
            end else begin
                bridge_state_d = bridge_state_q ;
            end
        end
        DRAM_READ : begin
            if (DRAM_READ_flag_q == 1) begin
                bridge_state_d = SD_WRITE ;
            end else begin
                bridge_state_d = bridge_state_q ;
            end
        end
        SD_WRITE : begin
            if (SD_WRITE_flag_q == 1) begin
                bridge_state_d = YIELD ;
            end else begin
                bridge_state_d = bridge_state_q ;
            end
        end
        DRAM_WRITE : begin
            if (DRAM_WRITE_flag_q == 1) begin
                bridge_state_d = YIELD ;
            end else begin
                bridge_state_d = bridge_state_q ;
            end
        end
        YIELD : begin
            if (YIELD_flag_q == 1) begin
                bridge_state_d = IDLE ;
            end else begin
                bridge_state_d = bridge_state_q ;
            end
        end
        default: bridge_state_d = IDLE ;
    endcase
end

//==============================================//
//*                Receive a task               //
//==============================================//
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        addr_dram_q <= 0 ;
        addr_sd_q   <= 0 ;
    end else begin
        if (in_valid==1) begin
            addr_dram_q <= {{(31-12){1'b0}},addr_dram} ;
            addr_sd_q   <= {{(31-15){1'b0}},addr_sd} ;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        direction_q <= 1'b0 ;
    end else begin
        if (in_valid) begin
            direction_q <= direction ;
        end
    end
end

//==============================================//
//*                   SD READ                   //
//==============================================//
//* SD_READ_flag_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_READ_flag_q <= 1'b0 ;
    end else begin
        SD_READ_flag_q <= SD_READ_flag_d ;
    end
end

//* SD_READ_cnt
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_READ_cnt <= 1'b0 ;
    end else begin
        if ( bridge_state_q == SD_READ ) begin
            SD_READ_cnt <= SD_READ_cnt + 1 ;
        end else begin
            SD_READ_cnt <= 1'b0 ;
        end
    end
end

//* SD_R_CRC7_result
always @(*) begin
    if ( bridge_state_q == SD_READ ) begin
        if ( SD_R_cmd_done_q == 0 ) begin
            SD_R_CRC7_result = CRC7({SD_READ_START_BIT,SD_READ_transmission_bit,SD_READ_COMMAND,addr_sd_q});
        end else begin
            SD_R_CRC7_result = 0 ;
        end
    end else begin
        SD_R_CRC7_result = 0 ;
    end
end

//* MOSI
always @(*) begin
    if ( bridge_state_q == SD_READ ) begin
        if ( SD_R_cmd_done_q == 0 ) begin
            case (SD_READ_cnt)
                0:begin
                    MOSI = SD_READ_START_BIT ;
                end
                1:begin
                    MOSI = SD_READ_transmission_bit ;
                end
                2, 3, 4, 5, 6, 7: begin
                    MOSI = SD_READ_COMMAND[6-1-(SD_READ_cnt-2)] ;
                end
                8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39:
                begin
                    MOSI = addr_sd_q[32-1-(SD_READ_cnt-8)];
                end
                40, 41, 42, 43, 44, 45, 46: begin
                    MOSI = SD_R_CRC7_result[7-1-(SD_READ_cnt-40)] ;
                end
                47: begin
                    MOSI = SD_READ_END_BIT ;
                end
                default: MOSI = 1 ;
            endcase
        end else begin
            MOSI = 1 ;
        end
    end else if ( bridge_state_q == SD_WRITE ) begin
        if (SD_W_cmd_done_q == 0) begin
            case (SD_WRITE_cnt)
                0: begin
                    MOSI = SD_WRITE_START_BIT ;
                end
                1: begin
                    MOSI = SD_WRITE_transmission_bit ;
                end
                2, 3, 4, 5, 6, 7 : begin
                    MOSI = SD_WRITE_COMMAND[6-1-(SD_WRITE_cnt-2)] ;
                end
                8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39:
                begin
                    MOSI = addr_sd_q[32-1-(SD_WRITE_cnt-8)];
                end
                40, 41, 42, 43, 44, 45, 46: begin
                    MOSI = SD_W_CRC7_result[7-1-(SD_WRITE_cnt-40)] ;
                end
                47: begin
                    MOSI = SD_WRITE_END_BIT ;
                end
                default: MOSI = 1 ;
            endcase
        end else if (SD_W_response_done_q == 1) begin
            case (SD_W_DATA_cnt)
                0, 1, 2, 3, 4, 5, 6, 7: begin // wait 1 unit
                    MOSI = 1 ;
                end
                8, 9, 10, 11, 12, 13, 14: begin
                    MOSI = 1 ;
                end
                15: begin
                    MOSI = 0 ;
                end
                16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79:
                begin
                    MOSI = DRAM_READ_DATA_repo[64-1-(SD_W_DATA_cnt-16)] ;
                end
                80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95 : begin
                    MOSI = SD_W_CRC16_result[16-1-(SD_W_DATA_cnt-80)] ;
                end
                default: MOSI = 1 ;
            endcase
        end else begin 
            MOSI = 1 ;
        end
    end else begin
        MOSI = 1 ;
    end
end

//* SD_R_cmd_done_q 
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_R_cmd_done_q <= 1'b0 ;
    end else begin
        SD_R_cmd_done_q <= SD_R_cmd_done_d ;
    end
end

//* SD_R_cmd_done_d
always @(*) begin
    if ( bridge_state_q == SD_READ ) begin
        if (SD_R_cmd_done_q == 1) begin
            if ( SD_READ_flag_q == 1 ) begin
                SD_R_cmd_done_d = 0 ;
            end else begin
                SD_R_cmd_done_d = 1 ;
            end
        end else begin
            if ( SD_READ_cnt == 47 ) begin
                SD_R_cmd_done_d = 1 ;
            end else begin
                SD_R_cmd_done_d = 0 ;
            end
        end
    end else begin
        SD_R_cmd_done_d = 0 ;
    end
end
//* SD_R_start_token reg
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_R_start_token_7 <= 1'b1 ;
        SD_R_start_token_6 <= 1'b1 ;
        SD_R_start_token_5 <= 1'b1 ;
        SD_R_start_token_4 <= 1'b1 ;
        SD_R_start_token_3 <= 1'b1 ;
        SD_R_start_token_2 <= 1'b1 ;
        SD_R_start_token_1 <= 1'b1 ;
        SD_R_start_token_0 <= 1'b1 ;
    end else begin
        SD_R_start_token_7 <= SD_R_start_token[7] ;
        SD_R_start_token_6 <= SD_R_start_token[6] ;
        SD_R_start_token_5 <= SD_R_start_token[5] ;
        SD_R_start_token_4 <= SD_R_start_token[4] ;
        SD_R_start_token_3 <= SD_R_start_token[3] ;
        SD_R_start_token_2 <= SD_R_start_token[2] ;
        SD_R_start_token_1 <= SD_R_start_token[1] ;
        SD_R_start_token_0 <= SD_R_start_token[0] ;
    end
end

//* check data start token 0xFE (8 bits)
//* SD_R_start_token
always @(*) begin
    if ( bridge_state_q == SD_READ ) begin
        if (SD_R_cmd_done_q == 1) begin
            case (SD_READ_cnt[2:0])
                0 : begin 
                    SD_R_start_token[7] = MISO ;
                    SD_R_start_token[6] = SD_R_start_token_6 ;
                    SD_R_start_token[5] = SD_R_start_token_5 ;
                    SD_R_start_token[4] = SD_R_start_token_4 ;
                    SD_R_start_token[3] = SD_R_start_token_3 ;
                    SD_R_start_token[2] = SD_R_start_token_2 ;
                    SD_R_start_token[1] = SD_R_start_token_1 ;
                    SD_R_start_token[0] = SD_R_start_token_0 ;
                end
                1 : begin 
                    SD_R_start_token[7] = SD_R_start_token_7 ;
                    SD_R_start_token[6] = MISO ;
                    SD_R_start_token[5] = SD_R_start_token_5 ;
                    SD_R_start_token[4] = SD_R_start_token_4 ;
                    SD_R_start_token[3] = SD_R_start_token_3 ;
                    SD_R_start_token[2] = SD_R_start_token_2 ;
                    SD_R_start_token[1] = SD_R_start_token_1 ;
                    SD_R_start_token[0] = SD_R_start_token_0 ;
                end
                2 : begin 
                    SD_R_start_token[7] = SD_R_start_token_7 ;
                    SD_R_start_token[6] = SD_R_start_token_6 ;
                    SD_R_start_token[5] = MISO ;
                    SD_R_start_token[4] = SD_R_start_token_4 ;
                    SD_R_start_token[3] = SD_R_start_token_3 ;
                    SD_R_start_token[2] = SD_R_start_token_2 ;
                    SD_R_start_token[1] = SD_R_start_token_1 ;
                    SD_R_start_token[0] = SD_R_start_token_0 ;
                end
                3 : begin 
                    SD_R_start_token[7] = SD_R_start_token_7 ;
                    SD_R_start_token[6] = SD_R_start_token_6 ;
                    SD_R_start_token[5] = SD_R_start_token_5 ;
                    SD_R_start_token[4] = MISO ;
                    SD_R_start_token[3] = SD_R_start_token_3 ;
                    SD_R_start_token[2] = SD_R_start_token_2 ;
                    SD_R_start_token[1] = SD_R_start_token_1 ;
                    SD_R_start_token[0] = SD_R_start_token_0 ;
                end
                4 : begin 
                    SD_R_start_token[7] = SD_R_start_token_7 ;
                    SD_R_start_token[6] = SD_R_start_token_6 ;
                    SD_R_start_token[5] = SD_R_start_token_5 ;
                    SD_R_start_token[4] = SD_R_start_token_4 ;
                    SD_R_start_token[3] = MISO ;
                    SD_R_start_token[2] = SD_R_start_token_2 ;
                    SD_R_start_token[1] = SD_R_start_token_1 ;
                    SD_R_start_token[0] = SD_R_start_token_0 ;
                end
                5 : begin 
                    SD_R_start_token[7] = SD_R_start_token_7 ;
                    SD_R_start_token[6] = SD_R_start_token_6 ;
                    SD_R_start_token[5] = SD_R_start_token_5 ;
                    SD_R_start_token[4] = SD_R_start_token_4 ;
                    SD_R_start_token[3] = SD_R_start_token_3 ;
                    SD_R_start_token[2] = MISO ;
                    SD_R_start_token[1] = SD_R_start_token_1 ;
                    SD_R_start_token[0] = SD_R_start_token_0 ;
                end
                6 : begin 
                    SD_R_start_token[7] = SD_R_start_token_7 ;
                    SD_R_start_token[6] = SD_R_start_token_6 ;
                    SD_R_start_token[5] = SD_R_start_token_5 ;
                    SD_R_start_token[4] = SD_R_start_token_4 ;
                    SD_R_start_token[3] = SD_R_start_token_3 ;
                    SD_R_start_token[2] = SD_R_start_token_2 ;
                    SD_R_start_token[1] = MISO ;
                    SD_R_start_token[0] = SD_R_start_token_0 ;
                end
                7 :begin 
                    SD_R_start_token[7] = SD_R_start_token_7 ;
                    SD_R_start_token[6] = SD_R_start_token_6 ;
                    SD_R_start_token[5] = SD_R_start_token_5 ;
                    SD_R_start_token[4] = SD_R_start_token_4 ;
                    SD_R_start_token[3] = SD_R_start_token_3 ;
                    SD_R_start_token[2] = SD_R_start_token_2 ;
                    SD_R_start_token[1] = SD_R_start_token_1 ;
                    SD_R_start_token[0] = MISO ;
                end
                default: SD_R_start_token = 8'b1111_1111 ;
            endcase
        end else begin
            SD_R_start_token = 8'b1111_1111 ;
        end
    end else begin
        SD_R_start_token = 8'b1111_1111 ;
    end
end

//* SD_R_DATA_start_flag_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_R_DATA_start_flag_q <= 1'b0 ;
    end else begin
        SD_R_DATA_start_flag_q <= SD_R_DATA_start_flag_d ;
    end
end

//* SD_R_DATA_start_flag_d
always @(*) begin
    if ( bridge_state_q == SD_READ ) begin
        if ( SD_R_DATA_start_flag_q == 1) begin
            if (SD_READ_flag_q == 1) begin
                SD_R_DATA_start_flag_d = 0 ;
            end else begin
                SD_R_DATA_start_flag_d = 1 ;
            end
        end else begin
            if (SD_R_start_token == 8'hFE) begin
                if (SD_READ_cnt[2:0]==3'd7) begin
                    SD_R_DATA_start_flag_d = 1 ;
                end else begin
                    SD_R_DATA_start_flag_d = 0 ;
                end
            end else begin
                SD_R_DATA_start_flag_d = 0 ;
            end
        end
    end else begin
        SD_R_DATA_start_flag_d = 0 ;
    end
end

//* SD_R_DATA_cnt
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_R_DATA_cnt <= 1'b0 ;
    end else begin
        if (bridge_state_q == SD_READ) begin
            if (SD_R_DATA_start_flag_q == 1) begin
                SD_R_DATA_cnt <= SD_R_DATA_cnt + 1 ;
            end else begin
                SD_R_DATA_cnt <= 0 ;
            end
        end else begin
            SD_R_DATA_cnt <= 0 ;
        end
    end
end

//* SD_R_data_block_done_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_R_data_block_done_q <= 1'b0 ;
    end else begin
        SD_R_data_block_done_q <= SD_R_data_block_done_d ;
    end
end

//* SD_R_data_block_done_d
always @(*) begin
    if ( bridge_state_q == SD_READ ) begin
        if (SD_R_data_block_done_q == 1) begin
            if (SD_READ_flag_q) begin
                SD_R_data_block_done_d = 0 ;
            end else begin
                SD_R_data_block_done_d = 1 ;
            end
        end else begin
            if (SD_R_DATA_cnt==63) begin
                SD_R_data_block_done_d = 1 ;
            end else begin
                SD_R_data_block_done_d = 0 ;
            end
        end
    end else begin
        SD_R_data_block_done_d = 0 ;
    end
end

//* Receive data & CRC16
//* SD_READ_DATA_repo
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_READ_DATA_repo <= 0 ;
    end else begin
        if ( bridge_state_q == SD_READ ) begin
            if ( SD_R_DATA_start_flag_q == 1 ) begin
                if (SD_R_data_block_done_q==0) begin
                    SD_READ_DATA_repo[64-1-SD_R_DATA_cnt] <= MISO ;
                end
            end
        end
    end
end

//* SD_READ_flag_d
always @(*) begin
    if ( bridge_state_q == SD_READ ) begin
        if (SD_R_DATA_cnt == (64+16-1)) begin
            SD_READ_flag_d = 1 ;
        end else begin
            SD_READ_flag_d = 0 ;
        end
    end else begin
        SD_READ_flag_d = 0 ;
    end
end

//==============================================//
//*                   SD WRITE                  //
//==============================================//
//* SD_WRITE_flag_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_WRITE_flag_q <= 1'b0 ;
    end else begin
        SD_WRITE_flag_q <= SD_WRITE_flag_d ;
    end
end

//* SD_WRITE_cnt
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_WRITE_cnt <= 1'b0 ;
    end else begin
        if (bridge_state_q == SD_WRITE) begin
            SD_WRITE_cnt <= SD_WRITE_cnt + 1 ;
        end else begin
            SD_WRITE_cnt <= 0 ;
        end
    end
end

//* MOSI is in line 302

//* SD_W_cmd_done_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_W_cmd_done_q <= 1'b0 ;
    end else begin
        SD_W_cmd_done_q <= SD_W_cmd_done_d ;
    end
end

//* SD_W_cmd_done_d
always @(*) begin
    if ( bridge_state_q == SD_WRITE ) begin
        if (SD_W_cmd_done_q == 1) begin
            if (SD_WRITE_flag_q == 1) begin
                SD_W_cmd_done_d = 0 ;
            end else begin
                SD_W_cmd_done_d = 1 ;
            end
        end else begin
            if (SD_WRITE_cnt == 47) begin
                SD_W_cmd_done_d = 1 ;
            end else begin
                SD_W_cmd_done_d = 0 ;
            end
        end
    end else begin
        SD_W_cmd_done_d = 0 ;
    end
end

//* SD_W_CRC7_result
always @(*) begin
    if ( bridge_state_q == SD_WRITE ) begin 
        if ( SD_W_cmd_done_q == 0 ) begin
            SD_W_CRC7_result = CRC7({SD_WRITE_START_BIT,SD_WRITE_transmission_bit,SD_WRITE_COMMAND,addr_sd_q});
        end else begin
            SD_W_CRC7_result = 0 ;
        end
    end else begin
        SD_W_CRC7_result = 0 ;
    end
end

//* SD_W_CRC16_result
always @(*) begin
    if (bridge_state_q == SD_WRITE) begin
        if (SD_W_response_done_q == 1) begin
            SD_W_CRC16_result = CRC16_CCITT(DRAM_READ_DATA_repo);
        end else begin
            SD_W_CRC16_result = 0 ;
        end
    end else begin
        SD_W_CRC16_result = 0 ;
    end
end

//* SD_W_response_done_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_W_response_done_q <= 1'b0 ;
    end else begin
        SD_W_response_done_q <= SD_W_response_done_d ;
    end
end

//* SD_W_response_done_d
always @(*) begin
    if (bridge_state_q == SD_WRITE) begin
        if (SD_W_response_done_q == 1) begin
            if (SD_WRITE_flag_q == 1) begin
                SD_W_response_done_d = 0 ;
            end else begin
                SD_W_response_done_d = 1 ;
            end
        end else begin
            if (SD_W_Response_token == 8'b0000_0000) begin
                if (SD_WRITE_cnt[2:0]==3'd7) begin
                    SD_W_response_done_d = 1 ;
                end else begin
                    SD_W_response_done_d = 0 ;
                end
            end else begin
                SD_W_response_done_d = 0 ;
            end
        end
    end else begin
        SD_W_response_done_d = 0 ;
    end
end

//* SD_W_Response_token reg 
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_W_Response_token_0 <= 1'b1 ;
        SD_W_Response_token_1 <= 1'b1 ;
        SD_W_Response_token_2 <= 1'b1 ;
        SD_W_Response_token_3 <= 1'b1 ;
        SD_W_Response_token_4 <= 1'b1 ;
        SD_W_Response_token_5 <= 1'b1 ;
        SD_W_Response_token_6 <= 1'b1 ;
        SD_W_Response_token_7 <= 1'b1 ;
    end else begin
        SD_W_Response_token_0 <= SD_W_Response_token[0];
        SD_W_Response_token_1 <= SD_W_Response_token[1];
        SD_W_Response_token_2 <= SD_W_Response_token[2];
        SD_W_Response_token_3 <= SD_W_Response_token[3];
        SD_W_Response_token_4 <= SD_W_Response_token[4];
        SD_W_Response_token_5 <= SD_W_Response_token[5];
        SD_W_Response_token_6 <= SD_W_Response_token[6];
        SD_W_Response_token_7 <= SD_W_Response_token[7];
    end
end

//* SD_W_Response_token
always @(*) begin
    if (bridge_state_q == SD_WRITE) begin
        if (SD_W_cmd_done_q == 1) begin
            case (SD_WRITE_cnt[2:0])
                0 : begin 
                    SD_W_Response_token[7] = MISO ;
                    SD_W_Response_token[6] = SD_W_Response_token_6  ;
                    SD_W_Response_token[5] = SD_W_Response_token_5  ;
                    SD_W_Response_token[4] = SD_W_Response_token_4  ;
                    SD_W_Response_token[3] = SD_W_Response_token_3  ;
                    SD_W_Response_token[2] = SD_W_Response_token_2  ;
                    SD_W_Response_token[1] = SD_W_Response_token_1  ;
                    SD_W_Response_token[0] = SD_W_Response_token_0 ;
                end
                1 : begin 
                    SD_W_Response_token[7] = SD_W_Response_token_7  ;
                    SD_W_Response_token[6] = MISO ;
                    SD_W_Response_token[5] = SD_W_Response_token_5 ;
                    SD_W_Response_token[4] = SD_W_Response_token_4  ;
                    SD_W_Response_token[3] = SD_W_Response_token_3  ;
                    SD_W_Response_token[2] = SD_W_Response_token_2  ;
                    SD_W_Response_token[1] = SD_W_Response_token_1  ;
                    SD_W_Response_token[0] = SD_W_Response_token_0  ;
                end
                2 : begin 
                    SD_W_Response_token[7] = SD_W_Response_token_7  ;
                    SD_W_Response_token[6] = SD_W_Response_token_6  ;
                    SD_W_Response_token[5] = MISO ;
                    SD_W_Response_token[4] = SD_W_Response_token_4  ;
                    SD_W_Response_token[3] = SD_W_Response_token_3  ;
                    SD_W_Response_token[2] = SD_W_Response_token_2  ;
                    SD_W_Response_token[1] = SD_W_Response_token_1  ;
                    SD_W_Response_token[0] = SD_W_Response_token_0  ;
                end
                3 : begin 
                    SD_W_Response_token[7] = SD_W_Response_token_7  ;
                    SD_W_Response_token[6] = SD_W_Response_token_6  ;
                    SD_W_Response_token[5] = SD_W_Response_token_5  ;
                    SD_W_Response_token[4] = MISO ;
                    SD_W_Response_token[3] = SD_W_Response_token_3 ;
                    SD_W_Response_token[2] = SD_W_Response_token_2  ;
                    SD_W_Response_token[1] = SD_W_Response_token_1  ;
                    SD_W_Response_token[0] = SD_W_Response_token_0  ;
                end
                4 : begin 
                    SD_W_Response_token[7] = SD_W_Response_token_7  ;
                    SD_W_Response_token[6] = SD_W_Response_token_6  ;
                    SD_W_Response_token[5] = SD_W_Response_token_5  ;
                    SD_W_Response_token[4] = SD_W_Response_token_4  ;
                    SD_W_Response_token[3] = MISO ;
                    SD_W_Response_token[2] = SD_W_Response_token_2  ;
                    SD_W_Response_token[1] = SD_W_Response_token_1  ;
                    SD_W_Response_token[0] = SD_W_Response_token_0  ;
                end
                5 : begin 
                    SD_W_Response_token[7] = SD_W_Response_token_7  ;
                    SD_W_Response_token[6] = SD_W_Response_token_6  ;
                    SD_W_Response_token[5] = SD_W_Response_token_5  ;
                    SD_W_Response_token[4] = SD_W_Response_token_4  ;
                    SD_W_Response_token[3] = SD_W_Response_token_3  ;
                    SD_W_Response_token[2] = MISO ;
                    SD_W_Response_token[1] = SD_W_Response_token_1  ;
                    SD_W_Response_token[0] = SD_W_Response_token_0  ;
                end
                6 : begin 
                    SD_W_Response_token[7] = SD_W_Response_token_7  ;
                    SD_W_Response_token[6] = SD_W_Response_token_6  ;
                    SD_W_Response_token[5] = SD_W_Response_token_5  ;
                    SD_W_Response_token[4] = SD_W_Response_token_4  ;
                    SD_W_Response_token[3] = SD_W_Response_token_3  ;
                    SD_W_Response_token[2] = SD_W_Response_token_2  ;
                    SD_W_Response_token[1] = MISO ;
                    SD_W_Response_token[0] = SD_W_Response_token_1  ;
                end
                7 : begin 
                    SD_W_Response_token[7] = SD_W_Response_token_7  ;
                    SD_W_Response_token[6] = SD_W_Response_token_6  ;
                    SD_W_Response_token[5] = SD_W_Response_token_5  ;
                    SD_W_Response_token[4] = SD_W_Response_token_4  ;
                    SD_W_Response_token[3] = SD_W_Response_token_3  ;
                    SD_W_Response_token[2] = SD_W_Response_token_2  ;
                    SD_W_Response_token[1] = SD_W_Response_token_1  ;
                    SD_W_Response_token[0] = MISO ;
                end
                default: SD_W_Response_token = 8'b1111_1111 ;
            endcase
        end else begin
            SD_W_Response_token = 8'b1111_1111 ;
        end
    end else begin
        SD_W_Response_token = 8'b1111_1111 ;
    end
end

//* SD_W_DATA_cnt
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_W_DATA_cnt <= 1'b0 ;
    end else begin
        if ( bridge_state_q == SD_WRITE ) begin
            if ( SD_W_response_done_q == 1 ) begin
                SD_W_DATA_cnt <= SD_W_DATA_cnt + 1 ;
            end else begin
                SD_W_DATA_cnt <= 0 ;
            end
        end else begin
            SD_W_DATA_cnt <= 0 ;
        end
    end
end

//* SD_W_DATA_done_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_W_DATA_done_q <= 1'b0 ;
    end else begin
        SD_W_DATA_done_q <= SD_W_DATA_done_d ;
    end
end

//* SD_W_DATA_done_d
always @(*) begin
    if ( bridge_state_q == SD_WRITE ) begin
        if (SD_W_DATA_done_q == 1) begin
            if (SD_WRITE_flag_q == 1) begin
                SD_W_DATA_done_d = 0 ;
            end else begin
                SD_W_DATA_done_d = 1 ;
            end
        end else begin
            if ( SD_W_DATA_cnt == 95 ) begin
                SD_W_DATA_done_d = 1 ;
            end else begin
                SD_W_DATA_done_d = 0 ;
            end
        end
    end else begin
        SD_W_DATA_done_d = 0 ;
    end
end

//* SD_W_data_response_done_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        SD_W_data_response_done_q <= 1'b0 ;
    end else begin
        SD_W_data_response_done_q <= SD_W_data_response_done_d ;
    end
end

//* SD_W_data_response_done_d
always @(*) begin
    if (bridge_state_q == SD_WRITE) begin
        if (SD_W_data_response_done_q == 1 ) begin
            if (SD_WRITE_flag_q == 1) begin
                SD_W_data_response_done_d = 0 ;
            end else begin
                SD_W_data_response_done_d = 1 ;
            end
        end else begin
            if (buzy_flag_q && MISO ) begin
                SD_W_data_response_done_d = 1 ;
            end else begin
                SD_W_data_response_done_d = 0 ;
            end
        end
    end else begin
        SD_W_data_response_done_d = 0 ;
    end
end

//* Buzy_token reg 
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        Buzy_token_0 <= 1'b1 ;
        Buzy_token_1 <= 1'b1 ;
        Buzy_token_2 <= 1'b1 ;
        Buzy_token_3 <= 1'b1 ;
        Buzy_token_4 <= 1'b1 ;
        Buzy_token_5 <= 1'b1 ;
        Buzy_token_6 <= 1'b1 ;
        Buzy_token_7 <= 1'b1 ;
    end else begin
        Buzy_token_0 <= Buzy_token[0] ;
        Buzy_token_1 <= Buzy_token[1] ;
        Buzy_token_2 <= Buzy_token[2] ;
        Buzy_token_3 <= Buzy_token[3] ;
        Buzy_token_4 <= Buzy_token[4] ;
        Buzy_token_5 <= Buzy_token[5] ;
        Buzy_token_6 <= Buzy_token[6] ;
        Buzy_token_7 <= Buzy_token[7] ;
    end
end

//* Buzy_token
always @(*) begin
    Buzy_token[0] = Buzy_token_0 ;
    Buzy_token[1] = Buzy_token_1 ;
    Buzy_token[2] = Buzy_token_2 ;
    Buzy_token[3] = Buzy_token_3 ;
    Buzy_token[4] = Buzy_token_4 ;
    Buzy_token[5] = Buzy_token_5 ;
    Buzy_token[6] = Buzy_token_6 ;
    Buzy_token[7] = Buzy_token_7 ;
    if ( bridge_state_q == SD_WRITE ) begin
        if (SD_W_DATA_done_d == 1) begin
            case (SD_W_DATA_cnt[2:0])
                0: Buzy_token[7] = MISO ;
                1: Buzy_token[6] = MISO ;
                2: Buzy_token[5] = MISO ;
                3: Buzy_token[4] = MISO ;
                4: Buzy_token[3] = MISO ;
                5: Buzy_token[2] = MISO ;
                6: Buzy_token[1] = MISO ;
                7: Buzy_token[0] = MISO ;
                default: Buzy_token = 8'b1111_1111 ;
            endcase
        end else begin
            Buzy_token = 8'b1111_1111 ;
        end
    end else begin
        Buzy_token = 8'b1111_1111 ;
    end
end

//* buzy_flag_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        buzy_flag_q <= 1'b0 ;
    end else begin
        buzy_flag_q <= buzy_flag_d ;
    end
end

//* buzy_flag_d
always @(*) begin
    if ( bridge_state_q == SD_WRITE ) begin
        if (buzy_flag_q == 1) begin
            if (SD_WRITE_flag_q == 1) begin
                buzy_flag_d = 0 ;
            end else begin
                buzy_flag_d = 1 ;
            end
        end else begin
            if ( Buzy_token == 8'b0000_0101 ) begin
                if (SD_W_DATA_cnt[2:0]==3'd7) begin
                    buzy_flag_d = 1 ;
                end else begin
                    buzy_flag_d = 0 ;
                end
            end else begin
                buzy_flag_d = 0 ;
            end
        end
    end else begin
        buzy_flag_d = 0 ;
    end
end

//* SD_WRITE_flag_d
always @(*) begin
    if (bridge_state_q == SD_WRITE) begin
        if (SD_W_data_response_done_q==1) begin
            SD_WRITE_flag_d = 1 ;
        end else begin
            SD_WRITE_flag_d = 0 ;
        end
    end else begin
        SD_WRITE_flag_d = 0 ;
    end
end

//==============================================//
//*                   DRAM READ                 //
//==============================================//
//* DRAM_READ_flag_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        DRAM_READ_flag_q <= 1'b0 ;
    end else begin
        DRAM_READ_flag_q <= DRAM_READ_flag_d ;
    end
end

//* DRAM_READ_flag_d
always @(*) begin
    if (bridge_state_q == DRAM_READ) begin
        DRAM_READ_flag_d = (R_done_q && AR_done_q);
    end else begin
        DRAM_READ_flag_d = 0 ;
    end
end

//* AR_done_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        AR_done_q <= 1'b0 ;
    end else begin
        AR_done_q <= AR_done_d ;
    end
end

//* AR_VALID , AR_ADDR
always @(*) begin
    if (bridge_state_q == DRAM_READ) begin
        if (AR_done_q == 0) begin
            AR_VALID = 1 ;
            AR_ADDR = addr_dram_q ;
        end else begin
            AR_VALID = 0 ;
            AR_ADDR = 0 ;
        end
    end else begin
        AR_VALID = 0 ;
        AR_ADDR = 0 ;
    end
end

//* AR_done_d
always @(*) begin
    if ( bridge_state_q == DRAM_READ ) begin
        if (AR_done_q==1) begin
            if (DRAM_READ_flag_q==1) begin
                AR_done_d = 0 ;
            end else begin
                AR_done_d = 1 ;
            end
        end else begin
            if (AR_VALID==1 && AR_READY==1) begin
                AR_done_d = 1 ;
            end else begin
                AR_done_d = 0 ;
            end
        end
    end else begin
        AR_done_d = 0 ;
    end
end

//* R_READY
always @(*) begin
    if ( bridge_state_q == DRAM_READ ) begin
        if (AR_done_q == 1) begin
            if (R_done_q == 0) begin
                R_READY = 1 ;
            end else begin
                R_READY = 0 ;
            end
        end else begin
            R_READY = 0 ;
        end
    end else begin
        R_READY = 0 ;
    end
end

//* R_done_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        R_done_q <= 1'b0 ;
    end else begin
        R_done_q <= R_done_d ;
    end
end

//* R_done_d
always @(*) begin
    if (bridge_state_q == DRAM_READ) begin
        if ( R_done_q == 1 ) begin
            if (DRAM_READ_flag_q == 1) begin
                R_done_d = 0 ;
            end else begin
                R_done_d = 1 ;
            end
        end else begin
            if (R_VALID==1 && R_READY==1) begin
                R_done_d = 1 ;
            end else begin
                R_done_d = 0 ;
            end
        end
    end else begin
        R_done_d = 0 ;
    end
end

//* R_DATA
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        DRAM_READ_DATA_repo <= 1'b0 ;
    end else begin
        if (R_VALID && R_READY) begin
            DRAM_READ_DATA_repo <= R_DATA ;
        end
    end
end

//==============================================//
//*                   DRAM WRITE                //
//==============================================//
//* DRAM_WRITE_flag_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        DRAM_WRITE_flag_q <= 1'b0 ;
    end else begin
        DRAM_WRITE_flag_q <= DRAM_WRITE_flag_d ;
    end
end

//* DRAM_WRITE_flag_d
always @(*) begin
    if (bridge_state_q == DRAM_WRITE) begin
        if (B_done_q == 1) begin
            DRAM_WRITE_flag_d = 1 ;
        end else begin
            DRAM_WRITE_flag_d = 0 ;
        end
    end else begin
        DRAM_WRITE_flag_d = 0 ;
    end
end

//* AW_done_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        AW_done_q <= 1'b0 ;
    end else begin
        AW_done_q <= AW_done_d ;
    end
end

//* AW_done_d
always @(*) begin
    if ( bridge_state_q == DRAM_WRITE ) begin
        if (AW_done_q==1) begin
            if (DRAM_WRITE_flag_q==1) begin
                AW_done_d = 0 ;
            end else begin
                AW_done_d = 1 ;
            end
        end else begin
            if (AW_READY && AW_VALID) begin
                AW_done_d = 1 ;
            end else begin
                AW_done_d = 0 ;
            end
        end
    end else begin
        AW_done_d = 0 ;
    end
end

//* W_done_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        W_done_q <= 1'b0 ;
    end else begin
        W_done_q <= W_done_d ;
    end
end

//* W_done_d 
always @(*) begin
    if ( bridge_state_q == DRAM_WRITE ) begin
        if (W_done_q==1) begin
            if (DRAM_WRITE_flag_q == 1) begin
                W_done_d = 0 ;
            end else begin
                W_done_d = 1 ;
            end
        end else begin
            if (W_READY && W_READY) begin
                W_done_d = 1 ;
            end else begin
                W_done_d = 0 ; 
            end
        end
    end else begin
        W_done_d = 0 ;
    end
end

//* AW_VALID , AW_ADDR 
always @(*) begin
    if ( bridge_state_q == DRAM_WRITE ) begin
        if ( AW_done_q == 0 ) begin
            AW_VALID = 1 ; 
            AW_ADDR  = addr_dram_q ;
        end else begin
            AW_VALID = 0 ; 
            AW_ADDR  = 0 ;
        end
    end else begin
        AW_VALID = 0 ; 
        AW_ADDR  = 0 ;
    end 
end

//* W_VALID , W_DATA
always @(*) begin
    if ( bridge_state_q == DRAM_WRITE ) begin
        if (AW_done_q==1) begin
            if (W_done_q==1) begin
                W_VALID = 0 ;
                W_DATA = 0 ;
            end else begin
                W_VALID = 1 ;
                W_DATA = SD_READ_DATA_repo ;
            end
        end else begin
            W_VALID = 0 ;
            W_DATA = 0 ;
        end
    end else begin
        W_VALID = 0 ;
        W_DATA = 0 ;
    end
end

//* B_READY
always @(*) begin
    if ( bridge_state_q == DRAM_WRITE ) begin
        if (AW_done_q && W_done_q) begin
            if (B_done_q == 1) begin
                B_READY = 0 ;
            end else begin
                B_READY = 1 ;
            end
        end else begin
            B_READY = 0 ;
        end
    end else begin
        B_READY = 0 ;
    end
end

//* B_done_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        B_done_q <= 1'b0 ;
    end else begin
        B_done_q <= B_done_d ;
    end
end

//* B_done_d
always @(*) begin
    if (bridge_state_q == DRAM_WRITE) begin
        if (B_done_q==1) begin
            if (DRAM_WRITE_flag_q == 1) begin
                B_done_d = 0 ;
            end else begin
                B_done_d = 1 ;
            end
        end else begin
            if (B_VALID && B_READY) begin
                B_done_d = 1 ;
            end else begin
                B_done_d = 0 ;
            end
        end
    end else begin
        B_done_d = 0 ;
    end
end

//==============================================//
//*                    YIELD                    //
//==============================================//
//* YIELD_flag_q
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        YIELD_flag_q <= 1'b0 ;
    end else begin
        YIELD_flag_q <= YIELD_flag_d ;
    end
end

//* YIELD_flag_d
always @(*) begin
    if ( bridge_state_q == YIELD ) begin
        if (Y_cnt == 6) begin
            YIELD_flag_d = 1 ;
        end else begin
            YIELD_flag_d = 0 ;
        end
    end else begin
        YIELD_flag_d = 0 ;
    end
end

//* out_valid
always @(*) begin
    if ( bridge_state_q == YIELD ) begin
        out_valid = 1 ;
    end else begin
        out_valid = 0 ;
    end
end

//* out_data_d
always @(*) begin
    if ( bridge_state_q == YIELD ) begin
        case (Y_cnt)
            0: out_data_d = (direction_q)? (SD_READ_DATA_repo[63:56]) : (DRAM_READ_DATA_repo[63:56]) ;
            1: out_data_d = (direction_q)? (SD_READ_DATA_repo[55:48]) : (DRAM_READ_DATA_repo[55:48]) ;
            2: out_data_d = (direction_q)? (SD_READ_DATA_repo[47:40]) : (DRAM_READ_DATA_repo[47:40]) ;
            3: out_data_d = (direction_q)? (SD_READ_DATA_repo[39:32]) : (DRAM_READ_DATA_repo[39:32]) ;
            4: out_data_d = (direction_q)? (SD_READ_DATA_repo[31:24]) : (DRAM_READ_DATA_repo[31:24]) ;
            5: out_data_d = (direction_q)? (SD_READ_DATA_repo[23:16]) : (DRAM_READ_DATA_repo[23:16]) ;
            6: out_data_d = (direction_q)? (SD_READ_DATA_repo[15: 8]) : (DRAM_READ_DATA_repo[15: 8]) ;
            7: out_data_d = (direction_q)? (SD_READ_DATA_repo[7 : 0]) : (DRAM_READ_DATA_repo[7 : 0]) ;
            default: out_data_d = 0 ;
        endcase
    end else begin
        out_data_d = 0 ;
    end
end

//* Y_cnt 
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        Y_cnt <= 1'b0 ;
    end else begin
        if ( bridge_state_q == YIELD ) begin
            Y_cnt <= Y_cnt + 1 ;
        end else begin
            Y_cnt <= 0 ;
        end
    end
end


//==============================================//
//             Example for function             //
//==============================================//

function automatic [6:0] CRC7;  // Return 7-bit result
    input [39:0] data;  // 40-bit data input
    reg [6:0] crc;
    integer i;
    reg data_in, data_out;
    parameter polynomial = 7'h9;  // x^7 + x^3 + 1

    begin
        crc = 7'd0;
        for (i = 0; i < 40; i = i + 1) begin
            data_in = data[39-i];
            data_out = crc[6];
            crc = crc << 1;  // Shift the CRC
            if (data_in ^ data_out) begin
                crc = crc ^ polynomial;
            end
        end
        CRC7 = crc;
    end
endfunction

function automatic [15:0] CRC16_CCITT;
    input [63:0] data;  // 40-bit data input
    reg [15:0] crc;
    integer i;
    reg data_in, data_out;
    parameter polynomial = 16'h1021;  // x^16 + x^12 + x^5 + 1

    begin
        crc = 16'd0;
        for (i = 0; i < 64; i = i + 1) begin
            data_in = data[63-i];
            data_out = crc[15];
            crc = crc << 1;  // Shift the CRC
            if (data_in ^ data_out) begin
                crc = crc ^ polynomial;
            end
        end
        CRC16_CCITT = crc;
    end
endfunction
endmodule

