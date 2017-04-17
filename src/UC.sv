module UC (
		input logic Clk, 
		input logic  Reset,
		input logic  [5:0] Op,
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
		output logic AWrite,
		output logic BWrite
);
	
	enum logic [4:0] {FETCH, DECODE, RTYPE, RTYPE_CONT, BEQ, BNE, LW, LW1, DELAY1_LW, DELAY2_LW, LW2, SW, DELAY1_SW, DELAY2_SW, SW1, LUI, J} state;

		
	always_ff@(posedge Clk or posedge Reset) begin
		if (Reset) state <= FETCH;
		else
			case (state)
				FETCH: state <= DECODE;
				DECODE: begin
					case (Op)
						6'h0:  state <= RTYPE;
						6'h4:  state <= BEQ;
						6'h5:  state <= BNE;
						6'h23: state <= LW;
						6'h2b: state <= SW;
						6'hf:  state <= LUI;
						6'h2:  state <= J;
					endcase
				end
				RTYPE: 			state <= RTYPE_CONT;
				RTYPE_CONT: 	state <= FETCH;
				BEQ: 			state <= FETCH;
				BNE: 			state <= FETCH;
				LW: 			state <= LW1;
				LW1: 			state <= DELAY1_LW;
				DELAY1_LW: 		state <= DELAY2_LW;
				DELAY2_LW: 		state <= LW2;
				LW2: 			state <= FETCH;
				SW: 			state <= DELAY1_SW;
				DELAY1_SW: 		state <= DELAY2_SW;
				DELAY2_SW: 		state <= SW1;
				SW1: 			state <= FETCH;
				LUI: 			state <= FETCH/*???*/;
				J: 				state <= FETCH;
				default: 		state <= FETCH;
			endcase
	end
	always_comb		
		case(state)
			FETCH: begin
				PCWriteCond 	= 0;		
				PCWrite 		= 1; 		// Faz com que o que o valor na entrada do pc seja realmente carregado.
				IorD 			= 0;			// o endere�o a ser carregado na porta "address" da mem�ria vem do ALUOut
				MemWrite 		= 0;		// ler da mem�ria				
				MemtoReg		= 0; 		
				IRWrite 		= 1;		// Carregar o IR com o que est� em MemData
				PCSource 		= 2'b00;	// Indica que o valor que ser� carregado no PC ser� o que vem do ALUResult
				ALUOp			= 2'b00;	// Faz com que a opera��o da ALU seja a de soma
				ALUSrcA 		= 0;		// A fonte da porta A da ALU ser� o valor do PC (isso controla um MUX)
				ALUSrcB 		= 2'b01;	// A fonte da porta B da ALU ser� o n�mero 4 (isso controla um MUX)				
				RegWrite		= 0;
				RegDst			= 0;		
				AWrite			= 0;		
				BWrite			= 0;			
			 end
			DECODE: begin

				PCWriteCond 	= 0;		
				PCWrite 		= 0; 		// Faz com que o que o valor na entrada do pc seja realmente carregado.
				IorD 			= 0;			// o endereco a ser carregado na porta "address" da memoria vem do ALUOut
				MemWrite 		= 1;		// ler da memoria				
				MemtoReg		= 0; 		
				IRWrite 		= 0;		// Carregar o IR com o que esta em MemData
				PCSource 		= 0;		// Indica que o valor que sera carregado no PC sera o que vem do ALUResult
				ALUOp			= 0;		// Faz com que a operacao da ALU seja a de soma
				ALUSrcA 		= 0;		// A fonte da porta A da ALU sera o valor do PC (isso controla um MUX)
				ALUSrcB 		= 0;		// A fonte da porta B da ALU sera o numero 4 (isso controla um MUX)				
				RegWrite		= 0;
				RegDst			= 0;		
				AWrite			= 1;		
				BWrite			= 1;		
			end
			RTYPE: begin
				PCWriteCond 	= 0;		
				PCWrite 		= 0; 		// Faz com que o que o valor na entrada do pc seja realmente carregado.
				IorD 			= 0;			// o endere�o a ser carregado na porta "address" da mem�ria vem do ALUOut
				MemWrite 		= 1;		// ler da mem�ria				
				MemtoReg		= 0; 		
				IRWrite 		= 0;		// Carregar o IR com o que est� em MemData
				PCSource 		= 0;		// Indica que o valor que ser� carregado no PC ser� o que vem do ALUResult
				ALUOp			= 2'b10;	// Faz com que a opera��o da ALU seja a de soma
				ALUSrcA 		= 1;		// A fonte da porta A da ALU ser� o valor do PC (isso controla um MUX)
				ALUSrcB 		= 2'b00;	// A fonte da porta B da ALU ser� o n�mero 4 (isso controla um MUX)				
				RegWrite		= 0;
				RegDst			= 0;		
				AWrite			= 0;		
				BWrite			= 0;		
			end
			RTYPE_CONT: begin
				PCWriteCond 	= 0;		
				PCWrite 		= 1; 		// Faz com que o que o valor na entrada do pc seja realmente carregado.
				IorD 			= 0;		// o endere�o a ser carregado na porta "address" da mem�ria vem do ALUOut
				MemWrite 		= 1;		// ler da mem�ria				
				MemtoReg		= 0; 		
				IRWrite 		= 0;		// Carregar o IR com o que est� em MemData
				PCSource 		= 0;		// Indica que o valor que ser� carregado no PC ser� o que vem do ALUResult
				ALUOp			= 0;		// Faz com que a opera��o da ALU seja a de soma
				ALUSrcA 		= 0;		// A fonte da porta A da ALU ser� o valor do PC (isso controla um MUX)
				ALUSrcB 		= 0;		// A fonte da porta B da ALU ser� o n�mero 4 (isso controla um MUX)				
				RegWrite		= 0;
				RegDst			= 1;		
				AWrite			= 0;		
				BWrite			= 0;		

			end			
			
			LW:
			begin
				PCWriteCond 	= 0;
				PCWrite 		= 0;
				IorD 			= 0;
				MemWrite 		= 0;
				MemtoReg 		= 0;
				IRWrite 		= 0;
				PCSource 		= 0;
				ALUOp 			= 2'b00;
				ALUSrcA 		= 1;
				ALUSrcB 		= 2'b10;
				RegWrite 		= 0;
				RegDst 			= 0;
				PCWriteCond 	= 0;
				IRWrite 		= 0;
				AWrite 			= 0;		
				BWrite 			= 0;		
			end
			
			LW1:
			begin
				PCWriteCond 	= 0;
				PCWrite 		= 0;
				IorD 			= 1;
				MemWrite 		= 0;
				MemtoReg 		= 0;
				IRWrite 		= 0;
				PCSource 		= 0;
				ALUOp 			= 0;
				ALUSrcA 		= 0;
				ALUSrcB 		= 0;
				RegWrite 		= 0;
				RegDst 			= 0;
				PCWriteCond 	= 0;
				IRWrite 		= 0;
				AWrite 			= 0;		
				BWrite 			= 0;		
			end
			
			LW2:
			begin
				PCWriteCond 	= 0;
				PCWrite 		= 0;
				IorD 			= 0;
				MemWrite 		= 0;
				MemtoReg 		= 0;
				IRWrite 		= 0;
				PCSource 		= 0;
				ALUOp 			= 0;
				ALUSrcA 		= 0;
				ALUSrcB 		= 0;
				RegWrite 		= 1;
				RegDst 			= 0;
				PCWriteCond 	= 0;
				IRWrite 		= 0;
				AWrite 			= 0;		
				BWrite 			= 0;		
			end

			SW:
			begin
				PCWriteCond 	= 0;
				PCWrite 		= 0;
				IorD 			= 0;
				MemWrite 		= 0;
				MemtoReg 		= 0;
				IRWrite 		= 0;
				PCSource 		= 0;
				ALUOp 			= 2'b00;
				ALUSrcA 		= 1;
				ALUSrcB 		= 2'b10;
				RegWrite 		= 0;
				RegDst 			= 0;
				PCWriteCond 	= 0;
				IRWrite 		= 0;
				AWrite 			= 0;		
				BWrite 			= 0;		
			end
			
			SW1:
			begin
				PCWriteCond 	= 0;
				PCWrite 		= 0;
				IorD 			= 1;
				MemWrite 		= 1;
				MemtoReg 		= 0;
				IRWrite 		= 0;
				PCSource 		= 0;
				ALUOp 			= 0;
				ALUSrcA 		= 0;
				ALUSrcB 		= 0;
				RegWrite 		= 0;
				RegDst 			= 0;
				PCWriteCond 	= 0;
				IRWrite 		= 0;
				AWrite 			= 0;		
				BWrite 			= 0;		
			end
			BEQ: begin
				PCWriteCond 	= 0;		
				PCWrite 		= 0; 		
				IorD 			= 0;		
				MemWrite 		= 0;		
				MemtoReg		= 0; 		
				IRWrite 		= 0;		
				PCSource 		= 2'b01;		
				ALUOp			= 2'b01;		
				ALUSrcA 		= 1;		
				ALUSrcB 		= 0;		
				RegWrite		= 0;
				RegDst			= 0;		
				AWrite			= 0;		
				BWrite			= 0;									
			end
			J: begin
				PCWriteCond 	= 0;		
				PCWrite 		= 0; 		
				IorD 			= 0;		
				MemWrite 		= 0;		
				MemtoReg		= 0; 		
				IRWrite 		= 0;		
				PCSource 		= 2'b10;		
				ALUOp			= 0;		
				ALUSrcA 		= 0;		
				ALUSrcB 		= 0;		
				RegWrite		= 0;
				RegDst			= 0;		
				AWrite			= 0;		
				BWrite			= 0;				
			end
			DELAY1_LW:
			begin			
				PCWrite 		= 0;
				IorD 			= 0;
				MemWrite 		= 0;
				MemtoReg 		= 0;
				IRWrite 		= 0;
				PCSource		= 0;
				ALUOp			= 0;
				ALUSrcA			= 0;
				ALUSrcB			= 0;
				RegWrite		= 0;
				RegDst			= 0;
				PCWriteCond		= 0;
				IRWrite			= 0;
				AWrite			= 0;
				BWrite			= 0;
			end
			DELAY2_LW:
			begin
				PCWrite 		= 0;
				IorD 			= 0;
				MemWrite 		= 0;
				MemtoReg 		= 0;
				IRWrite 		= 0;
				PCSource		= 0;
				ALUOp			= 0;
				ALUSrcA			= 0;
				ALUSrcB			= 0;
				RegWrite		= 0;
				RegDst			= 0;
				PCWriteCond		= 0;
				IRWrite			= 0;
				AWrite			= 0;
				BWrite			= 0;	
			end
			DELAY1_SW:
			begin			
				PCWrite 		= 0;
				IorD 			= 0;
				MemWrite 		= 0;
				MemtoReg 		= 0;
				IRWrite 		= 0;
				PCSource		= 0;
				ALUOp			= 0;
				ALUSrcA			= 0;
				ALUSrcB			= 0;
				RegWrite		= 0;
				RegDst			= 0;
				PCWriteCond		= 0;
				IRWrite			= 0;
				AWrite			= 0;
				BWrite			= 0;
			end
			DELAY2_SW:
			begin			
				PCWrite 		= 0;
				IorD 			= 0;
				MemWrite 		= 0;
				MemtoReg 		= 0;
				IRWrite 		= 0;
				PCSource		= 0;
				ALUOp			= 0;
				ALUSrcA			= 0;
				ALUSrcB			= 0;
				RegWrite		= 0;
				RegDst			= 0;
				PCWriteCond		= 0;
				IRWrite			= 0;
				AWrite			= 0;
				BWrite			= 0;
			end
			default: begin
				PCWrite 		= 0;
				IorD 			= 0;
				MemWrite 		= 0;
				MemtoReg 		= 0;
				IRWrite 		= 0;
				PCSource		= 0;
				ALUOp			= 0;
				ALUSrcA			= 0;
				ALUSrcB			= 0;
				RegWrite		= 0;
				RegDst			= 0;
				PCWriteCond		= 0;
				IRWrite			= 0;
				AWrite			= 0;
				BWrite			= 0;
			end
		endcase	
endmodule 