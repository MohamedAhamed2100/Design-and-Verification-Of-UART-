module UART_RX_FSM #(parameter IN_DATA_WIDTH = 8) (
     input wire            RST,
	 input wire            CLK,
	 input wire          RX_IN,
	 input wire         PAR_EN,
	 input wire        par_err,
	 input wire    strt_glitch,
	 input wire        stp_err,
	 input wire [$clog2(IN_DATA_WIDTH):0] bit_cnt,
	 input wire [5:0] edge_cnt,
	 input wire [5:0] prescale,
	 output reg     par_chk_en,
	 output reg    strt_chk_en,
	 output reg     stp_chk_en,
	 output reg       deser_en,
     output reg         enable,
	 output reg   data_samp_en,
	 output reg     data_valid
);


wire [5:0] edge_cnt_done ; 
assign edge_cnt_done = prescale - 6'b1 ;


reg [2:0] current_state , next_state ;


/*********************** gray state encoding ***********************/
parameter [2:0] IDLE   = 3'b000 
              , START  = 3'b001
              , DATA   = 3'b011
			  , PARITY = 3'b010
              , STOP   = 3'b110
              , ERROR_CHECK = 3'b111 ; 


/*********************** state transition ****************************/
always @(posedge CLK , negedge RST )
begin 
     if(~RST)
         current_state <= IDLE ;
     else 
	     current_state <= next_state ;
end 


/******************************************************************/
/***************************** ASM ********************************/
/******************************************************************/
always @(*)
begin
     case(current_state)
         IDLE:
		     begin
			 if(!RX_IN)
				     next_state = START;
			 else
				     next_state = IDLE;
			 end		 
		 START:
		     begin 
			 if (bit_cnt == 4'd0 && edge_cnt == edge_cnt_done)    
			 begin
		         if(~strt_glitch)
			         next_state = DATA;
			     else 
			         next_state = IDLE;
			 end		 
			 else 
			     next_state = START;
		     end 
		 DATA:
		     begin 
			 if (bit_cnt == 4'd8 && edge_cnt == edge_cnt_done)    
			 begin
		         if(PAR_EN)
			         next_state = PARITY;
			     else 
			         next_state = STOP;
			 end		 
			 else 
			     next_state = DATA;
		     end 
		 PARITY:
		     begin 
			 if (bit_cnt == 4'd9 && edge_cnt == edge_cnt_done)    
			     next_state = STOP ; 
			 else 
			     next_state = PARITY ;
		     end 
		 STOP:
		     begin 
			 if (PAR_EN)
			 begin    
			     if (bit_cnt == 4'd10 && edge_cnt == edge_cnt_done )    
			         next_state = ERROR_CHECK;
			     else 
			         next_state = STOP;
			 end		 
			 else 
			     if (bit_cnt == 4'd9 && edge_cnt == edge_cnt_done )    
			         next_state = ERROR_CHECK;
			     else 
			         next_state = STOP;
		     end 
		 ERROR_CHECK:
		     begin
             if(!RX_IN)
			     next_state = START ;
			 else
			     next_state = IDLE ; 									  
             end				  		   
         default: 
			 next_state = IDLE ; 
     endcase	
end 


always @(*)
begin
     par_chk_en   = 1'b0 ;
     strt_chk_en  = 1'b0 ;
     stp_chk_en   = 1'b0 ;
     deser_en     = 1'b0 ;
     enable       = 1'b0 ;
     data_samp_en = 1'b0 ;
     data_valid   = 1'b0 ;
	 
     case(current_state)
         IDLE:
		     begin
			 if(!RX_IN)
			     begin 
		         par_chk_en   = 1'b0 ;
                 strt_chk_en  = 1'b1 ;
                 stp_chk_en   = 1'b0 ;
                 deser_en     = 1'b0 ;
                 enable       = 1'b1 ;
                 data_samp_en = 1'b1 ;
                 data_valid   = 1'b0 ;
				 end 
			 else 
                 begin 
                 par_chk_en   = 1'b0 ;
                 strt_chk_en  = 1'b0 ;
                 stp_chk_en   = 1'b0 ;
                 deser_en     = 1'b0 ;
                 enable       = 1'b0 ;
                 data_samp_en = 1'b0 ;
                 data_valid   = 1'b0 ;
                 end				 	 
			 end
		 START:
		     begin
		     par_chk_en   = 1'b0 ;
             strt_chk_en  = 1'b1 ;
             stp_chk_en   = 1'b0 ;
             deser_en     = 1'b1 ;
             enable       = 1'b1 ;
             data_samp_en = 1'b0 ;
             data_valid   = 1'b0 ;
			 end
		 DATA:
		     begin
		     par_chk_en   = 1'b0 ;
             strt_chk_en  = 1'b0 ;
             stp_chk_en   = 1'b0 ;
             deser_en     = 1'b1 ;
             enable       = 1'b1 ;
             data_samp_en = 1'b1 ;
             data_valid   = 1'b0 ;
			 end 
		 PARITY:
		     begin
		     par_chk_en   = 1'b1 ;
             strt_chk_en  = 1'b0 ;
             stp_chk_en   = 1'b0 ;
             deser_en     = 1'b0 ;
             enable       = 1'b1 ;
             data_samp_en = 1'b1 ;
             data_valid   = 1'b0 ;
			 end 
		 STOP:
		     begin
		     par_chk_en   = 1'b0 ;
             strt_chk_en  = 1'b0 ;
             stp_chk_en   = 1'b1 ;  
             deser_en     = 1'b0 ; 
             enable       = 1'b1 ;
             data_samp_en = 1'b1 ;
             data_valid   = 1'b0 ;
			 end   
		 ERROR_CHECK:
		     begin
		     par_chk_en   = 1'b0 ;
             strt_chk_en  = 1'b0 ;
             stp_chk_en   = 1'b0 ;
             deser_en     = 1'b0 ;
             enable       = 1'b0 ;
             data_samp_en = 1'b0 ;
			 if (stp_err|par_err)
                 data_valid   = 1'b0 ;
			 else
			     data_valid   = 1'b1 ;
			 end
		 default:
		     begin
		     par_chk_en   = 1'b1 ;
             strt_chk_en  = 1'b1 ;
             stp_chk_en   = 1'b1 ;
             deser_en     = 1'b0 ;
             enable       = 1'b0 ;
             data_samp_en = 1'b0 ;
             data_valid   = 1'b0 ;
			 end
	 endcase		 
end 		 

endmodule 		     