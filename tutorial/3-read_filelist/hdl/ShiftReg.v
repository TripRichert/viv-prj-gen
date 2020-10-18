
module ShiftReg (
		 clk,
		 en,
		 D,
		 Q
		 );
   parameter width = 8;

   input clk;
   input en;
   input D;
   output [width - 1:0] Q;

   reg 			Q0 = 0;
   


   DFlipFlop first_ff (
		       clk,
		       en,
		       D,
		       Q[0]
		       );
   generate
      genvar 		i;
      
      for (i = 1; i < width; i = i + 1) begin
	 DFlipFlop ff_i (clk, en, Q[i - 1], Q[i]);
      end
   endgenerate
   
endmodule
      
   

   
  
