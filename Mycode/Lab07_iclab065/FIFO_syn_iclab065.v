// ref : https://blog.csdn.net/ocarvb/article/details/44936569
// iclab065 
// 2023-4-22
// 312605003
// Wang Yu
// version : submit

module FIFO_syn 
#(parameter WIDTH=8, parameter WORDS=64) (
input  wire             wclk,
input  wire             rclk,
input  wire             rst_n,
input  wire             winc,           //! write enable of clk2 (D)
input  wire [WIDTH-1:0] wdata,
output reg              wfull,
input  wire             rinc,           //! read enable of clk1 (S)
output reg [WIDTH-1:0]  rdata,
output reg              rempty,
//! These flags are no use .
output wire             flag_fifo_to_clk2,
input  wire             flag_clk2_to_fifo,
output wire             flag_fifo_to_clk1,
input  wire             flag_clk1_to_fifo );

//   Remember:
//   wptr and rptr should be gray coded
//   Don't modify the signal name
reg [$clog2(WORDS):0] wptr; //[6:0]
reg [$clog2(WORDS):0] rptr; //[6:0]

// -------------------------
// parameters
// -------------------------
wire [WIDTH-1:0] rdata_d;
reg rinc_q;
wire [$clog2(WORDS):0] wptr_q;
wire [$clog2(WORDS):0] rptr_q;
reg [5:0] raddr;
reg [6:0] r_binary_q;
reg [6:0] rptr_d;
reg [6:0] r_binary_d;
reg [5:0] waddr;
reg [6:0] w_binary_q; 
reg [6:0] wptr_d;
reg [6:0] w_binary_d;
wire w_en_n = ~winc;

// -------------------------
// design
// -------------------------
//* rdata
always @(posedge rclk or negedge rst_n)
begin
    if(!rst_n) rdata <= 0;
    else if (rinc || rinc_q)    rdata <= rdata_d;
end

//* rinc_q
always @(posedge rclk or negedge rst_n) rinc_q <= (~rst_n) ? (1'b0) : (rinc);

//* r_binary_d
always@(*)  r_binary_d = r_binary_q + (rinc & ~rempty);

//* rptr_d
always@(*)  rptr_d = (r_binary_d >> 1) ^ r_binary_d;

//* r_binary_q
always @(posedge rclk or negedge rst_n) r_binary_q <= (~rst_n) ? (0) : (r_binary_d);

//* rptr
always @(posedge rclk or negedge rst_n) rptr <= (~rst_n) ? (0) : (rptr_d);

//* raddr
always@(*) raddr = r_binary_q[5:0];

//* rempty
always @(posedge rclk or negedge rst_n)begin
    if(!rst_n)  rempty <= 1'b1;
    else  rempty <= (rptr_d == wptr_q) ? 1'b1 : 1'b0;
end

//* w_binary_d
always@(*)  w_binary_d = w_binary_q + (winc & ~wfull);

//* wptr_d
always@(*)  wptr_d = (w_binary_d >> 1) ^ w_binary_d;

//* w_binary_q
always @(posedge wclk or negedge rst_n) w_binary_q <= (~rst_n) ? (0) : (w_binary_d);

//* wptr
always @(posedge wclk or negedge rst_n) wptr <= (~rst_n) ? (0) : (wptr_d);

//* waddr
always @(*) waddr = w_binary_q[5:0];

//* wfull
always @(posedge wclk or negedge rst_n) begin
    if  (~rst_n) wfull <= 1'b0;
    else wfull <= ( {~wptr_d[6:5],wptr_d[4:0]} == rptr_q ) ? 1'b1 : 1'b0;
end

// --------------
// IPs
// --------------
NDFF_BUS_syn #(.WIDTH(WIDTH-1)) rtow_ptr(.D(rptr), .Q(rptr_q), .clk(wclk), .rst_n(rst_n));
NDFF_BUS_syn #(.WIDTH(WIDTH-1)) wtor_ptr(.D(wptr), .Q(wptr_q), .clk(rclk), .rst_n(rst_n));
DUAL_64X8X1BM1 u_dual_sram (
.CKA(wclk),     .CKB(rclk),
.WEAN(w_en_n),  .WEBN(1'b1),
.CSA(1'b1),     .CSB(1'b1),
.OEA(1'b1),     .OEB(1'b1),
.A0(waddr[0]),  .A1(waddr[1]),      .A2(waddr[2]),      .A3(waddr[3]),      .A4(waddr[4]),      .A5(waddr[5]),
.B0(raddr[0]),  .B1(raddr[1]),      .B2(raddr[2]),      .B3(raddr[3]),      .B4(raddr[4]),      .B5(raddr[5]),
.DIA0(wdata[0]),    .DIA1(wdata[1]),    .DIA2(wdata[2]),    .DIA3(wdata[3]),    
.DIA4(wdata[4]),    .DIA5(wdata[5]),    .DIA6(wdata[6]),    .DIA7(wdata[7]),
.DOB0(rdata_d[0]),  .DOB1(rdata_d[1]),  .DOB2(rdata_d[2]),  .DOB3(rdata_d[3]),
.DOB4(rdata_d[4]),  .DOB5(rdata_d[5]),  .DOB6(rdata_d[6]),  .DOB7(rdata_d[7]));

endmodule
