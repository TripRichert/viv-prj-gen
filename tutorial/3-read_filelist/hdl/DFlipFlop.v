module DFlipFlop (
                  input clk,
                  input en,
                  input D,
                  output reg Q
                  );
   reg Q_cpy = 0;

   always @ (Q_cpy) begin
      Q <= Q_cpy;
   end
   
   always @ (posedge clk) begin
     if (en) begin
        Q_cpy <= D;
     end else begin
        Q_cpy <=  Q_cpy;
     end
   end
endmodule
