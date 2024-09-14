`timescale 1ns/1ps

import common_pkg::*;

module top ;
     parameter clk_period = 5;
     bit clk = 0 ;
	 initial 
	 begin 
	     while(running == 1)
	         #(clk_period/2) clk = ~clk;
     end 
	 
	 uart_tx_intf intf (clk);
	 UART_TX U0_DUT (intf.dut);
	 test U0_test_bench (intf.tb);
	 
     initial
     begin 
         $dumpfile("UVM.vcd");
		 $dumpvars;
		 @(running == 0) #clk_period $finish ;
     end  
	 
endmodule 