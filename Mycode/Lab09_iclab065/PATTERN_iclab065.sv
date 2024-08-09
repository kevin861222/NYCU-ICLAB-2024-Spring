// version : submit
`include "Usertype_BEV.sv"

program PATTERN(input clk, INF.PATTERN inf);

import usertype::*;

//================================================================
// parameters & integer
//================================================================
//* cnt
integer pattern_cnt;
integer supply_drink_no_ing_cnt , supply_drink_no_ing_cnt_temp;

parameter DRAM_path = "../00_TESTBED/DRAM/dram.dat";
integer PATNUM = 3600; 
// integer 65536 = 'h10000;

logic [7:0] golden_DRAM [(65536+0):((65536+8*256)-1)];  // 256 


Action act_queue[9];
assign act_queue = '{2'h0, 
                    2'h0, 
                    2'h1, 
                    2'h1, 
                    2'h2, 
                    2'h2, 
                    2'h0, 
                    2'h2, 
                    2'h1};
ING supply_black , dram_black , ing_black;
ING supply_green , dram_green , ing_green;
ING supply_milk , dram_milk , ing_milk;
ING supply_pine_apple , dram_pine_apple , ing_pine_apple;

logic [7:0] box;
logic  [1:0] action;
logic  [2:0] bev_type;
logic [3:0] dram_month;
logic [4:0] dram_day;
logic  [1:0] size;
Date current_date;


class rand_act;
    rand Action act;
    constraint act_constraint{act inside {2'h0, 2'h1, 2'h2};}
endclass
rand_act act_rand = new();

class rand_drink;
    randc int drink;
    constraint drink_constraint{drink inside {[0:23]};}
endclass
rand_drink drink_rand = new();

class rand_date;
    randc Date date;
    constraint date_constraint{
        date.M inside {1,2,3,4,5,6,7,8,9,10,11,12};
        (date.M==1) -> date.D inside {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,28,30,31};
        (date.M==3) -> date.D inside {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,28,30,31};
        (date.M==5) -> date.D inside {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,28,30,31};
        (date.M==7) -> date.D inside {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,28,30,31};
        (date.M==8) -> date.D inside {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,28,30,31};
        (date.M==10)-> date.D inside {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,28,30,31};
        (date.M==12)-> date.D inside {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,28,30,31};
        (date.M==4) -> date.D inside {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,28,30};
        (date.M==6) -> date.D inside {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,28,30};
        (date.M==9) -> date.D inside {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,28,30};
        (date.M==11)-> date.D inside {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,28,30};
        (date.M==2) -> date.D inside {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28};}
endclass
rand_date date_rand = new();

class rand_supply_ing;
    randc ING supply_ing;
    constraint supply_ing_constraint {supply_ing inside {[0:4095]};}
endclass
rand_supply_ing supply_ing_rand = new();

class rand_box;
    randc Barrel_No box;
    constraint box_constraint{box inside {[1:255]};}
endclass
rand_box box_rand = new();

initial begin
    $readmemh(DRAM_path, golden_DRAM);
    check_reset_function_task;
    rst_sup_cnt;
    for(pattern_cnt=0; pattern_cnt < PATNUM; pattern_cnt++) begin
        if(pattern_cnt==0) begin
            task_act_when_patnum_is_zero;
        end else begin
            wait_n_cylce(1);
        end
        task_test_DUT ;
        display_task_pass_num(pattern_cnt);
    end
    display_task_Congratulations;
end

task check_reset_function_task; begin
    task_set_all_signal_zero;
    inf.rst_n = 1;
    #(10) inf.rst_n = 0;
    #(10) inf.rst_n = 1;

    if(inf.out_valid !==0) begin
        display_rst_fa_il ;
    end
    else if(inf.err_msg !== No_Err) begin
        display_rst_fa_il ;
    end
    else if(inf.complete !==0) begin
        display_rst_fa_il ;
    end 
end endtask

task input_task; begin
    if(pattern_cnt!==0) begin
        if(pattern_cnt<1800) begin 
            get_act_from_act_queue ; 
        end
        else begin 
            action = Make_drink;
        end
        input_act_to_DUT ;
    end
    wait_n_cylce(1);
    input_no_act_to_DUT ;
    if(action===Make_drink) begin
        task_make_drink ;
    end
    else if(action===Supply) begin
        task_supply_drink ;
    end
    else if(action===Check_Valid_Date) begin
        task_check_valid_date;
    end
end endtask

task wait_task; begin
forever begin
    wait_n_cylce(1);
    if (inf.out_valid == 1) begin
        break;
    end
end
end endtask

task verify_task; begin
    get_golden_data_grom_dram ;
    if(action==Make_drink) begin
        cost_of_ING(bev_type, size, ing_black, ing_green, ing_milk, ing_pine_apple);
        if((current_date.M==dram_month && current_date.D>dram_day)) begin
            if(inf.err_msg !== No_Exp) begin
                display_task_fa_il_num;
            end
            if(inf.complete !== 0) begin
                display_task_fa_il_num;
            end
        end 
        else if(current_date.M>dram_month) begin
            if(inf.err_msg !== No_Exp) begin
                display_task_fa_il_num;
            end
            if(inf.complete !== 0) begin
                display_task_fa_il_num;
            end
        end
        else if(dram_black<ing_black || dram_green<ing_green || dram_milk<ing_milk || dram_pine_apple<ing_pine_apple) begin
            if(inf.complete !== 0) begin
                display_task_fa_il_num;
            end
            if(inf.err_msg !== No_Ing) begin
                display_task_fa_il_num;
            end
        end else begin
            if(inf.complete !== 1) begin
                display_task_fa_il_num;
            end
            if(inf.err_msg !== No_Err) begin
                display_task_fa_il_num;
            end
            cal_and_update_dram ;
        end
    end else if(action==Supply) begin
        if((supply_black>~dram_black)) begin
            if(inf.complete !== 0) begin
                display_task_fa_il_num;
            end
            if(inf.err_msg !== Ing_OF) begin
                display_task_fa_il_num;
            end
        end 
        else if((supply_green>~dram_green)) begin
            if(inf.complete !== 0) begin
                display_task_fa_il_num;
            end
            if(inf.err_msg !== Ing_OF) begin
                display_task_fa_il_num;
            end
        end 
        else if((supply_milk>~dram_milk) ) begin
            if(inf.complete !== 0) begin
                display_task_fa_il_num;
            end
            if(inf.err_msg !== Ing_OF) begin
                display_task_fa_il_num;
            end
        end 
        else if((supply_pine_apple>~dram_pine_apple)) begin
            if(inf.complete !== 0) begin
                display_task_fa_il_num;
            end
            if(inf.err_msg !== Ing_OF) begin
                display_task_fa_il_num;
            end
        end 
        else begin
            if(inf.complete !== 1) begin
                display_task_fa_il_num;
            end
            if(inf.err_msg !== No_Err) begin
                display_task_fa_il_num;
            end
        end
        read_date_from_dram ;
        
        if(supply_black>~dram_black) begin
             {golden_DRAM[65536+box*8+7], golden_DRAM[65536+box*8+6][7:4]} = 12'd4095;
        end
        else begin 
            {golden_DRAM[65536+box*8+7], golden_DRAM[65536+box*8+6][7:4]} = (dram_black+supply_black);
        end

        if(supply_green>~dram_green) begin 
            {golden_DRAM[65536+box*8+6][3:0], golden_DRAM[65536+box*8+5]} = 12'd4095;
        end
        else begin 
            {golden_DRAM[65536+box*8+6][3:0], golden_DRAM[65536+box*8+5]} = (dram_green+supply_green);
        end
        
        if(supply_milk>~dram_milk) begin
             {golden_DRAM[65536+box*8+3], golden_DRAM[65536+box*8+2][7:4]} = 12'd4095;
        end
        else begin
            {golden_DRAM[65536+box*8+3], golden_DRAM[65536+box*8+2][7:4]} = (dram_milk+supply_milk);
        end
        
        if(supply_pine_apple>~dram_pine_apple) begin 
            {golden_DRAM[65536+box*8+2][3:0], golden_DRAM[65536+box*8+1]} = 12'd4095;
        end
        else begin
            {golden_DRAM[65536+box*8+2][3:0], golden_DRAM[65536+box*8+1]} = (dram_pine_apple+supply_pine_apple);
        end

    end else if(action==Check_Valid_Date) begin
        if(current_date.M>dram_month) begin
            if( inf.complete !== 0) begin
                display_task_fa_il_num;
            end
            if(inf.err_msg !== No_Exp ) begin
                display_task_fa_il_num;
            end
        end 
        else if((current_date.M==dram_month && current_date.D>dram_day)) begin
            if( inf.complete !== 0) begin
                display_task_fa_il_num;
            end
            if(inf.err_msg !== No_Exp ) begin
                display_task_fa_il_num;
            end
        end 
        else begin
            if(inf.complete !== 1) begin
                display_task_fa_il_num;
            end
            if(inf.err_msg !== No_Err) begin
                display_task_fa_il_num;
            end
        end
    end
end endtask

task cost_of_ING
(   input Bev_Type bev_type,
    input Bev_Size size,
    output ING black,
    output ING green,
    output ING milk,
    output ING pine_apple ); 

begin
    case(bev_type)
        Black_Tea: begin
            set_Black_Tea_cost(size , black,green,milk,pine_apple);
        end
        Milk_Tea: begin
            set_Milk_Tea_cost(size , black,green,milk,pine_apple);
        end
        Extra_Milk_Tea: begin
            set_Extra_Milk_Tea_cost(size , black,green,milk,pine_apple);
        end
        Green_Tea: begin
            set_Green_Tea_cost(size , black,green,milk,pine_apple);
        end
        Green_Milk_Tea: begin
            set_Green_Milk_Tea_cost(size , black,green,milk,pine_apple);
        end
        Pineapple_Juice: begin
            set_Pineapple_Juice_cost(size , black,green,milk,pine_apple);
        end
        Super_Pineapple_Tea: begin
            set_Super_Pineapple_Tea_cost(size , black,green,milk,pine_apple);
        end
        Super_Pineapple_Milk_Tea: begin
            set_Super_Pineapple_Milk_Tea_cost(size , black,green,milk,pine_apple);
        end
    endcase
end endtask

//* display tast
task display_task_Congratulations; 
begin
    $display("===============================================================");
    $display("                        Congratulations                        ");
    $display("===============================================================");
    $finish ;
end
endtask

task display_task_pass_num(int pattern_cnt); 
begin
    $display("                  PASS PATTERN NO.%d", pattern_cnt);
end
endtask

task display_rst_fa_il; 
begin
    $display("====================================================================");
    $display("              All Output signals should be 0 after rst_n            ");
    $display("====================================================================");
    $finish;
end
endtask

task display_task_fa_il_num; 
begin
    $display("===================================================");
    $display("                   Wrong Answer                    ");
    $display("===================================================");
    $finish;
end
endtask

task task_set_all_signal_zero; 
begin
    inf.sel_action_valid = 1'b0;
    inf.type_valid = 1'b0;
    inf.size_valid = 1'b0;
    inf.date_valid = 1'b0;
    inf.box_no_valid = 1'b0;
    inf.box_sup_valid = 1'b0;
    inf.D = 'x;
end
endtask


task task_act_when_patnum_is_zero; 
begin
    action = act_queue[0];
    inf.sel_action_valid = 'b1;
    inf.D.d_act[0] = action;
end
endtask

task rst_sup_cnt ;
begin
    supply_drink_no_ing_cnt = 'b0;
end
endtask

task get_act_from_act_queue ;
begin
    action = act_queue[pattern_cnt%9];
end
endtask

task input_act_to_DUT ;
begin
    inf.sel_action_valid = 'b1;
    inf.D.d_act[0] = action;
end
endtask

task input_no_act_to_DUT ;
begin
    inf.sel_action_valid = 'b0;
    inf.D = 'x;
end
endtask

task task_make_drink ;
begin
    void'(drink_rand.randomize());
    sent_type_inf_to_DUT ;
    wait_n_cylce(1);
    recover_type_inf ; 
    generate_size_inf ; 
    inf.size_valid = 1;
    inf.D.d_size[0] = size;
    wait_n_cylce(1);
    recover_size_inf ; 
    generate_12_31_date ;
    inf.date_valid = 1;
    inf.D.d_date[0] = current_date;
    wait_n_cylce(1);
    recover_date_inf;
    gernerate_box_inf ;

    inf.box_no_valid = 1;
    inf.D.d_box_no[0] = box;
    wait_n_cylce(1);
    inf.box_no_valid = 'b0;
    inf.D = 'x;
end
endtask

task task_supply_drink;
begin
    inf.date_valid = 'b1;
    void'(date_rand.randomize());
    if(date_rand.date.M==12) begin 
        if (date_rand.date.D==31) begin
            void'(date_rand.randomize());
        end
    end
    sent_date_inf_to_DUT_no_rand_again ; 
    
    wait_n_cylce(1);

    recover_date_inf;
    sent_box_inf_to_DUT;
    wait_n_cylce(1);
    inf.box_no_valid = 'b0;
    inf.D = 'x;

    generate_every_supply_drink ;

    // black tea
    inf.box_sup_valid = 1;
    
    inf.D.d_ing[0] = supply_black;
    wait_n_cylce(1);
    recover_box_sup_inf ;

    // green tea
    inf.box_sup_valid = 1;
    
    inf.D.d_ing[0] = supply_green;
    wait_n_cylce(1);
    recover_box_sup_inf ;


    // milk
    inf.box_sup_valid = 'b1;
    
    inf.D.d_ing[0] = supply_milk;
    wait_n_cylce(1);
    
    recover_box_sup_inf ;
    // pinapple
    inf.box_sup_valid = 'b1;
    
    inf.D.d_ing[0] = supply_pine_apple;
    wait_n_cylce(1);
    recover_box_sup_inf ;
end
endtask

task task_check_valid_date;
begin
    sent_date_inf_to_DUT ;
    wait_n_cylce(1);
    recover_date_inf ; 
    sent_box_inf_to_DUT ; 
    wait_n_cylce(1);
    recover_box_inf ;
end
endtask 

task get_golden_data_grom_dram;
begin
    get_dram_month ; 
    get_dram_day ;
    get_dram_black ;
    get_dram_green ;
    get_dram_milk ;
    get_dram_pine_apple ;
end
endtask 

task set_all_ING_to_zero
(   output ING black,
    output ING green,
    output ING milk,
    output ING pine_apple );  ;
begin
    black = 'b0 ;
    green = 'b0 ;
    milk = 'b0 ;
    pine_apple = 'b0 ;
end
endtask

task set_Black_Tea_cost
(   input Bev_Size size,
    output int black,
    output int green,
    output int milk,
    output int pine_apple );  ;
begin
    set_all_ING_to_zero(black,green,milk,pine_apple) ;
    case(size)
        L:black = 120*8;
        M:black = 120*6;
        S:black = 120*4;
    endcase
end
endtask

task set_Milk_Tea_cost
(   input Bev_Size size,
    output int black,
    output int green,
    output int milk,
    output int pine_apple );  ;
begin
    set_all_ING_to_zero(black,green,milk,pine_apple) ;
    case(size)
        L:begin
            black = 120*6;
            milk = 120*2;
        end
        M:begin
            black = 540;
            milk = 180;
        end
        S:begin
            black = 120*3;
            milk = 120;
        end
    endcase
end
endtask

task set_Extra_Milk_Tea_cost
(   input Bev_Size size,
    output int black,
    output int green,
    output int milk,
    output int pine_apple );  ;
begin
    set_all_ING_to_zero(black,green,milk,pine_apple) ;
    case(size)
        L:begin
            black = 120*4;
            milk = 120*4;
        end
        M:begin
            black = 120*3;
            milk = 120*3;
        end
        S:begin
            black = 120*2;
            milk = 120*2;
        end
    endcase
end
endtask

task set_Green_Tea_cost
(   input Bev_Size size,
    output int black,
    output int green,
    output int milk,
    output int pine_apple );  ;
begin
    set_all_ING_to_zero(black,green,milk,pine_apple) ;
    case(size)
        L:green = 960;
        M:green = 720;
        S:green = 480;
    endcase
end
endtask

task set_Green_Milk_Tea_cost
(   input Bev_Size size,
    output int black,
    output int green,
    output int milk,
    output int pine_apple );  ;
begin
    set_all_ING_to_zero(black,green,milk,pine_apple) ;
    case(size)
        L:begin
            green = 120 + 120 + 120 + 120;
            milk = 120 + 120 + 120 + 120;
        end
        M:begin
            green = 120 + 120 + 120 ;
            milk = 120 + 120 + 120 ;
        end
        S:begin
            green = 120 + 120 ;
            milk = 120 + 120;
        end
    endcase
end
endtask

task set_Pineapple_Juice_cost
(   input Bev_Size size,
    output int black,
    output int green,
    output int milk,
    output int pine_apple );  ;
begin
    set_all_ING_to_zero(black,green,milk,pine_apple) ;
    case(size)
        L:pine_apple = 120*8;
        M:pine_apple = 120*6;
        S:pine_apple = 120 + 120 + 120 + 120;
    endcase
end
endtask

task set_Super_Pineapple_Tea_cost
(   input Bev_Size size,
    output int black,
    output int green,
    output int milk,
    output int pine_apple );  ;
begin
    set_all_ING_to_zero(black,green,milk,pine_apple) ;
    case(size)
        L:begin
            black = 120 + 120 + 120 + 120;
            pine_apple = 120 + 120 + 120 + 120;
        end
        M:begin
            black = 120 + 120 + 120 ;
            pine_apple = 120 + 120 + 120;
        end
        S:begin
            black = 120 + 120;
            pine_apple = 120 + 120;
        end
    endcase
end
endtask

task set_Super_Pineapple_Milk_Tea_cost
(   input Bev_Size size,
    output int black,
    output int green,
    output int milk,
    output int pine_apple );  ;
begin
    set_all_ING_to_zero(black,green,milk,pine_apple) ;
    case(size)
        L:begin
            black = 120 + 120 + 120 + 120;
            milk = 120 + 120;
            pine_apple = 120 + 120;
        end
        M:begin
            black = 120 + 120 + 120;
            milk = 180;
            pine_apple = 180;
        end
        S:begin
            black = 120 + 120;
            milk = 120;
            pine_apple = 120;
        end
    endcase
end
endtask

task get_dram_month;
begin
    dram_month = golden_DRAM[65536+box*8+4];
end
endtask 

task get_dram_day;
begin
    dram_day = golden_DRAM[65536+box*8];
end
endtask 

task get_dram_black;
begin
    dram_black = {golden_DRAM[65536+box*8+7], golden_DRAM[65536+box*8+6][7:4]};
end
endtask 

task get_dram_green;
begin
    dram_green = {golden_DRAM[65536+box*8+6][3:0], golden_DRAM[65536+box*8+5]};
end
endtask 

task get_dram_milk;
begin
    dram_milk  = {golden_DRAM[65536+box*8+3], golden_DRAM[65536+box*8+2][7:4]};
end
endtask 

task get_dram_pine_apple;
begin
    dram_pine_apple  = {golden_DRAM[65536+box*8+2][3:0], golden_DRAM[65536+box*8+1]};
end
endtask 

task sent_date_inf_to_DUT ;
begin
    inf.date_valid = 'b1;
    rand_date_inf ;
    current_date = date_rand.date;
    inf.D.d_date[0] = current_date;
end
endtask

task rand_date_inf ;
begin
    void'(date_rand.randomize());
end
endtask


task sent_date_inf_to_DUT_no_rand_again ;
begin
    current_date = date_rand.date;
    inf.D.d_date[0] = current_date;
end
endtask

task recover_date_inf ;
begin
    inf.date_valid = 0;
    inf.D = 'x;
end
endtask

task recover_box_inf ;
begin
    inf.box_no_valid = 0;
    inf.D = 'x;   
end
endtask

task recover_size_inf ;
begin
    inf.size_valid = 'b0;
    inf.D = 'x;
end
endtask

task recover_type_inf ;
begin
    inf.type_valid = 'b0;
    inf.D = 'x;
end
endtask

task sent_box_inf_to_DUT ;
begin
    inf.box_no_valid = 'b1;
    rand_box_num;
    box = box_rand.box;
    inf.D.d_box_no[0] = box;
end
endtask

task rand_box_num ;
begin
    void'(box_rand.randomize());
end
endtask

task wait_n_cylce (int cycle_num) ;
begin
int for_loop_i ;
    for (for_loop_i = 0; for_loop_i < cycle_num;for_loop_i=for_loop_i+1 ) 
        @(negedge clk);
end
endtask

task task_test_DUT ; 
begin
    input_task;
    wait_task;
    verify_task;
end
endtask

task read_date_from_dram ; 
begin
    golden_DRAM[65536+box*8+4] = current_date.M;
    golden_DRAM[65536+box*8] = current_date.D;
end
endtask

task update_dram_data_black(int ans); 
begin
    {golden_DRAM[65536+box*8+7], golden_DRAM[65536+box*8+6][7:4]}=ans;
end
endtask

task update_dram_data_green(int ans); 
begin
    {golden_DRAM[65536+box*8+6][3:0], golden_DRAM[65536+box*8+5]}=ans;
end
endtask

task update_dram_data_milk(int ans); 
begin
    {golden_DRAM[65536+box*8+3], golden_DRAM[65536+box*8+2][7:4]}=ans;
end
endtask

task update_dram_data_pine_apple (int ans); 
begin
    {golden_DRAM[65536+box*8+2][3:0], golden_DRAM[65536+box*8+1]}=ans;
end
endtask

task sent_type_inf_to_DUT; 
begin
    inf.type_valid = 1;
    bev_type = drink_rand.drink/3;
    inf.D.d_type[0] = bev_type;
end
endtask

task generate_size_inf; 
begin
    case (drink_rand.drink%3)
        0: begin
            size = L;
        end 
        1: begin
            size = M;
        end
        default: begin
            size = S;
        end
    endcase
end
endtask

task generate_12_31_date; 
begin
    current_date.M = 12;
    current_date.D = 31;
end
endtask

task gernerate_box_inf; 
begin
    if(supply_drink_no_ing_cnt<20) begin
        box = 'b0;
        supply_drink_no_ing_cnt_temp = supply_drink_no_ing_cnt+1 ;
        supply_drink_no_ing_cnt= supply_drink_no_ing_cnt_temp;
    end else begin
        void'(box_rand.randomize());
        box = box_rand.box;
    end
end
endtask

task generate_every_supply_drink; 
begin
    supply_black = $urandom_range(0,4095);
    supply_green = $urandom_range(0, 4095);
    supply_milk = $urandom_range(0, 4095);
    supply_pine_apple = $urandom_range(0, 4095);
end
endtask

task recover_box_sup_inf; 
begin
    inf.box_sup_valid = 'b0;
    inf.D = 'x;
end
endtask

task cal_and_update_dram ; 
begin
    update_dram_data_black(dram_black-ing_black);
    update_dram_data_green(dram_green-ing_green); 
    update_dram_data_milk(dram_milk-ing_milk); 
    update_dram_data_pine_apple(dram_pine_apple-ing_pine_apple) ;
end
endtask

endprogram
