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
		output logic BWrite,
		output logic Break,
		output logic [5:0] State_out,
		output logic ALUOutLoad
);
	
	enum logic [5:0] {FETCH, F1, F2, F3, DECODE, RTYPE, RTYPE_CONT, BEQ, BNE, LW, LW1, DELAY1_LW, DELAY2_LW, LW2, SW, DELAY1_SW, DELAY2_SW, SW1, LUI, J, BREAK} state;
	
	initial state = FETCH;
		
	always_ff@(posedge Clk or posedge Reset) begin
		State_out <= state;
		if (Reset) state <= FETCH;
		else if (Break) state <= BREAK;
		else
			case (state)
				FETCH: state <= F1;
				F1: state <= F2;
				F2: state <= F3;
				F3: state <= DECODE;
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
				BREAK: 			state <= BREAK;
				default: 		state <= FETCH;
			endcase
	end
	always_comb		
		case(state)
			FETCH: begin
				PCWriteCond 	= 1'b0;		
				PCWrite 		= 1'b0; 	// Faz com que o que o valor na entrada do pc seja realmente carregado.
				IorD 			= 1'b0;		// o endere�o a ser carregado na porta "address" da mem�ria vem do ALUOut
				MemWrite 		= 1'b0;		// ler da mem�ria				
				MemtoReg		= 1'b0;
				IRWrite 		= 1'b0;		// Carregar o IR com o que est� em MemData
				PCSource 		= 2'b00;	// Indica que o valor que ser� carregado no PC ser� o que vem do ALUResult
				ALUOp			= 2'b00;	// Faz com que a opera��o da ALU seja a de soma
				ALUSrcA 		= 1'b0;		// A fonte da porta A da ALU ser� o valor do PC (isso controla um MUX)
				ALUSrcB 		= 2'b01;	// A fonte da porta B da ALU ser� o n�mero 4 (isso controla um MUX)				
				RegWrite		= 1'b0;
				RegDst			= 1'b0;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;			
			end
			F1: begin
				PCWrite 		= 1'b0;		
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 1'b0;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b111;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b01;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
			end
			F2: begin
				PCWrite 		= 1'b1;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 1'b0;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b111;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b01;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
			end
			F3: begin
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 1'b0;
				IRWrite 		= 1'b1;
				PCSource		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
			end
			LUI: begin
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 2'b10;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b1;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
			end
			DECODE: begin
				PCWriteCond 	= 1'b0;		
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;	
				MemtoReg		= 1'b0; 		
				IRWrite 		= 1'b1;
				PCSource 		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA 		= 1'b0;	
				ALUSrcB 		= 2'b11;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;		
				AWrite			= 1'b1;		
				BWrite			= 1'b1;
				ALUOutLoad		= 1'b1;
			end
			RTYPE: begin
				PCWriteCond 	= 1'b0;		
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;	
				MemtoReg		= 1'b0; 		
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 2'b10;
				ALUSrcA 		= 1'b1;	
				ALUSrcB 		= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;		
				ALUOutLoad		= 1'b0;
			end
			RTYPE_CONT: begin
				PCWriteCond 	= 1'b0;		
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;	
				MemtoReg		= 1'b0; 		
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA 		= 1'b0;	
				ALUSrcB 		= 2'b00;
				RegWrite		= 1'b1;
				RegDst			= 1'b1;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b1;
			end			
			
			LW:
			begin
				PCWriteCond 	= 1'b0;
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 1'b0;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA 		= 1'b1;
				ALUSrcB 		= 2'b10;
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				PCWriteCond 	= 1'b0;
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b0;
			end
			
			LW1:
			begin
				PCWriteCond 	= 1'b0;
				PCWrite 		= 1'b0;
				IorD 			= 1'b1;
				MemWrite 		= 1'b0;
				MemtoReg 		= 1'b0;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA 		= 1'b0;
				ALUSrcB 		= 2'b00;
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				PCWriteCond 	= 1'b0;
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b0;
			end
			
			LW2:
			begin
				PCWriteCond 	= 1'b0;
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 1'b0;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA 		= 1'b0;
				ALUSrcB 		= 2'b00;
				RegWrite 		= 1'b1;
				RegDst 			= 1'b0;
				PCWriteCond 	= 1'b0;
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b0;
			end

			SW:
			begin
				PCWriteCond 	= 1'b0;
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 1'b0;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA 		= 1'b1;
				ALUSrcB 		= 2'b10;
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				PCWriteCond 	= 1'b0;
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b1;
			end
			
			SW1:
			begin
				PCWriteCond 	= 1'b0;
				PCWrite 		= 1'b0;
				IorD 			= 1'b1;
				MemWrite 		= 1'b1;
				MemtoReg 		= 1'b0;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA 		= 1'b0;
				ALUSrcB 		= 2'b00;
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				PCWriteCond 	= 1'b0;
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b0;
			end
			BEQ: begin
				PCWriteCond 	= 1'b1;		
				PCWrite 		= 1'b0; 		
				IorD 			= 1'b0;		
				MemWrite 		= 1'b0;		
				MemtoReg		= 1'b0; 		
				IRWrite 		= 1'b0;		
				PCSource 		= 2'b01;		
				ALUOp			= 2'b01;		
				ALUSrcA 		= 1'b1;		
				ALUSrcB 		= 2'b00;		
				RegWrite		= 1'b0;
				RegDst			= 1'b0;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;									
				ALUOutLoad		= 1'b0;
			end
			J: begin
				PCWriteCond 	= 1'b0;		
				PCWrite 		= 1'b0; 		
				IorD 			= 1'b0;		
				MemWrite 		= 1'b0;		
				MemtoReg		= 1'b0; 		
				IRWrite 		= 1'b0;		
				PCSource 		= 2'b10;		
				ALUOp 			= 2'b00;		
				ALUSrcA 		= 1'b0;		
				ALUSrcB 		= 2'b00;		
				RegWrite		= 1'b0;
				RegDst			= 1'b0;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;				
				ALUOutLoad		= 1'b0;
			end
			DELAY1_LW:
			begin			
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 1'b0;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
			end
			DELAY2_LW:
			begin
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 1'b0;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;	
				ALUOutLoad		= 1'b0;
			end
			DELAY1_SW:
			begin			
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 1'b0;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
			end
			DELAY2_SW:
			begin			
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 1'b0;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
			end
			BREAK: begin
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 1'b0;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
			end
			default: begin
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 1'b0;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 2'b00;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
			end
		endcase	
endmodule 