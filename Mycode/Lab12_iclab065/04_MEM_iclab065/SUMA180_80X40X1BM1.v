/*******************************************************************************

             Synchronous High Speed Single Port SRAM Compiler 

                   UMC 0.18um GenericII Logic Process
   __________________________________________________________________________


       (C) Copyright 2002-2009 Faraday Technology Corp. All Rights Reserved.

     This source code is an unpublished work belongs to Faraday Technology
     Corp.  It is considered a trade secret and is not to be divulged or
     used by parties who have not received written authorization from
     Faraday Technology Corp.

     Faraday's home page can be found at:
     http://www.faraday-tech.com/
    
________________________________________________________________________________

      Module Name       :  SUMA180_80X40X1BM1  
      Word              :  80                  
      Bit               :  40                  
      Byte              :  1                   
      Mux               :  1                   
      Power Ring Type   :  port                
      Power Ring Width  :  2 (um)              
      Output Loading    :  0.05 (pf)           
      Input Data Slew   :  0.02 (ns)           
      Input Clock Slew  :  0.02 (ns)           

________________________________________________________________________________

      Library          : FSA0M_A
      Memaker          : 200901.2.1
      Date             : 2024/05/25 14:15:36

________________________________________________________________________________


   Notice on usage: Fixed delay or timing data are given in this model.
                    It supports SDF back-annotation, please generate SDF file
                    by EDA tools to get the accurate timing.

 |-----------------------------------------------------------------------------|

   Warning : If customer's design viloate the set-up time or hold time criteria 
   of synchronous SRAM, it's possible to hit the meta-stable point of 
   latch circuit in the decoder and cause the data loss in the memory bitcell.
   So please follow the memory IP's spec to design your product.

 |-----------------------------------------------------------------------------|

                Library          : FSA0M_A
                Memaker          : 200901.2.1
                Date             : 2024/05/25 14:15:36

 *******************************************************************************/

`resetall
`timescale 10ps/1ps


module SUMA180_80X40X1BM1 (A0,A1,A2,A3,A4,A5,A6,DO0,DO1,DO2,DO3,DO4,DO5,DO6,
                           DO7,DO8,DO9,DO10,DO11,DO12,DO13,DO14,DO15,
                           DO16,DO17,DO18,DO19,DO20,DO21,DO22,DO23,
                           DO24,DO25,DO26,DO27,DO28,DO29,DO30,DO31,
                           DO32,DO33,DO34,DO35,DO36,DO37,DO38,DO39,
                           DI0,DI1,DI2,DI3,DI4,DI5,DI6,DI7,DI8,DI9,
                           DI10,DI11,DI12,DI13,DI14,DI15,DI16,DI17,
                           DI18,DI19,DI20,DI21,DI22,DI23,DI24,DI25,
                           DI26,DI27,DI28,DI29,DI30,DI31,DI32,DI33,
                           DI34,DI35,DI36,DI37,DI38,DI39,CK,WEB,OE, CS);

  `define    TRUE                 (1'b1)              
  `define    FALSE                (1'b0)              

  parameter  SYN_CS               = `TRUE;            
  parameter  NO_SER_TOH           = `TRUE;            
  parameter  AddressSize          = 7;                
  parameter  Bits                 = 40;               
  parameter  Words                = 80;               
  parameter  Bytes                = 1;                
  parameter  AspectRatio          = 1;                
  parameter  TOH                  = (81:118:194);     

  output     DO0,DO1,DO2,DO3,DO4,DO5,DO6,DO7,DO8,
             DO9,DO10,DO11,DO12,DO13,DO14,DO15,DO16,DO17,DO18,
             DO19,DO20,DO21,DO22,DO23,DO24,DO25,DO26,DO27,DO28,
             DO29,DO30,DO31,DO32,DO33,DO34,DO35,DO36,DO37,DO38,
             DO39;
  input      DI0,DI1,DI2,DI3,DI4,DI5,DI6,DI7,DI8,
             DI9,DI10,DI11,DI12,DI13,DI14,DI15,DI16,DI17,DI18,
             DI19,DI20,DI21,DI22,DI23,DI24,DI25,DI26,DI27,DI28,
             DI29,DI30,DI31,DI32,DI33,DI34,DI35,DI36,DI37,DI38,
             DI39;
  input      A0,A1,A2,A3,A4,A5,A6;
  input      WEB;                                     
  input      CK;                                      
  input      CS;                                      
  input      OE;                                      

`protect
  reg        [Bits-1:0]           Memory [Words-1:0];           


  wire       [Bytes*Bits-1:0]     DO_;                
  wire       [AddressSize-1:0]    A_;                 
  wire                            OE_;                
  wire       [Bits-1:0]           DI_;                
  wire                            WEB_;               
  wire                            CK_;                
  wire                            CS_;                


  wire                            con_A;              
  wire                            con_DI;             
  wire                            con_CK;             
  wire                            con_WEB;            

  reg        [AddressSize-1:0]    Latch_A;            
  reg        [Bits-1:0]           Latch_DI;           
  reg                             Latch_WEB;          
  reg                             Latch_CS;           


  reg        [AddressSize-1:0]    A_i;                
  reg        [Bits-1:0]           DI_i;               
  reg                             WEB_i;              
  reg                             CS_i;               

  reg                             n_flag_A0;          
  reg                             n_flag_A1;          
  reg                             n_flag_A2;          
  reg                             n_flag_A3;          
  reg                             n_flag_A4;          
  reg                             n_flag_A5;          
  reg                             n_flag_A6;          
  reg                             n_flag_DI0;         
  reg                             n_flag_DI1;         
  reg                             n_flag_DI2;         
  reg                             n_flag_DI3;         
  reg                             n_flag_DI4;         
  reg                             n_flag_DI5;         
  reg                             n_flag_DI6;         
  reg                             n_flag_DI7;         
  reg                             n_flag_DI8;         
  reg                             n_flag_DI9;         
  reg                             n_flag_DI10;        
  reg                             n_flag_DI11;        
  reg                             n_flag_DI12;        
  reg                             n_flag_DI13;        
  reg                             n_flag_DI14;        
  reg                             n_flag_DI15;        
  reg                             n_flag_DI16;        
  reg                             n_flag_DI17;        
  reg                             n_flag_DI18;        
  reg                             n_flag_DI19;        
  reg                             n_flag_DI20;        
  reg                             n_flag_DI21;        
  reg                             n_flag_DI22;        
  reg                             n_flag_DI23;        
  reg                             n_flag_DI24;        
  reg                             n_flag_DI25;        
  reg                             n_flag_DI26;        
  reg                             n_flag_DI27;        
  reg                             n_flag_DI28;        
  reg                             n_flag_DI29;        
  reg                             n_flag_DI30;        
  reg                             n_flag_DI31;        
  reg                             n_flag_DI32;        
  reg                             n_flag_DI33;        
  reg                             n_flag_DI34;        
  reg                             n_flag_DI35;        
  reg                             n_flag_DI36;        
  reg                             n_flag_DI37;        
  reg                             n_flag_DI38;        
  reg                             n_flag_DI39;        
  reg                             n_flag_WEB;         
  reg                             n_flag_CS;          
  reg                             n_flag_CK_PER;      
  reg                             n_flag_CK_MINH;     
  reg                             n_flag_CK_MINL;     
  reg                             LAST_n_flag_WEB;    
  reg                             LAST_n_flag_CS;     
  reg                             LAST_n_flag_CK_PER; 
  reg                             LAST_n_flag_CK_MINH;
  reg                             LAST_n_flag_CK_MINL;
  reg        [AddressSize-1:0]    NOT_BUS_A;          
  reg        [AddressSize-1:0]    LAST_NOT_BUS_A;     
  reg        [Bits-1:0]           NOT_BUS_DI;         
  reg        [Bits-1:0]           LAST_NOT_BUS_DI;    

  reg        [AddressSize-1:0]    last_A;             
  reg        [AddressSize-1:0]    latch_last_A;       

  reg        [Bits-1:0]           last_DI;            
  reg        [Bits-1:0]           latch_last_DI;      

  reg        [Bits-1:0]           DO_i;               

  reg                             LastClkEdge;        

  reg                             flag_A_x;           
  reg                             flag_CS_x;          

  reg                             NODELAY;            
  reg        [Bits-1:0]           DO_tmp;             
  event                           EventTOHDO;         
  event                           EventNegCS;         

  assign     DO_                  = {DO_i};
  assign     con_A                = CS_;
  assign     con_DI               = CS_ & (!WEB_);
  assign     con_WEB              = CS_;
  assign     con_CK               = CS_;

  bufif1     ido0            (DO0, DO_[0], OE_);           
  bufif1     ido1            (DO1, DO_[1], OE_);           
  bufif1     ido2            (DO2, DO_[2], OE_);           
  bufif1     ido3            (DO3, DO_[3], OE_);           
  bufif1     ido4            (DO4, DO_[4], OE_);           
  bufif1     ido5            (DO5, DO_[5], OE_);           
  bufif1     ido6            (DO6, DO_[6], OE_);           
  bufif1     ido7            (DO7, DO_[7], OE_);           
  bufif1     ido8            (DO8, DO_[8], OE_);           
  bufif1     ido9            (DO9, DO_[9], OE_);           
  bufif1     ido10           (DO10, DO_[10], OE_);         
  bufif1     ido11           (DO11, DO_[11], OE_);         
  bufif1     ido12           (DO12, DO_[12], OE_);         
  bufif1     ido13           (DO13, DO_[13], OE_);         
  bufif1     ido14           (DO14, DO_[14], OE_);         
  bufif1     ido15           (DO15, DO_[15], OE_);         
  bufif1     ido16           (DO16, DO_[16], OE_);         
  bufif1     ido17           (DO17, DO_[17], OE_);         
  bufif1     ido18           (DO18, DO_[18], OE_);         
  bufif1     ido19           (DO19, DO_[19], OE_);         
  bufif1     ido20           (DO20, DO_[20], OE_);         
  bufif1     ido21           (DO21, DO_[21], OE_);         
  bufif1     ido22           (DO22, DO_[22], OE_);         
  bufif1     ido23           (DO23, DO_[23], OE_);         
  bufif1     ido24           (DO24, DO_[24], OE_);         
  bufif1     ido25           (DO25, DO_[25], OE_);         
  bufif1     ido26           (DO26, DO_[26], OE_);         
  bufif1     ido27           (DO27, DO_[27], OE_);         
  bufif1     ido28           (DO28, DO_[28], OE_);         
  bufif1     ido29           (DO29, DO_[29], OE_);         
  bufif1     ido30           (DO30, DO_[30], OE_);         
  bufif1     ido31           (DO31, DO_[31], OE_);         
  bufif1     ido32           (DO32, DO_[32], OE_);         
  bufif1     ido33           (DO33, DO_[33], OE_);         
  bufif1     ido34           (DO34, DO_[34], OE_);         
  bufif1     ido35           (DO35, DO_[35], OE_);         
  bufif1     ido36           (DO36, DO_[36], OE_);         
  bufif1     ido37           (DO37, DO_[37], OE_);         
  bufif1     ido38           (DO38, DO_[38], OE_);         
  bufif1     ido39           (DO39, DO_[39], OE_);         
  buf        ick0            (CK_, CK);                    
  buf        ia0             (A_[0], A0);                  
  buf        ia1             (A_[1], A1);                  
  buf        ia2             (A_[2], A2);                  
  buf        ia3             (A_[3], A3);                  
  buf        ia4             (A_[4], A4);                  
  buf        ia5             (A_[5], A5);                  
  buf        ia6             (A_[6], A6);                  
  buf        idi_0           (DI_[0], DI0);                
  buf        idi_1           (DI_[1], DI1);                
  buf        idi_2           (DI_[2], DI2);                
  buf        idi_3           (DI_[3], DI3);                
  buf        idi_4           (DI_[4], DI4);                
  buf        idi_5           (DI_[5], DI5);                
  buf        idi_6           (DI_[6], DI6);                
  buf        idi_7           (DI_[7], DI7);                
  buf        idi_8           (DI_[8], DI8);                
  buf        idi_9           (DI_[9], DI9);                
  buf        idi_10          (DI_[10], DI10);              
  buf        idi_11          (DI_[11], DI11);              
  buf        idi_12          (DI_[12], DI12);              
  buf        idi_13          (DI_[13], DI13);              
  buf        idi_14          (DI_[14], DI14);              
  buf        idi_15          (DI_[15], DI15);              
  buf        idi_16          (DI_[16], DI16);              
  buf        idi_17          (DI_[17], DI17);              
  buf        idi_18          (DI_[18], DI18);              
  buf        idi_19          (DI_[19], DI19);              
  buf        idi_20          (DI_[20], DI20);              
  buf        idi_21          (DI_[21], DI21);              
  buf        idi_22          (DI_[22], DI22);              
  buf        idi_23          (DI_[23], DI23);              
  buf        idi_24          (DI_[24], DI24);              
  buf        idi_25          (DI_[25], DI25);              
  buf        idi_26          (DI_[26], DI26);              
  buf        idi_27          (DI_[27], DI27);              
  buf        idi_28          (DI_[28], DI28);              
  buf        idi_29          (DI_[29], DI29);              
  buf        idi_30          (DI_[30], DI30);              
  buf        idi_31          (DI_[31], DI31);              
  buf        idi_32          (DI_[32], DI32);              
  buf        idi_33          (DI_[33], DI33);              
  buf        idi_34          (DI_[34], DI34);              
  buf        idi_35          (DI_[35], DI35);              
  buf        idi_36          (DI_[36], DI36);              
  buf        idi_37          (DI_[37], DI37);              
  buf        idi_38          (DI_[38], DI38);              
  buf        idi_39          (DI_[39], DI39);              
  buf        ics0            (CS_, CS);                    
  buf        ioe0            (OE_, OE);                    
  buf        iweb0           (WEB_, WEB);                  

  initial begin
    $timeformat (-12, 0, " ps", 20);
    flag_A_x = `FALSE;
    NODELAY = 1'b0;
  end

  always @(negedge CS_) begin
    if (SYN_CS == `FALSE) begin
       ->EventNegCS;
    end
  end
  always @(posedge CS_) begin
    if (SYN_CS == `FALSE) begin
       disable NegCS;
    end
  end

  always @(CK_) begin
    casez ({LastClkEdge,CK_})
      2'b01:
         begin
           last_A = latch_last_A;
           last_DI = latch_last_DI;
           CS_monitor;
           pre_latch_data;
           memory_function;
           latch_last_A = A_;
           latch_last_DI = DI_;
         end
      2'b?x:
         begin
           ErrorMessage(0);
           if (CS_ !== 0) begin
              if (WEB_ !== 1'b1) begin
                 all_core_x(9999,1);
              end else begin
                 #0 disable TOHDO;
                 NODELAY = 1'b1;
                 DO_i = {Bits{1'bX}};
              end
           end
         end
    endcase
    LastClkEdge = CK_;
  end

  always @(
           n_flag_A0 or
           n_flag_A1 or
           n_flag_A2 or
           n_flag_A3 or
           n_flag_A4 or
           n_flag_A5 or
           n_flag_A6 or
           n_flag_DI0 or
           n_flag_DI1 or
           n_flag_DI2 or
           n_flag_DI3 or
           n_flag_DI4 or
           n_flag_DI5 or
           n_flag_DI6 or
           n_flag_DI7 or
           n_flag_DI8 or
           n_flag_DI9 or
           n_flag_DI10 or
           n_flag_DI11 or
           n_flag_DI12 or
           n_flag_DI13 or
           n_flag_DI14 or
           n_flag_DI15 or
           n_flag_DI16 or
           n_flag_DI17 or
           n_flag_DI18 or
           n_flag_DI19 or
           n_flag_DI20 or
           n_flag_DI21 or
           n_flag_DI22 or
           n_flag_DI23 or
           n_flag_DI24 or
           n_flag_DI25 or
           n_flag_DI26 or
           n_flag_DI27 or
           n_flag_DI28 or
           n_flag_DI29 or
           n_flag_DI30 or
           n_flag_DI31 or
           n_flag_DI32 or
           n_flag_DI33 or
           n_flag_DI34 or
           n_flag_DI35 or
           n_flag_DI36 or
           n_flag_DI37 or
           n_flag_DI38 or
           n_flag_DI39 or
           n_flag_WEB or
           n_flag_CS or
           n_flag_CK_PER or
           n_flag_CK_MINH or
           n_flag_CK_MINL 
          )
     begin
       timingcheck_violation;
     end


  always @(EventTOHDO) 
    begin:TOHDO 
      #TOH 
      NODELAY <= 1'b0; 
      DO_i              =  {Bits{1'bX}}; 
      DO_i              <= DO_tmp; 
  end 

  always @(EventNegCS) 
    begin:NegCS
      #TOH 
      disable TOHDO;
      NODELAY = 1'b0; 
      DO_i              =  {Bits{1'bX}}; 
  end 

  task timingcheck_violation;
    integer i;
    begin
      if ((n_flag_CK_PER  !== LAST_n_flag_CK_PER)  ||
          (n_flag_CK_MINH !== LAST_n_flag_CK_MINH) ||
          (n_flag_CK_MINL !== LAST_n_flag_CK_MINL)) begin
          if (CS_ !== 1'b0) begin
             if (WEB_ !== 1'b1) begin
                all_core_x(9999,1);
             end
             else begin
                #0 disable TOHDO;
                NODELAY = 1'b1;
                DO_i = {Bits{1'bX}};
             end
          end
      end
      else begin
          NOT_BUS_A  = {
                         n_flag_A6,
                         n_flag_A5,
                         n_flag_A4,
                         n_flag_A3,
                         n_flag_A2,
                         n_flag_A1,
                         n_flag_A0};

          NOT_BUS_DI  = {
                         n_flag_DI39,
                         n_flag_DI38,
                         n_flag_DI37,
                         n_flag_DI36,
                         n_flag_DI35,
                         n_flag_DI34,
                         n_flag_DI33,
                         n_flag_DI32,
                         n_flag_DI31,
                         n_flag_DI30,
                         n_flag_DI29,
                         n_flag_DI28,
                         n_flag_DI27,
                         n_flag_DI26,
                         n_flag_DI25,
                         n_flag_DI24,
                         n_flag_DI23,
                         n_flag_DI22,
                         n_flag_DI21,
                         n_flag_DI20,
                         n_flag_DI19,
                         n_flag_DI18,
                         n_flag_DI17,
                         n_flag_DI16,
                         n_flag_DI15,
                         n_flag_DI14,
                         n_flag_DI13,
                         n_flag_DI12,
                         n_flag_DI11,
                         n_flag_DI10,
                         n_flag_DI9,
                         n_flag_DI8,
                         n_flag_DI7,
                         n_flag_DI6,
                         n_flag_DI5,
                         n_flag_DI4,
                         n_flag_DI3,
                         n_flag_DI2,
                         n_flag_DI1,
                         n_flag_DI0};

          for (i=0; i<AddressSize; i=i+1) begin
             Latch_A[i] = (NOT_BUS_A[i] !== LAST_NOT_BUS_A[i]) ? 1'bx : Latch_A[i];
          end
          for (i=0; i<Bits; i=i+1) begin
             Latch_DI[i] = (NOT_BUS_DI[i] !== LAST_NOT_BUS_DI[i]) ? 1'bx : Latch_DI[i];
          end
          Latch_CS  =  (n_flag_CS  !== LAST_n_flag_CS)  ? 1'bx : Latch_CS;
          Latch_WEB = (n_flag_WEB !== LAST_n_flag_WEB)  ? 1'bx : Latch_WEB;
          memory_function;
      end

      LAST_NOT_BUS_A                 = NOT_BUS_A;
      LAST_NOT_BUS_DI                = NOT_BUS_DI;
      LAST_n_flag_WEB                = n_flag_WEB;
      LAST_n_flag_CS                 = n_flag_CS;
      LAST_n_flag_CK_PER             = n_flag_CK_PER;
      LAST_n_flag_CK_MINH            = n_flag_CK_MINH;
      LAST_n_flag_CK_MINL            = n_flag_CK_MINL;
    end
  endtask // end timingcheck_violation;

  task pre_latch_data;
    begin
      Latch_A                        = A_;
      Latch_DI                       = DI_;
      Latch_WEB                      = WEB_;
      Latch_CS                       = CS_;
    end
  endtask //end pre_latch_data
  task memory_function;
    begin
      A_i                            = Latch_A;
      DI_i                           = Latch_DI;
      WEB_i                          = Latch_WEB;
      CS_i                           = Latch_CS;

      if (CS_ == 1'b1) A_monitor;

      casez({WEB_i,CS_i})
        2'b11: begin
           if (AddressRangeCheck(A_i)) begin
              if (NO_SER_TOH == `TRUE) begin
                if (A_i !== last_A) begin
                   NODELAY = 1'b1;
                   DO_tmp = Memory[A_i];
                   ->EventTOHDO;
                end else begin
                   NODELAY = 1'b0;
                   DO_tmp  = Memory[A_i];
                   DO_i    = DO_tmp;
                end
              end else begin
                NODELAY = 1'b1;
                DO_tmp = Memory[A_i];
                ->EventTOHDO;
              end
           end
           else begin
                #0 disable TOHDO;
                NODELAY = 1'b1;
                DO_i = {Bits{1'bX}};
           end
        end
        2'b01: begin
           if (AddressRangeCheck(A_i)) begin
                Memory[A_i] = DI_i;
                NODELAY = 1'b1;
                DO_tmp = Memory[A_i];
                if (NO_SER_TOH == `TRUE) begin
                  if (A_i !== last_A) begin
                     NODELAY = 1'b1;
                     ->EventTOHDO;
                  end else begin
                    if (DI_i !== last_DI) begin
                       NODELAY = 1'b1;
                       ->EventTOHDO;
                    end else begin
                       NODELAY = 1'b0;
                       DO_i = DO_tmp;
                    end
                  end
                end else begin
                  NODELAY = 1'b1;
                  ->EventTOHDO;
                end
           end else begin
                all_core_x(9999,1);
           end
        end
        2'b1x: begin
           #0 disable TOHDO;
           NODELAY = 1'b1;
           DO_i = {Bits{1'bX}};
        end
        2'b0x,
        2'bx1,
        2'bxx: begin
           if (AddressRangeCheck(A_i)) begin
                Memory[A_i] = {Bits{1'bX}};
                #0 disable TOHDO;
                NODELAY = 1'b1;
                DO_i = {Bits{1'bX}};
           end else begin
                all_core_x(9999,1);
           end
        end
      endcase
  end
  endtask //memory_function;

  task all_core_x;
     input byte_num;
     input do_x;

     integer byte_num;
     integer do_x;
     integer LoopCount_Address;
     begin
       if (do_x == 1) begin
          #0 disable TOHDO;
          NODELAY = 1'b1;
          DO_i = {Bits{1'bX}};
       end
       LoopCount_Address=Words-1;
       while(LoopCount_Address >=0) begin
         Memory[LoopCount_Address]={Bits{1'bX}};
         LoopCount_Address=LoopCount_Address-1;
      end
    end
  endtask //end all_core_x;

  task A_monitor;
     begin
       if (^(A_) !== 1'bX) begin
          flag_A_x = `FALSE;
       end
       else begin
          if (flag_A_x == `FALSE) begin
              flag_A_x = `TRUE;
              ErrorMessage(2);
          end
       end
     end
  endtask //end A_monitor;

  task CS_monitor;
     begin
       if (^(CS_) !== 1'bX) begin
          flag_CS_x = `FALSE;
       end
       else begin
          if (flag_CS_x == `FALSE) begin
              flag_CS_x = `TRUE;
              ErrorMessage(3);
          end
       end
     end
  endtask //end CS_monitor;

  task ErrorMessage;
     input error_type;
     integer error_type;

     begin
       case (error_type)
         0: $display("** MEM_Error: Abnormal transition occurred (%t) in Clock of %m",$time);
         1: $display("** MEM_Error: Read and Write the same Address, DO is unknown (%t) in clock of %m",$time);
         2: $display("** MEM_Error: Unknown value occurred (%t) in Address of %m",$time);
         3: $display("** MEM_Error: Unknown value occurred (%t) in ChipSelect of %m",$time);
         4: $display("** MEM_Error: Port A and B write the same Address, core is unknown (%t) in clock of %m",$time);
         5: $display("** MEM_Error: Clear all memory core to unknown (%t) in clock of %m",$time);
       endcase
     end
  endtask

  function AddressRangeCheck;
      input  [AddressSize-1:0] AddressItem;
      reg    UnaryResult;
      begin
        UnaryResult = ^AddressItem;
        if(UnaryResult!==1'bX) begin
           if (AddressItem >= Words) begin
              $display("** MEM_Error: Out of range occurred (%t) in Address of %m",$time);
              AddressRangeCheck = `FALSE;
           end else begin
              AddressRangeCheck = `TRUE;
           end
        end
        else begin
           AddressRangeCheck = `FALSE;
        end
      end
  endfunction //end AddressRangeCheck;

   specify
      specparam TAA  = (135:193:312);
      specparam TWDV = (101:145:234);
      specparam TRC  = (172:244:392);
      specparam THPW = (25:36:59);
      specparam TLPW = (25:36:59);
      specparam TAS  = (43:64:108);
      specparam TAH  = (10:11:16);
      specparam TWS  = (25:38:66);
      specparam TWH  = (10:10:10);
      specparam TDS  = (35:55:96);
      specparam TDH  = (10:10:10);
      specparam TCSS = (54:80:136);
      specparam TCSH = (9:14:23);
      specparam TOE      = (28:42:69);
      specparam TOZ      = (39:54:83);

      $setuphold ( posedge CK &&& con_A,          posedge A0, TAS,     TAH,     n_flag_A0      );
      $setuphold ( posedge CK &&& con_A,          negedge A0, TAS,     TAH,     n_flag_A0      );
      $setuphold ( posedge CK &&& con_A,          posedge A1, TAS,     TAH,     n_flag_A1      );
      $setuphold ( posedge CK &&& con_A,          negedge A1, TAS,     TAH,     n_flag_A1      );
      $setuphold ( posedge CK &&& con_A,          posedge A2, TAS,     TAH,     n_flag_A2      );
      $setuphold ( posedge CK &&& con_A,          negedge A2, TAS,     TAH,     n_flag_A2      );
      $setuphold ( posedge CK &&& con_A,          posedge A3, TAS,     TAH,     n_flag_A3      );
      $setuphold ( posedge CK &&& con_A,          negedge A3, TAS,     TAH,     n_flag_A3      );
      $setuphold ( posedge CK &&& con_A,          posedge A4, TAS,     TAH,     n_flag_A4      );
      $setuphold ( posedge CK &&& con_A,          negedge A4, TAS,     TAH,     n_flag_A4      );
      $setuphold ( posedge CK &&& con_A,          posedge A5, TAS,     TAH,     n_flag_A5      );
      $setuphold ( posedge CK &&& con_A,          negedge A5, TAS,     TAH,     n_flag_A5      );
      $setuphold ( posedge CK &&& con_A,          posedge A6, TAS,     TAH,     n_flag_A6      );
      $setuphold ( posedge CK &&& con_A,          negedge A6, TAS,     TAH,     n_flag_A6      );
      $setuphold ( posedge CK &&& con_DI,         posedge DI0, TDS,     TDH,     n_flag_DI0     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI0, TDS,     TDH,     n_flag_DI0     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI1, TDS,     TDH,     n_flag_DI1     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI1, TDS,     TDH,     n_flag_DI1     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI2, TDS,     TDH,     n_flag_DI2     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI2, TDS,     TDH,     n_flag_DI2     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI3, TDS,     TDH,     n_flag_DI3     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI3, TDS,     TDH,     n_flag_DI3     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI4, TDS,     TDH,     n_flag_DI4     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI4, TDS,     TDH,     n_flag_DI4     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI5, TDS,     TDH,     n_flag_DI5     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI5, TDS,     TDH,     n_flag_DI5     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI6, TDS,     TDH,     n_flag_DI6     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI6, TDS,     TDH,     n_flag_DI6     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI7, TDS,     TDH,     n_flag_DI7     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI7, TDS,     TDH,     n_flag_DI7     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI8, TDS,     TDH,     n_flag_DI8     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI8, TDS,     TDH,     n_flag_DI8     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI9, TDS,     TDH,     n_flag_DI9     );
      $setuphold ( posedge CK &&& con_DI,         negedge DI9, TDS,     TDH,     n_flag_DI9     );
      $setuphold ( posedge CK &&& con_DI,         posedge DI10, TDS,     TDH,     n_flag_DI10    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI10, TDS,     TDH,     n_flag_DI10    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI11, TDS,     TDH,     n_flag_DI11    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI11, TDS,     TDH,     n_flag_DI11    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI12, TDS,     TDH,     n_flag_DI12    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI12, TDS,     TDH,     n_flag_DI12    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI13, TDS,     TDH,     n_flag_DI13    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI13, TDS,     TDH,     n_flag_DI13    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI14, TDS,     TDH,     n_flag_DI14    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI14, TDS,     TDH,     n_flag_DI14    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI15, TDS,     TDH,     n_flag_DI15    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI15, TDS,     TDH,     n_flag_DI15    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI16, TDS,     TDH,     n_flag_DI16    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI16, TDS,     TDH,     n_flag_DI16    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI17, TDS,     TDH,     n_flag_DI17    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI17, TDS,     TDH,     n_flag_DI17    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI18, TDS,     TDH,     n_flag_DI18    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI18, TDS,     TDH,     n_flag_DI18    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI19, TDS,     TDH,     n_flag_DI19    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI19, TDS,     TDH,     n_flag_DI19    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI20, TDS,     TDH,     n_flag_DI20    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI20, TDS,     TDH,     n_flag_DI20    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI21, TDS,     TDH,     n_flag_DI21    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI21, TDS,     TDH,     n_flag_DI21    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI22, TDS,     TDH,     n_flag_DI22    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI22, TDS,     TDH,     n_flag_DI22    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI23, TDS,     TDH,     n_flag_DI23    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI23, TDS,     TDH,     n_flag_DI23    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI24, TDS,     TDH,     n_flag_DI24    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI24, TDS,     TDH,     n_flag_DI24    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI25, TDS,     TDH,     n_flag_DI25    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI25, TDS,     TDH,     n_flag_DI25    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI26, TDS,     TDH,     n_flag_DI26    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI26, TDS,     TDH,     n_flag_DI26    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI27, TDS,     TDH,     n_flag_DI27    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI27, TDS,     TDH,     n_flag_DI27    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI28, TDS,     TDH,     n_flag_DI28    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI28, TDS,     TDH,     n_flag_DI28    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI29, TDS,     TDH,     n_flag_DI29    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI29, TDS,     TDH,     n_flag_DI29    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI30, TDS,     TDH,     n_flag_DI30    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI30, TDS,     TDH,     n_flag_DI30    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI31, TDS,     TDH,     n_flag_DI31    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI31, TDS,     TDH,     n_flag_DI31    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI32, TDS,     TDH,     n_flag_DI32    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI32, TDS,     TDH,     n_flag_DI32    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI33, TDS,     TDH,     n_flag_DI33    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI33, TDS,     TDH,     n_flag_DI33    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI34, TDS,     TDH,     n_flag_DI34    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI34, TDS,     TDH,     n_flag_DI34    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI35, TDS,     TDH,     n_flag_DI35    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI35, TDS,     TDH,     n_flag_DI35    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI36, TDS,     TDH,     n_flag_DI36    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI36, TDS,     TDH,     n_flag_DI36    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI37, TDS,     TDH,     n_flag_DI37    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI37, TDS,     TDH,     n_flag_DI37    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI38, TDS,     TDH,     n_flag_DI38    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI38, TDS,     TDH,     n_flag_DI38    );
      $setuphold ( posedge CK &&& con_DI,         posedge DI39, TDS,     TDH,     n_flag_DI39    );
      $setuphold ( posedge CK &&& con_DI,         negedge DI39, TDS,     TDH,     n_flag_DI39    );
      $setuphold ( posedge CK &&& con_WEB,        posedge WEB, TWS,     TWH,     n_flag_WEB     );
      $setuphold ( posedge CK &&& con_WEB,        negedge WEB, TWS,     TWH,     n_flag_WEB     );
      $setuphold ( posedge CK,                    posedge CS, TCSS,    TCSH,    n_flag_CS      );
      $setuphold ( posedge CK,                    negedge CS, TCSS,    TCSH,    n_flag_CS      );
      $period    ( posedge CK &&& con_CK,         TRC,                       n_flag_CK_PER  );
      $width     ( posedge CK &&& con_CK,         THPW,    0,                n_flag_CK_MINH );
      $width     ( negedge CK &&& con_CK,         TLPW,    0,                n_flag_CK_MINL );
      if (NODELAY == 0)  (posedge CK => (DO0 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO1 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO2 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO3 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO4 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO5 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO6 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO7 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO8 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO9 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO10 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO11 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO12 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO13 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO14 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO15 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO16 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO17 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO18 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO19 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO20 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO21 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO22 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO23 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO24 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO25 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO26 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO27 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO28 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO29 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO30 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO31 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO32 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO33 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO34 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO35 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO36 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO37 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO38 :1'bx)) = TAA  ;
      if (NODELAY == 0)  (posedge CK => (DO39 :1'bx)) = TAA  ;


      (OE => DO0) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO1) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO2) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO3) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO4) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO5) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO6) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO7) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO8) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO9) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO10) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO11) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO12) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO13) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO14) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO15) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO16) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO17) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO18) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO19) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO20) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO21) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO22) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO23) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO24) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO25) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO26) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO27) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO28) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO29) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO30) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO31) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO32) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO33) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO34) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO35) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO36) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO37) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO38) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
      (OE => DO39) = (TOE,  TOE,  TOZ,  TOE,  TOZ,  TOE  );
   endspecify

`endprotect
endmodule


