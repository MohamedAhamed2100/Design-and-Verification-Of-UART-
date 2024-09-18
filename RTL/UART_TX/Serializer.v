module Serializer #( parameter IN_DATA_WIDTH = 8)
(
     input wire [IN_DATA_WIDTH-1:0] P_DATA  , // Paramitrized Parallel Input Data  
     input wire             Ser_Enable , // synchronous Serializer Enable signal
	 input wire                    CLK , // Clock Signal
	 input wire                    RST , // Asynchronous Reset Signal
	 input wire                   BUSY , // synchronous Busy Flag
	 input wire             Data_Valid , // synchronous Data_Valid Flag 
	 output                   Ser_Done , // serializer Done Flag 
	 output                   Ser_Data   // serializer Output data 

);


reg [$clog2(IN_DATA_WIDTH)-1:0] Ser_Count  ; // serializer Counter 
reg [IN_DATA_WIDTH-1:0]         Ser_P_DATA ; // save serializer Parallel Data for processing

/****************** Load Serializer Input **************/
always @(posedge CLK , negedge RST)
begin
     if(~RST)
	      Ser_P_DATA <= 'b0 ;
	 else if(Data_Valid && !BUSY)    // use busy : UART_TX couldn't accept any data on P_DATA during UART_TX processing, however Data_Valid get high
         Ser_P_DATA <= P_DATA ;
     else if(Ser_Enable)
         Ser_P_DATA <= Ser_P_DATA >> 1 ;      
end 


/****************** Serializer Counter **************/
always @(posedge CLK , negedge RST )
begin
     if(~RST)
	     Ser_Count <= 'b0 ;
	 else	
	 begin
         if(Ser_Enable)
	        Ser_Count <= Ser_Count + 'b1 ;
         else
		    Ser_Count <= 'b0 ;
	 end	    
end 

/******************* Assign Serializer Outputs **********************/
assign Ser_Data = Ser_P_DATA[0] ;
assign Ser_Done = (Ser_Count == IN_DATA_WIDTH-1) ? 1'b1 : 1'b0 ;

endmodule 