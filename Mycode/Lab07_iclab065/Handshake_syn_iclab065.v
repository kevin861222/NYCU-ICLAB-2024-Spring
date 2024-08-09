module Handshake_syn 
#(parameter WIDTH=8) (
input wire              sclk,
input wire              dclk,
input wire              rst_n,
input wire              sready,
input wire [WIDTH-1:0]  din,
input wire              dbusy,
output reg              sidle,
output reg              dvalid,
output reg [WIDTH-1:0]  dout,
//! These flags are no use .
output reg              flag_handshake_to_clk1,
input wire              flag_clk1_to_handshake,
output reg              flag_handshake_to_clk2,
input wire              flag_clk2_to_handshake  );
// -------------------------
// parameters
// -------------------------
// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;

// -------------------------
// design
// -------------------------
//* sidle
always @(posedge sclk or negedge rst_n)begin
    if(~rst_n)                          sidle <= 1;
    else if (sready || sreq || sack)    sidle <= 0;
    else                                sidle <= 1;
end

//* sreq
always @(posedge sclk or negedge rst_n) begin
    if(~rst_n)        sreq <= 0;
    else if(sack)     sreq <= 1'b0;
    else if(sready)   sreq <= 1'b1;
    else              sreq <= sreq;
end

//* dack
always @(posedge dclk or negedge rst_n) begin
    if(~rst_n)  dack <= 0;
    else        dack <= (dreq && !dbusy) ? (1) : (0);
end

//* dvalid
always @(posedge dclk or negedge rst_n)begin
    if(~rst_n)                      dvalid <= 0;
    else dvalid <= (dreq && !dbusy && dack) ? 1 : 0 ;
end

//* dout
always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)                dout <= 0;
    else if(dreq && !dbusy)   dout <= din ;
    else                      dout <= dout;
end

// --------------
// IPs
// --------------
NDFF_syn U_NDFF_req(.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));
NDFF_syn U_NDFF_ack(.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));
endmodule
