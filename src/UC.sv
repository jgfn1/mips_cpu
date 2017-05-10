module UC (
		input logic Clk,
		input logic [5:0] Op,
		input logic [5:0] Funct,
		input logic Reset,
		input logic Break,
		input logic OFlag,
		input logic ZeroFlag,
		input logic MenorFlag,
		input logic EndMulFlag,
		input logic [31:0] Instruction,
		output logic [2:0] ALUSrcB,
		output logic [1:0] MDRInSize,
		output logic [3:0] MemtoReg, //4/i0t's 2 bits because the mux was extended for LUI
		output logic [1:0] PCSource,
		output logic [2:0] ALUOp,
		output logic [5:0] State_out,
		output logic ALUOutLoad,
		output logic [1:0] ALUSrcA,
		output logic AWrite,
		output logic BWrite,
		output logic [2:0] IorD,
		output logic IRWrite,
		output logic MDRLoad,
		output logic MemWrite,
		output logic PCWrite,
		output logic EPCWrite,
		output logic [1:0] EPCSelect,
		output logic [1:0] RegDst,
		output logic RegWrite,
		output logic [1:0] SeletorMemWriteData,
		output logic [2:0] ADeslocOP,
		output logic [2:0] RegDeslocOp,
		output logic DeslocSelector
);

	enum logic [5:0] {FETCH, F1, F2, F3, DECODE, LUI, RTYPE, RTYPE_CONT, BEQ, BNE, //10
					LOAD, LOAD1, LOAD2, LOAD3, LOAD4, SW, SW1, J, BREAK, ADDI1, //10
					ADDI2, SXORI1, SXORI2, JAL, JR, SLT, SLT_CONT, SLTI, SLTI_CONT, SB, //10
					SB1, SB2, SB3, SB4, SB5, SH, SH1, MULT, MULT2, MFHI, //10
					MFLO, OVERFLOW, OVERFLOW1, OVERFLOW2, OPXCEPTION, OPXCEPTION1, OPXCEPTION2, RTE, SLL, SLLV, //10
					 SRA, SRAV, SRL, SHIFTWRITE, SH2, SH3, SH4, SH5, ANDI1, ANDI2// 10
					} state;
	enum logic [1:0] {WORD, HALF, BYTE} load_size;

	initial state = FETCH;
	reg Ovf = 1;

	always_ff@(posedge Clk or posedge Reset) begin
		State_out <= state;
		if (Reset) state <= FETCH;
		else if (Break) state <= BREAK;
		else if (OFlag & Ovf)
			begin
				if(Funct ==	6'h21) 	begin 	
						state <= RTYPE_CONT; //ADDU, same as RTYPE without overflow
						Ovf <= 0;	//continue execution normally
					end
				else if(Funct == 6'h23)	begin	
						state <= RTYPE_CONT; //SUBU, same as RTYPE without overflow
						Ovf <= 0;	//continue execution normally
					end
				else if(Op == 6'h9)	begin	
						state <= ADDI2; //ADDIU, as ADDIU and ADDI are the same instruction they use the same 
						Ovf <= 0;	//continue execution normally
					end
				else begin 
					state <= OVERFLOW;
					Ovf <= 0;
				end
			end
		else
			case (state)
				FETCH:
				begin
					state <= F1;
				end
				F1: state <= F2;
				F2: state <= F3;
				F3: state <= DECODE;
				DECODE: begin
					if (Instruction == 0) state <= FETCH; //NOP
					else
					case (Op)
						6'h00:	begin
						 			/* --------- RTYPE */
									//state <= RTYPE;
									case (Funct)
											6'h08: 		state <= JR;
											6'h10: 		state <= MFHI;
											6'h12: 		state <= MFLO;
											6'h2A:		state <= SLT;
											6'h18:		state <= MULT;
											6'h00:		state <= SLL;
											6'h04:		state <= SLLV;
											6'h03:		state <= SRA;
											6'h07:		state <= SRAV;
											6'h02:		state <= SRL;
											6'h23:		state <= RTYPE; //subu is rtype with possible overflow, treated before
											6'h21: 		state <= RTYPE; //addu is rtype with possible overflow
											default:	state <= RTYPE;
									endcase
						end
						6'h03:  state <= JAL;
						6'h28: 	state <= SB;
						6'h29: 	state <= SH;
						6'h04:	state <= BEQ;
						6'h05:	state <= BNE;
						6'h0A: 	state <= SLTI;
						6'hC:	state <= ANDI1;
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
						6'he:	state <= SXORI1;
						6'h0f:	state <= LUI;
						6'h02:	state <= J;
						6'h08:	state <= ADDI1;
						6'h09:	state <= ADDI1; //ADDI and ADDIU are the same instruction, but treated differently in case of Overflow
						6'h10:	state <= RTE;
						default: state <= OPXCEPTION;
					endcase
				end
				RTYPE: 					state <= RTYPE_CONT;
				RTYPE_CONT: 			state <= FETCH;
				BEQ: 					state <= FETCH;
				BNE: 					state <= FETCH;
				LOAD: 					state <= LOAD1;
				LOAD1: 					state <= LOAD2;
				LOAD2: 					state <= LOAD3;
				LOAD3: 					state <= LOAD4;
				LOAD4: 					state <= FETCH;
				SW:						state <= SW1;
				SW1:					state <= FETCH;
				LUI: 					state <= FETCH;
				J: 						state <= FETCH;
				BREAK: 					state <= BREAK;
				ADDI1:					state <= ADDI2;
				ADDI2:					state <= FETCH;
				SXORI1:					state <= SXORI2;
				SXORI2: 				state <= FETCH;
				ANDI1:					state <= ANDI2;
				ANDI2:					state <= FETCH;
				JAL: 					state <= FETCH;
				JR: 					state <= FETCH;
				SLT: 					state <= SLT_CONT;
				SLT_CONT: 				state <= FETCH;
				SLTI:					state <= SLTI_CONT;
				SLTI_CONT: 				state <= FETCH;
				MULT: 					state <= MULT2;
				MULT2: 					state <= EndMulFlag ?  FETCH : MULT2;
				MFHI:					state <= FETCH;
				MFLO:					state <= FETCH;
				RTE: 					state <= FETCH;
				SB:						state <= SB1;
				SB1:						state <= SB2;
				SB2:						state <= SB3;
				SB3:						state <= SB4;
				SB4:						state <= SB5;
				SB5:					state <= FETCH;
				SH:						state <= SH1;
				SH1:						state <= SH2;
				SH2:						state <= SH3;
				SH3:						state <= SH4;
				SH4:						state <= SH5;
				SH5:					state <= FETCH;
				OVERFLOW:				state <= OVERFLOW1;
				OVERFLOW1:				state <= OVERFLOW2;
				OVERFLOW2:				state <= FETCH;
				OPXCEPTION:				state <= OPXCEPTION1;
				OPXCEPTION1:			state <= OPXCEPTION2;
				OPXCEPTION2:			state <= FETCH;
				SLL: 					state <= SHIFTWRITE;
				SLLV: 					state <= SHIFTWRITE;
				SRA: 					state <= SHIFTWRITE;
				SRAV: 					state <= SHIFTWRITE;
				SRL: 					state <= SHIFTWRITE;
				SHIFTWRITE:				state <= FETCH;
				default: 				state <= FETCH;
			endcase
	end
	always_comb
		case(state)
			FETCH: begin		//reads from memory and sums up PC
				PCWrite 		= 1'b0;
				IorD			= 3'b000;		//address used by the memory comes from the PC
				MemWrite 		= 1'b0;		//make memory read
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b001;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b1;		//writes in ALUOut
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end
			F1: begin
				PCWrite 		= 1'b0;
				IorD 			  = 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;	//sum
				ALUSrcA			= 1'b0;		//A port of the ALU recieves the PC
				ALUSrcB			= 2'b00;	//B port of the ALU recieves 4
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  = 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			F2: begin
				PCWrite 		= 1'b1;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b1;
				PCSource		= 2'b01;	//PC recebe aluout
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end
			F3: begin			//memória terminou seu delay
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b01;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end
			DECODE: begin		//IR output available
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b10;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b00;		// PC
				ALUSrcB 		= 3'b011;	// (sign_ex_output << 2)
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b1;		// write rs in A
				BWrite			= 1'b1;		// write rt in B
				ALUOutLoad  	= 1'b1;		// Aluout = PC + (sign_ex_output << 2)
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b001;	// Writes read_data2 in RegDesloc
				DeslocSelector  = 1'b0;
				//newPin

				//Aluout recebe esse valor pra agilizar um possível branch. pag 326
			end
			LUI: begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0010; // Modificado por victor, estava 2 aqui.. passando MDR...
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b1;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end
			RTYPE: begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b10;	//operation defined by the funct field
				ALUSrcA 		= 2'b01;		//get the value of reg A
				ALUSrcB 		= 3'b000;	//get the value of reg B
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b1;		//write to ALUOut
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end
			RTYPE_CONT: begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000; 	//write data comes from ALUOut
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b1;		//Write in register
				RegDst			= 2'b01;		//select rd to be written into.
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			LOAD: begin			//make the sum for the address of the addr_imm and the value of A (rs)
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;	//sum
				ALUSrcA 		= 2'b01;		//get the value of reg A
				ALUSrcB 		= 3'b010;	//get the value of addr_imm extended to 32 bits
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b1;		//write to ALUOut
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= load_size;	//size of the load(WORD, HALF or BYTE. Depends on the opcode)
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			LOAD1: begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b001;		//Get address from ALUOut
				MemWrite 		= 1'b0;		//Read from memory
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				AWrite 			= 1'b0;
				BWrite 			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end

			LOAD2:
			begin				//memory delay
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				AWrite 			= 1'b0;
				BWrite 			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end
			LOAD3:
			begin				//Write to MDR
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				AWrite 			= 1'b0;
				BWrite 			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b1;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end
			LOAD4:
			begin				//write ro register (rt)
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0001;	//writes the output of MDR
				IRWrite 		= 1'b1;		//writes in the specified regsiter
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite 		= 1'b1;
				RegDst 			= 1'b0;		//register specified is rt (IR[20:16])
				AWrite 			= 1'b0;
				BWrite 			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end
			SW: begin			//make the sum for the address, addr_imm plus the value of A (rs)
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;	//sum
				ALUSrcA 		= 2'b01;		//get the value of reg A
				ALUSrcB 		= 3'b010;	//get the value of addr_imm extended to 32 bits
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b1;		//write to ALUOut
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end

			SW1: begin			//write the value of B to memory in the address calculated by ALUOut
				PCWrite 		= 1'b0;
				IorD 			= 3'b001;		//Get address from ALUOut
				MemWrite 		= 1'b1;		//Write to memory
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				AWrite 			= 1'b0;
				BWrite 			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end
			BEQ: begin			//jump or not
				PCWrite 		= ZeroFlag; 	//if its one then both numbers are equal, write to PC. Else, numbers are different don't write.
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b01;		//get address from aluout, calculated in DECODE
				ALUOp			= 3'b01;		//Subtract
				ALUSrcA 		= 2'b01;			//Value of A, reg rs, calculated on DECODE
				ALUSrcB 		= 3'b000;		//Value of B, reg rt, calculated on DECODE
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end
			BNE: begin			//jump or not
				PCWrite 		= ~ZeroFlag; 	//if its one then both numbers are equal, don't write. Else, numbers are different, write to PC.
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b01;		//get address from aluout, calculated in DECODE
				ALUOp			= 3'b01;		//Subtract
				ALUSrcA 		= 2'b01;			//Value of A, reg rs, calculated on DECODE
				ALUSrcB 		= 3'b000;		//Value of B, reg rt, calculated on DECODE
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end
			J: begin
				PCWrite 		= 1'b1; 		//write to PC
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b10;		// get {PC[31:28], IR[25:0], 2b'00} into the PC.
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end
			BREAK: begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end
			ANDI1: begin            //make the add, save into ALUOut
                PCWrite         = 1'b0;
                IorD             = 3'b000;
                MemWrite         = 1'b0;
                MemtoReg        = 3'b000;
                IRWrite         = 1'b0;
                PCSource         = 2'b00;
                ALUOp            = 3'b100;    //and
                ALUSrcA         = 1'b1;        //get the value of reg A
                ALUSrcB         = 2'b10;    //get the value of addr_imm extended to 32 bits
                RegWrite        = 1'b0;
                RegDst            = 2'b00;
                AWrite            = 1'b0;
                BWrite            = 1'b0;
                ALUOutLoad      = 1'b1;        //write to ALUOut
                MDRLoad            = 1'b0;
                SeletorMemWriteData = 2'b00;
                MDRInSize        = 2'b00;
                EPCWrite        = 1'b0;
                EPCSelect        = 2'b00;
                RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
                //Overflow        = OFlag;

            end
			ANDI2: begin                    //ALUOut updated, write to register.
                PCWrite         = 1'b0;
                IorD             = 3'b000;
                MemWrite         = 1'b0;
                MemtoReg        = 3'b000;     //write data comes from ALUOut
                IRWrite         = 1'b0;
                PCSource         = 2'b00;
                ALUOp             = 3'b000;
                ALUSrcA         = 1'b0;
                ALUSrcB         = 2'b00;
                RegWrite        = 1'b1;        //Write in register
                RegDst            = 2'b00;    //select rt to be written into.
                AWrite            = 1'b0;
                BWrite            = 1'b0;
                ALUOutLoad      = 1'b0;
                MDRLoad            = 1'b0;
                SeletorMemWriteData = 2'b00;
                MDRInSize        = 2'b00;
                EPCWrite        = 1'b0;
                EPCSelect        = 2'b00;
                RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
                //Overflow        = OFlag;
            
            end		
			SXORI1: begin			//make the XOR, save into ALUOut
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b011;	//xor
				ALUSrcA 		= 2'b01;		//get the value of reg A
				ALUSrcB 		= 3'b010;	//get the value of addr_imm extended to 32 bits
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b1;		//write to ALUOut
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin

			end
			SXORI2: begin			//ALUOut updated, write to register.
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000; 	//write data comes from ALUOut
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b1;		//Write in register
				RegDst			= 2'b00;		//select rt to be written into.
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				
			end
			// Mesmo JR sendo RTYPE (pois escreve em registrador..) no meu caso o RD é sempre 31 e eu não tenho como setar isso usando RTYPE e RTYPE_CONT
			JR: begin
				PCWrite 		= 1'b1; 		//write to PC
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;	// Out of ALU is the content on register A.
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b01;		// (rs) register A to ALU
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				
			end
			JAL: begin
				PCWrite 		= 1'b1; 		//Write in pc
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0111;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b10;		// get {PC[31:28], IR[25:0], 2b'00} into the PC.
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b1;			// Escrita em registrador.
				RegDst			= 2'b10;		// opção 3 do mux_br_wr_data setando 31 como endereço do registrador.
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;			// PC+4 está em ALUOUT devido ao FETCH
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SLT: begin								//Passando A e B para ALU, caso tenha flag de A < B, então vai escrever em rd 1 ou 0
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b01;				// Passando A (rs)
				ALUSrcB 		= 3'b000;			// Passando B (rt)
				RegWrite		= 1'b0;				// Ler do banco de registradores
				RegDst			= 2'b01;			// Setando (rd)
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b1;				//Salvando resultado no registrador ALU
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SLT_CONT: begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= MenorFlag ? 3'b100 : 3'b011; // Se RS é menor, então ALU retornou TRUE em menor flag e irá setar 1 (opção do 4 do mux_br_wr_data)
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b1;					// Escrever no banco de registradores
				RegDst			= 2'b01;				// Escrever em RD
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			// Eu acho que tem erro, porque acho que o MenorFlag já não está mais setado quando passa para SLT_CONT.
			// Mas pela lógica do ZeroFlag funciona...
			end
			SLTI: begin								//Passando A e B para ALU, caso tenha flag de A < B, então vai escrever em rd 1 ou 0
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b01;				// Passando A (rs)
				ALUSrcB 		= 3'b010;			// Passando B (immr[15-0])
				RegWrite		= 1'b0;				// Ler do banco de registradores
				RegDst			= 2'b00;			// Setando (rd)
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b1;				//Salvando resultado no registrador ALU
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SLTI_CONT: begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= MenorFlag ? 3'b100 : 3'b011; // Se RS é menor, então ALU retornou TRUE em menor flag e irá setar 1 (opção do 4 do mux_br_wr_data)
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b1;					// Escrever no banco de registradores
				RegDst			= 2'b01;				// Escrever em RD
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			// Eu acho que tem erro, porque acho que o MenorFlag já não está mais setado quando passa para SLT_CONT.
			// Mas pela lógica do ZeroFlag funciona...
			end
			SB: begin

				/*  Primeiro RS, ir� passar pela ALU e irei escrever em ALUOut,
				para setar IorD para 1, e dessa forma no pr�ximo (pq ALUOut � registrador.) ciclo eu vou ler no Address[rs]

				Ent�o no ciclo três � que seto IorD para 1, e usarei ALUout (rs) como endere�o..
				Meu BYTE que � o RT.. est� carregado no registrador B... (0xff & $RT) (metodo para obter a parte que quero */

				//Realizando o calculo de endereço.
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;
				ALUSrcA 		= 2'b01;			// O valor do registrador A (rs)
				ALUSrcB 		= 3'b010;		  // get the value of addr_imm extended to 32 bits
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b1;		//write to ALUOut
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SB1: begin
				//Lendo o valor em Address[RS]
				PCWrite 		= 1'b0;
				IorD 			= 3'b001;			// O Valor da ULA sera o valor a ler da memoria
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SB2: begin
				//Delay da memoria
				PCWrite 		= 1'b0;
				IorD 			= 3'b001;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SB3: begin //Delay da memoria
				PCWrite 		= 1'b0;
				IorD 			= 3'b001;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SB4: begin//Terminou delay da memoria
				PCWrite 		= 1'b0;
				IorD 			= 3'b001;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b1;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SB5: begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b001;			//Pegando o endereço que foi calculado em SB.. e esta em ALUOUT (registrador)
				MemWrite 		= 1'b1;			//Setando a memória para escrita
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;			// Soma na ALU
				ALUSrcA 		= 2'b10;			// Pegando o valor em MDR (valor lido de Address[rs]) com o ultimo byte zerado. [os ultimos 8bits zerados]
				ALUSrcB 		= 3'b100;			// Pegando o valor em RT onde zerei tudo exceto o ultimo byte. [os primeiros 24bits sao zeros.]
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				AWrite 			= 1'b0;
				BWrite 			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b01; // Indicando que a saida da ALU (antes de ir pro reg, deve ser o valor escrito na memoria).
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			/*
			SB1 antigo: begin

				/*  Primeiro RS, ir� passar pela ALU e irei escrever em ALUOut,
				para setar IorD para 1, e dessa forma no pr�ximo (pq ALUOut � registrador.) ciclo eu vou escrever no Address[rs]

				Ent�o no ciclo dois � que seto IorD para 1, e usarei ALUout (rs) como endere�o..
				Meu BYTE que � o RT.. est� carregado no registrador B... (0xff & $RT) (metodo para obter a parte que quero * /

				//Realizando o calculo de endereço.
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;
				ALUSrcA 		= 2'b01;			// O valor do registrador A (rs)
				ALUSrcB 		= 3'b010;		// get the value of addr_imm extended to 32 bits
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b1;		//write to ALUOut
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end*/
			/*** sh antigo SH: begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;
				ALUSrcA 		= 2'b01;			// O valor do registrador A (rs)
				ALUSrcB 		= 3'b010;			// get the value of addr_imm extended to 32 bits
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b1;		//write to ALUOut
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SH1: begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b001;			//Pegando o endereço que foi calculado em SB.. e está em ALUOUT
				MemWrite 		= 1'b1;			//Setando a memória para escrita
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b001;			// Soma na ALU
				ALUSrcA 		= 2'b11;			// Pegando o valor em RS com a segunda metade da word zerada. [os ultimos 16bits]
				ALUSrcB 		= 3'b101;			// Pegando o valor em RT onde zerei a primeira metade da word. [os primeiros 16bits]
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				AWrite 			= 1'b0;
				BWrite 			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b01; // Indicando que a saida da ALU (antes de ir pro reg, deve ser o valor escrito na memoria).
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end*/
			SH: begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;
				ALUSrcA 		= 2'b01;			// O valor do registrador A (rs)
				ALUSrcB 		= 3'b010;		  // get the value of addr_imm extended to 32 bits
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b1;		//write to ALUOut
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SH1: begin
				//Lendo o valor em Address[RS]
				PCWrite 		= 1'b0;
				IorD 			= 3'b001;			// O Valor da ULA sera o valor a ler da memoria
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SH2: begin
				//Delay da memoria
				PCWrite 		= 1'b0;
				IorD 			= 3'b001;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SH3: begin //Delay da memoria
				PCWrite 		= 1'b0;
				IorD 			= 3'b001;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SH4: begin//Terminou delay da memoria
				PCWrite 		= 1'b0;
				IorD 			= 3'b001;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp			= 3'b00;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b1;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SH5: begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b001;			//Pegando o endereço que foi calculado em SB.. e esta em ALUOUT (registrador)
				MemWrite 		= 1'b1;			//Setando a memória para escrita
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;			// Soma na ALU
				ALUSrcA 		= 2'b11;			// Pegando o valor em MDR (valor lido de Address[rs]) com a ultima parte da wrod zerado. [os ultimos 16bits zerados]
				ALUSrcB 		= 3'b101;			// Pegando o valor em RT onde zerei tudo exceto a ultima metade da word. [os primeiros 16bits sao zeros.]
				RegWrite 		= 1'b0;
				RegDst 			= 1'b0;
				AWrite 			= 1'b0;
				BWrite 			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b01; // Indicando que a saida da ALU (antes de ir pro reg, deve ser o valor escrito na memoria).
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end


			MFHI: begin // rd <= hi;
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0101; 				// HI on the Mux write_data_register_bank
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b1;					// Escrever no banco de registradores
				RegDst			= 2'b01;				// Escrever em RD
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			MFLO: begin // rd <= lo
				PCWrite 		= 1'b0;
				IorD 			= 1'b0;
				MemWrite 		= 1'b0;
				MemtoReg		= 4'b0110; 				// lo on the Mux write_data_register_bank
				IRWrite 		= 1'b0;
				PCSource 		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA 		= 2'b00;
				ALUSrcB 		= 3'b000;
				RegWrite		= 1'b1;					// Escrever no banco de registradores
				RegDst			= 2'b01;				// Escrever em RD
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad		= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			OVERFLOW:
			begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b011;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b1;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			OVERFLOW1:
			begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			OVERFLOW2:
			begin
				PCWrite 		= 1'b1;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b01;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			OPXCEPTION:
			begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b010;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b1;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			OPXCEPTION1:
			begin
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			OPXCEPTION2:
			begin
				PCWrite 		= 1'b1;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b01;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			RTE:
			begin
				PCWrite 		= 1'b1;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b11;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
			SLL: begin			//shift left logic, shifts (rt) (shamt) times
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b010;		//shift left op
				DeslocSelector  = 1'b0;
				//newPin
			end
			SLLV: begin			//shift left logic, shifts (rt) (rs) times
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b010;		//shift left op
				DeslocSelector  = 1'b0;
				//newPin
			end
			SRA: begin			//shift left logic, shifts (rt)
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b100;		//shift right op
				DeslocSelector  = 1'b0;
				//newPin
			end
			SRAV: begin			//shift left logic, shifts (rt)
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b100;		//shift right op
				DeslocSelector  = 1'b0;
				//newPin
			end
			SRL: begin			//shift left logic, shifts (rt)
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b011;		//shift right op
				DeslocSelector  = 1'b0;
				//newPin
			end
			SHIFTWRITE: begin			//writes result in rd
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b1000;		//gets RegDesloc_out, option I
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b01;		//writes in register
				RegDst			= 2'b01;		//selects RD to write
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end

			default: begin					//isso vai virar o caso do opcode indexistente
				PCWrite 		= 1'b0;
				IorD 			= 3'b000;
				MemWrite 		= 1'b0;
				MemtoReg 		= 4'b0000;
				IRWrite 		= 1'b0;
				PCSource		= 2'b00;
				ALUOp 			= 3'b000;
				ALUSrcA			= 1'b0;
				ALUSrcB			= 2'b00;
				RegWrite		= 1'b0;
				RegDst			= 2'b00;
				AWrite			= 1'b0;
				BWrite			= 1'b0;
				ALUOutLoad  	= 1'b0;
				MDRLoad			= 1'b0;
				SeletorMemWriteData = 2'b00;
				MDRInSize		= 2'b00;
				EPCWrite		= 1'b0;
				EPCSelect		= 2'b00;
				RegDeslocOp		= 3'b000;
				DeslocSelector  = 1'b0;
				//newPin
			end
		endcase
endmodule
