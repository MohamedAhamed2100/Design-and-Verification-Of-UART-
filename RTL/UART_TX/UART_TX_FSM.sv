module UART_TX_FSM (
   input wire       CLK        , // clock signal
   input wire       RST        , // Asynchronous active low reset signal 
   input wire       PAR_EN     , // parity calculator enable 
   input wire       ser_done   , // serializer done flag
   input wire       Data_Valid , // synchronous data valid flag 
   output reg [1:0] mux_sel    , // mux selector 
   output reg       ser_en     , // serializer enable 
   output reg       busy         // synchronous busy flag 
);

/***************** defined States of FSM  ****************/
typedef enum bit [2:0] {
             IDLE   = 3'b000,
             start  = 3'b001,
			 data   = 3'b011,
			 parity = 3'b010,
			 stop   = 3'b110 
} state; 
				 
state Current_State , Next_State ; // Synchroubized states 


reg busy_comb; 
/*************** busy flag ************/
always@(posedge CLK , negedge RST ) 
begin 
     if( ~RST )
         busy <= 1'b0 ;
	 else
	     busy <= busy_comb ;
end 

/*********************************************************/
/********* Algorirhmic State Machine Chart (ASM) *********/  
/*********************************************************/

/****************** State Transition *********************/
always@(posedge CLK , negedge RST ) 
begin 
     if( ~RST )
         Current_State <= IDLE ;
	 else
	     Current_State <= Next_State ;
end 



/******************************* next state logic *****************************/
always @(*)
begin 
     case(Current_State)
	 
	     IDLE  : begin
		         if(Data_Valid)
				     Next_State = start ;
			     else 
				     Next_State =  IDLE ;
				 end
				 
	     start : Next_State = data ;	
		 
		 data  : begin
		         if(ser_done)
				     begin 
				         if(PAR_EN)
				             Next_State = parity ;
					     else 
					         Next_State = stop ;
                     end       					 
			     else 
				     Next_State =  data ;	 
				 end
				 
		 parity: Next_State = stop ;
		 
		 stop  : Next_State = IDLE ;
		 
		 default: Next_State = IDLE ;
		 
	 endcase
	 
end

/*********************** output logic *****************************/
always @(*)
begin 

     mux_sel   = 2'b00;
	 busy_comb = 1'b0 ;
	 ser_en    = 1'b0 ;
				 
     case(Current_State)
	 
	     IDLE  : begin
		         mux_sel   = 2'b01;
				 busy_comb = 1'b0 ;
				 end
				 
	     start : begin
				 busy_comb = 1'b1 ;
				 end	
		 
		 data  : begin
		         mux_sel   = 2'b10;
				 busy_comb = 1'b1 ;
				 ser_en    = 1'b1 ;
				 if (ser_done)
				    ser_en = 1'b0 ;
				 else
				    ser_en = 1'b1 ;
				 end
				 
		 parity: begin
		         mux_sel   = 2'b11;
				 busy_comb = 1'b1 ;
				 end
		 
		 stop  : begin
		         mux_sel   = 2'b01;
				 busy_comb = 1'b1 ;
				 end
		 
		 default: begin
                 mux_sel   = 2'b01;
	             busy_comb = 1'b0 ;
	             ser_en    = 1'b0 ;
				 end
		 
	 endcase
end

endmodule 