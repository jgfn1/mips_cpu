module Extensor_sinal(input logic [15:0] Entrada, output logic [31:0] Saida);
		
	assign Saida = { {16{1'b0}} , Entrada[15:0]};
			
endmodule 