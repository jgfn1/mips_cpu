module UP(input logic clk, 
		input logic reset, 		
		output logic [31:0] alu_result, 
		output logic [31:0] alu_out, 
		output logic [31:0] pc_output,
		output logic [31:0] mem_data,
		output logic [31:0] mdr_output,
		output logic [5:0] op,
		output logic [4:0] rs,
		output logic [4:0] rt,
		output logic [15:0]addr_imm
);

//alu
logic of_alu, negf_alu, zf_alu, menorf_alu, maiorf_alu, igualf_alu;
logic [2:0] alu_op;
logic [31:0] mux32_alu_a_output, mux32_alu_b_output, mux32_alu_output;

//alu out
//logic [31:0] alu_out;
logic alu_out_load;

//pc and pc bound
logic [31:0]/* pc_output, output do pr�prio do pc*/ mux32_memory_output /* output do mux q est� perto do pc*/, pc_input;
logic reset_pc, pc_write, pc_write_cond; // I/O da UC;


//uc and uc bound
logic reg_write, reg_dst, mem_write, iorD, alu_src_a;
logic [1:0] pc_source, alu_src_b;

//IR and IR bound
logic ir_write;
//logic [5:0] op;
//logic [4:0] rs;
//logic [4:0] rt;
//logic [15:0]addr_imm;
logic [4:0] mux5_out;
logic mem_to_reg;

//br
logic [31:0] read_data1, read_data2, mux32_br_output;

//memory
//logic [31:0] mem_data;

//A e B
logic [31:0] a_output, b_output;
logic a_load, b_load;

//mdr - Memory Data Register
//logic [31:0] mdr_output;
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
	.MemWrite   (mem_write   ),
	.MemtoReg   (mem_to_reg   ),
	.IRWrite    (ir_write    ),
	.PCSource   (pc_source   ),
	.ALUOp      (alu_op      ),
	.ALUSrcA    (alu_src_a    ),
	.ALUSrcB    (alu_src_b    ),
	.RegWrite   (reg_write   ),
	.RegDst     (reg_dst     ),
	.Reset      (~reset      ),
	.Op         (op         ),
	.AWrite		(a_load 	),
	.BWrite		(b_load 	)
);


Registrador PC(
			.Clk(clk),
			.Reset(reset_pc),
			//.Load( (pc_write | (pc_write_cond & zf_alu))/*pequeno circuito do lado esquerdo da UC*/),
			.Load( pc_write ),/*pequeno circuito do lado esquerdo da UC*/
			.Entrada(pc_input),
			.Saida(pc_output)
);

Mux32_2_1 mux3221_mem ( //mux3221_mem = mux de 32 bits de 2 pra 1 o qual a sa�da � entrada do banco de registradores na porta Write data
	.A(pc_output),
	.B(alu_out),
	.Mux32_seletor(iorD),
	.Mux32_out(mux32_memory_output)
);
/*
	input  logic  [31:0] A, 
	input  logic  [31:0] B,
	input  logic  Mux32_seletor, 
	output logic  [31:0]Mux32_out
	*/
	
Memoria memory(
	.Address(mux32_memory_output),
	.Clock(clk),
	.Wr(mem_write),
	.Datain(read_data2), /*veio do reg B*/ //Write data
	.Dataout(mem_data)
);
		// Address	: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);	-- Endere�o de mem�ria a ser lido
		// Clock	: IN  STD_LOGIC;						-- Clock do sistema
		// Wr		: IN  STD_LOGIC;						-- Indica se a mem�ria ser� lida (0) ou escrita (1)
		// Datain	: IN  STD_LOGIC_VECTOR(31 DOWNTO 0);	-- Valor lido da mem�ria quando Wr = 0
		// Dataout	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)		-- Valor a ser escrito quando Wr = 1

Instr_Reg IR (
	.Clk(clk),
	.Reset(reset),
	.Load_ir(ir_write),
	.Entrada(mem_data),
	.Instr31_26(op),
	.Instr25_21(rs),
	.Instr20_16	(rt),
	.Instr15_0(addr_imm)
);

Registrador mdr ( //Memory Data Register
	.Clk(clk),
	.Reset(reset),
	.Load(mdr_load),
	.Entrada(mem_data),
	.Saida(mdr_output)
);



Mux5_2_1 mux521 (
	.A(rt),
	.B(addr_imm[15-:5]), //pega apenas os primeiros 5 bits de addr_imm, que � uma saida do IR. Livro pag 322.
	.Mux5_seletor(reg_dst),
	.Mux5_out(mux5_out)
);

Mux32_2_1 mux3221_br ( //mux3221_br = mux de 32 bits de 2 pra 1 o qual a sa�da � entrada do banco de registradores na porta Write data
	.A(alu_out),
	.B(mdr_output),
	.Mux32_seletor(mem_to_reg),
	.Mux32_out(mux32_br_output)
);
/*
	input  logic  [31:0] A, 
	input  logic  [31:0] B,
	input  logic  Mux32_seletor, 
	output logic  [31:0]Mux32_out
*/


Banco_reg banco_reg (
	.Clk(clk),
	.Reset(reset),
	.RegWrite(reg_write),
	.ReadReg1(rs),
	.ReadReg2(rt),
	.WriteReg(mux5_out),
	.WriteData(mux32_br_output),
	.ReadData1(read_data1),
	.ReadData2(read_data2)
			// Clk			: IN	STD_LOGIC;						-- Clock do banco de registradores
			// Reset		: IN	STD_LOGIC;						-- Reinicializa o conteudo dos registradores
			// RegWrite	: IN	STD_LOGIC;						-- Indica se a opera��o � de escrita ou leitura
			// ReadReg1	: IN	STD_LOGIC_VECTOR (4 downto 0);	-- Indica o registrador #1 a ser lido
			// ReadReg2	: IN	STD_LOGIC_VECTOR (4 downto 0);	-- Indica o registrador #2 a ser lido
			// WriteReg	: IN	STD_LOGIC_VECTOR (4 downto 0);	-- Indica o registrador a ser escrito
			// WriteData 	: IN	STD_LOGIC_VECTOR (31 downto 0);	-- Indica o dado a ser escrito
			// ReadData1	: OUT	STD_LOGIC_VECTOR (31 downto 0);	-- Mostra a informa�ao presente no registrador #1
			// ReadData2	: OUT	STD_LOGIC_VECTOR (31 downto 0)	-- Mostra a informa��o presente no registrador #2
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
			// Clk		: IN  STD_LOGIC;						-- Clock do registrador
			// Reset	: IN  STD_LOGIC;						-- Reinicializa o conteudo do registrador
			// Load	: IN  STD_LOGIC;						-- Carrega o registrador com o vetor Entrada
			// Entrada : IN  STD_LOGIC_vector (31 downto 0); 	-- Vetor de bits que possui a informa��o a ser carregada no registrador
			// Saida	: OUT STD_LOGIC_vector (31 downto 0)	-- Vetor de bits que possui a informa��o j� carregada no registrador
);
Registrador B (
	.Clk(clk),
	.Reset(reset),
	.Load(b_load),
	.Entrada(read_data2), 
	.Saida(b_output)
			// Clk		: IN  STD_LOGIC;						-- Clock do registrador
			// Reset	: IN  STD_LOGIC;						-- Reinicializa o conteudo do registrador
			// Load	: IN  STD_LOGIC;						-- Carrega o registrador com o vetor Entrada
			// Entrada : IN  STD_LOGIC_vector (31 downto 0); 	-- Vetor de bits que possui a informa��o a ser carregada no registrador
			// Saida	: OUT STD_LOGIC_vector (31 downto 0)	-- Vetor de bits que possui a informa��o j� carregada no registrador
);

Mux32_2_1 mux3221_alu ( //mux3221_br = mux de 32 bits de 2 pra 1 o qual a sa�da � entrada do banco de registradores na porta Write data
	.A(pc_output),
	.B(a_output),
	.Mux32_seletor(alu_src_a),
	.Mux32_out(mux32_alu_a_output)
);

Mux32_4_1(
	.A(b_output),
	.B(4), //4'd
	.C(sign_ex_output),
	.D((sign_ex_output << 2)), //shitf_left2 est� implicito
 	.ALUSrcB(alu_src_b),
 	.Mux32_4_out(mux32_alu_b_output)
 );

Ula32 ULA (.A(mux32_alu_a_output),
		.B(mux32_alu_b_output),				//arrumar isso
		.S(alu_result),
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
	.Saida(alu_control_output)
);


Mux32_3_1(
	.A(alu_result),
	.B(alu_out), //4'd
	.C({ pc_output[31-:4], rs, rt, addr_imm, 2'b00}),
 	.PCSource(pc_source),
 	.Saida(pc_input)
 );

Registrador ALUOut (
	.Clk(clk),
	.Reset(reset),
	.Load(alu_out_load),
	.Entrada(alu_result),
	.Saida(alu_out)
);

endmodule 