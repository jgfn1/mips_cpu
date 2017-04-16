module UC (input logic Clk, 
		output logic PCWriteCond,
		output logic PCWrite,
		output logic IorD,
		output logic MemWrite,
		output logic MemtoReg,
		output logic IRWrite,
		output logic [1:0]PCSource,
		output logic [2:0] ALUOp,
		output logic ALUSrcA,
		output logic [1:0] ALUSrcB,
		output logic RegWrite,
		output logic RegDst,
		input logic  Reset,
		input logic  [5:0] Op,
		output logic AWrite,
		output logic BWrite
	);
	
	enum logic [2:0] {FETCH, DECODE, RTYPE, RTYPE_CONT} state;
	
	always_ff@(posedge Clk or negedge Reset) begin
		if (~Reset) state <= FETCH;
		else
			case (state)
				FETCH: state <= DECODE;
				DECODE: begin
					case (Op)
						6'h0:state <= RTYPE;
					endcase
				end
				RTYPE: state <= RTYPE_CONT;
				RTYPE_CONT: state <= FETCH;
			endcase
	end
	always_latch
		case(state)
			FETCH: begin
				MemWrite <= 0;		// escrever na memórioa
				IorD <= 0;			// o endereço a ser carregado na porta "address" da memória vem do ALUOut
				IRWrite <= 1;		// Carregar o IR com o que está em MemData

				ALUSrcA <= 0;		// A fonte da porta A da ALU será o valor do PC (isso controla um MUX)
				ALUSrcB <= 2'b01;	// A fonte da porta B da ALU será o número 4 (isso controla um MUX)
				ALUOp <= 2'b00;		// Faz com que a operação da ALU seja a de soma
				PCSource <= 2'b00;	// Indica que o valor que será carregado no PC será o que vem do ALUResult
				PCWrite <= 1; 		// Faz com que o que o valor na entrada do pc seja realmente carregado.
			 end
			DECODE: begin
				AWrite = 1;
				BWrite = 1;
			end
			RTYPE: begin
				ALUSrcA <= 1; 		
				ALUSrcB <= 2'b00;
				ALUOp <= 2'b10; 
			end
			RTYPE_CONT: begin
				RegDst <= 1;
				RegWrite <= 1;
				MemtoReg <= 0;
			end
/*			default: begin
				PCWrite <= 0;
				IorD <= 0;
				MemWrite <= 0;
				MemtoReg <= 0;
				IRWrite <= 0;
				PCSource <= 0;
				ALUOp <= 0;
				ALUSrcA <= 0;
				ALUSrcB <= 0;
				RegWrite <= 0;
				RegDst <= 0;
				PCWriteCond <= 0;
				IRWrite <= 0;
			end*/
		endcase
endmodule 