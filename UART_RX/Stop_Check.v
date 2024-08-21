module Stop_Check (
      input wire          RST, // reset signal
	  input wire          CLK, // clock signal
	  input wire   stp_chk_en, // stop bit checker enable 
	  input wire  sampled_bit, // sample bit 
      output reg      stp_err // stop bit error flag 
);

/******************* stop error checker **********************/
always@(posedge CLK ,negedge RST)
begin
     if (~RST)
	    stp_err <= 1'b0;
	 else if (stp_chk_en)
	    stp_err <= 1'b1 ^ sampled_bit ;	 
end

endmodule 