module UP(input logic clk, 
		input logic reset, 		
		output logic [31:0] Alu, 
		output logic [31:0] AluOut, 
		output logic [31:0] PC,
		output logic [31:0] Mem_Data,
		output logic [31:0] Address,
		output logic [31:0] MDR,
		output logic [31:0] mux32_alu_WriteDataMem,
		output logic [31:0] WriteDataMem,
		output logic [31:0] WriteDataReg,
		output logic [31:0] mux32_alu_a_output,
		output logic [5:0] op_out,
		output logic [4:0] rs,
		output logic [4:0] WriteRegister,
		output logic [31:0] instruction,
		output logic [15:0]addr_imm,
		output logic zf_alu,
		output logic [5:0] state_output,
		output logic pc_write,
		output logic [1:0] mem_to_reg,
		output logic [31:0] mux32_br_output,
		output logic IRWrite,
		output logic wr
);

//alu
logic of_alu, negf_alu, /*zf_alu,*/ menorf_alu, maiorf_alu, igualf_alu;
logic [2:0] alu_op;
logic [31:0] mux32_alu_output;

logic brk;

//alu out
//logic [31:0] AluOut;
//logic alu_out_load;

assign instruction = {op, rs, WriteRegister, addr_imm};

//pc and pc bound
logic [31:0] pc_input;
logic reset_pc, /*pc_write,*/ pc_write_cond; // I/O da UC;


//uc and uc bound
logic reg_write, reg_dst, iorD, alu_src_a;
logic [1:0] pc_source, alu_src_b;

//IR and IR bound
//logic IRWrite;
logic [5:0] op;
//logic [4:0] rs;
//logic [4:0] WriteRegister;
//logic [15:0]addr_imm;
logic [4:0] mux5_out;
//logic [1:0] mem_to_reg;

//br
logic [31:0] read_data1, read_data2; //mux32_br_output;

//memory
//logic [31:0] Mem_Data;

//A e B
logic [31:0] a_output/*, WriteDataMem*/;
logic a_load, b_load;

//mdr - Memory Data Register
//logic [31:0] MDR;
logic mdr_load;

//extensor de sinal
logic [31:0] sign_ex_output;

//alu control
logic [2:0] alu_control_output;



UC uni_c (
	.Clk        (clk        ),
	.PCWriteCond(pc_write_cond),
	.PCWrite    (pc_write    ),
	.IorD       (iorD       ),
	.MemWrite   (wr   ),
	.MemtoReg   (mem_to_reg   ),
	.IRWrite    (IRWrite    ),
	.PCSource   (pc_source   ),
	.ALUOp      (alu_op      ),
	.ALUSrcA    (alu_src_a    ),
	.ALUSrcB    (alu_src_b    ),
	.RegWrite   (reg_write   ),
	.RegDst     (reg_dst     ),
	.Reset      (reset      ),
	.Op         (op         ),
	.AWrite		(a_load 	),
	.BWrite		(b_load 	),
	.State_out	(state_output),
	.Break		(brk 		),
	.ALUOutLoad	(alu_out_load)
);


Registrador pc(
			.Clk(clk),
			.Reset(reset_pc),
			.Load( (pc_write || (pc_write_cond && zf_alu) ) ),/*pequeno circuito do lado esquerdo da UC*/			
			//
			.Entrada(pc_input),
			.Saida(PC)
);

Mux32_2_1 mux3221_mem ( //mux3221_mem = mux de 32 bits de 2 pra 1 o qual a sa?da ? entrada do banco de registradores na poWriteRegistera Write data
	.A(PC),
	.B(AluOut),
	.Mux32_seletor(iorD),
	.Mux32_out(Address)
);

	
Memoria memory(
	.Address(Address),
	.Clock(clk),
	.Wr(wr),
	.Datain(read_data2), /*veio do reg B*/ //Write data
	.Dataout(Mem_Data)
);
	
Instr_Reg IR (
	.Clk(clk),
	.Reset(reset),
	.Load_ir(IRWrite),
	.Entrada(Mem_Data),
	.Instr31_26(op),
	.Instr25_21(rs),
	.Instr20_16	(WriteRegister),
	.Instr15_0(addr_imm)
);

assign op_out = op;

Registrador mdr_reg ( //Memory Data Register
	.Clk(clk),
	.Reset(reset),
	.Load(1),
	.Entrada(Mem_Data),
	.Saida(MDR)
);



Mux5_2_1 mux521 (
	.A(WriteRegister),
	.B(addr_imm[15-:5]), //pega apenas os primeiros 5 bits de addr_imm, que ? uma saida do IR. Livro pag 322.
	.Mux5_seletor(reg_dst),
	.Mux5_out(mux5_out)
);
assign WriteDataReg = {addr_imm, {16{1'b0}}};
Mux32_2_1 mux3221_br ( //mux3221_br = mux de 32 bits de 2 pra 1 o qual a sa?da ? entrada do banco de registradores na poWriteRegistera Write data
	.A(AluOut),
	.B(WriteDataReg),
	.Mux32_seletor(mem_to_reg),
	.Mux32_out(mux32_br_output)
);


Banco_reg banco_reg (
	.Clk(clk),
	.Reset(reset),
	.RegWrite(reg_write),
	.ReadReg1(rs),
	.ReadReg2(WriteRegister),
	.WriteReg(mux5_out),
	.WriteData(mux32_br_output),
	.ReadData1(read_data1),
	.ReadData2(read_data2)		
);

Extensor_sinal sign_ex(
	.Entrada(addr_imm),
	.Saida(sign_ex_output)
);

Registrador A (
	.Clk(clk),
	.Reset(reset),
	.Load(a_load),
	.Entrada(read_data1), 
	.Saida(a_output)			
);
Registrador B (
	.Clk(clk),
	.Reset(reset),
	.Load(b_load),
	.Entrada(read_data2), 
	.Saida(WriteDataMem)			
);

Mux32_2_1 mux3221_alu ( //mux3221_br = mux de 32 bits de 2 pra 1 o qual a sa?da ? entrada do banco de registradores na poWriteRegistera Write data
	.A(PC),
	.B(a_output),
	.Mux32_seletor(alu_src_a),
	.Mux32_out(mux32_alu_a_output)
);

Mux32_4_1 mux32441(
	.A(WriteDataMem),
	.B(4), //4'd
	.C(sign_ex_output),
	.D((sign_ex_output << 2)), //shitf_left2 est? implicito
 	.ALUSrcB(alu_src_b),
 	.Mux32_4_out(mux32_alu_WriteDataMem)
 );

Ula32 ULA (
		.A(mux32_alu_a_output),
		.B(mux32_alu_WriteDataMem),				//arrumar isso
		.S(Alu),
		.Overflow(of_alu),
		.Seletor(alu_control_output), 
		.Negativo(negf_alu), 
		.z(zf_alu), 
		.Igual(igualf_alu), 
		.Maior(maiorf_alu), 
		.Menor(menorf_alu)
);

ALUControl ALUControl (
	.Entrada(addr_imm[5-:6]), 
	.ALUOp(alu_op), 
	.Saida(alu_control_output)//,
	//.Break(brk)
);


Mux32_3_1(
	.A(Alu),
	.B(AluOut), //4'd
	.C({ PC[31-:4], rs, WriteRegister, addr_imm, 2'b00}),
 	.PCSource(pc_source),
 	.Saida(pc_input)
 );

Registrador ALUOut (
	.Clk(clk),
	.Reset(reset),
	.Load(alu_out_load),
	.Entrada(Alu),
	.Saida(AluOut)
);

endmodule 