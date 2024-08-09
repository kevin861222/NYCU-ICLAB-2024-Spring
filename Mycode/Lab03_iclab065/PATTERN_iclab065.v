`ifdef RTL
    `define CYCLE_TIME 40.0
`endif
`ifdef GATE
    `define CYCLE_TIME 40.0
`endif

`include "../00_TESTBED/pseudo_DRAM.v"
`include "../00_TESTBED/pseudo_SD.v"


// Wang Yu

module PATTERN(
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
// ===============================================================
/* Input for design */
output reg        clk, rst_n;
output reg        in_valid;
output reg        direction;
output reg [13:0] addr_dram;
output reg [15:0] addr_sd;

/* Output for pattern */
input        out_valid;
input  [7:0] out_data; 
// ===============================================================




// DRAM Signals
// write address channel
input [31:0] AW_ADDR;
input AW_VALID;
output AW_READY;
// write data channel
input W_VALID;
input [63:0] W_DATA;
output W_READY;
// write response channel
output B_VALID;
output [1:0] B_RESP;
input B_READY;
// read address channel
input [31:0] AR_ADDR;
input AR_VALID;
output AR_READY;
// read data channel
output [63:0] R_DATA;
output R_VALID;
output [1:0] R_RESP;
input R_READY;

// SD Signals
output MISO;
input MOSI;

// ===============================================================
// Parameter and Integer
// ===============================================================
reg [63:0] golden ;
reg direction_temp;
reg [12:0]addr_dram_temp;
reg [15:0]addr_sd_temp;
integer fscanf_temp ;

real CYCLE = `CYCLE_TIME;
integer pat_read;
integer PAT_NUM;
integer total_latency, latency;
integer i_pat;
integer Excution_Laterncy ; //! 

// ===============================================================
// Clock Cycle
// ===============================================================
initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;


// ===============================================================
// Main function
// ===============================================================
//* Correctness Test.
initial begin
    pat_read = $fopen("../00_TESTBED/Input.txt", "r"); 
    reset_signal_task;

    i_pat = 0;
    total_latency = 0;
    $fscanf(pat_read, "%d", PAT_NUM); 
    for (i_pat = 1; i_pat <= PAT_NUM; i_pat = i_pat + 1) begin
        input_task;
        wait_out_valid_task;
        check_ans_task;
        //total_latency = total_latency + latency;
        $display("PASS PATTERN NO.%4d", i_pat);
    end
    $fclose(pat_read);
    @(negedge clk);
    $writememh("../00_TESTBED/DRAM_final.dat", u_DRAM.DRAM); //Write down your DRAM Final State
    $writememh("../00_TESTBED/SD_final.dat", u_SD.SD);		 //Write down your SD CARD Final State
    YOU_PASS_task;
end

//* The out_data should be reset when your out_valid is low.
initial begin
    $display("check out data is rst");
    while (1) begin
        if (out_valid==0) begin
            chech_out_data_is_rst(out_data);
        end
        @(negedge clk);
    end
end

//* Excution Laterncy is limited in 10000 cycles
initial begin
    $display("check Excution Latency");
    while (1) begin
        Excution_Laterncy = 0 ;
        wait( in_valid === 1 );
        wait( in_valid === 0 );
        @(negedge clk);
        while (out_valid === 0) begin
            if (Excution_Laterncy >= 10000) begin
                Excution_Latency_timeout();
            end
            Excution_Laterncy = Excution_Laterncy+1 ;
            @(negedge clk);
        end
        @(negedge clk);
    end
end

//* Prevent hang
integer timeout = (1000000);
initial begin
    while(timeout > 0) begin
        @(posedge clk);
        timeout = timeout - 1;
    end
    $display($time, "Simualtion Hang ....");
    $finish;
end

//* The data in the DRAM and SD card should be correct when out_valid is high
initial begin
    while (1) begin
        wait(out_valid===1);
        check_DRAM_equal_SD();
        @(negedge clk);
    end
end

// ===============================================================
// Write your own task here
// ===============================================================
task chech_out_data_is_rst ; 
input [7:0] out_data ; //! 
begin
    if (out_data !== 'b0) begin
        $display("----------------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  out_data should be 0 when your out_valid is low at %8t", $time);
        $display("    █  ▄▀▀▀▄                 █  ╭  SPEC MAIN-2 FAIL                          ");
        $display("    ▀▄                       █                                           ");
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("----------------------------------------------------------------------------------------");
        repeat(2) #CYCLE;
        $finish;
    end
end endtask

task Excution_Latency_timeout ; begin
    $display("----------------------------------------------------------------------------------------");
    $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
    $display("    ▄▀            ▀▄      ▄▄                                          ");
    $display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
    $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  Excution Latency is limited in 10000 cycles");
    $display("    █  ▄▀▀▀▄                 █  ╭  SPEC MAIN-3 FAIL                          ");
    $display("    ▀▄                       █                                           ");
    $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
    $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
    $display("----------------------------------------------------------------------------------------");
    repeat(2) #CYCLE;
    $finish;
end endtask

task reset_signal_task ; begin
    rst_n      = 'b1;
    // input for design
    in_valid = 'b0 ;
    direction = 'bx ;
    addr_dram = 'bx ;
    addr_sd = 'bx ;
    force clk = 'b0 ;

    #CYCLE;       rst_n = 0; 
    #(CYCLE * 2); rst_n = 1;
    if(out_valid !== 1'b0 || out_data !== 'b0 || AW_ADDR!=='b0 || AW_VALID!=='b0 || W_VALID!=='b0 || W_DATA!=='b0 || B_READY!=='b0 || AR_ADDR!=='b0 || AR_VALID!=='b0 || R_READY!=='b0 || MOSI!=='b1) begin
        $display("----------------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  Output signal should be 0 after RESET  at %8t", $time);
        $display("    █  ▄▀▀▀▄                 █  ╭  SPEC MAIN-1 FAIL                          ");
        $display("    ▀▄                       █                                           ");
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("----------------------------------------------------------------------------------------");
        repeat(2) #CYCLE;
        $finish;
    end
	#CYCLE; release clk;
end endtask

task check_ans_task ; begin
    latency = 0 ;
    while (out_valid===1) begin
        latency = latency + 1 ;
        if(direction_temp == 1'b0) begin
            golden = u_DRAM.DRAM[addr_dram_temp];
        end
        else if(direction_temp == 1'b1) begin
            golden = u_SD.SD[addr_sd_temp];
        end

        if(out_data !== golden[63:56] && latency == 1) begin
            $display("cycle1 fail");
            not_equal_golden_ans(golden[63:56]);
        end
        if(out_data !== golden[55:48] && latency == 2) begin
            $display("cycle2 fail");
            not_equal_golden_ans(golden[55:48]);
        end
        if(out_data !== golden[47:40] && latency == 3) begin
            $display("cycle3 fail");
            not_equal_golden_ans(golden[47:40]);
        end
        if(out_data !== golden[39:32] && latency == 4) begin
            $display("cycle4 fail");
            not_equal_golden_ans(golden[39:32]);
        end
        if(out_data !== golden[31:24] && latency == 5) begin
            $display("cycle5 fail");
            not_equal_golden_ans(golden[31:24]);
        end
        if(out_data !== golden[23:16] && latency == 6) begin
            $display("cycle6 fail");
            not_equal_golden_ans(golden[23:16]);
        end
        if(out_data !== golden[15:8] && latency == 7) begin
            $display("cycle7 fail");
            not_equal_golden_ans(golden[15:8]);
        end
        if(out_data !== golden[7:0] && latency == 8) begin
            $display("cycle8 fail");
            not_equal_golden_ans(golden[7:0]);
        end
        if (latency > 8) begin
            // The out_valid and out_data must be asserted in 8 cycles
            asserted_more_than_8_cycles();
        end
        @(negedge clk);
    end
    if (latency !== 8) begin
        output_less_than_8_cycle(latency);
    end
end endtask

task not_equal_golden_ans ;
input [7:0] golden_ans ;
begin
    $display("----------------------------------------------------------------------------------------");
    $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
    $display("    ▄▀            ▀▄      ▄▄                                          ");
    $display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
    $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  The out_data should be correct when out_valid is high");
    $display("    █  ▄▀▀▀▄                 █  ╭  SPEC MAIN-5 FAIL                          ");
    $display("    ▀▄                       █  ╭  golden = %d , your ans = %d          ",golden_ans,out_data);
    $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
    $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
    $display("----------------------------------------------------------------------------------------");
    repeat(2) #CYCLE;
    $finish;
end endtask

//* The out_valid and out_data must be asserted in 8 cycles
task output_less_than_8_cycle ;
input [2:0] loop ; //!  
begin
    $display("----------------------------------------------------------------------------------------");
    $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
    $display("    ▄▀            ▀▄      ▄▄                                          ");
    $display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
    $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  The out_valid and out_data must be asserted in 8 cycles");
    $display("    █  ▄▀▀▀▄                 █  ╭  SPEC MAIN-4 FAIL                          ");
    $display("    ▀▄                       █  ╭  You only output %d cycles     ",loop);
    $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
    $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
    $display("----------------------------------------------------------------------------------------");
    repeat(2) #CYCLE;
    $finish;
end endtask

task asserted_more_than_8_cycles ; begin
    $display("----------------------------------------------------------------------------------------");
    $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
    $display("    ▄▀            ▀▄      ▄▄                                          ");
    $display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
    $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  The out_valid and out_data must be asserted in 8 cycles");
    $display("    █  ▄▀▀▀▄                 █  ╭  SPEC MAIN-4 FAIL                          ");
    $display("    ▀▄                       █         ");
    $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
    $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
    $display("----------------------------------------------------------------------------------------");
    repeat(2) #CYCLE;
    $finish;
end endtask

task wait_out_valid_task ; begin
    wait(out_valid==='b1);
    @(negedge clk);
end endtask

task input_task; begin
    fscanf_temp = $fscanf(pat_read, "%d ", direction_temp);
    fscanf_temp = $fscanf(pat_read, "%d ", addr_dram_temp);
    fscanf_temp = $fscanf(pat_read, "%d ", addr_sd_temp);

    in_valid = 1'b1;
    direction = direction_temp;
    addr_dram = addr_dram_temp;
    addr_sd = addr_sd_temp;
    @(negedge clk);

    in_valid = 1'b0;
    direction = 'b0;
    addr_dram = 'b0;
    addr_sd = 'b0;
end endtask




task YOU_PASS_task; begin
    $display("---------------------------------------------------------------------------------------------");
    $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
    $display("    ▄▀            ▀▄      ▄▄                                          ");
    $display("    █  ▀   ▀       ▀▄▄   █  █      Congratulations !                            ");
    $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  You have passed all patterns ! ");
    $display("    █ ▀▄▄▄▄▀                 █  ╭ ");
    $display("    ▀▄                       █     Your clock period = %.1f ns   ", CYCLE);
    $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █      ");
    $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
    $display("---------------------------------------------------------------------------------------------"); 
    repeat(2)@(negedge clk);
    $finish;
end endtask

task YOU_FAIL_task; begin
    $display("*                              FAIL!                                    *");
    $display("*                    Error message from PATTERN.v                       *");
end endtask

task check_DRAM_equal_SD ; begin
    if (u_DRAM.DRAM[addr_dram_temp] !== u_SD.SD[addr_sd_temp]) begin
        $display("----------------------------------------------------------------------------------------");
        $display("     ▄▀▀▄▀▀▀▀▀▀▄▀▀▄                                                   ");
        $display("    ▄▀            ▀▄      ▄▄                                          ");
        $display("    █  ▀   ▀       ▀▄▄   █  █   ╭  FAIL !                            ");
        $display("    █   ▀▀            ▀▀▀   ▀▄  ╭  The data in the DRAM and SD card should be correct ");
        $display("    █  ▄▀▀▀▄                 █  ╭  when out_valid is high                          ");
        $display("    ▀▄                       █  ╭  SPEC MAIN-6 FAIL    ");
        $display("     █   ▄▄   ▄▄▄▄▄    ▄▄   █                                           ");
        $display("     ▀▄▄▀ ▀▀▄▀     ▀▄▄▀  ▀▄▀                                            ");
        $display("----------------------------------------------------------------------------------------");
        $finish;
    end
end endtask

pseudo_DRAM u_DRAM (
    .clk(clk),
    .rst_n(rst_n),
    // write address channel
    .AW_ADDR(AW_ADDR),
    .AW_VALID(AW_VALID),
    .AW_READY(AW_READY),
    // write data channel
    .W_VALID(W_VALID),
    .W_DATA(W_DATA),
    .W_READY(W_READY),
    // write response channel
    .B_VALID(B_VALID),
    .B_RESP(B_RESP),
    .B_READY(B_READY),
    // read address channel
    .AR_ADDR(AR_ADDR),
    .AR_VALID(AR_VALID),
    .AR_READY(AR_READY),
    // read data channel
    .R_DATA(R_DATA),
    .R_VALID(R_VALID),
    .R_RESP(R_RESP),
    .R_READY(R_READY)
);

pseudo_SD u_SD (
    .clk(clk),
    .MOSI(MOSI),
    .MISO(MISO)
);

endmodule