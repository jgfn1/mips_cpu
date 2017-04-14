module UP(input logic clk, input logic reset, output logic [31:0] saida_ula);

logic [31:0] saida_pc;
logic empty_pc, load_pc, reg_write_uc, reg_dst_uc, mem_write_uc, iorD_uc, alu_src_uc, alu_op_uc, memto_reg_uc; // I/O da UC
logic [1:0] aluSrcB_pc;
logic of_ula, negf_ula, zf_ula, menorf_ula, maiorf_ula, igualf_ula;
logic [2:0] seletor_ula;
logic [31:0] memData, ir_write;
logic [5:0] op;
logic [4:0] rs;
logic [4:0] rt;
logic [15:0]addr_imm;
logic [4:0] mux5_out;

UC uni_c (.Clk(clk),
		.Reset_PC(reset), 
		.Load_PC(load_pc), 
		.Empty_PC(empty_pc), 
		.Seletor_ULA(seletor_ula),
		.IRWrite(ir_write)
);

Ula32 ULA (.A(saida_pc),
		.B(40), 
		.S(saida_ula), 
		.Overflow(of_ula),
		.Seletor(seletor_ula), 
		.Negativo(negf_ula), 
		.z(zf_ula), 
		.Igual(igualf_ula), 
		.Maior(maiorf_ula), 
		.Menor(menorf_ula)
);
	
Registrador PC(
			.Clk(clk),
			.Reset(empty_pc),
			.Load(load_pc),
			.Entrada(saida_ula),
			.Saida(saida_pc)
);

IR inst_reg (.IRWrite(ir_write),
	.Clk(clk),
	.MemData(memData),
	.Op(op),
	.Rs(rs),
	.Rt(rt),
	.Addr_imm(addr_imm)
);

Mux5_2_1 mux521 (
	.A(rt),
	.B(addr_imm[15-:5]), //pega apenas os primeiros 5 bits de addr_imm, que � uma saida do IR. Livro pag 322.
	.Mux5_seletor(reg_dst_pc),
	.Mux5_out(mux5_out)
);
/*
Mux32_2_1 mux3221_br ( //mux3221_br = mux de 32 bits 2 pra um o qual a sa�da � entrada do banco de registradores na porta Write data
	
);
*/

Banco_reg banco_reg (
	.Clk(clk),
	.Reset(reset),
	.RegWrite(reg_write_pc)
	.ReadReg1(rs),
	.ReadReg2(rt),
	.WriteReg(mux5_out),
	.WriteData(),
	.ReadData1(),
	.ReadData2()
);

			// Clk			: IN	STD_LOGIC;						-- Clock do banco de registradores
			// Reset		: IN	STD_LOGIC;						-- Reinicializa o conteudo dos registradores
			// RegWrite		: IN	STD_LOGIC;						-- Indica se a opera��o � de escrita ou leitura
			// ReadReg1		: IN	STD_LOGIC_VECTOR (4 downto 0);	-- Indica o registrador #1 a ser lido
			// ReadReg2		: IN	STD_LOGIC_VECTOR (4 downto 0);	-- Indica o registrador #2 a ser lido
			// WriteReg		: IN	STD_LOGIC_VECTOR (4 downto 0);	-- Indica o registrador a ser escrito
			// WriteData 	: IN	STD_LOGIC_VECTOR (31 downto 0);	-- Indica o dado a ser escrito
			// ReadData1	: OUT	STD_LOGIC_VECTOR (31 downto 0);	-- Mostra a informa�ao presente no registrador #1
			// ReadData2	: OUT	STD_LOGIC_VECTOR (31 downto 0)	-- Mostra a informa��o presente no registrador #2

endmodule 