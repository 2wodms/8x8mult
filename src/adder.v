module adder(
    input  [15:0] dataa,
    input  [15:0] datab,
    output [15:0] sum
);
    assign sum = dataa + datab;

endmodule


`timescale 1 ns/1 ns

module adder_tb();

	reg [15:0] dataa, datab;
	wire [15:0] sum;
	
	adder adder1 (.dataa(dataa), .datab(datab), .sum(sum));

	initial begin
		dataa = 16'd8;
		datab = 16'd5;
		#20 dataa = 16'd0;
		datab = 16'd1;
		#10 dataa = 16'd10;
		datab = 16'd5;
	end

initial begin
    //$monitor(adder);
    $dumpfile("adder.vcd");
    $dumpvars;
end
    

endmodule
