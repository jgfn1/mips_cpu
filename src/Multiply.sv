module Multiply(
	Clk,
	State,
	A,
	B,
	Produto,
	EndMulFlag
);

	input logic Clk;
	input logic [5:0] State;
	input logic [31:0] A;
	input logic [31:0] B;
	output reg  [64:0] Produto;
	output logic EndMulFlag;

	reg signal;
	reg [31:0] multiplicando;
	reg [6:0] counter;

  /** Algoritmo da multiplicacao da pagina 150 do Patterson 2th edition. **/

  always_ff@(posedge Clk) begin
	    case(State)
			36: begin // MULT
				EndMulFlag = 0;
				counter = 0;

				Produto[31:0] = A[31:0];
				multiplicando[31:0] = B[31:0];
				signal = A[31] ^ B[31];
			end
			37: begin // MULT2
				counter = counter + 7'b1;

				if(Produto[0] == 1)
					Produto[63:32] = Produto[63:32] + multiplicando[31:0];

				Produto = Produto >> 1;

				if(counter == 31) begin
					Produto[63] = signal;
				 	EndMulFlag = 1;
				end
			end
			default: begin

			end
	    endcase
  end

endmodule
