
// iclab065 
// 2023-4-22
// 312605003
// Wang Yu
// version : submit

module CLK_1_MODULE 
#(parameter DATA_WIDTH = 4)(
input  wire                     clk,                //! @ 01sim : 4.1ns, 7.1ns, 17.1ns, 47.1ns , @ 03sim : 47.1ns
input  wire                     rst_n,
input  wire                     in_valid,
input  wire [DATA_WIDTH-1:0]    in_matrix_A,
input  wire [DATA_WIDTH-1:0]    in_matrix_B,
input  wire                     out_idle,
output reg                      handshake_sready,
output reg [2*DATA_WIDTH-1:0]   handshake_din,
input  wire                     fifo_empty,
input  wire [2*DATA_WIDTH-1:0]  fifo_rdata,
output reg                      fifo_rinc,
output reg                      out_valid,
output reg [2*DATA_WIDTH-1:0]   out_matrix,
//! These flags are no use .
input  wire                     flag_handshake_to_clk1,
output wire                     flag_clk1_to_handshake,
output wire                     flag_clk1_to_fifo,
input  wire                     flag_fifo_to_clk1  );
reg [4:0] storage_cnt;
reg [4:0] trans_B_cnt;
//----------------------------
// FSM
//----------------------------
localparam  IDLE =  2'd0,
            INPUT = 2'd1,
            TRANS = 2'd2;
reg [1:0] FSM_S_q, FSM_S_d;


//* FSM_S_q
always@(posedge clk or negedge rst_n) FSM_S_q <= (~rst_n) ? IDLE : FSM_S_d;

//* FSM_S_d
always@(*) begin
    case (FSM_S_q)
        IDLE:       FSM_S_d = (in_valid)?                   INPUT : IDLE ;
        INPUT:      FSM_S_d = (storage_cnt > 15 )?          TRANS : INPUT ;
        TRANS :     FSM_S_d = (trans_B_cnt > 15) ?  IDLE : TRANS ;
        default:    FSM_S_d = IDLE;
    endcase
end

//----------------------------
// Recieve data
//----------------------------
// storage registers for input data
reg [3:0] matrix_A_storage [0:15] , matrix_B_storage [0:15];


//* matrix_A_storage , matrix_B_storage
always@(posedge clk) begin
    if(in_valid) begin 
        matrix_A_storage[storage_cnt] <= in_matrix_A;
        matrix_B_storage[storage_cnt] <= in_matrix_B;
    end
end

//* storage_cnt
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) storage_cnt <= 0;
    else begin
        if(in_valid)     storage_cnt <= storage_cnt + 1;
        else if(FSM_S_q == IDLE) storage_cnt <= 0;
    end
end
//----------------------------
// Send data
//----------------------------
reg [4:0] trans_A_cnt;


//* handshake_sready
always @(*) handshake_sready = (storage_cnt != 16) ? 1'b0 : out_idle;

//* trans_A_cnt
always@(posedge clk or negedge rst_n) begin
    if(~rst_n)    trans_A_cnt <= 0;
    else begin
        if(FSM_S_q == TRANS) begin 
            if(handshake_sready) begin 
                if(trans_A_cnt<16) trans_A_cnt <= trans_A_cnt + 1;
                else if(FSM_S_q == IDLE ) trans_A_cnt <= 0;
            end
            else if(FSM_S_q == IDLE ) trans_A_cnt <= 0;
        end
        else if(FSM_S_q == IDLE ) trans_A_cnt <= 0;
    end
end

//* trans_B_cnt
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) trans_B_cnt <= 0;
    else begin
        if(FSM_S_q == TRANS) begin
            if ( handshake_sready ) begin 
                if( trans_A_cnt == 16)  trans_B_cnt <= trans_B_cnt + 1;
                else if(FSM_S_q == IDLE) trans_B_cnt <= 0;     
            end
            else if(FSM_S_q == IDLE) trans_B_cnt <= 0;    
        end
        else if(FSM_S_q == IDLE) trans_B_cnt <= 0;
    end
end

//* handshake_din
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) handshake_din <= 0;
    else if(handshake_sready && FSM_S_q == TRANS) handshake_din <= (trans_A_cnt < 16) ? matrix_A_storage[trans_A_cnt] : matrix_B_storage[trans_B_cnt];
end

//----------------------------
// Read data from FIFO
//----------------------------
reg fifo_empty_q ;
reg fifo_empty_qq;

//* fifo_rinc
always @(*) fifo_rinc = (~fifo_empty) ? 1 : 0;

//* fifo_empty
always @(posedge clk or negedge rst_n) fifo_empty_q <= (~rst_n) ? 1'b1 : fifo_empty;

//* fifo_empty_qq
always @(posedge clk or negedge rst_n) fifo_empty_qq <= (~rst_n) ? 1'b1 : fifo_empty_q;

//----------------------------
// Output data
//----------------------------
//
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin
        out_valid <= 0 ;
        out_matrix <= 0 ;
    end else begin
        if(~fifo_empty_qq) begin
            out_valid <= 1'b1 ;
            out_matrix <= fifo_rdata ;
        end else begin
            out_valid <= 0 ;
            out_matrix <= 0 ;
        end
    end
end
endmodule



module CLK_2_MODULE 
#(parameter DATA_WIDTH = 4)(
input  wire                     clk,
input  wire                     rst_n,
input  wire                     in_valid,
input  wire                     fifo_full,
input  wire [2*DATA_WIDTH-1:0]  in_matrix,
output reg                      out_valid,
output reg [2*DATA_WIDTH-1:0]   out_matrix,
output reg                      busy,
//! These flags are no use .
input  wire                     flag_handshake_to_clk2,
output wire                     flag_clk2_to_handshake,
input  wire                     flag_fifo_to_clk2,
output wire                     flag_clk2_to_fifo      );
// -------------------------
// parameters
// -------------------------
reg in_valid_pulse ;
reg [5:0] store_cnt_B;
reg [8:0] cnt_write;
reg [3:0] mult_A , mult_B;
reg [3:0] cnt_calc_A , cnt_calc_B;
reg [7:0] ans_matrix [0:255] ;
reg [8:0] ans_cnt;
reg start_output_flag;
integer i ;

//----------------------------
// FSM
//----------------------------
localparam  IDLE = 0,
            SAVE = 1,
            WRITE = 2;
reg [1:0] FSM_D_q, FSM_D_d;

//* FSM_D_q
always@(posedge clk or negedge rst_n) FSM_D_q <= (~rst_n) ? IDLE : FSM_D_d;

//* FSM_D_d
always@(*) begin 
    case (FSM_D_q)
        IDLE : FSM_D_d = (in_valid_pulse)? SAVE : IDLE;
        SAVE : FSM_D_d = (store_cnt_B == 16)? WRITE : SAVE;
        WRITE : FSM_D_d = (cnt_write == 256 && ~fifo_full)? IDLE : WRITE;
        default: FSM_D_d = IDLE;
    endcase
end

//----------------------------
// Handshake
//----------------------------

//* busy
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) busy <= 0;
    else if(store_cnt_B == 16 && cnt_write != 'b100000000) busy <= 1;
    else if(cnt_write == 'b100000000 && ~fifo_full) busy <= 0;
end


//----------------------------
// Save maatrix A , B
//----------------------------
reg in_valid_q ;


//* in_valid_q
always @(posedge clk or negedge rst_n) in_valid_q <= (~rst_n) ? 0 : in_valid;

//* in_valid_pulse
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) in_valid_pulse <= 0 ;
    else if(!in_valid) in_valid_pulse <= (in_valid ^ in_valid_q) ;
end

reg [5:0] store_cnt_A;
//* store_cnt_A
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) store_cnt_A <= 0;
    else begin
        if(store_cnt_A < 16 && in_valid_pulse &&  FSM_D_q==SAVE) store_cnt_A <= store_cnt_A + 1;
        else if(cnt_write == 'b100000000) store_cnt_A <= 0;
    end
end
  
//* store_cnt_B
always@(posedge clk or negedge rst_n) begin
    if(~rst_n) store_cnt_B <= 0;
    else begin
        if(store_cnt_A == 16 && in_valid_pulse &&  store_cnt_B < 16 && FSM_D_q==SAVE) store_cnt_B <= store_cnt_B + 1;
        else if(cnt_write == 'b100000000) store_cnt_B <= 0;
    end
end

reg [3:0] matrix_A[0:15] , matrix_B[0:15];
//* matrix_A
always@(posedge clk) begin
    if(in_valid_pulse & FSM_D_q[0]) matrix_A[store_cnt_A] <= in_matrix;
    else if(FSM_D_q == IDLE)
        for(i=0; i<16; i= i+1) begin
            matrix_A[i] <= 0;
        end
end

//* matrix_B
always@(posedge clk)begin
    if(in_valid_pulse & FSM_D_q[0])    matrix_B[store_cnt_B] <= in_matrix;
    else if(FSM_D_q == IDLE)
        for(i=0; i<16; i= i+1) begin 
            matrix_B[i] <= 0;
        end
end

//----------------------------
// Calculate matrix
//----------------------------

//* mult_A 
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) mult_A <= 0 ;
    else if(FSM_D_q == IDLE) mult_A <= 0 ;
    else if(store_cnt_B =='d16 && ~fifo_full) mult_A <= matrix_A[cnt_calc_A];
end

//* cnt_calc_A
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) cnt_calc_A <= 0 ;
    else if(FSM_D_q == IDLE) cnt_calc_A <= 0 ;
    else if(store_cnt_B =='d16 && ~fifo_full)
        if (cnt_calc_B == 'd15 && cnt_calc_A != 'd15) cnt_calc_A <= cnt_calc_A + 'd1;
end

//* mult_B
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) mult_B <= 0 ;
    else if(FSM_D_q == IDLE) mult_B <= 0 ;
    else if(store_cnt_B =='d16 && ~fifo_full) mult_B <= matrix_B[cnt_calc_B];
end

//*  cnt_calc_B
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) cnt_calc_B <= 0 ;
    else if(FSM_D_q == IDLE) cnt_calc_B <= 0 ;
    else if(store_cnt_B =='d16 && ~fifo_full) begin
        if(cnt_calc_B == 15) begin
            if(cnt_calc_A == 15) cnt_calc_B <= cnt_calc_B;
            else cnt_calc_B <= 0;
        end else cnt_calc_B <= cnt_calc_B + 1;
    end
end

//----------------------------
// Save ans
//----------------------------

//* start_output_flag
always @(*) begin
    if(~|(FSM_D_q))start_output_flag = 0;
    else if(store_cnt_B == 16 && cnt_calc_A == 0 && cnt_calc_B >= 1)start_output_flag = 1;
    else if(store_cnt_B == 16 && cnt_calc_A >= 1)start_output_flag = 1;
    else start_output_flag = 0;
end

//* cnt_write
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) cnt_write <= 0;
    else if(~|(FSM_D_q)) cnt_write <= 0;
    else if(busy && cnt_write < 'b100000000 && ~fifo_full) cnt_write <= cnt_write + 1;
    else cnt_write <= cnt_write;
end

//----------------------------
// Write to AFIFO
//----------------------------

//* out_valid 
always @(*) begin
    if(~rst_n) out_valid = 0 ;
    else begin
        if (busy && cnt_write < 256 && ~fifo_full) out_valid = 1 ;
        else out_valid = 0 ;
    end
end

//* out_matrix
always @(*) begin
    if(~rst_n) out_matrix = 0 ;
    else begin
        if(busy && cnt_write < 256 && ~fifo_full) out_matrix = mult_A * mult_B;
        else out_matrix = 0 ;
    end
end
endmodule







