module Parity_Calc # ( parameter IN_DATA_WIDTH = 8 )
(
     input   wire                          CLK, // Clock Signal
     input   wire                          RST, // Active Low Asynchronous reset Signal
     input   wire                       PAR_EN, // Synchronous Parity Enable Signal 
     input   wire                      PAR_TYP, // Synchronous Parity Type 
     input   wire                         BUSY, // Synchronous BUSY Flag
     input   wire   [IN_DATA_WIDTH-1:0] P_DATA, // Input Parallel Data
     input   wire                   Data_Valid, // Synchronous Data_Valid Flag
     output  reg                       Par_Bit  // Parity Bit 
);

reg [IN_DATA_WIDTH-1:0] PAR_P_Data ; //save Parity Calculator input data for processing 

/******************* Load Parallel Input Data **************/
always @(posedge CLK , negedge RST)
begin
     if(!RST)
         PAR_P_Data <= 'b0 ;
     else if(Data_Valid && !BUSY)
         PAR_P_Data <= P_DATA ;
 end
 
/****************** Parity Bit Calculation *****************/
always @(posedge CLK , negedge RST)
begin
     if(!RST)
         Par_Bit <= 'b0 ;
     else
     begin
         if (PAR_EN)
	     begin
	         case(PAR_TYP)
	             1'b0 : Par_Bit <= ^PAR_P_Data  ;   // Even Parity Bit
	             1'b1 : Par_Bit <= ~(^PAR_P_Data) ; // Odd Parity Bit 	
	         endcase       	 
	     end
     end
end 


endmodule