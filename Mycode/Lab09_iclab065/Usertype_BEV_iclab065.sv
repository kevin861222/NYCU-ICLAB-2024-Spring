/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2024 Autumn IC Design Laboratory 
Lab09: SystemVerilog Design and Verification 
File Name   : Usertype_BEV.sv
Module Name : usertype
Release version : v1.0 (Release Date: Apr-2024)
Author : Jui-Huang Tsai (erictsai.ee12@nycu.edu.tw)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

`ifndef USERTYPE
`define USERTYPE

package usertype;

typedef enum logic  [1:0] { Make_drink	        = 2'h0,
                            Supply	            = 2'h1,
							Check_Valid_Date    = 2'h2
							}  Action ;
							
typedef enum logic  [1:0] { No_Err       		= 2'b00, // No error
                            No_Exp              = 2'b01, // Pass the Expiration Date
							No_Ing              = 2'b10, // Ingredient not enough
						    Ing_OF	            = 2'b11  // Ingredient Overflow
}Error_Msg ;

typedef enum logic  [2:0] { Black_Tea      	         = 3'h0,
							Milk_Tea	             = 3'h1,
							Extra_Milk_Tea           = 3'h2,
							Green_Tea 	             = 3'h3,
                            Green_Milk_Tea           = 3'h4,
                            Pineapple_Juice          = 3'h5,
                            Super_Pineapple_Tea      = 3'h6,
                            Super_Pineapple_Milk_Tea = 3'h7
                            }  Bev_Type ;  // 

typedef enum logic  [1:0]	{ L  = 2'b00,
							  M  = 2'b01,
							  S  = 2'b11
                            } Bev_Size ;

typedef logic [11:0] ING;
typedef logic [3:0] Month;
typedef logic [4:0] Day;
typedef logic [7:0] Barrel_No;

typedef struct packed {
    Month M;
    Day D;
} Date; // Date

typedef struct packed {
    ING black_tea;
    ING green_tea;
    ING milk;
    ING pineapple_juice;
    Month M;
    Day D;     
} Bev_Bal; // Ingredient Barrel

typedef struct packed {
	Bev_Type Bev_Type_O;
    Bev_Size Bev_Size_O;
} Order_Info; // Order info

typedef union packed{ 
    Action [35:0] d_act;  // 2
    Bev_Type [23:0] d_type;  // 3
    Bev_Size [35:0] d_size;  // 2
    Date [7:0] d_date;  // 9
    Barrel_No [8:0] d_box_no;  // 8
    ING [5:0] d_ing;  // 12
} Data;

//################################################## Don't revise the code above

//#################################
// Type your user define type here
//#################################

//################################################## Don't revise the code below
endpackage
import usertype::*; //import usertype into $unit

`endif
