module Sinal(input[15:0] intruA, output[31:0] saidaF);
		
		assign saidaF = {16{intruA[15], {intruA[15:0]}};
			
		endmodule