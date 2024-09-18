module strt_Check (
     input wire RST, // reset signal 
	 input wire CLK, // clock signal 
	 input wire sampled_bit, // sample data 
	 input wire strt_chk_en,  // start check enable
     input wire [5:0] edge_cnt, // edge counter 
     input wire [5:0] Prescale, // prescale	 
	 output reg strt_glitch     // start glitch 
);

/************************* start bit error checker ********************/
always@(posedge CLK , negedge RST)
begin
     if(!RST)
	     strt_glitch <= 1'b0 ;
	 else if (strt_chk_en && (edge_cnt == ((Prescale >> 1) + 6'b10)))	 
	     strt_glitch <= sampled_bit ; 
end 

endmodule 