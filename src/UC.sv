module UC (
		input logic Clk, 
		input logic  [5:0] Op,
		input logic  Reset,
		input logic Break,
		input logic OFlag,
		input logic ZeroFlag,
		output logic [1:0] ALUSrcB,
		output logic [1:0] MDRInSize,
		output logic [1:0] MemtoReg, //it's 2 bits because the mux was extended for LUI
		output logic [1:0]PCSource,
		output logic [2:0] ALUOp,
		output logic [5:0] State_out,
		output logic ALUOutLoad,
		output logic ALUSrcA,
		output logic AWrite,
		output logic BWrite,
		output logic IorD,
		output logic IRWrite,
		output logic MDRLoad,
		output logic MemWrite,
		output logic Overflow, 		// em instruções que não causam overflow só é forçar 0 no estado ao invés de usar OFlag
		output logic PCWrite,
		output logic RegDst,		
		output logic RegWrite,
);
	
	enum logic [5:0] {FETCH, F1, F2, F3, DECODE, LUI, RTYPE, RTYPE_CONT, BEQ, BNE, LOAD, LOAD1, 
	LOAD2, LOAD3, LOAD4, SW, SW1, J, BREAK, ADDI1, ADDI2} state;
	enum logic [1:0] {WORD, HALF, BYTE} load_size;
	
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
						6'h23:	begin
							state <= LOAD;
							load_size <= WORD;
						end
						6'h24:	begin
							state <= LOAD;
							load_size <= BYTE;
						end
						6'h25:	begin
							state <= LOAD;
							load_size <= HALF;
						end
						6'h2b:	state <= SW;
						6'h0f:	state <= LUI;
						6'h02:	state <= J;
						6'h08:	state <= ADDI1;
						//default: state <= OPEXCEP;
					endcase
				end
				RTYPE: 			state <= RTYPE_CONT;
				RTYPE_CONT: 	state <= FETCH;
				BEQ: 			state <= FETCH;
				BNE: 			state <= FETCH;
				LOAD: 			state <= LOAD1;
				LOAD1: 			state <= LOAD2;
				LOAD2: 			state <= LOAD3;
				LOAD3: 			state <= LOAD4;
				LOAD4: 			state <= FETCH;
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
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

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
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

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
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

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
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

			end
			DECODE: begin		//Output do IR disponível
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
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

				//Aluout recebe esse valor pra agilizar um possível branch. pag 326
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
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

			end
			RTYPE: begin
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
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

			end
			RTYPE_CONT: begin
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
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;
			end	
			LOAD: begin			//make the sum for the address of the addr_imm and the value of A (rs)
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
				MDRInSize		= load_size;	//size of the load(WORD, HALF or BYTE. Depends on the opcode)
				//Overflow		= OFlag;
			end
			LOAD1: begin
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
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

			end
			
			LOAD2:
			begin				//memory delay
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
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

			end
			LOAD3:
			begin				//Write to MDR
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
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b1;
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

			end
			LOAD4:
			begin				//write ro register (rt)
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
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

			end
			SW: begin			//make the sum for the address, addr_imm plus the value of A (rs)
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
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

			end
			
			SW1: begin			//write the value of B to memory in the address calculated by ALUOut
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
				AWrite 			= 1'b0;		
				BWrite 			= 1'b0;		
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

			end
			BEQ: begin			//jump or not
				PCWrite 		= ZeroFlag; 	//if its one then both numbers are equal, write to PC. Else, numbers are different don't write.
				IorD 			= 1'b0;			
				MemWrite 		= 1'b0;			
				MemtoReg		= 2'b00; 		
				IRWrite 		= 1'b0;		
				PCSource 		= 2'b01;		//get address from aluout, calculated in DECODE
				ALUOp			= 3'b01;		//Subtract
				ALUSrcA 		= 1'b1;			//Value of A, reg rs, calculated on DECODE
				ALUSrcB 		= 2'b00;		//Value of B, reg rt, calculated on DECODE
				RegWrite		= 1'b0;
				RegDst			= 1'b0;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;									
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

			end
			BNE: begin			//jump or not
				PCWrite 		= ~ZeroFlag; 	//if its one then both numbers are equal, don't write. Else, numbers are different, write to PC.
				IorD 			= 1'b0;			
				MemWrite 		= 1'b0;			
				MemtoReg		= 2'b00; 		
				IRWrite 		= 1'b0;		
				PCSource 		= 2'b01;		//get address from aluout, calculated in DECODE
				ALUOp			= 3'b01;		//Subtract
				ALUSrcA 		= 1'b1;			//Value of A, reg rs, calculated on DECODE
				ALUSrcB 		= 2'b00;		//Value of B, reg rt, calculated on DECODE
				RegWrite		= 1'b0;
				RegDst			= 1'b0;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;									
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

			end
			J: begin
				PCWrite 		= 1'b1; 		//write to PC
				IorD 			= 1'b0;		
				MemWrite 		= 1'b0;		
				MemtoReg		= 2'b00; 		
				IRWrite 		= 1'b0;		
				PCSource 		= 2'b10;		// get {PC[31:28], IR[25:0], 2b'00} into the PC.
				ALUOp 			= 3'b000;		
				ALUSrcA 		= 1'b0;		
				ALUSrcB 		= 2'b00;		
				RegWrite		= 1'b0;
				RegDst			= 1'b0;		
				AWrite			= 1'b0;		
				BWrite			= 1'b0;				
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

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
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

			end
			ADDI1: begin			//make the sum, save indo ALUOut
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
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

			end
			ADDI2: begin			//ALUOut updated, write to register.
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
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;
			end
			default: begin					//isso vai virar o caso do opcode indexistente
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
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				MDRInSize		= 2'b00;
				//Overflow		= OFlag;

			end
		endcase	
endmodule 