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
	
	enum logic [3:0] {FETCH, DECODE, RTYPE, RTYPE_CONT, BEQ, BNE, LUI, J} state;

		
	always_ff@(posedge Clk or posedge Reset) begin
		if (Reset) state <= FETCH;
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
				default: state <= FETCH;
			endcase
	end
	always_comb		
		case(state)
			FETCH: begin
				PCWriteCond 	<= 0;		//-fVictor
				PCWrite 		<= 1; 		// Faz com que o que o valor na entrada do pc seja realmente carregado.
				IorD 			<= 0;			// o endere�o a ser carregado na porta "address" da mem�ria vem do ALUOut
				MemWrite 		<= 0;		// ler da mem�ria				
				MemtoReg		<= 0; 		//-fVictor
				IRWrite 		<= 1;		// Carregar o IR com o que est� em MemData
				PCSource 		<= 2'b00;	// Indica que o valor que ser� carregado no PC ser� o que vem do ALUResult
				ALUOp			<= 2'b00;	// Faz com que a opera��o da ALU seja a de soma
				ALUSrcA 		<= 0;		// A fonte da porta A da ALU ser� o valor do PC (isso controla um MUX)
				ALUSrcB 		<= 2'b01;	// A fonte da porta B da ALU ser� o n�mero 4 (isso controla um MUX)				
				RegWrite		<= 0;
				RegDst			<= 0;		//-fVictor
				AWrite			<= 0;		//-fVictor
				BWrite			<= 0;		//-fVictor
				
				/*PCWrite 		<= 1;
				IRWrite 		<= 1;
				PCSource 		<= 2'b00;
				ALUOp			<= 2'b00;
				ALUSrcB 		<= 2'b01;*/				
			 end
			DECODE: begin

				PCWriteCond 	<= 0;		//-fVictor
				PCWrite 		<= 0; 		// Faz com que o que o valor na entrada do pc seja realmente carregado.
				IorD 			<= 0;			// o endere�o a ser carregado na porta "address" da mem�ria vem do ALUOut
				MemWrite 		<= 1;		// ler da mem�ria				
				MemtoReg		<= 0; 		//-fVictor
				IRWrite 		<= 0;		// Carregar o IR com o que est� em MemData
				PCSource 		<= 0;		// Indica que o valor que ser� carregado no PC ser� o que vem do ALUResult
				ALUOp			<= 0;		// Faz com que a opera��o da ALU seja a de soma
				ALUSrcA 		<= 0;		// A fonte da porta A da ALU ser� o valor do PC (isso controla um MUX)
				ALUSrcB 		<= 0;		// A fonte da porta B da ALU ser� o n�mero 4 (isso controla um MUX)				
				RegWrite		<= 0;
				RegDst			<= 0;		//-fVictor
				AWrite			<= 1;		//-fVictor
				BWrite			<= 1;		//-fVictor

				/*MemWrite <= 1;				
				AWrite = 1;
				BWrite = 1;*/
			end
			RTYPE: begin

				PCWriteCond 	<= 0;		//-fVictor
				PCWrite 		<= 0; 		// Faz com que o que o valor na entrada do pc seja realmente carregado.
				IorD 			<= 0;			// o endere�o a ser carregado na porta "address" da mem�ria vem do ALUOut
				MemWrite 		<= 1;		// ler da mem�ria				
				MemtoReg		<= 0; 		//-fVictor
				IRWrite 		<= 0;		// Carregar o IR com o que est� em MemData
				PCSource 		<= 0;		// Indica que o valor que ser� carregado no PC ser� o que vem do ALUResult
				ALUOp			<= 2'b10;	// Faz com que a opera��o da ALU seja a de soma
				ALUSrcA 		<= 1;		// A fonte da porta A da ALU ser� o valor do PC (isso controla um MUX)
				ALUSrcB 		<= 2'b00;	// A fonte da porta B da ALU ser� o n�mero 4 (isso controla um MUX)				
				RegWrite		<= 0;
				RegDst			<= 0;		//-fVictor
				AWrite			<= 0;		//-fVictor
				BWrite			<= 0;		//-fVictor

				/*MemWrite <= 1;				
				ALUSrcA <= 1; 		
				ALUSrcB <= 2'b00;
				ALUOp <= 2'b10;*/
			end
			RTYPE_CONT: begin
				PCWriteCond 	<= 0;		//-fVictor
				PCWrite 		<= 1; 		// Faz com que o que o valor na entrada do pc seja realmente carregado.
				IorD 			<= 0;		// o endere�o a ser carregado na porta "address" da mem�ria vem do ALUOut
				MemWrite 		<= 1;		// ler da mem�ria				
				MemtoReg		<= 0; 		//-fVictor
				IRWrite 		<= 0;		// Carregar o IR com o que est� em MemData
				PCSource 		<= 0;		// Indica que o valor que ser� carregado no PC ser� o que vem do ALUResult
				ALUOp			<= 0;		// Faz com que a opera��o da ALU seja a de soma
				ALUSrcA 		<= 0;		// A fonte da porta A da ALU ser� o valor do PC (isso controla um MUX)
				ALUSrcB 		<= 0;		// A fonte da porta B da ALU ser� o n�mero 4 (isso controla um MUX)				
				RegWrite		<= 0;
				RegDst			<= 1;		//-fVictor
				AWrite			<= 0;		//-fVictor
				BWrite			<= 0;		//-fVictor

				/*MemWrite <= 1;				
				RegDst <= 1;
				RegWrite <= 1;
				MemtoReg <= 0; */
			end
			BEQ: begin
				PCWriteCond 	<= 0;		//-fVictor
				PCWrite 		<= 0; 		// Faz com que o que o valor na entrada do pc seja realmente carregado.
				IorD 			<= 0;		// o endere�o a ser carregado na porta "address" da mem�ria vem do ALUOut
				MemWrite 		<= 0;		// ler da mem�ria				
				MemtoReg		<= 0; 		//-fVictor
				IRWrite 		<= 0;		// Carregar o IR com o que est� em MemData
				PCSource 		<= 0;		// Indica que o valor que ser� carregado no PC ser� o que vem do ALUResult
				ALUOp			<= 0;		// Faz com que a opera��o da ALU seja a de soma
				ALUSrcA 		<= 0;		// A fonte da porta A da ALU ser� o valor do PC (isso controla um MUX)
				ALUSrcB 		<= 0;		// A fonte da porta B da ALU ser� o n�mero 4 (isso controla um MUX)				
				RegWrite		<= 0;
				RegDst			<= 0;		//-fVictor
				AWrite			<= 0;		//-fVictor
				BWrite			<= 0;		//-fVictor							
				
				/*PCWriteCond <= 1;
				PCWrite <= 1;
				ALUSrcA <= 1; 		
				ALUSrcB <= 2'b00;
				ALUOp <= 2'b01;*/
			end
			J: begin
				PCWriteCond 	<= 0;		//-fVictor
				PCWrite 		<= 0; 		// Faz com que o que o valor na entrada do pc seja realmente carregado.
				IorD 			<= 0;		// o endere�o a ser carregado na porta "address" da mem�ria vem do ALUOut
				MemWrite 		<= 0;		// ler da mem�ria				
				MemtoReg		<= 0; 		//-fVictor
				IRWrite 		<= 0;		// Carregar o IR com o que est� em MemData
				PCSource 		<= 0;		// Indica que o valor que ser� carregado no PC ser� o que vem do ALUResult
				ALUOp			<= 0;		// Faz com que a opera��o da ALU seja a de soma
				ALUSrcA 		<= 0;		// A fonte da porta A da ALU ser� o valor do PC (isso controla um MUX)
				ALUSrcB 		<= 0;		// A fonte da porta B da ALU ser� o n�mero 4 (isso controla um MUX)				
				RegWrite		<= 0;
				RegDst			<= 0;		//-fVictor
				AWrite			<= 0;		//-fVictor
				BWrite			<= 0;		//-fVictor*/
				
				//PCSource <= 2'b10;			
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