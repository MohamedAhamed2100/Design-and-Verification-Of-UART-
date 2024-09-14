interface uart_tx_intf  (
     input bit clk
	) ;
//------------ signals --------------------
     logic       rst;
     logic [7:0] p_data;
     logic       data_valid;
     logic       par_en;
     logic       par_type; 
     logic       tx_out;
     logic       busy;
	 
//----------- clocking block --------------
clocking cb @(posedge clk);
     input tx_out , busy ;
endclocking	 

//--------------- mode ports ---------------
modport tb (output clk , rst , p_data , data_valid , par_en , par_type , clocking cb);
modport dut(input clk , rst , p_data , data_valid , par_en , par_type , output tx_out , busy );

endinterface 