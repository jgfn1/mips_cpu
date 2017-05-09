/* ***************************************
******************************************
 ------------	File of MUX's --------------
******************************************
*************************************** */

//
// 	---- MUX 5 bits - com 2 entradas
//
module  Mux5_2 (
	 	input  logic  [4:0] A,
	 	input  logic  [4:0] B,
	 	input  logic  Seletor,
	 	output logic  [4:0] Saida
	 );

	 assign Saida = (Seletor) ? B : A;

endmodule

//
// 	---- MUX 5 bits - com 3 entradas
//
module  Mux5_3 (
	 	input  logic  [4:0] A,
	 	input  logic  [4:0] B,
	 	input  logic  [4:0] C,
	 	input  logic  [1:0] Seletor,
	 	output logic  [4:0] Saida
	 );

	 always_comb
		 	case (Seletor)
		 		0: Saida = A;
		 		1: Saida = B;
		 		2: Saida = C;
		 		3: Saida = A; // isso n�o vai ser usado mas evita warning..
		 	endcase

endmodule

//
// 	---- MUX 32 bits - Com 2 entradas
//
module Mux32_2 (
				input logic [31:0] A,
				input logic [31:0] B,
				input logic Seletor,
				output logic [31:0] Saida
		);

		always_comb
				case (Seletor)
					0: Saida = A;
					1: Saida = B;
				endcase
endmodule



//
// 	---- MUX 32 bits - Com 3 entradas
//
module Mux32_3 (
				input logic [31:0] A,
				input logic [31:0] B,
				input logic [31:0] C,
				input logic [1:0] Seletor,
				output logic [31:0] Saida
		);

		always_comb
				case (Seletor)
					0: Saida = A;
					1: Saida = B;
					2: Saida = C;
					3: Saida = A; // isso n�o vai ser usado mas evita warning..
				endcase
endmodule


//
// 	---- MUX 32 bits - Com 4 entradas
//
module Mux32_4(
			input logic [31:0] A,
			input logic [31:0] B,
			input logic [31:0] C,
			input logic [31:0] D,
			input logic [1:0] Seletor,
			output logic [31:0] Saida
		);

		always_comb
				case (Seletor)
					0: Saida = A;
					1: Saida = B;
					2: Saida = C;
					3: Saida = D;
				endcase
endmodule


//
// 	---- MUX 32 bits - Com 5 entradas
//
module Mux32_5(
			input logic [31:0] A,
			input logic [31:0] B,
			input logic [31:0] C,
			input logic [31:0] D,
			input logic [31:0] E,
			input logic [2:0] Seletor,
			output logic [31:0] Saida
		);

		always_comb
				case (Seletor)
					0: Saida = A;
					1: Saida = B;
					2: Saida = C;
					3: Saida = D;
					4: Saida = E;
					default: Saida = A;
				endcase
endmodule



//
// 	---- MUX 32 bits - Com 6 entradas
//
module Mux32_6(
			input logic [31:0] A,
			input logic [31:0] B,
			input logic [31:0] C,
			input logic [31:0] D,
			input logic [31:0] E,
			input logic [31:0] F,
			input logic [2:0] Seletor,
			output logic [31:0] Saida
		);

		always_comb
				case (Seletor)
					0: Saida = A;
					1: Saida = B;
					2: Saida = C;
					3: Saida = D;
					4: Saida = E;
					5: Saida = F;
					default: Saida = A;
				endcase
endmodule


//
// 	---- MUX 32 bits - Com 7 entradas
//
module Mux32_7(
			input logic [31:0] A,
			input logic [31:0] B,
			input logic [31:0] C,
			input logic [31:0] D,
			input logic [31:0] E,
			input logic [31:0] F,
			input logic [31:0] G,
			input logic [2:0] Seletor,
			output logic [31:0] Saida
		);

		always_comb
				case (Seletor)
					0: Saida = A;
					1: Saida = B;
					2: Saida = C;
					3: Saida = D;
					4: Saida = E;
					5: Saida = F;
					6: Saida = G;
					default: Saida = A;
				endcase
endmodule

//
// 	---- MUX 32 bits - Com 8 entradas
//
module Mux32_09(
			input logic [31:0] A,
			input logic [31:0] B,
			input logic [31:0] C,
			input logic [31:0] D,
			input logic [31:0] E,
			input logic [31:0] F,
			input logic [31:0] G,
			input logic [31:0] H,
			input logic [31:0] I,
			input logic [4:0] Seletor,
			output logic [31:0] Saida
		);

		always_comb
				case (Seletor)
					0: Saida = A;
					1: Saida = B;
					2: Saida = C;
					3: Saida = D;
					4: Saida = E;
					5: Saida = F;
					6: Saida = G;
					7: Saida = H;
					8: Saida = I;
					default: Saida = A;
				endcase
endmodule
