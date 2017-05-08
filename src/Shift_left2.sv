module Shift_left2(input logic [31:0] Entrada , output logic [31:0] Saida);
		always_comb
			begin
				Saida = (Entrada << 2);
			end
endmodule

module Shift_left_reg64(input logic enable, input logic [31:0] i1,  input logic [31:0]  i2, output logic [31:0] o1, output logic [31:0] o2);
		always_ff @(posedge enable)
				begin
						o1[31:0] = (i1 << 1);
						o1[0] = i2[31];
						o2[31:0] = (i2 << 1);
				end
endmodule

module Shift_right_reg64(input logic enable, input logic [31:0] i1,  input logic [31:0]  i2, output logic [31:0] o1, output logic [31:0] o2);
		always_ff @(posedge enable)
			begin
						o2[31:0] = (i2 >> 1);
						o2[31] = i1[0];
						o1[31:0] = (i1 >> 1);
				end
endmodule
