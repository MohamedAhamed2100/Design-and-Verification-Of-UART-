/************** 4 Inputs x 1 Output  Mux ************/
module MUX (
    input wire [3:0] IN , 
	input wire [1:0] SEL, // 2-bits Selector 
	input wire       CLK, // Clock signal 
	input wire       RST, // Asynhcronous Reset
	output reg       OUT
);


reg OUT_Comb ; // Combinational Output of MUX  

/************* Sequential Always for Register MUX OUTPUT *************/
always@(posedge CLK , negedge RST ) 
begin 
     if( ~RST )
        OUT <= 1'b0 ;
	 else
	     OUT <= OUT_Comb ;
end 

/************* Cominational Always for MUX Behavior *************/
always@(*) 
begin 
     case(SEL)
	     2'b00: OUT_Comb = IN[0] ;
		  2'b01: OUT_Comb = IN[1] ;
		  2'b10: OUT_Comb = IN[2] ;
		  2'b11: OUT_Comb = IN[3] ;
	 endcase
end 

endmodule