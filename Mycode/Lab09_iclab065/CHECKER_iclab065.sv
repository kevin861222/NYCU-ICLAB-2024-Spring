// version : submit
`include "Usertype_BEV.sv"

module Checker(input clk, INF.CHECKER inf);
import usertype::*;

//* at least number
parameter   type_and_size_alnum = 100 ,
            errmsg_alnum = 20,
            act_alnum = 200,
            supply_ing_alnum = 1;
//* auto bin
parameter   auto_bin_max = 32;

Bev_Type bev_type;
always_ff @(posedge clk iff inf.type_valid) bev_type = inf.D.d_type[0];


//* covergroup

covergroup cover_group_type_and_size 
    @(posedge clk iff inf.size_valid);
    option.at_least = type_and_size_alnum ;
    btype: coverpoint bev_type {bins b_bev_type[] = {3'h0,3'h1,3'h2,3'h3,3'h4,3'h5,3'h6,3'h7};}
    bsize: coverpoint inf.D.d_size[0] {bins b_bev_size[] = {2'b00, 2'b01, 2'b11};}
    btype_X_bsize: cross btype, bsize;
endgroup

covergroup cover_group_errmsg 
    @(posedge clk iff inf.out_valid);
    option.at_least = errmsg_alnum ;
    msg: coverpoint inf.err_msg {bins b_msg[] = {2'h0, 2'h1, 2'h2, 2'h3};}
endgroup

covergroup cover_group_act 
    @(posedge clk iff inf.sel_action_valid);
    option.at_least = act_alnum ;
    act_X_act: coverpoint inf.D.d_act[0] {bins b_act[] = (2'h0,2'h1,2'h2=>2'h0,2'h1,2'h2);}
endgroup

covergroup cover_group_supply_ing 
    @(posedge clk iff inf.box_sup_valid);
    option.at_least = supply_ing_alnum ;
    option.auto_bin_max = auto_bin_max;
    supply_ing: coverpoint inf.D.d_ing[0];
endgroup

cover_group_supply_ing cover_group_supply_ing_inst = new();
cover_group_type_and_size cover_group_type_and_size_inst = new();
cover_group_errmsg cover_group_errmsg_inst = new();
cover_group_act cover_group_act_inst = new();



//*    1. All outputs signals (including BEV.sv and bridge.sv) should be zero after reset.
property SPEC_1_rst;
    @(posedge inf.rst_n) 1 |-> @(posedge clk) (   inf.out_valid   === 0 &&    inf.complete    === 0 &&    inf.err_msg     === 0 &&    inf.C_addr      === 0 &&    inf.C_r_wb      === 0 &&    inf.C_in_valid  === 0 &&    inf.C_data_w    === 0 &&    inf.C_out_valid === 0 &&    inf.C_data_r    === 0 &&    inf.AR_VALID    === 0 &&    inf.AR_ADDR     === 0 &&    inf.R_READY     === 0 &&    inf.AW_VALID    === 0 &&    inf.AW_ADDR     === 0 &&    inf.W_VALID     === 0 &&    inf.W_DATA      === 0 &&    inf.B_READY     === 0 &&    inf.AR_READY    === 0 &&    inf.R_VALID     === 0 &&    inf.R_RESP      === 0 &&    inf.R_DATA      === 0 &&    inf.AW_READY    === 0 &&    inf.W_READY     === 0 &&    inf.B_VALID     === 0 &&    inf.B_RESP      === 0 );
endproperty





//*    2.	Latency should be less than 1000 cycles for each operation.

property SPEC_2_MD;
    @(posedge clk) (inf.sel_action_valid===1 && inf.D.d_act[0]===Make_drink) ##[1:4] inf.type_valid ##[1:4] inf.size_valid ##[1:4] inf.date_valid ##[1:4] inf.box_no_valid |-> ##[1:999] inf.out_valid;
endproperty


property SPEC_2_S;
    @(posedge clk) (inf.sel_action_valid===1 && inf.D.d_act[0]===Supply) ##[1:4] inf.date_valid##[1:4] inf.box_no_valid ##[1:4] (inf.box_sup_valid[->4]) |-> ##[1:999] inf.out_valid;
endproperty


property SPEC_2_C;
    @(posedge clk) (inf.sel_action_valid===1 && inf.D.d_act[0]===Check_Valid_Date) ##[1:4] inf.date_valid ##[1:4] inf.box_no_valid |-> ##[1:999] inf.out_valid;
endproperty




//*    3. If action is completed (complete=1), err_msg should be 2’b0 (no_err).

property SPEC_3_errmsg;
    @(negedge clk) ((inf.out_valid!==0) && (inf.complete===1)) |-> inf.err_msg===No_Err; 
endproperty



//*    4. Next input valid will be valid 1-4 cycles after previous input valid fall.

property SPEC_4_MD;
    @(posedge clk) (inf.sel_action_valid===1 && inf.D.d_act[0]===Make_drink) |-> ##[1:4] inf.type_valid  ##[1:4] inf.size_valid  ##[1:4] inf.date_valid  ##[1:4] inf.box_no_valid; 
endproperty

property SPEC_4_S;
    @(posedge clk) (inf.sel_action_valid===1 && inf.D.d_act[0]===Supply) |-> ##[1:4] inf.date_valid ##[1:4] inf.box_no_valid ##[1:4] inf.box_sup_valid ##[1:4] inf.box_sup_valid ##[1:4] inf.box_sup_valid ##[1:4] inf.box_sup_valid; 
endproperty

property SPEC_4_C;
    @(posedge clk) (inf.sel_action_valid===1 && inf.D.d_act[0]===Check_Valid_Date) |-> ##[1:4] inf.date_valid ##[1:4] inf.box_no_valid; 
endproperty



//*    5. All input valid signals won't overlap with each other. 
property SPEC_5_type;
    @(posedge clk) (inf.type_valid===1) |-> !(inf.sel_action_valid || inf.size_valid || inf.date_valid || inf.box_no_valid || inf.box_sup_valid); 
endproperty

property SPEC_5_sel_action;
    @(posedge clk) (inf.sel_action_valid===1) |-> !(inf.type_valid || inf.size_valid || inf.date_valid || inf.box_no_valid || inf.box_sup_valid); 
endproperty

property SPEC_5_date;
    @(posedge clk) (inf.date_valid===1) |-> !(inf.type_valid || inf.size_valid || inf.sel_action_valid || inf.box_no_valid || inf.box_sup_valid); 
endproperty

property SPEC_5_size;
    @(posedge clk) (inf.size_valid===1) |-> !(inf.type_valid || inf.sel_action_valid || inf.date_valid || inf.box_no_valid || inf.box_sup_valid); 
endproperty

property SPEC_5_box_sup;
    @(posedge clk) (inf.box_sup_valid===1) |-> !(inf.type_valid || inf.size_valid || inf.date_valid || inf.box_no_valid || inf.sel_action_valid); 
endproperty

property SPEC_5_box_no;
    @(posedge clk) (inf.box_no_valid===1) |-> !(inf.type_valid || inf.size_valid || inf.date_valid || inf.sel_action_valid || inf.box_sup_valid); 
endproperty




//*    6. Out_valid can only be high for exactly one cycle.

property SPEC_6_outvalid_one_cycle;
    @(posedge clk) inf.out_valid!==0 |=> !inf.out_valid; 
endproperty



//*    7. Next operation will be valid 1-4 cycles after out_valid fall.

property SPEC_7_next_opt;
    @(posedge clk) (inf.out_valid===1) ##(1) !inf.out_valid |-> ##[0:3] inf.sel_action_valid; 
endproperty



//*    8. The input date from pattern should adhere to the real calendar. (ex: 2/29, 3/0, 4/31, 13/1 are illegal cases)

property SPEC_8_MONTH;
    @(posedge clk) (inf.date_valid===1) |-> inf.D.d_date[0].M inside {[1:12]}; 
endproperty

property SPEC_8_DAY_31;
    @(posedge clk) 
    ((inf.date_valid===1) && (  inf.D.d_date[0].M===1  ||
                                inf.D.d_date[0].M===3  ||
                                inf.D.d_date[0].M===5  ||
                                inf.D.d_date[0].M===7  ||
                                inf.D.d_date[0].M===8  ||
                                inf.D.d_date[0].M===10 ||
                                inf.D.d_date[0].M===12
                        )) |-> inf.D.d_date[0].D inside {[1:31]}; 
endproperty

property SPEC_8_DAY_28;
    @(posedge clk) ((inf.date_valid===1) && inf.D.d_date[0].M===2) |-> inf.D.d_date[0].D inside {[1:28]}; 
endproperty

property SPEC_8_DAY_30;
    @(posedge clk) 
    ((inf.date_valid===1) && (  inf.D.d_date[0].M===4 ||
                                inf.D.d_date[0].M===6 ||
                                inf.D.d_date[0].M===9 ||
                                inf.D.d_date[0].M===11)) |-> inf.D.d_date[0].D inside {[1:30]}; 
endproperty

//*    9. C_in_valid can only be high for one cycle and can't be pulled high again before C_out_valid

property SPEC_9_one_cycle;
    @(posedge clk) (inf.C_in_valid!==0) |=> (inf.C_in_valid===0); 
endproperty

property SPEC_9_wait_C_out_valid;
    @(posedge clk) (inf.C_in_valid!==0) |=> (inf.C_in_valid===0) until_with (inf.C_out_valid!==0); 
endproperty

//* assert 
assert property(SPEC_1_rst)                 else print_Assertion_violate_msg("1");
assert property(SPEC_2_MD)                  else print_Assertion_violate_msg("2");
assert property(SPEC_2_S)                   else print_Assertion_violate_msg("2");
assert property(SPEC_2_C)                   else print_Assertion_violate_msg("2");
assert property(SPEC_3_errmsg)              else print_Assertion_violate_msg("3");
assert property(SPEC_4_MD)                  else print_Assertion_violate_msg("4");
assert property(SPEC_4_S)                   else print_Assertion_violate_msg("4");
assert property(SPEC_4_C)                   else print_Assertion_violate_msg("4");
assert property(SPEC_5_sel_action)          else print_Assertion_violate_msg("5");
assert property(SPEC_5_type)                else print_Assertion_violate_msg("5");
assert property(SPEC_5_size)                else print_Assertion_violate_msg("5");
assert property(SPEC_5_date)                else print_Assertion_violate_msg("5");
assert property(SPEC_5_box_no)              else print_Assertion_violate_msg("5");
assert property(SPEC_5_box_sup)             else print_Assertion_violate_msg("5");
assert property(SPEC_6_outvalid_one_cycle)  else print_Assertion_violate_msg("6");
assert property(SPEC_7_next_opt)            else print_Assertion_violate_msg("7");
assert property(SPEC_8_MONTH)               else print_Assertion_violate_msg("8");
assert property(SPEC_8_DAY_28)              else print_Assertion_violate_msg("8");
assert property(SPEC_8_DAY_30)              else print_Assertion_violate_msg("8");
assert property(SPEC_8_DAY_31)              else print_Assertion_violate_msg("8");
assert property(SPEC_9_wait_C_out_valid)    else print_Assertion_violate_msg("9");
assert property(SPEC_9_one_cycle)           else print_Assertion_violate_msg("9");

//* display task
task print_Assertion_violate_msg(string Assertion_num);
    $display("                 Assertion %s is violated                     ", Assertion_num);
    $fatal;
endtask

endmodule