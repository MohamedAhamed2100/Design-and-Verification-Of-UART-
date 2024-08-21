module data_sampling (
     input wire               RST ; // reset signal
     input wire           CLK ; // clock signal
     input wire [5:0]     prescale ; // prescale value (scaling for RX clock)
     input wire         RX_IN ; // UART RX serial input  
	 input wire  data_samp_en ; // data sample enable 
	 input wire      edge_cnt ; // edge counter 
	 output reg    sample_bit ; // sample bit 
);


reg [2:0] sample ; // oversampling = 3 samples for one bit 


/********************** sampling position ************************/
wire [5:0] middle_edge,before_middle_edge,after_middle_edge;  // 6 bit to take prescale equal 32  

assign middle_edge = (prescale >> 1) - 1'b1     ;  // (prescale/2)-1 -- EX: ((prescale=16)/2)-1= 7
assign before_middle_edge =  middle_edge - 1'b1 ;
assign after_middle_edge =  middle_edge +  1'b1 ;


/******************* sampling process *************************/
always @(negedge RST , posedge CLK)
begin
     if(!RST)
         sample <= 'b0 ;
	 else 
	     if (data_samp_en)
             if(before_middle_edge)
		         sample[0] <= RX_IN ;
             else if(middle_edge)
		         sample[1] <= RX_IN ;
             else if(after_middle_edge)
		         sample[2] <= RX_IN ;
	 	 else
             sample <= 1'b0 ;   		 
end


/******************* sampler result ******************************/
always @(negedge RST , posedge CLK)
begin
     if(!RST)
         sample_bit <= 1'b0 ;
	 else
	 begin
	     if (data_samp_en)
		 begin
             case(sample)
                 3'b000: sample_bit <= 1'b0 ;	 
                 3'b001: sample_bit <= 1'b0 ;
		         3'b010: sample_bit <= 1'b0 ;
		         3'b011: sample_bit <= 1'b1 ;
		         3'b100: sample_bit <= 1'b0 ;
		         3'b101: sample_bit <= 1'b1 ;
		         3'b110: sample_bit <= 1'b1 ;
		         3'b111: sample_bit <= 1'b1 ;
			 endcase	 
		 end 
         else
         sample_bit <= 1'b0 ;		 
	end			 
end 
endmodule 
