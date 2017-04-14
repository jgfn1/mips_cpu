module IR (input IRWrite, //comes from UC
		input Clk,
		input logic [31:0] MemData, // from Memory
		output logic [5:0] Op, 			// to UC
		output logic [4:0] Rs, 			// various locations
		output logic [4:0] Rt, 			// same
		output logic [15:0] Addr_imm 	// adress/immediate (page 5 of the project and page 323 of the book)
		// Addr_immediate will be "divided/sliced" several times throughout the project (view pages in above line)
);

enum logic{read, write} state;

logic [31:0] IR_Out;

	always_ff@(posedge Clk) begin 
		case(state)
			write: begin //if state is write, the inst_reg will recieve MemData and IR_Out will be having the same value after 1 clock cycle,
						//using MemData directly here saves time
				Op 	<= 	MemData[31-:6]; // gets only the fisRt 6 bits of the reg (staRting from 31 down to 26) into Op
				Rs 	<= 	MemData[25-:5]; 
				Rt 	<= 	MemData[20-:5]; 
				Addr_imm <= MemData[15-:16];
			end
			read: begin
						//in the read state the MemData should be the output of inst_reg
				Op 	<= 	IR_Out[31-:6]; // gets only the first 6 bits of the reg (staRting from 31 down to 26) into Op
				Rs 	<= 	IR_Out[25-:5]; 
				Rt 	<= 	IR_Out[20-:5]; 
				Addr_imm <= IR_Out[15-:16];
			end
		endcase
	end
	
	always_comb //isso aq é só por formalidade msm...
		case(IRWrite)
			1: state = write;
			0: state = read;
		endcase

Registrador inst_reg (.Clk(Clk),
	.Reset(1), //never reset, right?
	.Load(IRWrite), 
	.Entrada(MemData),                                                                                                                                                                                     
	.Saida(IR_Out)
);

endmodule 