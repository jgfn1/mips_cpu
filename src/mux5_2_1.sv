module  Mux5_2_1 (
	input  logic  [4:0] A, 
	input  logic  [4:0] B,
	input  logic  Mux5_seletor, 
	output logic  [4:0] Mux5_out
);

assign Mux5_out = (Mux5_seletor) ? B : A;

endmodule 