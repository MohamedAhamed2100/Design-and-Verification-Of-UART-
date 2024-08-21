/********************* serial input -- parallel output *************************/
module deserializer # ( parameter IN_DATA_WIDTH = 8 )
(
 input wire                       CLK, // clock sigal 
 input wire                       RST, // reset signal 
 input wire               sampled_bit, // sampled bit 
 input wire                  deser_en, // deserializer enable 
 input wire [5:0]            edge_cnt, // edge counter 
 input wire [5:0]            Prescale, // prescale
 output reg [IN_DATA_WIDTH-1:0] P_DATA // parallel data
);

              
/************************* deserializer ************************/
always @ (posedge CLK or negedge RST)
begin
     if(!RST)
         P_DATA <= 'b0 ;
     else if(deser_en && edge_cnt == (Prescale - 6'b1))
         P_DATA <= {sampled_bit,P_DATA[7:1]} ;	// add bit at the end of P_DATA within new edge  
end
 

endmodule
 