	module UP(
		input logic clk,
		input logic reset,
		output logic [5:0] state_output,
		output logic [31:0] Alu,
		output logic [31:0] AluOut,
		output logic [31:0] PC,
		//output logic [31:0] Mem_Data,
		//output logic [31:0] Address,
		output logic [31:0] MDR,
		//output logic mdr_load,
		//output logic [1:0] mdr_in_size,
		//output logic [31:0] mdr_input,
		output logic [31:0] alu_b_input,
		output logic [31:0] b_output,
		output logic [31:0] alu_a_input,
		//output logic [5:0] op,
		//output logic [4:0] rs,
		//output logic [4:0] rt,
		output logic [31:0] instruction,
		//output logic [15:0] addr_imm,
		output logic of_alu,
		output logic zf_alu,
		output logic pc_write,
		output logic [2:0] mem_to_reg,
		output logic [31:0] write_data_br,
		output logic IRWrite,
		output logic mem_write,
		output logic alu_out_load,
		output logic a_load,
		output logic b_load,
		output logic [2:0] alu_op,
		output logic [1:0] pc_source,
		//output logic [1:0] alu_src_b,
		//output logic alu_src_a,
		output logic [2:0] alu_control_output,
		output logic [31:0] read_data1,
		output logic [31:0] read_data2,
		output logic [31:0] lui_number,
		output logic [31:0] pc_input,
		output logic [31:0] a_output,
		output logic [4:0] write_reg_br,
		output logic reg_write,
		output logic [1:0] reg_dst,
		output logic iorD,
		output logic [31:0] sign_ex_output,
		output logic [63:0] mult_product
);

/*		PC AND PC BOUND 	*/
//logic [31:0] PC;
//logic [31:0] pc_input;
//logic pc_write;
//logic [1:0] pc_source;
logic reset_pc;

/*		MEMORY 		*/
logic [1:0] seletorMemWriteData;
logic [31:0] memDataIn;
logic [31:0] Mem_Data;
logic [31:0] Address;
//logic mem_write;
//logic iorD;

/*		MRD 		*/
//logic [31:0] MDR;
logic mdr_load;
logic [31:0] mdr_input;
logic [1:0] mdr_in_size;

/*		IR 			*/
logic [5:0] op;
logic [4:0] rs;
logic [4:0] rt;
logic [15:0] addr_imm;
//logic [31:0] instruction;
//logic IRWrite;
/*		SIGN EXTENDER		*/
//logic [31:0] sign_ex_output;

/*		UC BOUND	*/
//logic [5:0] state_output;
logic brk;

/*		REGISTERS BANK		*/
//logic [1:0] mem_to_reg;
//logic [31:0] write_data_br;
//logic [4:0] write_reg_br;
//logic reg_write;
//logic reg_dst;
//logic [31:0] lui_number;
//logic [31:0] read_data1;
//logic [31:0] read_data2;
logic [2:0] multiplicando_op;

/*		A and B 	*/
//logic [31:0] a_output;
//logic [31:0] b_output;
//logic a_load;
//logic b_load;

/*		ALU 	*/
//logic [31:0] Alu;
//logic [31:0] alu_b_input;
//logic [31:0] alu_a_input;
//logic [2:0] alu_op;
logic [1:0] alu_src_b;
logic alu_src_a;
//logic [2:0] alu_control_output;
//logic of_alu;
logic negf_alu;
logic menorf_alu;
logic maiorf_alu;
logic igualf_alu;
//logic zf_alu;

/*		ALUOut 		*/
//logic alu_out_load;
//logic [31:0] AluOut;

/*		ASSIGNs		*/
assign lui_number = { addr_imm, {16{1'b0}} };
assign instruction = {op, rs, rt, addr_imm};


/** Multiply **/
//logic [63:0] mult_product; // Overflow[64];   HI [63-32];   LO[31:00];
logic end_mul_flag;

UC uni_c (
	.Clk        (clk        ),
	.ADeslocOP 	(multiplicando_op),
	.ALUOp      (alu_op      ),
	.ALUOutLoad	(alu_out_load),
	.ALUSrcA    (alu_src_a    ),
	.ALUSrcB    (alu_src_b    ),
	.AWrite		(a_load 	),
	.Break		(brk 		),
	.BWrite		(b_load 	),
	.EndMulFlag (end_mul_flag),
	.IorD       (iorD       ),
	.IRWrite    (IRWrite    ),
	.MDRInSize	(mdr_in_size),
	.MDRLoad 	(mdr_load	),
	.MenorFlag (menorf_alu),
	.MemtoReg   (mem_to_reg   ),
	.MemWrite   (mem_write   ),
	.OFlag		(of_alu 	),
	.Op         (op         ),
	.Funct			(addr_imm[5-:6]),
	.Overflow	(overflow 	), 				//sinal que decide se o overflow deve ser tratado
	.PCSource   (pc_source   ),
	.PCWrite    (pc_write    ),
	.RegDst     (reg_dst     ),
	.RegWrite   (reg_write   ),
	.Reset      (reset      ),
	.State_out	(state_output),
	.SeletorMemWriteData (seletorMemWriteData),
	.ZeroFlag	(zf_alu		),
);


Registrador pc(
			.Clk(clk),
			.Reset(reset_pc),
			.Load( pc_write ),/*pequeno circuito do lado esquerdo da UC*/
			.Entrada(pc_input),
			.Saida(PC)
);

Mux32_2 mux_memory ( //mux3221_mem = mux de 32 bits de 2 pra 1 o qual a sa?da ? entrada do banco de registradores na porta Write data
	.A(PC),
	.B(AluOut),
	.Seletor(iorD),
	.Saida(Address)
);

Mux32_3 mem_in (
		.A(read_data2),
		.B(32'hFF & read_data2), 						// to Store byte[rt]     [ f = 1111... só pra lembrar]
		.C(32'hFFFF & read_data2),					// to Store Halfword
		.Seletor(seletorMemWriteData),
		.Saida(memDataIn)
);

Memoria memory(
	.Address(Address),
	.Clock(clk),
	.Wr(mem_write),
	.Datain(memDataIn), /*veio do reg B*/ //Write data
	.Dataout(Mem_Data)
);

Instr_Reg IR (
	.Clk(clk),
	.Reset(reset),
	.Load_ir(IRWrite),
	.Entrada(Mem_Data),
	.Instr31_26(op),
	.Instr25_21(rs),
	.Instr20_16	(rt),
	.Instr15_0(addr_imm)
);

Mux32_3 mux_mdr_input (	//mux de 32 bits que define a entrada do MDR, que pode ser uma palavra (32bits), meia palavra (16 bits) ou um byte.
							//obs: para meia palavra e um byte os bits menos significativos s? coletados e extendidos com zero. Usado no lhu e lbu.
	.A(Mem_Data),
	.B({ {16{1'b0}}, Mem_Data[15-:16]}),
	.C({ {24{1'b0}}, Mem_Data[7-:8]}),
	.Seletor(mdr_in_size),
	.Saida(mdr_input)
);

Registrador mdr_reg ( //Memory Data Register
	.Clk(clk),
	.Reset(reset),
	.Load(mdr_load),
	.Entrada(mdr_input),
	.Saida(MDR)
);

Mux5_3 mux_br_wr_reg (
	.A(rt),								// Pega o RT
	.B(addr_imm[15-:5]),  // pega apenas os primeiros 5 bits de addr_imm, que ? uma saida do IR. Livro pag 322.
	.C(6'h1F), 					 // 31 endereço do registrador $RA
	.Seletor(reg_dst),
	.Saida(write_reg_br)
);

Mux32_5 mux_br_wr_data ( //mux3221_br = mux de 32 bits de 2 pra 1 o qual a sa?da ? entrada do banco de registradores na porta Write data
	.A(AluOut),
	.B(MDR),
	.C(lui_number),		//ISSO E PARA O LUI, NAO MEXER
	.D(32'b0),
	.E(32'b1),
	.Seletor(mem_to_reg),
	.Saida(write_data_br)
);

Banco_reg banco_reg (
	.Clk(clk),
	.Reset(reset),
	.RegWrite(reg_write),
	.ReadReg1(rs),
	.ReadReg2(rt),
	.WriteReg(write_reg_br),
	.WriteData(write_data_br),
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
	.Saida(b_output)
);

Uncomplement uncomplement_A (
	.Input(a_output),
	.Output(a_uncomplemented)
);

Uncomplement uncomplement_B (
	.Input(b_output),
	.Output(b_uncomplemented)
);

Mux32_2 mux_alu_a (
	.A(PC),
	.B(a_output),
	.Seletor(alu_src_a),
	.Saida(alu_a_input)
);

Mux32_4 mux_alu_b(
	.A(b_output),
	.B(32'd4),
	.C(sign_ex_output),
	.D((sign_ex_output << 2)), //shitf_left2 esta implicito
 	.Seletor(alu_src_b),
 	.Saida(alu_b_input)
 );

Ula32 ULA (
		.A(alu_a_input),
		.B(alu_b_input),
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
	.Funct(addr_imm[5-:6]),
	.ALUOp(alu_op),
	.Saida(alu_control_output),
	.Break(brk)
);


Mux32_3 mux_pc (
	.A(Alu),
	.B(AluOut),
	.C({PC[31-:4], rs, rt, addr_imm, 2'b00}),
 	.Seletor(pc_source),
 	.Saida(pc_input)
 );

Registrador ALUOut (
	.Clk(clk),
	.Reset(reset),
	.Load(alu_out_load),
	.Entrada(Alu),
	.Saida(AluOut)
);


Multiply multiply(
	.Clk(clk),
	.State(state_output),
	.A(uncomplement_B),
	.B(uncomplement_A),
	.EndMulFlag(end_mul_flag),
	.Produto(mult_product)
);

endmodule
