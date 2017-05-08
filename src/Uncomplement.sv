module Uncomplement(input logic [31:0] Input, output logic [31:00] Output);
		always_comb begin
				if(Input[31] == 1)
						Output = ~Input + 1'b1;
				else
						Output = Input;
		end
endmodule
