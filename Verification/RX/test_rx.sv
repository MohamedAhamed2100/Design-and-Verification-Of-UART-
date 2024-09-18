`include "uart_rx_intf.sv"
`timescale 1us/1ns

import common_pkg::*;

module test_rx (uart_rx_intf.tb ifc);

	 //--------------- tx clock -----------
     real clk_tx_period = 8.680555556 ;
	 // TX_CLK
	 bit TX_CLK = 0 ;
	 always #(clk_tx_period/2) TX_CLK = ~TX_CLK ; 
	 
//-------------- test number -----------------------
bit [7:0] Test_NUM ;

// -------------- transaction class ------------
class transaction  ;
     logic reset;
     // rand bit [5:0] s;
     rand bit [7:0] d ;
     rand bit p_e;
     rand bit p_t;

	 // constraint scale_dist { s inside {6'd8 ,6'd16 ,6'd32} ;} 
	 constraint data_dist { d dist {8'd0:/1 , 8'd255:/1 ,[8'd1 : 8'd254]:/98}; }
	
endclass 

// instansiation 	 
transaction tr ; 

// -------------- cover group -------------------
covergroup covports ;
     // CP1: coverpoint tr.s ;
     CP2: coverpoint tr.d ;
     CP3: coverpoint tr.p_e ;   
     CP4: coverpoint tr.p_t ;
endgroup

//--------------------- initialize task ------------------------------
task initialize ;
begin
	ifc.RX_IN = 1'b1 ;  // to start in idle state 
	ifc.RST = 1'b1 ;   
	ifc.prescale = 6'b1000_00 ;    
	ifc.PAR_EN  = 1'b0 ;
	ifc.PAR_TYP = 1'b0 ;
end
endtask

// ------------- Rx configeration task -----------------
task RX_configeration ;
	 input [5:0] Pre_scale ;
	 input Parity_Enable , Parity_Type ; 
	 begin 
	 ifc.prescale = Pre_scale;
	 // $display("prescale : %d , Pre_scale : %d ",ifc.prescale , Pre_scale); 
	 ifc.PAR_EN = Parity_Enable;
	 ifc.PAR_TYP = Parity_Type;
	 end 
endtask

//------------------------ Load Data -----------------------------
task Load_Data ;
 input  [7:0]  DATA ;

 integer   i  ;
 
 begin
     //$display("DATA:%b" , DATA);
	 
      // start_bit
	 @ (posedge TX_CLK)  
	     ifc.RX_IN = 1'b0 ;  
		 //$display("RX_IN:%b" , ifc.RX_IN);
		 
     // data bits
	 for(i=0 ;i<8 ;i=i+1)
	     begin
		     @(posedge TX_CLK) 		
		         ifc.RX_IN = DATA[i] ;  
				 //$display("RX_IN:%b" , ifc.RX_IN);
		 end 
         
	 //parity bit
	if(ifc.PAR_EN)
		begin
			@(posedge TX_CLK) 
			     case(ifc.PAR_TYP)
			         1'b0 : ifc.RX_IN = ~^DATA  ; // Even Parity
			         1'b1 : ifc.RX_IN = ^DATA ; // Odd Parity
			     endcase	
			//$display("RX_IN:%b" , ifc.RX_IN);	 
		end
	 
	 
	 //stop bit 
	 @(posedge TX_CLK) 
	     ifc.RX_IN = 1'b1 ;  // stop_bit
	//$display("RX_IN:%b" , ifc.RX_IN);
	
 end
endtask

// ----------------- check task  ----------------
task check_rx_output ; 

	 input bit [7:0] expected_pattern ;
	 input bit [7:0] test_num ;
	  
	 begin
	 @(posedge ifc.cb.data_valid)
	     assert(ifc.cb.P_DATA == expected_pattern)
		     begin
			     $display(" Test case %d is succeeded " ,test_num );
		         $display("prescale : %d ,, Parity_enable : %b ,, Parity_type : %b " ,ifc.prescale,ifc.PAR_EN,ifc.PAR_TYP);
				 $display("rx_out = %b ,, expexted_pattern = %b" , ifc.cb.P_DATA ,expected_pattern);
				 $display("start error : %b ,, parity error : %b ,, stop error : %b ,, data valid : %b ",ifc.cb.strt_glitch ,ifc.cb.par_err ,ifc.cb.stp_err ,ifc.cb.data_valid );
				 $display("");
			 end
	         else
		     begin
			     $display(" Test case %d is failed " ,test_num );
		         $display("prescale : %d ,, Parity_enable : %b ,, Parity_type : %b " ,ifc.prescale,ifc.PAR_EN,ifc.PAR_TYP);
			     $display("rx_out : %b ,, expexted_pattern : %b" , ifc.cb.P_DATA ,expected_pattern);
				 $display("start error : %b ,, parity error : %b ,, stop error : %b ,, data valid : %b ",ifc.cb.strt_glitch ,ifc.cb.par_err ,ifc.cb.stp_err ,ifc.cb.data_valid );
				 $display("");
			 end  
	 end 
endtask


// ----------------- initial --------------------
initial 
begin 
     covports xyz ;
     xyz = new();
     tr = new();
     
	 initialize();
	 
     tr.reset = 1'b0;
     xyz.stop();
     @ifc.cb
     tr.reset = 1'b1;
     @ifc.cb
     xyz.start();
	 
	 Test_NUM = 'b0;
	 
     //-------------------- prescale = 8 ----------------------
	 // RX_configeration
		 RX_configeration(6'd8,tr.p_e,tr.p_t);
		 
     repeat (100)
     begin 
	     assert(tr.randomize);
	     xyz.sample();
		 
		 clk_rx_period = clk_tx_period / ifc.prescale ; 
		 // $display("clk_rx_period %.2f",clk_rx_period);
		 
		 //Load_Data
		 Load_Data(tr.d);
		 
		 //check_rx_output
		 check_rx_output(tr.d,Test_NUM);
         @ifc.cb;
		 
		 // increase test nuber by one 
		 Test_NUM = Test_NUM + 'b1 ;
     end 
	 
	 //-------------------- prescale = 16 ----------------------
	 // RX_configeration
		 RX_configeration(6'd16,tr.p_e,tr.p_t);
		 
     repeat (100)
     begin 
	     assert(tr.randomize);
	     xyz.sample();
		 
		 clk_rx_period = clk_tx_period / ifc.prescale ; 
		 // $display("clk_rx_period %.2f",clk_rx_period);
		 
		 //Load_Data
		 Load_Data(tr.d);
		 
		 //check_rx_output
		 check_rx_output(tr.d,Test_NUM);
         @ifc.cb;
		 
		 // increase test nuber by one 
		 Test_NUM = Test_NUM + 'b1 ;
     end 
	 
	 //-------------------- prescale = 32 ----------------------
	 // RX_configeration
		 RX_configeration(6'd32,tr.p_e,tr.p_t);
		 
     repeat (100)
     begin 
	     assert(tr.randomize);
	     xyz.sample();
		 
		 clk_rx_period = clk_tx_period / ifc.prescale ; 
		 // $display("clk_rx_period %.2f",clk_rx_period);
		 
		 //Load_Data
		 Load_Data(tr.d);
		 
		 //check_rx_output
		 check_rx_output(tr.d,Test_NUM);
         @ifc.cb;
		 
		 // increase test nuber by one 
		 Test_NUM = Test_NUM + 'b1 ;
     end 
	 
	 
	 running = 0;
	 $display ("Goverage = %.2f%% " , xyz.get_coverage());
end 

endmodule 

