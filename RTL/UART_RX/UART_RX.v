module UART_RX # ( parameter IN_DATA_WIDTH = 8 )(
     input wire            RST_TOP,
	 input wire            CLK_TOP,
	 input wire          RX_IN_TOP,
	 input wire [5:0] prescale_TOP,
	 input wire         PAR_EN_TOP,
	 input wire        PAR_TYP_TOP, 
	 output wire    data_valid_TOP,
	 output wire       par_err_TOP,
	 output wire       stp_err_TOP,
	 output wire   strt_glitch_TOP,
	 output wire [IN_DATA_WIDTH-1:0] P_DATA_TOP 
);	 


   	 wire [3:0] bit_cnt_TOP;
//$clog2(IN_DATA_WIDTH)
	 wire [5:0] edge_cnt_TOP;
	 wire     par_chk_en_TOP;
	 wire    strt_chk_en_TOP;
	 wire     stp_chk_en_TOP;
	 wire       deser_en_TOP;
     wire         enable_TOP;
	 wire   data_samp_en_TOP;
	 wire    sampled_bit_TOP;  
	  
	 
/**************** instantiation UART_RX_FSM *************************/
UART_RX_FSM U0_UART_RX_FSM(
     .RST(RST_TOP),
     .CLK(CLK_TOP),
     .RX_IN(RX_IN_TOP),
     .PAR_EN(PAR_EN_TOP),
     .par_err(par_err_TOP),
     .strt_glitch(strt_glitch_TOP),
     .stp_err(stp_err_TOP),
     .bit_cnt(bit_cnt_TOP),
     .edge_cnt(edge_cnt_TOP),
     .prescale(prescale_TOP),
     .par_chk_en(par_chk_en_TOP),
     .strt_chk_en(strt_chk_en_TOP),
     .stp_chk_en(stp_chk_en_TOP),
     .deser_en(deser_en_TOP),
     .enable(enable_TOP),
     .data_samp_en(data_samp_en_TOP),
     .data_valid(data_valid_TOP)
);

/**************** instantiation edge_bit_counter *************************/
edge_bit_counter U0_edge_bit_counter(
     .CLK(CLK_TOP), 
     .RST(RST_TOP), 
     .enable(enable_TOP), 
     .Prescale(prescale_TOP), 
     .bit_cnt(bit_cnt_TOP), 
     .edge_cnt(edge_cnt_TOP)  
);

/**************** instantiation data_sampling *************************/
data_sampling U0_data_sampling(
     .RST(RST_TOP), 
     .CLK(CLK_TOP), 
     .prescale(prescale_TOP), 
     .RX_IN(RX_IN_TOP),  
     .data_samp_en(data_samp_en_TOP), 
     .edge_cnt(edge_cnt_TOP), 
     .sampled_bit(sampled_bit_TOP)  
);

/**************** instantiation deserializer *************************/
deserializer U0_deserializer(
     .CLK(CLK_TOP),  
     .RST(RST_TOP), 
     .sampled_bit(sampled_bit_TOP),  
     .deser_en(deser_en_TOP),  
     .edge_cnt(edge_cnt_TOP),  
     .Prescale(prescale_TOP), 
     .P_DATA(P_DATA_TOP)
);

/**************** instantiation strt_Check *************************/
strt_Check U0_strt_Check(
     .RST(RST_TOP), 
     .CLK(CLK_TOP), 
     .sampled_bit(sampled_bit_TOP), 
     .strt_chk_en(strt_chk_en_TOP), 
     .edge_cnt(edge_cnt_TOP),  
     .Prescale(prescale_TOP),	 
     .strt_glitch(strt_glitch_TOP)     
);

/**************** instantiation parity_Check *************************/
parity_Check U0_parity_Check(
     .CLK(CLK_TOP),
     .RST(RST_TOP),
     .P_DATA(P_DATA_TOP), 
     .PAR_TYP(PAR_TYP_TOP), 
     .sampled_bit(sampled_bit_TOP), 
     .par_chk_en(par_chk_en_TOP),
     .edge_cnt(edge_cnt_TOP),  
     .Prescale(prescale_TOP),	 
     .par_err(par_err_TOP) 	
);

/**************** instantiation Stop_Check *************************/
Stop_Check U0_Stop_Check(
     .RST(RST_TOP), 
     .CLK(CLK_TOP), 
     .stp_chk_en(stp_chk_en_TOP), 
     .sampled_bit(sampled_bit_TOP),
     .edge_cnt(edge_cnt_TOP),  
     .Prescale(prescale_TOP),	 
     .stp_err(stp_err_TOP) 
);

endmodule