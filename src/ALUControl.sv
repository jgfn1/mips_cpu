module ALUControl(
	input logic[5:0] Funct,
	input logic[2:0] ALUOp,
	output logic[2:0] Saida,
	output logic Break
);
	assign Break = (Funct == 6'h0d) ? 1'b1: 1'b0;
	always_comb
		case(ALUOp)
			3'b000: 	Saida = 3'b001;	 // Sum
			3'b001:		Saida = 3'b010;	 // Subtraction
			3'b010: begin // ALU operation is defined by the FUNCT field
					case (Funct)
						6'h20: 		Saida = 3'b001;// ADD defined in funct
						6'h21: 		Saida = 3'b001;// ADDU, at first is equal to ADD, but will be treated differently in case of Overflow
						6'h22: 		Saida = 3'b010;// SUB defined in funct
						6'h23: 		Saida = 3'b010;// SUBU, at first is equal to SUB, but will be treated differently in case of Overflow
						6'h24: 		Saida = 3'b011;// AND defined in funct					
						6'h26: 		Saida = 3'b110;// XOR defined in funct					
						default: 	Saida = 3'b000;// Loads A, by default
					endcase				
			end
			3'b011: 	Saida = 3'b110;//XOR activated through ALUOp, used in the sxori instruction
			3'b100: 	Saida = 3'b011;//AND activated through ALUOp, used in the andi instruction
			default:	Saida = 3'b000; // Loads A, by default
		endcase
endmodule