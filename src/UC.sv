module UC (
		input logic Clk, 
		input logic  Reset,
		input logic  [5:0] Op,
		output logic PCWriteCond,
		output logic PCWrite,
		output logic IorD,
		output logic MemWrite,
		output logic [1:0] MemtoReg, //it's 2 bits because the mux was extended for LUI
		output logic IRWrite,
		output logic [1:0]PCSource,
		output logic [2:0] ALUOp,
		output logic ALUSrcA,
		output logic [1:0] ALUSrcB,
		output logic RegWrite,
		output logic RegDst,		
		output logic AWrite,
		output logic BWrite,
		input logic Break,
		output logic [5:0] State_out,
		output logic ALUOutLoad,
		output logic MDRLoad
);
	
	enum logic [5:0] {FETCH, F1, F2, F3, DECODE, LUI, RTYPE, RTYPE_CONT, BEQ, BNE, LW, LW1, 
	LW2, LW3, LW4, SW, SW1, J, BREAK, ADDI1, ADDI2} state;
	
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
						6'h00:	state <= RTYPE;
						6'h04:	state <= BEQ;
						6'h05:	state <= BNE;
						6'h23:	state <= LW;
						6'h2b:	state <= SW;
						6'h0f:	state <= LUI;
						6'h02:	state <= J;
						6'h08:	state <= ADDI1;
					endcase
				end
				RTYPE: 			state <= RTYPE_CONT;
				RTYPE_CONT: 	state <= FETCH;
				BEQ: 			state <= FETCH;
				BNE: 			state <= FETCH;
				LW: 			state <= LW1;
				LW1: 			state <= LW2;
				LW2: 			state <= LW3;
				LW3: 			state <= LW4;
				LW4: 			state <= FETCH;
				SW:				state <= SW1;
				SW1:			state <= FETCH;
				LUI: 			state <= FETCH/*???*/;
				J: 				state <= FETCH;
				BREAK: 			state <= BREAK;
				ADDI1:			state <= ADDI2;
				ADDI2:			state <= FETCH;
				default: 		state <= FETCH;
			endcase
	end
	always_comb		
		case(state)
			FETCH: begin		//reads from memory and sums up PC
				PCWriteCond 	= 1'b0;		
				PCWrite 		= 1'b0; 	
				IorD 			= 1'b0;		//address used by the memory comes from the PC
				MemWrite 		= 1'b0;		//make memory read	
				MemtoReg		= 2'b00;	
				IRWrite 		= 1'b0;		
				PCSource 		= 2'b00;	
				ALUOp			= 3'b00;	
				ALUSrcA 		= 1'b0;		
				ALUSrcB 		= 2'b01;	
				RegWrite		= 1'b0;		
				RegDst			= 1'b0;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;		
				ALUOutLoad		= 1'b1;		//writes in ALUOut
				MDRLoad			= 1'b0;
			end
			F1: begin						
				PCWrite 		= 1'b0;		
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 2'b00;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;	//sum
				ALUSrcA			= 1'b0;		//A port of the ALU recieves the PC
				ALUSrcB			= 2'b00;	//B port of the ALU recieves 4
				RegWrite		= 1'b0;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
			end
			F2: begin					
				PCWrite 		= 1'b1;		
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 2'b00;
				IRWrite 		= 1'b1;
				PCSource		= 2'b01;	//PC recebe aluout
				ALUOp 			= 3'b000;	
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
			end
			F3: begin			//memória terminou seu delay
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 2'b00;
				IRWrite 		= 1'b0;		
				PCSource		= 2'b01;	
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
			end
			DECODE: begin		//Output do IR disponível
				PCWriteCond 	= 1'b0;		
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;	
				MemtoReg		= 2'b00; 		
				IRWrite 		= 1'b0;
				PCSource 		= 2'b10;	
				ALUOp 			= 3'b000;
				ALUSrcA 		= 1'b0;		//PC
				ALUSrcB 		= 2'b11;	// (sign_ex_output << 2)
				RegWrite		= 1'b0;
				RegDst			= 1'b0;	
				AWrite			= 1'b1;		// escrever rs em A
				BWrite			= 1'b1;		// escrever rt em B
				ALUOutLoad		= 1'b1;		// Aluout = PC + (sign_ex_output << 2)
				MDRLoad			= 1'b0;
				//Aluout recebe esse valor pra agilizar um possível jump. pag 326
			end
			LUI: begin
				PCWrite 		= 1'b0;		
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 2'b10;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b1;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
			end
			RTYPE: begin
				PCWriteCond 	= 1'b0;		
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;	
				MemtoReg		= 2'b00; 		
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b10;	//operation defined by the funct field
				ALUSrcA 		= 1'b1;		//get the value of reg A 
				ALUSrcB 		= 2'b00;	//get the value of reg B 
				RegWrite		= 1'b0;
				RegDst			= 1'b0;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;		
				ALUOutLoad		= 1'b1;		//write to ALUOut
				MDRLoad			= 1'b0;
			end
			RTYPE_CONT: begin
				PCWriteCond 	= 1'b0;		
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;	
				MemtoReg		= 2'b00; 	//write data comes from ALUOut	
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 1'b0;	
				ALUSrcB 		= 2'b00;
				RegWrite		= 1'b1;		//Write in register
				RegDst			= 1'b1;		//select rd to be written into.
				AWrite			= 1'b0;		
				BWrite			= 1'b0;		
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
			end			
			
			LW: begin			//make the sum for the address of the addr_imm and the value of A (rs)
				PCWriteCond 	= 1'b0;		
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;	
				MemtoReg		= 2'b00; 		
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;	//sum
				ALUSrcA 		= 1'b1;		//get the value of reg A
				ALUSrcB 		= 2'b10;	//get the value of addr_imm extended to 32 bits
				RegWrite		= 1'b0;
				RegDst			= 1'b0;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;		
				ALUOutLoad		= 1'b1;		//write to ALUOut
				MDRLoad			= 1'b0;
			end
			
			LW1: begin
				PCWriteCond 	= 1'b0;
				PCWrite 		= 1'b0;
				IorD 			= 1'b1;		//Get address from ALUOut
				MemWrite 		= 1'b0;		//Read from memory
				MemtoReg 		= 2'b00;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 1'b0;
				ALUSrcB 		= 2'b00;
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				PCWriteCond 	= 1'b0;
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
			end
			
			LW2:
			begin				//memory delay
				PCWriteCond 	= 1'b0;
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 2'b00;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 1'b0;
				ALUSrcB 		= 2'b00;
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				PCWriteCond 	= 1'b0;
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
			end
			LW3:
			begin				//Write to MDR
				PCWriteCond 	= 1'b0;
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 2'b00;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 1'b0;
				ALUSrcB 		= 2'b00;
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				PCWriteCond 	= 1'b0;
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b1;
			end
			LW4:
			begin				//write ro register (rt)
				PCWriteCond 	= 1'b0;
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;		
				MemtoReg 		= 2'b01;	//writes the output of MDR
				IRWrite 		= 1'b1;		//writes in the specified regsiter
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 1'b0;
				ALUSrcB 		= 2'b00;
				RegWrite 		= 1'b1;
				RegDst 			= 1'b0;		//register specified is rt (IR[20:16])
				PCWriteCond 	= 1'b0;
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
			end
			SW: begin			//make the sum for the address, addr_imm plus the value of A (rs)
				PCWriteCond 	= 1'b0;		
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;	
				MemtoReg		= 2'b00; 		
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;	//sum
				ALUSrcA 		= 1'b1;		//get the value of reg A
				ALUSrcB 		= 2'b10;	//get the value of addr_imm extended to 32 bits
				RegWrite		= 1'b0;
				RegDst			= 1'b0;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;		
				ALUOutLoad		= 1'b1;		//write to ALUOut
				MDRLoad			= 1'b0;
			end
			
			SW1: begin			//write the value of B to memory in the address calculated by ALUOut
				PCWriteCond 	= 1'b0;
				PCWrite 		= 1'b0;
				IorD 			= 1'b1;		//Get address from ALUOut
				MemWrite 		= 1'b1;		//Write to memory
				MemtoReg 		= 2'b00;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 1'b0;
				ALUSrcB 		= 2'b00;
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				PCWriteCond 	= 1'b0;
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
			end
			BEQ: begin
				PCWriteCond 	= 1'b1;		
				PCWrite 		= 1'b0; 		
				IorD 			= 1'b0;		
				MemWrite 		= 1'b0;		
				MemtoReg		= 2'b00; 		
				IRWrite 		= 1'b0;		
				PCSource 		= 2'b01;		
				ALUOp			= 3'b01;		
				ALUSrcA 		= 1'b1;		
				ALUSrcB 		= 2'b00;		
				RegWrite		= 1'b0;
				RegDst			= 1'b0;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;									
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
			end
			J: begin
				PCWriteCond 	= 1'b0;		
				PCWrite 		= 1'b0; 		
				IorD 			= 1'b0;		
				MemWrite 		= 1'b0;		
				MemtoReg		= 2'b00; 		
				IRWrite 		= 1'b0;		
				PCSource 		= 2'b10;		
				ALUOp 			= 3'b000;		
				ALUSrcA 		= 1'b0;		
				ALUSrcB 		= 2'b00;		
				RegWrite		= 1'b0;
				RegDst			= 1'b0;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;				
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
			end
			BREAK: begin
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 2'b00;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
			end
			ADDI1: begin			//make the sum, save indo ALUOut
				PCWriteCond 	= 1'b0;		
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;	
				MemtoReg		= 2'b00; 		
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;	//sum
				ALUSrcA 		= 1'b1;		//get the value of reg A
				ALUSrcB 		= 2'b10;	//get the value of addr_imm extended to 32 bits
				RegWrite		= 1'b0;
				RegDst			= 1'b0;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;		
				ALUOutLoad		= 1'b1;		//write to ALUOut
				MDRLoad			= 1'b0;
			end
			ADDI2: begin			//ALUOut updated, write to register.
				PCWriteCond 	= 1'b0;		
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;	
				MemtoReg		= 2'b00; 	//write data comes from ALUOut	
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 1'b0;	
				ALUSrcB 		= 2'b00;
				RegWrite		= 1'b1;		//Write in register
				RegDst			= 1'b0;		//select rt to be written into.
				AWrite			= 1'b0;		
				BWrite			= 1'b0;		
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
			end
			default: begin
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg 		= 2'b00;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 1'b0;
				PCWriteCond		= 1'b0;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
			end
		endcase	
endmodule 