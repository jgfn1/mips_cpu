module ALUControl(
	input logic[5:0] Entrada,
	input logic[2:0] ALUOp,
	output logic[2:0] Saida,
	output logic Break
);
	assign Break = (Entrada == 6'h0d) ? 1'b1: 1'b0;
	always_comb
		if(ALUOp == 3'b000)						
			Saida = 3'b001;
		else if(ALUOp == 3'b001)					//subtração					
			Saida = 3'b010;
		else if(ALUOp == 3'b010 || Entrada == 6'h20) // soma com a fuct
			Saida = 3'b001;
		else if(ALUOp == 3'b010 || Entrada == 6'h24) // AND
			Saida = 3'b011;
		else if(ALUOp == 3'b010 || Entrada == 6'h22) // sub com a fuct
			Saida = 3'b010;
		else if(ALUOp == 3'b010 || Entrada == 6'h26) // xor
			Saida = 3'b110;
		else if(ALUOp == 3'b000)
			Saida = 3'b001;
		else if(ALUOp == 3'b111)  //forçar soma
			Saida = 3'b001;
		else 						//soma
			Saida = 3'b001;
endmodule 