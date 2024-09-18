`timescale 1ns/1ps

module UART_TX_TB ();

/************************* Parameters *************************/
parameter IN_DATA_WIDTH_TB = 8 ;      
parameter CLK_PERIOD = 5   ;  // 200 MHz

/*************************** DUT Signals **************************/
reg                  		CLK_TB;
reg                  		RST_TB;
reg [IN_DATA_WIDTH_TB-1:0]  P_DATA_TB;
reg                  		Data_Valid_TB;
reg                 		parity_enable_TB;
reg                 		parity_type_TB; 
wire                		TX_OUT_TB;
wire                		busy_TB;

/********************* DUT Instaniation *************************/
UART_TX #(.DATA_WIDTH(IN_DATA_WIDTH_TB)) U0_UART_TX(
.CLK_TOP(CLK_TB),
.RST_TOP(RST_TB),
.P_DATA_TOP(P_DATA_TB),
.Data_Valid_TOP(Data_Valid_TB),
.PAR_EN_TOP(parity_enable_TB),
.PAR_TYP_TOP(parity_type_TB),
.TX_OUT_TOP(TX_OUT_TB), 
.busy_TOP(busy_TB)
);

// initialize task
task initialize ;
     begin 
     CLK_TB = 1'b0;
     RST_TB = 1'b1;
     P_DATA_TB = 'b0 ;
     Data_Valid_TB = 1'b0;
     parity_enable_TB = 1'b0;
     parity_type_TB = 1'b0;
	 end 
endtask 

/************************* Clock Generator *********************/
always #(CLK_PERIOD/2) CLK_TB = ~CLK_TB ;

/************************ simulation Tasks *****************************/
// reset task
task reset ;
     begin 
     RST_TB = 1'b0;
     # CLK_PERIOD 
     RST_TB = 1'b1;
     # CLK_PERIOD ; 
	 end 
endtask

// load data task
task load_data ;
     input [IN_DATA_WIDTH_TB-1 : 0] P_Data ;
	 begin 
     P_DATA_TB = P_Data ; 
	 Data_Valid_TB = 1'b1;
	 # CLK_PERIOD
	 Data_Valid_TB = 1'b0;
	 end 
endtask

// configuration setup
task configuration_setup;
     input parity_enable , parity_type;  
	 begin 
	  parity_enable_TB = parity_enable ;
	  parity_type_TB = parity_type ;
	 end 
endtask

// check TX output
task check_TX_output ; 
	 input [2:0] Test_num ;   // test number  
	 
	 reg parity_bit ; 
	 reg [10:0] generated_pattern , expected_pattern ;
	 
	 integer i ;
     
	 localparam start = 1'b0 , stop = 1'b1 ; 
	 
	 begin
	 
	 // prepare generated bit from TX 
	     @(posedge busy_TB)
             for(i=0; i<11; i=i+1)
		     begin
		         @(negedge CLK_TB) generated_pattern[i] = TX_OUT_TB ;
		     end
			 
	 // calculate parity bit for comparsion 			  
         if(parity_enable_TB)	
         begin 
		     if (!parity_type_TB)
			     parity_bit = ~^P_DATA_TB;
			 else
                 parity_bit = (^P_DATA_TB); 			 
         end

         
	 // comparsion step  
		 if(parity_enable_TB)
		     expected_pattern = {stop,parity_bit,P_DATA_TB,start};
	     else
		     expected_pattern = {1'b1,stop,P_DATA_TB,start};
			 
		 if(generated_pattern == expected_pattern) 
			 $display("Test Case %d is succeeded",Test_num);
	     else
			 $display("Test Case %d is failed", Test_num); 
	 end 
endtask

/*************************** intial block **********************************/ 
initial
begin
 
 // initialization
 initialize() ;

 // reset
 reset() ; 


 /******************** Test Case 0 (No Parity) *******************/
 // TX Configuration (Parity Enable = 0 & ignore parity & DATA end by 1)
 configuration_setup (1'b0,1'b0);

 // Load Data 
 load_data(8'hC8);  

 // Check TX Output
 check_TX_output(0) ;

 #(2*CLK_PERIOD)
 
  /******************** Test Case 1 (No Parity) *******************/
 // TX Configuration (Parity Enable = 0 & checking parity enable is working & DATA end by 1 )
 configuration_setup (1'b0,1'b1);

 // Load Data 
 load_data(8'hC8);  

 // Check TX Output
 check_TX_output(1) ;

 #(2*CLK_PERIOD)
 
  /******************** Test Case 2 (No Parity) *******************/
 // TX Configuration (Parity Enable = 0 & ignore parity & DATA end by 0)
 configuration_setup (1'b0,1'b0);

 // Load Data 
 load_data(8'h28);  

 // Check TX Output
 check_TX_output(2) ;

 #(2*CLK_PERIOD)
 
 /***************** Test Case 3 (Odd Parity) ******************/

 // TX Configuration (Parity Enable = 1 & Parity Type = 1 & DATA end by 1)
 configuration_setup (1'b1,1'b1);

 // Load Data 
 load_data(8'hA1);  

 // Check TX Output
 check_TX_output(3) ; 

 #(2*CLK_PERIOD)

 /****************** Test Case 4 (Even Parity) ********************/

 // TX Configuration (Parity Enable = 1 & Parity Type = 0 & DATA end by 1)
 configuration_setup (1'b1,1'b0);

 // Load Data 
 load_data(8'hF3);  

 // Check TX Output
 check_TX_output(4) ;
 
 #(2*CLK_PERIOD)
 
 /***************** Test Case 5 (Odd Parity) ******************/

 // TX Configuration (Parity Enable = 1 & Parity Type = 1 & DATA end by 0)
 configuration_setup (1'b1,1'b1);

 // Load Data 
 load_data(8'h31);  

 // Check TX Output
 check_TX_output(5) ; 

 #(2*CLK_PERIOD)

 /****************** Test Case 6 (Even Parity) ********************/

 // TX Configuration (Parity Enable = 1 & Parity Type = 0 & DATA end by 0)
 configuration_setup (1'b1,1'b0);

 // Load Data 
 load_data(8'h33);  

 // Check TX Output
 check_TX_output(6) ;
 
 #(2*CLK_PERIOD)
 
$stop ;
  
end
 
endmodule
