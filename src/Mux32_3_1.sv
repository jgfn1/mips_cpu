module Mux32_3_1 (input logic [31:0] A, input logic [31:0] B, input logic [31:0] C, input logic [1:0] Seletor, output logic [31:0] Saida);

	always_comb
		case (Seletor)
			0: Saida = A;
			1: Saida = B;
			2: Saida = C;
			3: Saida = A; // isso não vai ser usado mas evita warning..
		endcase
endmodule 