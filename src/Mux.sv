/* ***************************************
******************************************
 ------------	File of MUX's --------------
******************************************
*************************************** */

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
