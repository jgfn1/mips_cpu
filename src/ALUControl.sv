module ALUControl(
	input logic[5:0] Funct,
	input logic[2:0] ALUOp,
	output logic[2:0] Saida,
	output logic Break
);
	assign Break = (Funct == 6'h0d) ? 1'b1: 1'b0;
	always_comb
		case(ALUOp)
			3'b000: 	Saida = 3'b001;	 // Soma
			3'b001:		Saida = 3'b010;	 // Subtracao
			3'b010: begin // O que será feito na ALU é definido pela FUNCT
					case (Funct)
						6'h20: 		Saida = 3'b001;// ADD definido na funct
						6'h21: 		Saida = 3'b001;// ADDU definido na funct
						6'h22: 		Saida = 3'b010;// SUB definido na funct				
						6'h24: 		Saida = 3'b011;// AND definido na funct					
						6'h26: 		Saida = 3'b110;// XOR definido na funct					
						default: 	Saida = 3'b000;// por default, carrega A.
					endcase				
			end
			default:	Saida = 3'b001; // Soma
		endcase
endmodule