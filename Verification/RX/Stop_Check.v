module Stop_Check (
      input wire          RST, // reset signal
	  input wire          CLK, // clock signal
	  input wire   stp_chk_en, // stop bit checker enable 
	  input wire  sampled_bit, // sample bit 
	  input wire [5:0]            edge_cnt, // edge counter 
      input wire [5:0]            Prescale, // prescale
      output reg      stp_err // stop bit error flag 
);

/******************* stop error checker **********************/
always@(posedge CLK ,negedge RST)
begin
     if (~RST)
	    stp_err <= 1'b0;
	 else if (stp_chk_en && (edge_cnt == ((Prescale >> 1) + 6'b10)))
	    stp_err <= 1'b1 ^ sampled_bit ;	 
end

endmodule 