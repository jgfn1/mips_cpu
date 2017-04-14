module UP(input logic clk, input logic reset_pc, output logic [31:0] saida_ula);

logic [31:0] saida_pc;
logic empty_pc;
logic load_pc;
logic of_ula, negf_ula, zf_ula, menorf_ula, maiorf_ula, igualf_ula;
logic [2:0] seletor_ula;
logic [31:0] memData, ir_write;
logic [5:0] op;
logic [4:0] rs;
logic [4:0] rt;
logic [15:0]addr_imm;

UC uni_c (.Clk(clk),
		.Reset_PC(reset_pc), 
		.Load_PC(load_pc), 
		.Empty_PC(empty_pc), 
		.Seletor_ULA(seletor_ula),
		.IRWrite(ir_write)
);

Ula32 ULA (.A(saida_pc),
		.B(4), 
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

			/*Clk		: IN  STD_LOGIC;						-- Clock do registrador
			Reset	: IN  STD_LOGIC;						-- Reinicializa o conteudo do registrador
			Load	: IN  STD_LOGIC;						-- Carrega o registrador com o vetor Entrada
			Entrada : IN  STD_LOGIC_vector (31 downto 0); 	-- Vetor de bits que possui a informação a ser carregada no registrador
			Saida	: OUT STD_LOGIC_vector (31 downto 0)	-- Vetor de bits que possui a informação já carregada no registrador*/

endmodule 