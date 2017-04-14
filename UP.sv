module UP(input logic clk, input logic reset, output logic [31:0] saida_ula);

logic [31:0] saida_pc;
logic empty_pc, load_pc, reg_write_pc, reg_dst;
logic of_ula, negf_ula, zf_ula, menorf_ula, maiorf_ula, igualf_ula;
logic [2:0] seletor_ula;
logic [31:0] memData, ir_write;
logic [5:0] op;
logic [4:0] rs;
logic [4:0] rt;
logic [15:0]addr_imm;

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

Banco_reg banco_reg (
	.Clk(clk),
	.Reset(reset),
	.RegWrite()
);

			// Clk			: IN	STD_LOGIC;						-- Clock do banco de registradores
			// Reset		: IN	STD_LOGIC;						-- Reinicializa o conteudo dos registradores
			// RegWrite	: IN	STD_LOGIC;						-- Indica se a opera��o � de escrita ou leitura
			// ReadReg1	: IN	STD_LOGIC_VECTOR (4 downto 0);	-- Indica o registrador #1 a ser lido
			// ReadReg2	: IN	STD_LOGIC_VECTOR (4 downto 0);	-- Indica o registrador #2 a ser lido
			// WriteReg	: IN	STD_LOGIC_VECTOR (4 downto 0);	-- Indica o registrador a ser escrito
			// WriteData 	: IN	STD_LOGIC_VECTOR (31 downto 0);	-- Indica o dado a ser escrito
			// ReadData1	: OUT	STD_LOGIC_VECTOR (31 downto 0);	-- Mostra a informa�ao presente no registrador #1
			// ReadData2	: OUT	STD_LOGIC_VECTOR (31 downto 0)	-- Mostra a informa��o presente no registrador #2

endmodule 