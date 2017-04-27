module  Mux32_2_1 (
	input  logic  [31:0] A, 
	input  logic  [31:0] B,	
	input  logic  [1:0] Mux32_seletor, 
	output logic  [31:0]Mux32_out
);

	always_comb
			case (Mux32_seletor)
				0: Mux32_out = A;
				1: Mux32_out = B;
				2: Mux32_out = B;
				3: Mux32_out = A;
			endcase

endmodule