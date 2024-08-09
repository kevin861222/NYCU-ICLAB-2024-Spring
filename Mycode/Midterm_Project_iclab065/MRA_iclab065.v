//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NYCU ED430
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2024 Spring
//   Midterm Proejct            : MRA  
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : MRA.v
//   Module Name : MRA
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

// Version : submit
// clk : 13.2 ns

// 13.1 ad

module MRA #(
  parameter ID_WIDTH   = 4,
            ADDR_WIDTH = 32,
            DATA_WIDTH = 128
) (
// CHIP IO
clk            	,	
rst_n          	,	
in_valid       	,	
frame_id        ,	
net_id         	,	  
loc_x          	,	  
loc_y         	,
cost	 		,		
busy         	,

// AXI4 IO
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
   rready_m_inf,

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
   bready_m_inf 
);

// ===============================================================
//  					Input / Output 
// ===============================================================
  // << CHIP io port with system >>
input clk;
input rst_n;
input in_valid;
input [4:0] frame_id;
input [3:0] net_id;
input [5:0] loc_x;
input [5:0] loc_y;
output reg [13:0] cost;
output reg busy;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
     Your AXI-4 interface could be designed as a bridge in submodule,
     therefore I declared output of AXI as wire.  
     Ex: AXI4_interface AXI4_INF(...);
*/
// ------------------------
// <<<<< AXI READ >>>>>
// ------------------------
// (1)	axi read address channel 
output wire [ID_WIDTH-1:0] arid_m_inf;     
output wire [1:0] arburst_m_inf;  
output wire [2:0] arsize_m_inf;  
output wire [7:0] arlen_m_inf;    
output wire arvalid_m_inf;
input  wire arready_m_inf;
output wire [ADDR_WIDTH-1:0] araddr_m_inf;
// ------------------------
// (2)	axi read data channel 
input  wire [ID_WIDTH-1:0] rid_m_inf;
input  wire rvalid_m_inf;
output wire rready_m_inf;
input  wire [DATA_WIDTH-1:0] rdata_m_inf;
input  wire rlast_m_inf;
input  wire [1:0] rresp_m_inf;   
// ------------------------
// <<<<< AXI WRITE >>>>>
// ------------------------
// (1) 	axi write address channel 
output wire [ID_WIDTH-1:0] awid_m_inf;     
output wire [1:0] awburst_m_inf;
output wire [2:0] awsize_m_inf;   
output wire [7:0] awlen_m_inf;    
output wire awvalid_m_inf;
input  wire awready_m_inf;
output wire [ADDR_WIDTH-1:0] awaddr_m_inf;
// -------------------------
// (2)	axi write data channel 
output wire wvalid_m_inf;
input  wire wready_m_inf;
output wire [DATA_WIDTH-1:0] wdata_m_inf;
output wire wlast_m_inf;
// -------------------------
// (3)	axi write response channel 
input  wire [ID_WIDTH-1:0] bid_m_inf;      
input  wire bvalid_m_inf;
output wire bready_m_inf;
input  wire [1:0] bresp_m_inf;    

// for loop int
integer i ;
integer j ;

// ===============================================================
//  					Variable Declare
// ===============================================================
// AXI wire , reg 
wire arready ;
wire wready ;
wire rvalid ;
wire rlast ;
wire awready ;
wire bvalid ;
reg  arvalid ;
reg awvalid ;
reg rready ;
reg wvalid ;
reg wlast ;

reg [ADDR_WIDTH-1:0] araddr ;
reg [ADDR_WIDTH-1:0] awaddr ;
wire [DATA_WIDTH-1:0] rdata ;
reg [DATA_WIDTH-1:0]  wdata ;

reg WEB_map, WEB_weight ;

reg [3:0] task_bay_num;
reg [4:0] frame_id_q;
reg [3:0] net_id_q [0:14];

reg [5:0] source_x[0:15] ;
reg [5:0] source_y[0:15] ;
reg [5:0] sink_x[0:15] ;
reg [5:0] sink_y[0:15];

reg [5:0] cur_x ;
reg [5:0] cur_y ;
reg [5:0] switch_y ;
reg [5:0] switch_x ; 

reg [6:0] addr_map_cnt_q ;
reg [6:0] addr_map_cnt_d ;
reg [6:0] addr_weight_cnt_d_reg ;
reg [6:0] addr_weight_cnt_d ;

reg [127:0] data_in_map ;
reg [127:0] data_in_weight ;
reg [127:0] data_out_map ;
reg [127:0] data_out_weight ;

reg [1:0] map [0:63] [0:63] ;
reg get_weight_flag ;
reg empty_map[0:63][0:63];
reg match_path[0:63][0:63];
reg filling_map[0:63][0:63];
reg [3:0] store_cnt;
reg filled_beside[1:62][1:62];
reg [4:0] global_cnt;

//* flags
reg read_dram_done_flag ;

// WAVE PROPAGATION by 2,2,3,3 
wire [1:0] propagation_que [0:3];

wire read_map_flag = (read_dram_done_flag == 0 && (rready & rvalid)) ? 1:0 ; 
wire read_weight_flag = (read_dram_done_flag == 1 && (rready & rvalid)) ? 1:0;
wire source_retraced  = ({cur_y, cur_x} == {source_y[task_bay_num], source_x[task_bay_num]})? 1:0;
wire sink_is_near_to_source = filled_beside[sink_y[task_bay_num]][sink_x[task_bay_num]] ;

wire [5:0] cur_y_plus_1 = cur_y + 1;
wire [5:0] cur_y_minus_1 = cur_y - 1;
wire [5:0] cur_x_plus_1 = cur_x + 1;
wire [5:0] cur_x_minus_1 = cur_x - 1;

wire down_can_go = (cur_y_plus_1 != 0 && match_path[cur_y_plus_1][cur_x])? 1:0;
reg up_can_go;
reg left_can_go;
reg right_can_go;

// ===============================================================
//                              FSM
// ===============================================================
localparam  IDLE = 0 ,
            READ_DRAM  = 1 , 
            FILL = 2 , 
            RETRACE = 3 ,
            DRAM_WRITE_BACK=4 ;

reg [2:0]   state_q , state_d ;

//* state_q
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) state_q <= IDLE;
    else state_q <= state_d;
end
  
//* state_d
always@(*)begin
    case(state_q)
        IDLE: begin
            if(in_valid)        state_d = READ_DRAM;
            else                state_d = IDLE;
        end
        READ_DRAM: begin
            if(!in_valid)       state_d = DRAM_WRITE_BACK;
            else                state_d = READ_DRAM;
        end
        DRAM_WRITE_BACK:begin
            if(rlast && read_dram_done_flag == 0)         state_d = FILL;
            else if(rlast && read_dram_done_flag == 1)    state_d = RETRACE;
            else                               state_d = DRAM_WRITE_BACK;
        end
        FILL:begin
            if (sink_is_near_to_source) 
                if (get_weight_flag) state_d = RETRACE;
                else           state_d = DRAM_WRITE_BACK;
            else state_d = FILL;
        end
        RETRACE: begin
            if(source_retraced) begin
                if(task_bay_num != store_cnt - 1) state_d = FILL;
                else                      state_d = IDLE;
            end else state_d = RETRACE;
        end
        default: state_d = IDLE ;
    endcase
end  

// ===============================================================
//                            Design
// ===============================================================
//* propagation_que
assign {propagation_que[3],propagation_que[2],propagation_que[1],propagation_que[0]} = {2'd3 , 2'd3 , 2'd2 , 2'd2};

//* frame_id_q
always @(posedge clk) if (in_valid) frame_id_q <= frame_id ;

//* busy
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)                                         busy <= 0;
    else if (state_q == READ_DRAM && in_valid == 0 )    busy <= 1;
    else if (bvalid)                                    busy <= 0;
end

//* switch
reg switch ;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)  switch <= 0;
    else        switch <= switch + in_valid ;
end

//* store_cnt
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)                 store_cnt <= 0;
    else if (in_valid & switch) store_cnt <= store_cnt+1;
    else if (state_q != IDLE)   store_cnt <= store_cnt;
    else                        store_cnt <= 0;
end

//* task_bay_num
always @(posedge clk) begin
    if (in_valid) task_bay_num <= 0 ;
    else if (state_q == RETRACE && source_retraced) task_bay_num <= task_bay_num + 1;
end

// ===============================================================
//                  Read DRAM  -AXI AR  /  R
// =============================================================== 
//---------------------------------------
//* AXI - R chennal
assign rvalid             = rvalid_m_inf;
assign rdata               = rdata_m_inf;
assign rready_m_inf             = rready;
assign rlast               = rlast_m_inf;
//---------------------------------------
//---------------------------------------
//* AXI - AR chennal
assign arvalid_m_inf           = arvalid;
assign arready           = arready_m_inf;
assign araddr_m_inf             = araddr;
//---------------------------------------
//* araddr
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)                       araddr <= 0;
    else if (in_valid)                araddr <= {16'h0001, frame_id, 11'h0};
    else if (read_dram_done_flag == 0 && rlast ) araddr <= {16'h0002, frame_id_q, 11'h0};
end

//* arvalid
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)                                                             arvalid <= 0; 
    else if ((state_q == IDLE || state_q== DRAM_WRITE_BACK) && in_valid)    arvalid <= 1;
    else if (arvalid & arready)                                             arvalid <= 0;
    else if (read_dram_done_flag == 0 && rlast )                            arvalid <= 1;
end

//* rready
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)                     rready <= 0;
    else if (arready && arvalid)    rready <= 1;
    else if (rlast)                 rready <= 0;
end

// ===============================================================
//                  Map building
// =============================================================== 
//* read_dram_done_flag
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)                                     read_dram_done_flag <= 0;
    else if (read_dram_done_flag == 0 && rlast ==1) read_dram_done_flag <= 1; 
    else if (busy ==0)                              read_dram_done_flag <= 0;
end

//* WEB_map
// read:1 write:0
always @(*) begin
    if (read_dram_done_flag == 0) begin
        if (rready & rvalid)  WEB_map = 0;
        else WEB_map = 1;
    end 
    else if (state_q == RETRACE) WEB_map = global_cnt[0] ;
    else WEB_map = 1;
end

//* addr_map_cnt_q 
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)                  addr_map_cnt_q <= 0;
    else if ((rready & rvalid)) addr_map_cnt_q <= addr_map_cnt_q + 1;
    else if ((wvalid & wready)) addr_map_cnt_q <= addr_map_cnt_q + 1;
    else if (arvalid | awvalid) addr_map_cnt_q <= 0;
end

//* addr_weight_cnt_d
always @(*) begin
    if (state_q == RETRACE) addr_weight_cnt_d = {switch_y, switch_x[5]};
    else addr_weight_cnt_d = addr_weight_cnt_d_reg ;
end

//* addr_map_cnt_d
always @(*) begin
    if (state_q != RETRACE) addr_map_cnt_d = addr_map_cnt_q + (wvalid & wready);   
    else if (down_can_go)    addr_map_cnt_d = {cur_y_plus_1, cur_x[5]};
    else if (up_can_go)      addr_map_cnt_d = {cur_y_minus_1, cur_x[5]};
    else if (left_can_go)    addr_map_cnt_d = {cur_y, cur_x_plus_1[5]};
    else if (right_can_go)   addr_map_cnt_d = {cur_y, cur_x_minus_1[5]};
    else                    addr_map_cnt_d = 0;
end

//* data_in_map
always @(*) begin
    if (read_dram_done_flag == 0) begin // data still output from DRAM
        if (rready & rvalid)    data_in_map = rdata;        
        else                    data_in_map = data_out_map;
    end else if (state_q == RETRACE) begin
                                data_in_map = data_out_map; 
        if (down_can_go)        data_in_map[(cur_x[4:0]*4)+:4] = net_id_q[task_bay_num];
        else if (up_can_go)     data_in_map[(cur_x[4:0]*4)+:4] = net_id_q[task_bay_num];
        else if (left_can_go)   data_in_map[(cur_x_plus_1[4:0]*4)+:4] = net_id_q[task_bay_num];
        else if (right_can_go)  data_in_map[(cur_x_minus_1[4:0]*4)+:4] = net_id_q[task_bay_num];
    end else                    data_in_map = 128'b0;
end

//* filled_beside 
always @(*) begin
    for (i = 1; i < 63; i = i + 1) begin
        for (j = 1; j < 63; j = j + 1) begin
            filled_beside[i][j] =  (map[i+1][j][1] ||map[i-1][j][1] ||map[i][j+1][1] ||map[i][j-1][1]);
        end
    end
end

//* empty_map 
always @(*) begin
    for (i = 0; i < 64; i = i + 1) begin
        for (j = 0; j < 64; j = j + 1) begin
            empty_map[i][j] = map[i][j] == 0;
        end
    end
end

//* match_path
always @(*) begin
    for (i = 0; i < 64; i = i + 1) begin
        for (j = 0; j < 64; j = j + 1) begin
            match_path[i][j] = (map[i][j] == propagation_que[global_cnt[2:1]]);
        end
    end
end

//* up_can_go
always @(*) begin
    if(cur_y != 0 && match_path[cur_y_minus_1][cur_x]) up_can_go =1;
    else up_can_go =0;
end

//* left_can_go
always @(*) begin
    if(cur_x_plus_1 != 0 && match_path[cur_y][cur_x_plus_1]) left_can_go =1;
    else left_can_go =0;
end

//* right_can_go
always @(*) begin
    if(cur_x != 0 && match_path[cur_y][cur_x_minus_1])right_can_go =1;
    else right_can_go =0;
end

//* addr_weight_cnt_d_reg
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) addr_weight_cnt_d_reg <= 0;
    else if (rready && rvalid) addr_weight_cnt_d_reg <= addr_weight_cnt_d_reg + 7'd1;
    else if (arready) addr_weight_cnt_d_reg <= 0;
end
  
//* net_id_q
always @(posedge clk) if (in_valid) net_id_q[global_cnt[4:1]] <= net_id ;
  
//* source_x
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (i = 0; i < 16; i = i + 1)  source_x[i] <= 0;
    end else if (in_valid) begin
        if (global_cnt[0] ==0)          source_x[global_cnt[4:1]] <= loc_x;
        else                            source_x[global_cnt[4:1]] <= source_x[global_cnt[4:1]];
    end
end  

//* source_y
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) for (i = 0; i < 16; i = i + 1) source_y[i] <= 0;
    else if (in_valid) begin
        if (global_cnt[0]==0) source_y[global_cnt[4:1]] <= loc_y;
        else source_y[global_cnt[4:1]] <=  source_y[global_cnt[4:1]];
    end
end  

//* sink_x
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) for (i = 0; i < 16; i = i + 1) sink_x[i] <= 0;
    else if (in_valid && global_cnt[0]==1) sink_x[global_cnt[4:1]] <= loc_x;
    else sink_x[global_cnt[4:1]] <= sink_x[global_cnt[4:1]];
end

//* sink_y
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) for (i = 0; i < 16; i = i + 1) sink_y[i] <= 0;
    else if (in_valid && global_cnt[0]==1) sink_y[global_cnt[4:1]] <= loc_y;
    else sink_y[global_cnt[4:1]] <= sink_y[global_cnt[4:1]];
end

//* global_cnt
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)                                     global_cnt <= 0;
    else if (in_valid)                              global_cnt <= global_cnt + 1;
    else if (~busy)                                 global_cnt <= 0;
    else if (state_q == FILL) begin
        if (sink_is_near_to_source ==0)             global_cnt <= global_cnt + 1;
        else                                        global_cnt <= {global_cnt - 1, 1'b1};
    end else if (state_q == RETRACE) begin
        if (source_retraced)                        global_cnt <= 0;
        else                                        global_cnt <= global_cnt - 1;
    end
end

//* get_weight_flag
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) get_weight_flag <= 0;
    else if (in_valid) get_weight_flag <= 0;
    else if (read_dram_done_flag == 1) begin
        if (rlast) get_weight_flag <= 1;
        else       get_weight_flag <= get_weight_flag;
    end else get_weight_flag <= get_weight_flag;
end

//* switch_x
always @(*) begin
    if (read_map_flag ==1) begin
        switch_x = source_x[0];
    end 
    else if (source_retraced ==1) begin
        switch_x = source_x[task_bay_num+1];
    end 
    else begin
        if (down_can_go || up_can_go) begin
            switch_x = cur_x;
        end
        else if (left_can_go) begin
            switch_x = cur_x_plus_1;
        end
        else begin
            switch_x = cur_x_minus_1;
        end
    end
end

//* switch_y
always @(*) begin
    if (read_map_flag) begin
        switch_y = source_y[0];
    end 
    else if (source_retraced) begin
        switch_y = source_y[task_bay_num+1];
    end 
    else begin
        if (down_can_go) begin
            switch_y = cur_y_plus_1;
        end
        else if (up_can_go) begin
            switch_y = cur_y_minus_1;
        end
        else begin
            switch_y = cur_y;
        end
    end
end

//* map[0:63][0:63]
always @(posedge clk) begin
    if (read_map_flag) begin
        for (i = 0; i < 32; i = i + 1)begin
            map[addr_map_cnt_d>>1][i+32*addr_map_cnt_d[0]] <= {1'b0, |rdata[(i*4)+:4]};
        end
        for (i = 2; i < 62; i = i + 1)begin
            for (j = 2; j < 62; j = j + 1)begin
                if (i == switch_y && j == switch_x) begin
                    map[i][j] <= 2'b11;
                end
            end
        end
    end 
    else if (state_q == FILL) begin
        if (empty_map[0][0] ==1)begin
            if(map[1][0][1] || map[0][1][1] == 1) begin // upper-left
                map[0][0] <= propagation_que[global_cnt[1:0]];
            end
        end
        if (empty_map[0][63]==1) begin
            if(map[1][63][1] | map[0][62][1])begin  // upper-right
                map[0][63] <= propagation_que[global_cnt[1:0]];
            end
        end
        if (empty_map[63][0]==1)begin
            if (map[62][0][1] | map[63][1][1])begin  // bottom-left
                map[63][0] <= propagation_que[global_cnt[1:0]];
            end
        end
        if (empty_map[63][63]==1)begin
            if (map[62][63][1] | map[63][62][1])begin // bottom-right
                map[63][63] <= propagation_que[global_cnt[1:0]];
            end
        end
    //------------------------------------------------------------------
        for (i = 1; i <= 62; i = i + 1)begin                        // top
            if (empty_map[0][i])begin
                if(map[1][i][1] | map[0][i+1][1] | map[0][i-1][1])begin
                    map[0][i] <= propagation_que[global_cnt[1:0]];
                end
            end
            if (empty_map[63][i])begin                              // bottom
                if(map[62][i][1] | map[63][i+1][1] | map[63][i-1][1])begin
                    map[63][i] <= propagation_que[global_cnt[1:0]];
                end
            end
            if (empty_map[i][0])begin                               // left
                if (map[i+1][0][1] | map[i-1][0][1] | map[i][1][1])begin
                    map[i][0] <= propagation_que[global_cnt[1:0]];     
                end
            end
            if (empty_map[i][63])begin                              // right
                if(map[i+1][63][1] | map[i-1][63][1] | map[i][62][1])begin
                    map[i][63] <= propagation_que[global_cnt[1:0]];
                end
            end
        end
        for (i = 1; i < 63; i = i + 1) begin
            for (j = 1; j < 63; j = j + 1) begin
                if (empty_map[i][j] )begin
                    if( filled_beside[i][j]) map[i][j] <= propagation_que[global_cnt[1:0]];
                end
            end
        end
    end 
    //------------------------------------------------------------------    
    else if (state_q == RETRACE) begin
        if (source_retraced) begin
            for (i = 0; i < 64; i = i + 1) begin
                for (j = 0; j < 64; j = j + 1) begin
                    if (map[i][j][1]) begin
                        map[i][j] <= 0;  
                    end
                end
            end
            for (i = 2; i < 62; i = i + 1)begin
                for (j = 2; j < 62; j = j + 1)begin
                    if (i == switch_y && j == switch_x) begin
                        map[i][j] <= {1'b1, 1'b1};
                    end
                end
            end
        end else if (global_cnt[0]==0) begin  
            for (i = 0; i < 64; i = i + 1) begin
                for (j = 0; j < 64; j = j + 1) begin
                    if (i == switch_y && j == switch_x) begin
                        map[i][j] <= {1'b0, 1'b1};
                    end
                end
            end
        end
    end
end

  
//* WEB_weight
always @(*) begin
    WEB_weight = 1'b1;
    if (rready & rvalid && read_dram_done_flag) WEB_weight = 1'b0;
end

//* data_in_weight
always @(*) begin
    data_in_weight = 128'b0;
    if (read_dram_done_flag == 1) begin
        if (rready & rvalid) data_in_weight = rdata;
    end
end

// ===============================================================
//          Calculate Cost
// ===============================================================
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) cost <= 0;
    else if (in_valid) cost <= 0;
    else if (state_q == RETRACE) begin
        if (global_cnt[0]==0) begin
            if (down_can_go && {cur_y_plus_1, cur_x} != {source_y[task_bay_num], source_x[task_bay_num]})begin
                cost <= cost + data_out_weight[(cur_x[4:0]*4)+:4];
            end else if (up_can_go && {cur_y_minus_1, cur_x} != {source_y[task_bay_num], source_x[task_bay_num]})begin
                cost <= cost + data_out_weight[(cur_x[4:0]*4)+:4];
            end else if (left_can_go && {cur_y, cur_x_plus_1} != {source_y[task_bay_num], source_x[task_bay_num]})begin
                cost <= cost + data_out_weight[(cur_x_plus_1[4:0]*4)+:4];
            end else if (right_can_go && {cur_y, cur_x_minus_1} != {source_y[task_bay_num], source_x[task_bay_num]})begin
                cost <= cost + data_out_weight[(cur_x_minus_1[4:0]*4)+:4];
            end
        end
    end
end

//* cur_x
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) cur_x <= 0;
    else if (state_q == FILL) cur_x <= sink_x[task_bay_num];
    else if (state_q == RETRACE) begin
        if (global_cnt[0] ==0) cur_x <= switch_x;
    end
end

//* cur_y
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) cur_y <= 0;
    else if (state_q == FILL) cur_y <= sink_y[task_bay_num];
    else if (state_q == RETRACE) begin
        if (global_cnt[0] ==0) cur_y <= switch_y;
    end
end

//================================================================================================================  
// Write DATA To DRAM  -AXI AW  /  W
//================================================================================================================  
//---------------------------------------
//* AXI - W chennal
assign wvalid_m_inf             = wvalid;
assign wready             = wready_m_inf;
assign wdata_m_inf               = wdata;
assign wlast_m_inf               = wlast;
//---------------------------------------
//---------------------------------------
//* AXI - B chennal
assign bvalid             = bvalid_m_inf;
//---------------------------------------
//---------------------------------------
//* AXI - AW chennal
assign awvalid_m_inf           = awvalid;
assign awready           = awready_m_inf;
assign awaddr_m_inf             = awaddr;
//---------------------------------------

//* awaddr
always @(*) awaddr = {16'h0001, frame_id_q, 11'h0};

//* awvalid
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) awvalid <= 0;
    else if (awvalid && awready) awvalid <= 0;
    else if (state_q == RETRACE && source_retraced )begin
        if (task_bay_num == store_cnt - 1) awvalid <= 1;
        else awvalid <= 0;
    end
end

//* wvalid
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)                 wvalid <= 0;
    else if (awvalid & awready) wvalid <= 1;
    else if (wlast)             wvalid <= 0;
end

//* wdata
always @(*) wdata = data_out_map;

//* wlast
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)                     wlast <= 0;
    else if (wvalid & wready) begin
        if(addr_map_cnt_d == 127)   wlast <= 1;
        else                        wlast <= 0;
    end
end


// ===============================================================
//  					SRAM IP
// ===============================================================
SRAM_wrapper u_SRAM_map ( .sram_addr(addr_map_cnt_d) ,
                          .map_in(data_in_map) ,
                          .map_out(data_out_map) ,
                          .clk(clk) , 
                          .sram_WEB(WEB_map) );
SRAM_wrapper u_SRAM_weight ( .sram_addr(addr_weight_cnt_d) ,
                          .map_in(data_in_weight) ,
                          .map_out(data_out_weight) ,
                          .clk(clk) , 
                          .sram_WEB(WEB_weight) );

// ===============================================================
//  					Const of AXI
// ===============================================================
assign awid_m_inf    = 'd0; 
assign arid_m_inf    = 'd0;  

assign arlen_m_inf   = 'd127;  
assign awlen_m_inf   = 'd127;  

assign bready_m_inf  = 'd1;
assign arburst_m_inf = 'd1;  
assign awburst_m_inf = 'd1;  

assign arsize_m_inf  = 'd4;  
assign awsize_m_inf  = 'd4;  

endmodule

module SRAM_wrapper (
  input wire [6:0] sram_addr ,
  input wire [127:0] map_in ,
  output wire [127:0] map_out ,
  input wire clk , 
  input wire sram_WEB 
);
  SRAM_128_128_m1  u_SRAM
( .A0(sram_addr[0])    ,.A1(sram_addr[1])    ,.A2(sram_addr[2])    ,.A3(sram_addr[3])    ,.A4(sram_addr[4])    ,.A5(sram_addr[5])    ,.A6(sram_addr[6]),
  .DO0  (map_out[0])   ,.DO1  (map_out[1])   ,.DO2  (map_out[2])   ,.DO3  (map_out[3])   ,.DO4  (map_out[4])   ,.DO5  (map_out[5])   ,.DO6  (map_out[6])   ,.DO7  (map_out[7])   ,.DO8  (map_out[8])   ,.DO9 (map_out[9]),
  .DO10 (map_out[10])  ,.DO11 (map_out[11])  ,.DO12 (map_out[12])  ,.DO13 (map_out[13])  ,.DO14 (map_out[14])  ,.DO15 (map_out[15])  ,.DO16 (map_out[16])  ,.DO17 (map_out[17])  ,.DO18 (map_out[18])  ,.DO19(map_out[19]),
  .DO20 (map_out[20])  ,.DO21 (map_out[21])  ,.DO22 (map_out[22])  ,.DO23 (map_out[23])  ,.DO24 (map_out[24])  ,.DO25 (map_out[25])  ,.DO26 (map_out[26])  ,.DO27 (map_out[27])  ,.DO28 (map_out[28])  ,.DO29(map_out[29]),
  .DO30 (map_out[30])  ,.DO31 (map_out[31])  ,.DO32 (map_out[32])  ,.DO33 (map_out[33])  ,.DO34 (map_out[34])  ,.DO35 (map_out[35])  ,.DO36 (map_out[36])  ,.DO37 (map_out[37])  ,.DO38 (map_out[38])  ,.DO39(map_out[39]),
  .DO40 (map_out[40])  ,.DO41 (map_out[41])  ,.DO42 (map_out[42])  ,.DO43 (map_out[43])  ,.DO44 (map_out[44])  ,.DO45 (map_out[45])  ,.DO46 (map_out[46])  ,.DO47 (map_out[47])  ,.DO48 (map_out[48])  ,.DO49(map_out[49]),
  .DO50 (map_out[50])  ,.DO51 (map_out[51])  ,.DO52 (map_out[52])  ,.DO53 (map_out[53])  ,.DO54 (map_out[54])  ,.DO55 (map_out[55])  ,.DO56 (map_out[56])  ,.DO57 (map_out[57])  ,.DO58 (map_out[58])  ,.DO59(map_out[59]),
  .DO60 (map_out[60])  ,.DO61 (map_out[61])  ,.DO62 (map_out[62])  ,.DO63 (map_out[63])  ,.DO64 (map_out[64])  ,.DO65 (map_out[65])  ,.DO66 (map_out[66])  ,.DO67 (map_out[67])  ,.DO68 (map_out[68])  ,.DO69(map_out[69]),
  .DO70 (map_out[70])  ,.DO71 (map_out[71])  ,.DO72 (map_out[72])  ,.DO73 (map_out[73])  ,.DO74 (map_out[74])  ,.DO75 (map_out[75])  ,.DO76 (map_out[76])  ,.DO77 (map_out[77])  ,.DO78 (map_out[78])  ,.DO79(map_out[79]),
  .DO80 (map_out[80])  ,.DO81 (map_out[81])  ,.DO82 (map_out[82])  ,.DO83 (map_out[83])  ,.DO84 (map_out[84])  ,.DO85 (map_out[85])  ,.DO86 (map_out[86])  ,.DO87 (map_out[87])  ,.DO88 (map_out[88])  ,.DO89(map_out[89]),
  .DO90 (map_out[90])  ,.DO91 (map_out[91])  ,.DO92 (map_out[92])  ,.DO93 (map_out[93])  ,.DO94 (map_out[94])  ,.DO95 (map_out[95])  ,.DO96 (map_out[96])  ,.DO97 (map_out[97])  ,.DO98 (map_out[98])  ,.DO99(map_out[99]),
  .DO100(map_out[100]) ,.DO101(map_out[101]) ,.DO102(map_out[102]) ,.DO103(map_out[103]) ,.DO104(map_out[104]) ,.DO105(map_out[105]) ,.DO106(map_out[106]) ,.DO107(map_out[107]) ,.DO108(map_out[108]) ,.DO109(map_out[109]),
  .DO110(map_out[110]) ,.DO111(map_out[111]) ,.DO112(map_out[112]) ,.DO113(map_out[113]) ,.DO114(map_out[114]) ,.DO115(map_out[115]) ,.DO116(map_out[116]) ,.DO117(map_out[117]) ,.DO118(map_out[118]) ,.DO119(map_out[119]),
  .DO120(map_out[120]) ,.DO121(map_out[121]) ,.DO122(map_out[122]) ,.DO123(map_out[123]) ,.DO124(map_out[124]) ,.DO125(map_out[125]) ,.DO126(map_out[126]) ,.DO127(map_out[127]) ,
  .DI0  (map_in[0])    ,.DI1  (map_in[1])    ,.DI2  (map_in[2])    ,.DI3  (map_in[3])    ,.DI4  (map_in[4])    ,.DI5  (map_in[5])    ,.DI6  (map_in[6])    ,.DI7  (map_in[7])    ,.DI8 (map_in[8])    ,.DI9(map_in[9]),
  .DI10 (map_in[10])   ,.DI11 (map_in[11])   ,.DI12 (map_in[12])   ,.DI13 (map_in[13])   ,.DI14 (map_in[14])   ,.DI15 (map_in[15])   ,.DI16 (map_in[16])   ,.DI17 (map_in[17])   ,.DI18(map_in[18])  ,.DI19(map_in[19]),
  .DI20 (map_in[20])   ,.DI21 (map_in[21])   ,.DI22 (map_in[22])   ,.DI23 (map_in[23])   ,.DI24 (map_in[24])   ,.DI25 (map_in[25])   ,.DI26 (map_in[26])   ,.DI27 (map_in[27])   ,.DI28(map_in[28])  ,.DI29(map_in[29]),
  .DI30 (map_in[30])   ,.DI31 (map_in[31])   ,.DI32 (map_in[32])   ,.DI33 (map_in[33])   ,.DI34 (map_in[34])   ,.DI35 (map_in[35])   ,.DI36 (map_in[36])   ,.DI37 (map_in[37])   ,.DI38(map_in[38])  ,.DI39(map_in[39]),
  .DI40 (map_in[40])   ,.DI41 (map_in[41])   ,.DI42 (map_in[42])   ,.DI43 (map_in[43])   ,.DI44 (map_in[44])   ,.DI45 (map_in[45])   ,.DI46 (map_in[46])   ,.DI47 (map_in[47])   ,.DI48(map_in[48])  ,.DI49(map_in[49]),
  .DI50 (map_in[50])   ,.DI51 (map_in[51])   ,.DI52 (map_in[52])   ,.DI53 (map_in[53])   ,.DI54 (map_in[54])   ,.DI55 (map_in[55])   ,.DI56 (map_in[56])   ,.DI57 (map_in[57])   ,.DI58(map_in[58])  ,.DI59(map_in[59]),
  .DI60 (map_in[60])   ,.DI61 (map_in[61])   ,.DI62 (map_in[62])   ,.DI63 (map_in[63])   ,.DI64 (map_in[64])   ,.DI65 (map_in[65])   ,.DI66 (map_in[66])   ,.DI67 (map_in[67])   ,.DI68(map_in[68])  ,.DI69(map_in[69]),
  .DI70 (map_in[70])   ,.DI71 (map_in[71])   ,.DI72 (map_in[72])   ,.DI73 (map_in[73])   ,.DI74 (map_in[74])   ,.DI75 (map_in[75])   ,.DI76 (map_in[76])   ,.DI77 (map_in[77])   ,.DI78(map_in[78])  ,.DI79(map_in[79]),
  .DI80 (map_in[80])   ,.DI81 (map_in[81])   ,.DI82 (map_in[82])   ,.DI83 (map_in[83])   ,.DI84 (map_in[84])   ,.DI85 (map_in[85])   ,.DI86 (map_in[86])   ,.DI87 (map_in[87])   ,.DI88(map_in[88])  ,.DI89(map_in[89]),
  .DI90 (map_in[90])   ,.DI91 (map_in[91])   ,.DI92 (map_in[92])   ,.DI93 (map_in[93])   ,.DI94 (map_in[94])   ,.DI95 (map_in[95])   ,.DI96 (map_in[96])   ,.DI97 (map_in[97])   ,.DI98(map_in[98])  ,.DI99(map_in[99]),
  .DI100(map_in[100])  ,.DI101(map_in[101])  ,.DI102(map_in[102])  ,.DI103(map_in[103])  ,.DI104(map_in[104])  ,.DI105(map_in[105])  ,.DI106(map_in[106])  ,.DI107(map_in[107])  ,.DI108(map_in[108]) ,.DI109(map_in[109]),
  .DI110(map_in[110])  ,.DI111(map_in[111])  ,.DI112(map_in[112])  ,.DI113(map_in[113])  ,.DI114(map_in[114])  ,.DI115(map_in[115])  ,.DI116(map_in[116])  ,.DI117(map_in[117])  ,.DI118(map_in[118]) ,.DI119(map_in[119]),
  .DI120(map_in[120])  ,.DI121(map_in[121])  ,.DI122(map_in[122])  ,.DI123(map_in[123])  ,.DI124(map_in[124])  ,.DI125(map_in[125])  ,.DI126(map_in[126])  ,.DI127(map_in[127])  ,
  .CK(clk)             ,.WEB(sram_WEB)       ,.OE(1'b1)            ,.CS(1'b1) );
endmodule


// module SRAM_wrapper_32 (
//   input wire [6:0] sram_addr ,
//   input wire [31:0] map_in ,
//   output wire [31:0] map_out ,
//   input wire clk , 
//   input wire sram_WEB 
// );
// SRAM_128_32_1m u_SRAM_micro_or_weight
// (   .A0(sram_addr[0])    ,.A1(sram_addr[1])    ,.A2(sram_addr[2])    ,.A3(sram_addr[3])    ,.A4(sram_addr[4])    ,.A5(sram_addr[5])    ,.A6(sram_addr[6]),
//     .DO0  (micro_or_weight_out[0])   ,.DO1 (micro_or_weight_out[1])   ,.DO2 (micro_or_weight_out[2])   ,.DO3 (micro_or_weight_out[3])   ,.DO4 (micro_or_weight_out[4])   ,.DO5 (micro_or_weight_out[5])   ,.DO6 (micro_or_weight_out[6])   ,.DO7 (micro_or_weight_out[7])   ,.DO8 (micro_or_weight_out[8])   ,.DO9 (micro_or_weight_out[9]),
//     .DO10 (micro_or_weight_out[10])  ,.DO11(micro_or_weight_out[11])  ,.DO12(micro_or_weight_out[12])  ,.DO13(micro_or_weight_out[13])  ,.DO14(micro_or_weight_out[14])  ,.DO15(micro_or_weight_out[15])  ,.DO16(micro_or_weight_out[16])  ,.DO17(micro_or_weight_out[17])  ,.DO18(micro_or_weight_out[18])  ,.DO19(micro_or_weight_out[19]),
//     .DO20 (micro_or_weight_out[20])  ,.DO21(micro_or_weight_out[21])  ,.DO22(micro_or_weight_out[22])  ,.DO23(micro_or_weight_out[23])  ,.DO24(micro_or_weight_out[24])  ,.DO25(micro_or_weight_out[25])  ,.DO26(micro_or_weight_out[26])  ,.DO27(micro_or_weight_out[27])  ,.DO28(micro_or_weight_out[28])  ,.DO29(micro_or_weight_out[29]),
//     .DO30 (micro_or_weight_out[30])  ,.DO31(micro_or_weight_out[31])  ,
//     .DI0  (micro_or_weight_in[0])   ,.DI1(micro_or_weight_in[1])    ,.DI2(micro_or_weight_in[2])    ,.DI3(micro_or_weight_in[3])    ,.DI4(micro_or_weight_in[4])    ,.DI5(micro_or_weight_in[5])    ,.DI6(micro_or_weight_in[6])    ,.DI7(micro_or_weight_in[7])    ,.DI8(micro_or_weight_in[8])    ,.DI9(micro_or_weight_in[9]),
//     .DI10 (micro_or_weight_in[10])  ,.DI11(micro_or_weight_in[11])  ,.DI12(micro_or_weight_in[12])  ,.DI13(micro_or_weight_in[13])  ,.DI14(micro_or_weight_in[14])  ,.DI15(micro_or_weight_in[15])  ,.DI16(micro_or_weight_in[16])  ,.DI17(micro_or_weight_in[17])  ,.DI18(micro_or_weight_in[18])  ,.DI19(micro_or_weight_in[19]),
//     .DI20 (micro_or_weight_in[20])  ,.DI21(micro_or_weight_in[21])  ,.DI22(micro_or_weight_in[22])  ,.DI23(micro_or_weight_in[23])  ,.DI24(micro_or_weight_in[24])  ,.DI25(micro_or_weight_in[25])  ,.DI26(micro_or_weight_in[26])  ,.DI27(micro_or_weight_in[27])  ,.DI28(micro_or_weight_in[28])  ,.DI29(micro_or_weight_in[29]),
//     .DI30 (micro_or_weight_in[30])  ,.DI31(micro_or_weight_in[31])  ,
//     .CK(clk)    ,.WEB(sram_WEB)   ,.OE(1'b1)    ,.CS(1'b1));
// endmodule


// module SRAM_wrapper (
//   input wire [6:0] sram_addr ,
//   input wire [127:0] map_in ,
//   output wire [127:0] map_out ,
//   input wire clk , 
//   input wire sram_WEB 
// );
//   SRAM_128_128_M1  u_SRAM
// ( .A0(sram_addr[0])    ,.A1(sram_addr[1])    ,.A2(sram_addr[2])    ,.A3(sram_addr[3])    ,.A4(sram_addr[4])    ,.A5(sram_addr[5])    ,.A6(sram_addr[6]),
//   .DO0  (map_out[0])   ,.DO1  (map_out[1])   ,.DO2  (map_out[2])   ,.DO3  (map_out[3])   ,.DO4  (map_out[4])   ,.DO5  (map_out[5])   ,.DO6  (map_out[6])   ,.DO7  (map_out[7])   ,.DO8  (map_out[8])   ,.DO9 (map_out[9]),
//   .DO10 (map_out[10])  ,.DO11 (map_out[11])  ,.DO12 (map_out[12])  ,.DO13 (map_out[13])  ,.DO14 (map_out[14])  ,.DO15 (map_out[15])  ,.DO16 (map_out[16])  ,.DO17 (map_out[17])  ,.DO18 (map_out[18])  ,.DO19(map_out[19]),
//   .DO20 (map_out[20])  ,.DO21 (map_out[21])  ,.DO22 (map_out[22])  ,.DO23 (map_out[23])  ,.DO24 (map_out[24])  ,.DO25 (map_out[25])  ,.DO26 (map_out[26])  ,.DO27 (map_out[27])  ,.DO28 (map_out[28])  ,.DO29(map_out[29]),
//   .DO30 (map_out[30])  ,.DO31 (map_out[31])  ,.DO32 (map_out[32])  ,.DO33 (map_out[33])  ,.DO34 (map_out[34])  ,.DO35 (map_out[35])  ,.DO36 (map_out[36])  ,.DO37 (map_out[37])  ,.DO38 (map_out[38])  ,.DO39(map_out[39]),
//   .DO40 (map_out[40])  ,.DO41 (map_out[41])  ,.DO42 (map_out[42])  ,.DO43 (map_out[43])  ,.DO44 (map_out[44])  ,.DO45 (map_out[45])  ,.DO46 (map_out[46])  ,.DO47 (map_out[47])  ,.DO48 (map_out[48])  ,.DO49(map_out[49]),
//   .DO50 (map_out[50])  ,.DO51 (map_out[51])  ,.DO52 (map_out[52])  ,.DO53 (map_out[53])  ,.DO54 (map_out[54])  ,.DO55 (map_out[55])  ,.DO56 (map_out[56])  ,.DO57 (map_out[57])  ,.DO58 (map_out[58])  ,.DO59(map_out[59]),
//   .DO60 (map_out[60])  ,.DO61 (map_out[61])  ,.DO62 (map_out[62])  ,.DO63 (map_out[63])  ,.DO64 (map_out[64])  ,.DO65 (map_out[65])  ,.DO66 (map_out[66])  ,.DO67 (map_out[67])  ,.DO68 (map_out[68])  ,.DO69(map_out[69]),
//   .DO70 (map_out[70])  ,.DO71 (map_out[71])  ,.DO72 (map_out[72])  ,.DO73 (map_out[73])  ,.DO74 (map_out[74])  ,.DO75 (map_out[75])  ,.DO76 (map_out[76])  ,.DO77 (map_out[77])  ,.DO78 (map_out[78])  ,.DO79(map_out[79]),
//   .DO80 (map_out[80])  ,.DO81 (map_out[81])  ,.DO82 (map_out[82])  ,.DO83 (map_out[83])  ,.DO84 (map_out[84])  ,.DO85 (map_out[85])  ,.DO86 (map_out[86])  ,.DO87 (map_out[87])  ,.DO88 (map_out[88])  ,.DO89(map_out[89]),
//   .DO90 (map_out[90])  ,.DO91 (map_out[91])  ,.DO92 (map_out[92])  ,.DO93 (map_out[93])  ,.DO94 (map_out[94])  ,.DO95 (map_out[95])  ,.DO96 (map_out[96])  ,.DO97 (map_out[97])  ,.DO98 (map_out[98])  ,.DO99(map_out[99]),
//   .DO100(map_out[100]) ,.DO101(map_out[101]) ,.DO102(map_out[102]) ,.DO103(map_out[103]) ,.DO104(map_out[104]) ,.DO105(map_out[105]) ,.DO106(map_out[106]) ,.DO107(map_out[107]) ,.DO108(map_out[108]) ,.DO109(map_out[109]),
//   .DO110(map_out[110]) ,.DO111(map_out[111]) ,.DO112(map_out[112]) ,.DO113(map_out[113]) ,.DO114(map_out[114]) ,.DO115(map_out[115]) ,.DO116(map_out[116]) ,.DO117(map_out[117]) ,.DO118(map_out[118]) ,.DO119(map_out[119]),
//   .DO120(map_out[120]) ,.DO121(map_out[121]) ,.DO122(map_out[122]) ,.DO123(map_out[123]) ,.DO124(map_out[124]) ,.DO125(map_out[125]) ,.DO126(map_out[126]) ,.DO127(map_out[127]) ,
//   .DI0  (map_in[0])    ,.DI1  (map_in[1])    ,.DI2  (map_in[2])    ,.DI3  (map_in[3])    ,.DI4  (map_in[4])    ,.DI5  (map_in[5])    ,.DI6  (map_in[6])    ,.DI7  (map_in[7])    ,.DI8 (map_in[8])    ,.DI9(map_in[9]),
//   .DI10 (map_in[10])   ,.DI11 (map_in[11])   ,.DI12 (map_in[12])   ,.DI13 (map_in[13])   ,.DI14 (map_in[14])   ,.DI15 (map_in[15])   ,.DI16 (map_in[16])   ,.DI17 (map_in[17])   ,.DI18(map_in[18])  ,.DI19(map_in[19]),
//   .DI20 (map_in[20])   ,.DI21 (map_in[21])   ,.DI22 (map_in[22])   ,.DI23 (map_in[23])   ,.DI24 (map_in[24])   ,.DI25 (map_in[25])   ,.DI26 (map_in[26])   ,.DI27 (map_in[27])   ,.DI28(map_in[28])  ,.DI29(map_in[29]),
//   .DI30 (map_in[30])   ,.DI31 (map_in[31])   ,.DI32 (map_in[32])   ,.DI33 (map_in[33])   ,.DI34 (map_in[34])   ,.DI35 (map_in[35])   ,.DI36 (map_in[36])   ,.DI37 (map_in[37])   ,.DI38(map_in[38])  ,.DI39(map_in[39]),
//   .DI40 (map_in[40])   ,.DI41 (map_in[41])   ,.DI42 (map_in[42])   ,.DI43 (map_in[43])   ,.DI44 (map_in[44])   ,.DI45 (map_in[45])   ,.DI46 (map_in[46])   ,.DI47 (map_in[47])   ,.DI48(map_in[48])  ,.DI49(map_in[49]),
//   .DI50 (map_in[50])   ,.DI51 (map_in[51])   ,.DI52 (map_in[52])   ,.DI53 (map_in[53])   ,.DI54 (map_in[54])   ,.DI55 (map_in[55])   ,.DI56 (map_in[56])   ,.DI57 (map_in[57])   ,.DI58(map_in[58])  ,.DI59(map_in[59]),
//   .DI60 (map_in[60])   ,.DI61 (map_in[61])   ,.DI62 (map_in[62])   ,.DI63 (map_in[63])   ,.DI64 (map_in[64])   ,.DI65 (map_in[65])   ,.DI66 (map_in[66])   ,.DI67 (map_in[67])   ,.DI68(map_in[68])  ,.DI69(map_in[69]),
//   .DI70 (map_in[70])   ,.DI71 (map_in[71])   ,.DI72 (map_in[72])   ,.DI73 (map_in[73])   ,.DI74 (map_in[74])   ,.DI75 (map_in[75])   ,.DI76 (map_in[76])   ,.DI77 (map_in[77])   ,.DI78(map_in[78])  ,.DI79(map_in[79]),
//   .DI80 (map_in[80])   ,.DI81 (map_in[81])   ,.DI82 (map_in[82])   ,.DI83 (map_in[83])   ,.DI84 (map_in[84])   ,.DI85 (map_in[85])   ,.DI86 (map_in[86])   ,.DI87 (map_in[87])   ,.DI88(map_in[88])  ,.DI89(map_in[89]),
//   .DI90 (map_in[90])   ,.DI91 (map_in[91])   ,.DI92 (map_in[92])   ,.DI93 (map_in[93])   ,.DI94 (map_in[94])   ,.DI95 (map_in[95])   ,.DI96 (map_in[96])   ,.DI97 (map_in[97])   ,.DI98(map_in[98])  ,.DI99(map_in[99]),
//   .DI100(map_in[100])  ,.DI101(map_in[101])  ,.DI102(map_in[102])  ,.DI103(map_in[103])  ,.DI104(map_in[104])  ,.DI105(map_in[105])  ,.DI106(map_in[106])  ,.DI107(map_in[107])  ,.DI108(map_in[108]) ,.DI109(map_in[109]),
//   .DI110(map_in[110])  ,.DI111(map_in[111])  ,.DI112(map_in[112])  ,.DI113(map_in[113])  ,.DI114(map_in[114])  ,.DI115(map_in[115])  ,.DI116(map_in[116])  ,.DI117(map_in[117])  ,.DI118(map_in[118]) ,.DI119(map_in[119]),
//   .DI120(map_in[120])  ,.DI121(map_in[121])  ,.DI122(map_in[122])  ,.DI123(map_in[123])  ,.DI124(map_in[124])  ,.DI125(map_in[125])  ,.DI126(map_in[126])  ,.DI127(map_in[127])  ,
//   .CK(clk)             ,.WEB(sram_WEB)       ,.OE(1'b1)            ,.CS(1'b1) );
// endmodule


// module SRAM_wrapper (
//   input wire [6:0] sram_addr ,
//   input wire [127:0] map_in ,
//   output wire [127:0] map_out ,
//   input wire clk , 
//   input wire sram_WEB 
// );
//   SUMA180_128X128X1BM1  u_SRAM
// ( .A0(sram_addr[0])    ,.A1(sram_addr[1])    ,.A2(sram_addr[2])    ,.A3(sram_addr[3])    ,.A4(sram_addr[4])    ,.A5(sram_addr[5])    ,.A6(sram_addr[6]),
//   .DO0  (map_out[0])   ,.DO1  (map_out[1])   ,.DO2  (map_out[2])   ,.DO3  (map_out[3])   ,.DO4  (map_out[4])   ,.DO5  (map_out[5])   ,.DO6  (map_out[6])   ,.DO7  (map_out[7])   ,.DO8  (map_out[8])   ,.DO9 (map_out[9]),
//   .DO10 (map_out[10])  ,.DO11 (map_out[11])  ,.DO12 (map_out[12])  ,.DO13 (map_out[13])  ,.DO14 (map_out[14])  ,.DO15 (map_out[15])  ,.DO16 (map_out[16])  ,.DO17 (map_out[17])  ,.DO18 (map_out[18])  ,.DO19(map_out[19]),
//   .DO20 (map_out[20])  ,.DO21 (map_out[21])  ,.DO22 (map_out[22])  ,.DO23 (map_out[23])  ,.DO24 (map_out[24])  ,.DO25 (map_out[25])  ,.DO26 (map_out[26])  ,.DO27 (map_out[27])  ,.DO28 (map_out[28])  ,.DO29(map_out[29]),
//   .DO30 (map_out[30])  ,.DO31 (map_out[31])  ,.DO32 (map_out[32])  ,.DO33 (map_out[33])  ,.DO34 (map_out[34])  ,.DO35 (map_out[35])  ,.DO36 (map_out[36])  ,.DO37 (map_out[37])  ,.DO38 (map_out[38])  ,.DO39(map_out[39]),
//   .DO40 (map_out[40])  ,.DO41 (map_out[41])  ,.DO42 (map_out[42])  ,.DO43 (map_out[43])  ,.DO44 (map_out[44])  ,.DO45 (map_out[45])  ,.DO46 (map_out[46])  ,.DO47 (map_out[47])  ,.DO48 (map_out[48])  ,.DO49(map_out[49]),
//   .DO50 (map_out[50])  ,.DO51 (map_out[51])  ,.DO52 (map_out[52])  ,.DO53 (map_out[53])  ,.DO54 (map_out[54])  ,.DO55 (map_out[55])  ,.DO56 (map_out[56])  ,.DO57 (map_out[57])  ,.DO58 (map_out[58])  ,.DO59(map_out[59]),
//   .DO60 (map_out[60])  ,.DO61 (map_out[61])  ,.DO62 (map_out[62])  ,.DO63 (map_out[63])  ,.DO64 (map_out[64])  ,.DO65 (map_out[65])  ,.DO66 (map_out[66])  ,.DO67 (map_out[67])  ,.DO68 (map_out[68])  ,.DO69(map_out[69]),
//   .DO70 (map_out[70])  ,.DO71 (map_out[71])  ,.DO72 (map_out[72])  ,.DO73 (map_out[73])  ,.DO74 (map_out[74])  ,.DO75 (map_out[75])  ,.DO76 (map_out[76])  ,.DO77 (map_out[77])  ,.DO78 (map_out[78])  ,.DO79(map_out[79]),
//   .DO80 (map_out[80])  ,.DO81 (map_out[81])  ,.DO82 (map_out[82])  ,.DO83 (map_out[83])  ,.DO84 (map_out[84])  ,.DO85 (map_out[85])  ,.DO86 (map_out[86])  ,.DO87 (map_out[87])  ,.DO88 (map_out[88])  ,.DO89(map_out[89]),
//   .DO90 (map_out[90])  ,.DO91 (map_out[91])  ,.DO92 (map_out[92])  ,.DO93 (map_out[93])  ,.DO94 (map_out[94])  ,.DO95 (map_out[95])  ,.DO96 (map_out[96])  ,.DO97 (map_out[97])  ,.DO98 (map_out[98])  ,.DO99(map_out[99]),
//   .DO100(map_out[100]) ,.DO101(map_out[101]) ,.DO102(map_out[102]) ,.DO103(map_out[103]) ,.DO104(map_out[104]) ,.DO105(map_out[105]) ,.DO106(map_out[106]) ,.DO107(map_out[107]) ,.DO108(map_out[108]) ,.DO109(map_out[109]),
//   .DO110(map_out[110]) ,.DO111(map_out[111]) ,.DO112(map_out[112]) ,.DO113(map_out[113]) ,.DO114(map_out[114]) ,.DO115(map_out[115]) ,.DO116(map_out[116]) ,.DO117(map_out[117]) ,.DO118(map_out[118]) ,.DO119(map_out[119]),
//   .DO120(map_out[120]) ,.DO121(map_out[121]) ,.DO122(map_out[122]) ,.DO123(map_out[123]) ,.DO124(map_out[124]) ,.DO125(map_out[125]) ,.DO126(map_out[126]) ,.DO127(map_out[127]) ,
//   .DI0  (map_in[0])    ,.DI1  (map_in[1])    ,.DI2  (map_in[2])    ,.DI3  (map_in[3])    ,.DI4  (map_in[4])    ,.DI5  (map_in[5])    ,.DI6  (map_in[6])    ,.DI7  (map_in[7])    ,.DI8 (map_in[8])    ,.DI9(map_in[9]),
//   .DI10 (map_in[10])   ,.DI11 (map_in[11])   ,.DI12 (map_in[12])   ,.DI13 (map_in[13])   ,.DI14 (map_in[14])   ,.DI15 (map_in[15])   ,.DI16 (map_in[16])   ,.DI17 (map_in[17])   ,.DI18(map_in[18])  ,.DI19(map_in[19]),
//   .DI20 (map_in[20])   ,.DI21 (map_in[21])   ,.DI22 (map_in[22])   ,.DI23 (map_in[23])   ,.DI24 (map_in[24])   ,.DI25 (map_in[25])   ,.DI26 (map_in[26])   ,.DI27 (map_in[27])   ,.DI28(map_in[28])  ,.DI29(map_in[29]),
//   .DI30 (map_in[30])   ,.DI31 (map_in[31])   ,.DI32 (map_in[32])   ,.DI33 (map_in[33])   ,.DI34 (map_in[34])   ,.DI35 (map_in[35])   ,.DI36 (map_in[36])   ,.DI37 (map_in[37])   ,.DI38(map_in[38])  ,.DI39(map_in[39]),
//   .DI40 (map_in[40])   ,.DI41 (map_in[41])   ,.DI42 (map_in[42])   ,.DI43 (map_in[43])   ,.DI44 (map_in[44])   ,.DI45 (map_in[45])   ,.DI46 (map_in[46])   ,.DI47 (map_in[47])   ,.DI48(map_in[48])  ,.DI49(map_in[49]),
//   .DI50 (map_in[50])   ,.DI51 (map_in[51])   ,.DI52 (map_in[52])   ,.DI53 (map_in[53])   ,.DI54 (map_in[54])   ,.DI55 (map_in[55])   ,.DI56 (map_in[56])   ,.DI57 (map_in[57])   ,.DI58(map_in[58])  ,.DI59(map_in[59]),
//   .DI60 (map_in[60])   ,.DI61 (map_in[61])   ,.DI62 (map_in[62])   ,.DI63 (map_in[63])   ,.DI64 (map_in[64])   ,.DI65 (map_in[65])   ,.DI66 (map_in[66])   ,.DI67 (map_in[67])   ,.DI68(map_in[68])  ,.DI69(map_in[69]),
//   .DI70 (map_in[70])   ,.DI71 (map_in[71])   ,.DI72 (map_in[72])   ,.DI73 (map_in[73])   ,.DI74 (map_in[74])   ,.DI75 (map_in[75])   ,.DI76 (map_in[76])   ,.DI77 (map_in[77])   ,.DI78(map_in[78])  ,.DI79(map_in[79]),
//   .DI80 (map_in[80])   ,.DI81 (map_in[81])   ,.DI82 (map_in[82])   ,.DI83 (map_in[83])   ,.DI84 (map_in[84])   ,.DI85 (map_in[85])   ,.DI86 (map_in[86])   ,.DI87 (map_in[87])   ,.DI88(map_in[88])  ,.DI89(map_in[89]),
//   .DI90 (map_in[90])   ,.DI91 (map_in[91])   ,.DI92 (map_in[92])   ,.DI93 (map_in[93])   ,.DI94 (map_in[94])   ,.DI95 (map_in[95])   ,.DI96 (map_in[96])   ,.DI97 (map_in[97])   ,.DI98(map_in[98])  ,.DI99(map_in[99]),
//   .DI100(map_in[100])  ,.DI101(map_in[101])  ,.DI102(map_in[102])  ,.DI103(map_in[103])  ,.DI104(map_in[104])  ,.DI105(map_in[105])  ,.DI106(map_in[106])  ,.DI107(map_in[107])  ,.DI108(map_in[108]) ,.DI109(map_in[109]),
//   .DI110(map_in[110])  ,.DI111(map_in[111])  ,.DI112(map_in[112])  ,.DI113(map_in[113])  ,.DI114(map_in[114])  ,.DI115(map_in[115])  ,.DI116(map_in[116])  ,.DI117(map_in[117])  ,.DI118(map_in[118]) ,.DI119(map_in[119]),
//   .DI120(map_in[120])  ,.DI121(map_in[121])  ,.DI122(map_in[122])  ,.DI123(map_in[123])  ,.DI124(map_in[124])  ,.DI125(map_in[125])  ,.DI126(map_in[126])  ,.DI127(map_in[127])  ,
//   .CK(clk)             ,.WEB(sram_WEB)       ,.OE(1'b1)            ,.CS(1'b1) );
// endmodule