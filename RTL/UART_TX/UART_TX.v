
module UART_TX  # (parameter DATA_WIDTH = 8)
(    input   wire                         CLK_TOP,
     input   wire                         RST_TOP,
     input   wire    [DATA_WIDTH-1:0]     P_DATA_TOP,
     input   wire                         Data_Valid_TOP,
     input   wire                         PAR_EN_TOP,
     input   wire                         PAR_TYP_TOP, 
     output  wire                         TX_OUT_TOP,
     output  wire                         busy_TOP
 );

/************** Internal Signals ********************/
wire ser_en_TOP , ser_done_TOP ,ser_data_TOP , par_bit_TOP ;		
wire  [1:0]   mux_sel_TOP ;


/*************** instansiate UART_TX_FSM UNIT **************/
UART_TX_FSM  U0_fsm (
     .CLK(CLK_TOP),
     .RST(RST_TOP),
     .Data_Valid(Data_Valid_TOP), 
     .PAR_EN(PAR_EN_TOP),
     .ser_done(ser_done_TOP), 
     .ser_en(ser_en_TOP),
     .mux_sel(mux_sel_TOP), 
     .busy(busy_TOP)
);

/*************** instansiate Serializer UNIT **************/
Serializer # (.IN_DATA_WIDTH(DATA_WIDTH)) U0_Serializer (
     .CLK(CLK_TOP),
     .RST(RST_TOP),
     .P_DATA(P_DATA_TOP),
     .BUSY(busy_TOP),
     .Ser_Enable(ser_en_TOP), 
     .Data_Valid(Data_Valid_TOP), 
     .Ser_Data(ser_data_TOP),
     .Ser_Done(ser_done_TOP)
);

/*************** instansiate MUX UNIT **************/
MUX U0_MUX (
     .CLK(CLK_TOP),
     .RST(RST_TOP),
     .IN({par_bit_TOP,ser_data_TOP,1'b1,1'b0}),
     .SEL(mux_sel_TOP),
     .OUT(TX_OUT_TOP) 
);

/********** instansiate Parity_Calc UNIT ***********/
Parity_Calc # (.IN_DATA_WIDTH(DATA_WIDTH)) U0_Parity_Calc (
     .CLK(CLK_TOP),
     .RST(RST_TOP),
     .PAR_EN(PAR_EN_TOP),
     .PAR_TYP(PAR_TYP_TOP),
     .P_DATA(P_DATA_TOP),
     .BUSY(busy_TOP),
     .Data_Valid(Data_Valid_TOP), 
     .Par_Bit(par_bit_TOP)
); 



endmodule
 