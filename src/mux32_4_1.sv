module Mux32_4_1(
	input logic [31:0] A, 
	input logic [31:0] B, 
	input logic [31:0] C, 
	input logic [31:0] D, 
	input logic [1:0] ALUSrcB, 
	output logic [31:0] Mux32_4_out
);
		
		always_comb
			case (ALUSrcB)
				0: Mux32_4_out = A;
				1: Mux32_4_out = B;
				2: Mux32_4_out = C;
				3: Mux32_4_out = D;
			endcase
endmodule 