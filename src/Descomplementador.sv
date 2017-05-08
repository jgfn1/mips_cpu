module Descomplementador(input logic Clk, input logic Enable, input logic [31:0] Entrada, output logic [31:00] Saida);
		always@(posedge Clk) begin
				if(Enable == 1)
						if(Entrada[31] == 1)
								assign Saida = ~Entrada + 1'b1;
						else
								assign Saida = Entrada;
		end
endmodule
