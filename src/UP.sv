	module UP(
		input logic clk,
		input logic reset,
		output logic [5:0] Estado,

		output logic [31:0] PC,
		output logic [31:0] EPC,
		output logic [31:0] Mem_Data,
		output logic [31:0] Address,
		output logic [31:0] WriteDataMem,
		output logic [4:0] WriteRegister,
		output logic [31:0] WriteDataReg,
		output logic [31:0] MDR,
		output logic [3:0] mem_to_reg,

		// Alu...
		//output logic [31:0] a_output,
		//output logic [31:0] b_output,
		output logic [31:0] alu_a_input,
		output logic [31:0] alu_b_input,
		output logic [31:0] Alu,
		output logic [31:0] AluOut,
		output logic alu_out_load,

		output logic wr,
		output logic IRWrite,
		output logic RegWrite,

		//Desloc...
		output logic [2:0]	 regdesloc_op,
		output logic [4:0] shift_amount,
		output logic [4:0] num_desloc,
		output logic desloc_selector,
		output logic [31:0] regdesloc_out,
		//Multiply
		//output logic end_mul_flag,
		//output reg [63:0] mult_product

		//output logic mdr_load,
		//output logic [1:0] mdr_in_size,
		//output logic [31:0] mdr_input,
		output logic [5:0] op,
		output logic [4:0] rs,
		output logic [4:0] rt,
		output logic [15:0] addr_imm,
		output logic [31:0] read_data1,
		output logic [31:0] read_data2,
		output logic of_alu,
		output logic epc_write,
		output logic [1:0] epc_select,
		output logic [31:0] instruction
		//output logic [1:0] alu_src_b,
		//output logic alu_src_a,
		//output logic [31:0] read_data1,
		//output logic [31:0] read_data2,
		//output logic [31:0] lui_number,
		//output logic [31:0] sign_ex_output,



);



/***** now.... ***/

// logic [31:0] instruction;
// logic of_alu;
 logic zf_alu;
 logic pc_write;
 logic a_load;
 logic b_load;
 logic [2:0] alu_op;
 logic [1:0] pc_source;
 logic [2:0] alu_control_output;
 logic [31:0] pc_input;
 logic [1:0] reg_dst;
 logic [2:0] iorD;
 logic [31:0] a_output;
 logic [31:0] b_output;



/*		PC AND PC BOUND 	*/
//logic [31:0] PC;
//logic [31:0] pc_input;
//logic pc_write;
//logic [1:0] pc_source;
logic reset_pc;
//logic epc_write;
//logic [1:0] epc_select;
logic [31:0] mux_pc_out;

/*		MEMORY 		*/
logic [1:0] seletorMemWriteData;
//logic [31:0] WriteDataMem;
//logic [31:0] Mem_Data;
//logic [31:0] Address;
//logic wr;
//logic iorD;

/*		MRD 		*/
//logic [31:0] MDR;
logic mdr_load;
logic [31:0] mdr_input;
logic [1:0] mdr_in_size;

/*		IR 			*/
// logic [5:0] op;
// logic [4:0] rs;
// logic [4:0] rt;
// logic [15:0] addr_imm;
//logic [31:0] instruction;
//logic IRWrite;
/*		SIGN EXTENDER		*/
logic [31:0] sign_ex_output;

/*		UC BOUND	*/
//logic [5:0] Estado;
logic brk;

/*		REGISTERS BANK		*/
//logic [1:0] mem_to_reg;
//logic [31:0] WriteDataReg;
//logic [4:0] WriteRegister;
//logic RegWrite;
//logic reg_dst;
logic [31:0] lui_number;
//logic [31:0] read_data1;
//logic [31:0] read_data2;
logic [2:0] multiplicando_op;

/*		SHIFT REGISTER		*/
//logic [31:0] regdesloc_in;
// logic [2:0]	 regdesloc_op;
// logic [4:0] shift_amount;
// logic [4:0] num_desloc;
// logic desloc_selector;
// logic [31:0] regdesloc_out;

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
logic [2:0] alu_src_b;
logic [1:0] alu_src_a;
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
assign shift_amount = addr_imm[10-:5];


/** Multiply **/
logic [63:0] mult_product; // Overflow[64];   HI [63-32];   LO[31:00];
logic end_mul_flag;
logic [31:0] a_uncomplemented;
logic [31:0] b_uncomplemented;
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
	.MemWrite   (wr   ),
	.OFlag		(of_alu 	),
	.Op         (op         ),
	.Funct		(addr_imm[5-:6]),
	.PCSource   (pc_source   ),
	.PCWrite    (pc_write    ),
	.EPCWrite    (epc_write    ),
	.EPCSelect	(epc_select	 ),
	.RegDst     (reg_dst     ),
	.RegWrite   (RegWrite   ),
	.Reset      (reset      ),
	.State_out	(Estado),
	.SeletorMemWriteData (seletorMemWriteData),
	.ZeroFlag	(zf_alu		),
	.RegDeslocOp(regdesloc_op),
	.Instruction(instruction),
	.DeslocSelector (desloc_selector)
);


Registrador pc(
			.Clk(clk),
			.Reset(reset_pc),
			.Load( pc_write ),/*pequeno circuito do lado esquerdo da UC*/
			.Entrada(mux_pc_out),
			.Saida(PC)
);

Registrador epc(
			.Clk(clk),
			.Reset(reset),
			.Load( epc_write ),
			.Entrada(PC),
			.Saida(EPC)
);

Mux32_3 new_mux_pc(
		.A(pc_input),
		.B( { {26{1'b0}}, Mem_Data[31-:8]} ), //8 MSB read from memory concatenated with 26 0's
		.C(EPC),
		.Seletor(epc_select),
		.Saida(mux_pc_out)
);

Mux32_4 mux_memory ( //mux3221_mem = mux de 32 bits de 2 pra 1 o qual a sa?da ? entrada do banco de registradores na porta Write data
	.A(PC),
	.B(AluOut),
	.C(32'd254),
	.D(32'd255),
	.Seletor(iorD),
	.Saida(Address)
);

Mux32_3 mem_in (
		.A(read_data2),
		.B(Alu),						// Warning! Isn't a register, because in SB I'll use RegisterALUOut with address and ALu with value...
		.Seletor(seletorMemWriteData),
		.Saida(WriteDataMem)
);

Memoria memory(
	.Address(Address),
	.Clock(clk),
	.Wr(wr),
	.Datain(WriteDataMem), /*veio do reg B*/ //Write data
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
	.Saida(WriteRegister)
);

Mux32_09 mux_br_wr_data ( //mux3221_br = mux de 32 bits de 2 pra 1 o qual a sa?da ? entrada do banco de registradores na porta Write data
	.A(AluOut),
	.B(MDR),
	.C(lui_number),		//ISSO E PARA O LUI, NAO MEXER
	.D(32'b0),
	.E(32'b1),
	.F(mult_product[63:32]),
	.G(mult_product[31:0]),
	.H(PC),
	.I(regdesloc_out),
	.Seletor(mem_to_reg),
	.Saida(WriteDataReg)
);

Banco_reg banco_reg (
	.Clk(clk),
	.Reset(reset),
	.RegWrite(RegWrite),
	.ReadReg1(rs),
	.ReadReg2(rt),
	.WriteReg(WriteRegister),
	.WriteData(WriteDataReg),
	.ReadData1(read_data1),
	.ReadData2(read_data2)
);

Mux5_2 mux_reg_desloc (		//selecionar de onde vem o N do regdesloc
	.A(shift_amount),			//value of shamt
	.B(read_data1),  			//value of rs
	.Seletor(desloc_selector),
	.Saida(num_desloc)
);

RegDesloc regdesloc (
	.Clk(clk),
	.Reset(reset),
	.Entrada(read_data2),
	.Shift(regdesloc_op),
	.N(num_desloc),
	.Saida(regdesloc_out)
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

Mux32_4 mux_alu_a (
	.A(PC),
	.B(a_output),
	//.C({a_output[31-:24],  {8{1'b0}} }),
	//.D({a_output[31-:16],  {16{1'b0}} }),
	.C(MDR & 6'hFFFFFF00), // O Valor lido de Address[rs]
	.D(MDR & 6'hFFFF0000), // O Valor lido de Address[rs]
	.Seletor(alu_src_a),
	.Saida(alu_a_input)
);

Mux32_6 mux_alu_b(
	.A(b_output),
	.B(32'd4),
	.C(sign_ex_output),
	.D((sign_ex_output << 2)), 		//shitf_left2 esta implicito
	//.E({{24{1'b0}}, read_data2[7-:8]}), 			// to Store byte[rt]  [00000000 00000000 00000000] + read_data2[xxxxxxxx]
	//.F({{16{1'b0}}, read_data2[15-:16]}),			// to Store Halfword  [00000000 00000000] + read_data2[xxxxxxxx xxxxxxxx]
	.E(6'hFF & b_output),
	.F(6'hFFFF & b_output),
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
	.State(Estado),
	.A(a_uncomplemented),
	.B(b_uncomplemented),
	.Produto(mult_product),
	.EndMulFlag(end_mul_flag)
);

endmodule
