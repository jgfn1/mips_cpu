module  mux5_2_1 (
	input  logic  [4:0] A, 
	input  logic  [4:0] B,
	input  logic  mux5_seletor, 
	output logic  mux5_out
);

assign mux5_out = (mux5_seletor) ? B : A;

endmodule 