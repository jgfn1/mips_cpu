module  mux32_2_1 (
	input  logic  [31:0] A, 
	input  logic  [31:0] B,
	input  logic  mux32_seletor, 
	output logic  mux32_out
);

assign mux32_out = (mux32_seletor) ? B : A;

endmodule 