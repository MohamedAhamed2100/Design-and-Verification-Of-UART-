module edge_bit_counter #(parameter IN_DATA_WIDTH = 8) 
(
     input wire                                CLK, // clock signal 
     input wire                                RST, // reset signal
     input wire                             enable, // edge counter enable 
     input wire [5:0]                     Prescale, // prescale
     output reg [3:0]  bit_cnt, // bit counter
     output reg [5:0]                     edge_cnt  // edge counter 
);
//$clog2(IN_DATA_WIDTH)

wire edge_cnt_done ; 

/********************** edge counter ********************/ 
always @(posedge CLK , negedge RST)
begin
     if(!RST)
         edge_cnt <= 'b0;
     else if(enable)
     begin
         if (edge_cnt_done)
             edge_cnt <= 'b0;
	     else
              edge_cnt <= edge_cnt + 'b1;	
     end 
     else
        edge_cnt <= 'b0; 
end
 
assign edge_cnt_done = (edge_cnt == (Prescale - 6'b1)) ? 1'b1 : 1'b0 ; 

/******************** bit counter ***********************/
always @(posedge CLK , negedge RST)
begin
     if(!RST)
         bit_cnt <= 'b0 ;
     else if(enable)
     begin
         if (edge_cnt_done)
             bit_cnt <= bit_cnt + 'b1 ; 
	  end		 
     else
         bit_cnt <= 'b0 ;	
 end 

endmodule