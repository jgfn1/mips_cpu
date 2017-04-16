module Shift_left2(input logic [31:0] Entrada , output logic [31:0] Saida);
		always_comb
			begin 
				Saida = (Entrada << 2);
			end
endmodule 