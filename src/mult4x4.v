module mult4x4(
    input  [3:0] dataa   ,
    input  [3:0] datab   ,
    output [7:0] product
);

    assign product = dataa * datab ;


endmodule


`timescale 1 ns/1 ns
module mult4x4_tb();

	reg [3:0] dataa, datab;
	wire [7:0] product;
	
	//mult4x4 인스턴스 네임
	mult4x4 mult4x4_1 (.dataa(dataa), .datab(datab), .product(product));

	//dataa 0값, datab에 2값을 주었음.
	initial begin
		dataa = 4'd0;
		datab = 4'd2;
		forever
			#10 dataa = dataa + 3; //dataa에 10ns마다 +3씩 더해지는 과정
	end

    initial begin
        $dumpfile("mult4x4.vcd");
        $dumpvars;
    end
endmodule
