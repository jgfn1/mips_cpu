module  Mux32_2_1 (
	input  logic  [31:0] A, 
	input  logic  [31:0] B,
	input  logic  Mux32_seletor, 
	output logic  [31:0]Mux32_out
);

assign Mux32_out = (Mux32_seletor) ? B : A;

endmodule

/*	input  logic  [31:0] A, 
	input  logic  [31:0] B,
	input  logic  Mux32_seletor, 
	output logic  [31:0]Mux32_out
	*/