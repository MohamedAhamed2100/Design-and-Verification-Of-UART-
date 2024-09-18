`include "uart_tx_intf.sv"

import common_pkg::*;

module test (uart_tx_intf.tb ifc);

// -------------- transaction class ------------
class transaction  ;
     logic reset;
     rand bit [7:0] d;
     rand bit v ;
     rand bit p_e;
     rand bit p_t;
endclass 

// instansiation 	 
transaction tr ; 

// -------------- cover group -------------------
covergroup covports ;
     CP1: coverpoint tr.d ;
     CP2: coverpoint tr.v ;
     CP3: coverpoint tr.p_e ;   
     CP4: coverpoint tr.p_t ;
endgroup

// ------------- load signals task -----------------
task load_signals ;
     input  [7:0] P_Data ;
	 input Data_Valid , Parity_Enable , Parity_Type ; 
	 begin 
     ifc.p_data = P_Data ; 
	 
	 Data_Valid = 1'b1;
	 ifc.data_valid = Data_Valid;
	 @ifc.cb
	 Data_Valid = 1'b0;
	 ifc.data_valid = 1'b0;
	 
	 ifc.par_en = Parity_Enable;
	 ifc.par_type = Parity_Type;
	 
	 end 
endtask


// ----------------- check task  ----------------
task check_tx_output ; 

	 bit parity_bit ; 
	 bit [9:0] generated_pattern , expected_pattern ;
	 bit [10:0] generated_pattern_par , expected_pattern_par ;
	 
	 integer i ;
     
	 localparam start = 1'b0 , stop = 1'b1 ; 
	 
	 begin
	 
	 // prepare generated bit from TX 
	     @(posedge ifc.cb.busy)  // wait untill busy =  1 
		     if(ifc.par_en)
			 begin 
                 for(i=0; i<11; i=i+1)
		         begin
		             @(negedge ifc.clk) generated_pattern_par[i] = ifc.cb.tx_out ; // wait to negative edge of clock  
		         end
			 end 	 
			 else
             begin			 
			     for(i=0; i<10; i=i+1)
		         begin
		             @(negedge ifc.clk) generated_pattern[i] = ifc.cb.tx_out ; // wait to negative edge of clock  
		         end
			 end 	 
				 
				 
	 // calculate parity bit for comparsion 			  
         if(ifc.par_en)	
         begin 
		     if (!ifc.par_type)
			     parity_bit = ~^ifc.p_data;
			 else if (!ifc.par_type && ifc.p_data == 8'b0000_0000)
			     parity_bit = ~^ifc.p_data;
			 else
                 parity_bit = ^ifc.p_data; 			 
         end
         
	 // comparsion step  
		 if(ifc.par_en)
		     expected_pattern_par = {stop,parity_bit,ifc.p_data,start};
	     else
		     expected_pattern = {stop,ifc.p_data,start};
			 
		 if(ifc.par_en)
			 begin	 
		         if(generated_pattern_par == expected_pattern_par)
		         begin
		             $display("Parallel_data : %b ,, Parity_enable : %b ,, Parity_type : %b " ,ifc.p_data,ifc.par_en,ifc.par_type);
			         $display("Test case is succeeded ,, generated_pattern = %b ,, expexted_pattern = %b" ,generated_pattern_par,expected_pattern_par);
					 $display("");
			     end
	             else
		         begin 
		             $display("Parallel_data : %b ,, Parity_enable : %b ,, Parity_type : %b " ,ifc.p_data,ifc.par_en,ifc.par_type);
			         $display("Test case is failed ,, generated_pattern = %b ,, expexted_pattern = %b" ,generated_pattern_par,expected_pattern_par);
					 $display("");
			     end 
			 end
		 else 
		     begin
			     if(generated_pattern == expected_pattern)
		         begin
		             $display("Parallel_data : %b ,, Parity_enable : %b ,, Parity_type : %b " ,ifc.p_data,ifc.par_en,ifc.par_type);
			         $display("Test case is succeeded ,, generated_pattern = %b ,, expexted_pattern = %b" ,generated_pattern,expected_pattern);
					 $display("");
			     end
	             else
		         begin 
		             $display("Parallel_data : %b ,, Parity_enable : %b ,, Parity_type : %b " ,ifc.p_data,ifc.par_en,ifc.par_type);
			         $display("Test case is failed ,, generated_pattern = %b ,, expexted_pattern = %b" ,generated_pattern,expected_pattern);
					 $display("");
			     end 
			 end  
	 end 
endtask


// ----------------- initial --------------------
initial 
begin 
     covports xyz ;
     xyz = new();
     tr = new();
   
     tr.reset = 1'b0;
     xyz.stop();
     @ifc.cb
     tr.reset = 1'b1;
     @ifc.cb
     xyz.start();
   
     repeat (200)
     begin 
	     assert(tr.randomize);
	     xyz.sample();
		 load_signals(tr.d,tr.v,tr.p_e,tr.p_t);
		 check_tx_output;
         @ifc.cb;
     end 
	 
	 running = 0;
	 $display ("Goverage = %.2f%% " , xyz.get_coverage());
end 

endmodule 




