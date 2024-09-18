`timescale 1us/1ns

import common_pkg::*;

module top_rx ;
     bit clk = 0 ;
	 initial 
	 begin 
	     while(running == 1)
		 begin 
	         #(clk_rx_period/2) clk = ~clk;
			 // $display("clk_rx_period : %0.2f ",clk_rx_period);
		 end 
     end 
	 
	 uart_rx_intf intf (clk);
	 UART_RX U0_DUT (intf.dut);
	 test_rx U0_test_bench (intf.tb);
	 
     initial
     begin 
         $dumpfile("UVM_RX.vcd");
		 $dumpvars;
		 @(running == 0) #clk_rx_period $finish ;
     end  
	 
endmodule 