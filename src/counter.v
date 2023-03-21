module counter(
    input clk,
    input aclr_n,
    output reg [1:0] count_out
);
    always@(posedge clk) begin
        if(aclr_n == 0)
            count_out <= 2'b00;
        else
            count_out <= count_out + 1'b1;
    end
endmodule

`timescale 1 ns/1 ns

module counter_tb();

	reg clk, aclr_n;
	wire [1:0] count_out;
	
	counter counter1 (.clk(clk), .aclr_n(aclr_n), .count_out(count_out));

	initial begin
		clk = 0;
		forever clk = #20 ~clk;
	end
	
	initial begin
		aclr_n = 1'b0;
		#40 aclr_n = 1'b1;
	end

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars;
    end
endmodule












