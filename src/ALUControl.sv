module ALUControl(
	input logic[5:0] Funct,
	input logic[2:0] ALUOp,
	output logic[2:0] Saida,
	output logic Break
);
	assign Break = (Funct == 6'h0d) ? 1'b1: 1'b0;
	always_comb
		if(ALUOp == 3'b000)							 //soma
			Saida = 3'b001;
		else if(ALUOp == 3'b001)					 //subtracao
			Saida = 3'b010;
		else if(ALUOp == 3'b010) begin
				case (Funct)
					6'h20: 		Saida = 3'b001;
					default: 	Saida = 3'b110;
				endcase
				/*if(Funct == 6'h20) // soma com a fuct
						Saida = 3'b001;
				else if(Funct == 6'h24) // AND com a fuct
						Saida = 3'b011;
				else if(Funct == 6'h22) // sub com a fuct
						Saida = 3'b010;
				else if(Funct == 6'h26) // xor com a fuct
						Saida = 3'b110;*/
		end
		else 						//soma
			Saida = 3'b001;
endmodule
