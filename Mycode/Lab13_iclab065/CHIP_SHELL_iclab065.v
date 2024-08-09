module CHIP(
    //Input Port
    clk,
	rst_n,
	in_valid,
    in_weight, // 3bits
	out_mode,

    //Output Port
    out_valid, 
	out_code
);


input           clk, rst_n, in_valid, out_mode;
input [2:0] 	in_weight;
output          out_valid, out_code;

wire C_clk;
wire C_rst_n;
wire C_in_valid;
wire C_out_mode;
wire [2:0] C_in_weight;
wire C_out_valid;
wire C_out_code;

//TA has already defined for you
// CLKBUFX20 buf0(.A(C_clk),.Y(BUF_CLK));
//LBP module
HT_TOP CORE(
    .clk(C_clk),
    .rst_n(C_rst_n),
    .in_valid(C_in_valid),
    .out_mode(C_out_mode),
    .in_weight(C_in_weight),
    .out_valid(C_out_valid),
    .out_code(C_out_code)
    );

// CLKBUFX20 buf0(.A(C_clk),.Y(BUF_CLK));

XMD I_CLK               ( .O(C_clk),            .I(clk),                .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_RST_N             ( .O(C_rst_n),          .I(rst_n),              .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_IN_VALID          ( .O(C_in_valid),       .I(in_valid),           .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_OUT_MODE          ( .O(C_out_mode),       .I(out_mode),           .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_IN_WEIGHT_0       ( .O(C_in_weight[0]),   .I(in_weight[0]),       .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_IN_WEIGHT_1       ( .O(C_in_weight[1]),   .I(in_weight[1]),       .PU(1'b0), .PD(1'b0), .SMT(1'b0));
XMD I_IN_WEIGHT_2       ( .O(C_in_weight[2]),   .I(in_weight[2]),       .PU(1'b0), .PD(1'b0), .SMT(1'b0));

YA2GSD O_VALID          ( .I(C_out_valid),      .O(out_valid),          .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));
YA2GSD O_CODE           ( .I(C_out_code),       .O(out_code),           .E(1'b1), .E2(1'b1), .E4(1'b1), .E8(1'b0), .SR(1'b0));

//I/O power 3.3V pads x? (DVDD + DGND)
VCC3IOD VDDP0 ();
GNDIOD  GNDP0 ();
VCC3IOD VDDP1 ();
GNDIOD  GNDP1 ();
VCC3IOD VDDP2 ();
GNDIOD  GNDP2 ();
VCC3IOD VDDP3 ();
GNDIOD  GNDP3 ();

//...

//Core poweri 1.8V pads x? (VDD + GND)
VCCKD VDDC0 ();
GNDKD GNDC0 ();
VCCKD VDDC1 ();
GNDKD GNDC1 ();
VCCKD VDDC2 ();
GNDKD GNDC2 ();
VCCKD VDDC3 ();
GNDKD GNDC3 ();

VCCKD VDDC4 ();
GNDKD GNDC4 ();
VCCKD VDDC5 ();
GNDKD GNDC5 ();
VCCKD VDDC6 ();
GNDKD GNDC6 ();
VCCKD VDDC7 ();
GNDKD GNDC7 ();

VCCKD VDDC8 ();
GNDKD GNDC8 ();

VCCKD VDDC9 ();
GNDKD GNDC9 ();
VCCKD VDDC10 ();
GNDKD GNDC10 ();
VCCKD VDDC11 ();
GNDKD GNDC11 ();
VCCKD VDDC12 ();
GNDKD GNDC12 ();
//...



endmodule

