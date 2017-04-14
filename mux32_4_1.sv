module mux32_4_1(input logic [31:0] A, input logic [31:0] B, input logic [31:0] C, input logic [31:0] D, input logic [1:0] ALUSrcB, output logic [31:0] out_mux32_4);
		
		always_comb
			case (ALUSrcB)
				0: out_mux32_4 = A;
				1: out_mux32_4 = B;
				2: out_mux32_4 = C;
				3: out_mux32_4 = D;
			endcase

endmodule 