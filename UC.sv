module UC (input logic Clk, 
		input logic Reset_PC, 
		output logic Load_PC, 
		output logic Empty_PC, 
		output logic Seletor_alu,
		output logic IRWrite,
		output logic RegWrite,
		output logic RegDst,
		output logic MemWrite,
		output logic IorD,
		output logic ALUSrcA,
		output logic ALUOp,
		output logic ALUSrcB,
		output logic MemtoReg
		);
	
	enum logic [2:0] {A, B} state;
	
	always_ff@(posedge Clk, negedge Reset_PC) begin
		if (~Reset_PC) state <= A;
		else
			case (state)
				A: state <= B;
				B: state <= B;
			endcase
	end
	always_comb
		case(state)
			A: begin
				Seletor_alu = 0;		//nop
				Load_PC = 0;		//comando para o PC receber ou não o que está na entrada dele
				Empty_PC = 1;		//sinal para enviar para o PC se esvaziar/resetar
			end
			B: begin
				Seletor_alu = 1;	// soma
				Load_PC = 1;		// 
				Empty_PC = 0;		// 
			end
		endcase
endmodule 