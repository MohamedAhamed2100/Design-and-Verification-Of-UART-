interface uart_rx_intf (
	 input bit CLK_RX
);

//------------ signals --------------------
     bit            RST;
	 bit          RX_IN;
	 bit [5:0] prescale;
	 bit         PAR_EN;
	 bit        PAR_TYP; 
	 bit     data_valid;
	 bit        par_err;
	 bit        stp_err;
	 bit    strt_glitch;
	 bit [7:0]   P_DATA; 


//----------- clocking block --------------
clocking cb @(posedge CLK_RX);
     input data_valid , par_err , stp_err , strt_glitch , P_DATA ;
endclocking  

//--------------- mode ports ---------------
modport tb (output CLK_RX , RST , RX_IN , prescale , PAR_EN , PAR_TYP , clocking cb);
modport dut(input CLK_RX , RST , RX_IN , prescale , PAR_EN , PAR_TYP , output data_valid , par_err , stp_err , strt_glitch , P_DATA );

endinterface