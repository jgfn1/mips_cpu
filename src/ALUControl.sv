module ALUControl(
	input logic[5:0] Entrada,
	input logic[1:0] ALUOp,
	output logic[2:0] Saida
);

	always_comb
		if(ALUOp == 2'b00)							//soma sem a fuct
			Saida = 3'b001;
		else if(ALUOp == 2'b01)						//sub sem a fuct
			Saida = 3'b010;
		else if(ALUOp == 2'b10 || Entrada == 6'h20) // soma com a fuct
			Saida = 3'b001;
		else if(ALUOp == 2'b10 || Entrada == 6'h24) // AND
			Saida = 3'b011;
		else if(ALUOp == 2'b10 || Entrada == 6'h22) // sub com a fuct
			Saida = 3'b010;
		else if(ALUOp == 2'b10 || Entrada == 6'h26) // xor
			Saida = 3'b110;
		else 
			Saida = 3'b001;
endmodule