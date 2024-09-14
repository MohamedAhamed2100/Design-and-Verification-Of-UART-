`include "uart_tx_intf.sv"

module UART_TX  (uart_tx_intf.dut abc);

/************** Internal Signals ********************/
wire ser_en_TOP , ser_done_TOP ,ser_data_TOP , par_bit_TOP ;		
wire  [1:0]   mux_sel_TOP ;
parameter DATA_WIDTH = 8 ; 

/*************** instansiate UART_TX_FSM UNIT **************/
UART_TX_FSM  U0_fsm (
     .CLK(abc.clk),
     .RST(abc.rst),
     .Data_Valid(abc.data_valid), 
     .PAR_EN(abc.par_en),
     .ser_done(ser_done_TOP), 
     .ser_en(ser_en_TOP),
     .mux_sel(mux_sel_TOP), 
     .busy(abc.busy)
);

/*************** instansiate Serializer UNIT **************/
Serializer # (.IN_DATA_WIDTH(DATA_WIDTH)) U0_Serializer (
     .CLK(abc.clk),
     .RST(abc.rst),
     .P_DATA(abc.p_data),
     .BUSY(abc.busy),
     .Ser_Enable(ser_en_TOP), 
     .Data_Valid(abc.data_valid), 
     .Ser_Data(ser_data_TOP),
     .Ser_Done(ser_done_TOP)
);

/*************** instansiate MUX UNIT **************/
MUX U0_MUX (
     .CLK(abc.clk),
     .RST(abc.rst),
     .IN({par_bit_TOP,ser_data_TOP,1'b1,1'b0}),
     .SEL(mux_sel_TOP),
     .OUT(abc.tx_out) 
);

/********** instansiate Parity_Calc UNIT ***********/
Parity_Calc # (.IN_DATA_WIDTH(DATA_WIDTH)) U0_Parity_Calc (
     .CLK(abc.clk),
     .RST(abc.rst),
     .PAR_EN(abc.par_en),
     .PAR_TYP(abc.par_type),
     .P_DATA(abc.p_data),
     .BUSY(abc.busy),
     .Data_Valid(abc.data_valid), 
     .Par_Bit(par_bit_TOP)
); 



endmodule
 