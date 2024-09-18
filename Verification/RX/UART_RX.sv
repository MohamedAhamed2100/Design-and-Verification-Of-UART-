module UART_RX (uart_rx_intf.dut f);	 

     parameter IN_DATA_WIDTH = 8;
	 
   	 wire [3:0] bit_cnt_TOP;

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
     .RST(f.RST),
     .CLK(f.CLK_RX),
     .RX_IN(f.RX_IN),
     .PAR_EN(f.PAR_EN),
     .par_err(f.par_err),
     .strt_glitch(f.strt_glitch),
     .stp_err(f.stp_err),
     .bit_cnt(bit_cnt_TOP),
     .edge_cnt(edge_cnt_TOP),
     .prescale(f.prescale),
     .par_chk_en(par_chk_en_TOP),
     .strt_chk_en(strt_chk_en_TOP),
     .stp_chk_en(stp_chk_en_TOP),
     .deser_en(deser_en_TOP),
     .enable(enable_TOP),
     .data_samp_en(data_samp_en_TOP),
     .data_valid(f.data_valid)
);

/**************** instantiation edge_bit_counter *************************/
edge_bit_counter U0_edge_bit_counter(
     .CLK(f.CLK_RX), 
     .RST(f.RST), 
     .enable(enable_TOP), 
     .Prescale(f.prescale), 
     .bit_cnt(bit_cnt_TOP), 
     .edge_cnt(edge_cnt_TOP)  
);

/**************** instantiation data_sampling *************************/
data_sampling U0_data_sampling(
     .RST(f.RST), 
     .CLK(f.CLK_RX), 
     .prescale(f.prescale), 
     .RX_IN(f.RX_IN),  
     .data_samp_en(data_samp_en_TOP), 
     .edge_cnt(edge_cnt_TOP), 
     .sampled_bit(sampled_bit_TOP)  
);


/**************** instantiation deserializer *************************/
deserializer U0_deserializer(
     .CLK(f.CLK_RX),  
     .RST(f.RST), 
     .sampled_bit(sampled_bit_TOP),  
     .deser_en(deser_en_TOP),  
     .edge_cnt(edge_cnt_TOP),  
     .Prescale(f.prescale), 
     .P_DATA(f.P_DATA)
);

/**************** instantiation strt_Check *************************/
strt_Check U0_strt_Check(
     .RST(f.RST), 
     .CLK(f.CLK_RX), 
     .sampled_bit(sampled_bit_TOP), 
     .strt_chk_en(strt_chk_en_TOP), 
     .edge_cnt(edge_cnt_TOP),  
     .Prescale(f.prescale),	 
     .strt_glitch(f.strt_glitch)   
);

/**************** instantiation parity_Check *************************/
parity_Check U0_parity_Check(
     .CLK(f.CLK_RX),
     .RST(f.RST),
     .P_DATA(f.P_DATA), 
     .PAR_TYP(f.PAR_TYP), 
     .sampled_bit(sampled_bit_TOP), 
     .par_chk_en(par_chk_en_TOP), 
	 .edge_cnt(edge_cnt_TOP),  
     .Prescale(f.prescale),
     .par_err(f.par_err) 
	
);

/**************** instantiation Stop_Check *************************/
Stop_Check U0_Stop_Check(
     .RST(f.RST), 
     .CLK(f.CLK_RX), 
     .stp_chk_en(stp_chk_en_TOP), 
     .sampled_bit(sampled_bit_TOP),
     .edge_cnt(edge_cnt_TOP),  
     .Prescale(f.prescale),	 
     .stp_err(f.stp_err) 
);

endmodule