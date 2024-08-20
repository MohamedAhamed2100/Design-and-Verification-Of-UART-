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

reg [IN_DATA_WIDTH-1:0] PAR_P_Data ; //Parity Calculator input data for processing 

/******************* Load Parallel Input Data **************/
always @(posedge CLK , negedge RST)
begin
     if(!RST)
     begin
         PAR_P_Data <= 'b0 ;
     end
     else if(Data_Valid && !BUSY)
     begin
         PAR_P_Data <= P_DATA ;
     end 
 end
 
/****************** Parity Bit Calculation *****************/
always @(posedge CLK , negedge RST)
begin
     if(!RST)
     begin
         Par_Bit <= 'b0 ;
     end
     else
     begin
         if (PAR_EN)
	     begin
	         case(PAR_TYP)
	             1'b0 : Par_Bit <= ^DATA_V  ;   // Even Parity Bit
	             1'b1 : Par_Bit <= ~(^DATA_V) ; // Odd Parity Bit 	
	         endcase       	 
	     end
     end
end 


endmodule