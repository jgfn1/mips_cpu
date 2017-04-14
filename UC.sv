module UC (input logic Clk, 
		input logic Reset_PC, 
		output logic Load_PC, 
		output logic Empty_PC, 
		output logic Seletor_ULA,
		output logic IRWrite
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
				Seletor_ULA = 0;		//nop
				Load_PC = 0;		//comando para o PC receber ou não o que está na entrada dele
				Empty_PC = 1;		//sinal para enviar para o PC se esvaziar/resetar
			end
			B: begin
				Seletor_ULA = 1;	// soma
				Load_PC = 1;		// 
				Empty_PC = 0;		// 
			end
		endcase
endmodule 