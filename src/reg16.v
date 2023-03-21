module reg16(
    input wire clk,
    input wire sclr_n,
    input wire clk_ena,
    input wire [15:0] datain,
    output reg [15:0] reg_out
);

always @(posedge clk or negedge sclr_n) begin
    if(!sclr_n)
        reg_out <= 0;
    else if(clk_ena)
        reg_out <= datain;
end
    endmodule


`timescale 1 ns/1 ns

module reg16_tb();

	reg clk, clk_ena, sclr_n;
	reg  [15:0] datain;
	wire [15:0] reg_out;
	
	reg16 reg16_1 (.clk(clk), .clk_ena(clk_ena), .sclr_n(sclr_n),
		.datain(datain), .reg_out(reg_out));

	// clk 20ns 마다
	initial begin
		clk = 0;
		forever clk = #20 ~clk;
	end
	
	initial begin
		clk_ena = 1'b0;
		sclr_n = 1'b0;
		datain = 16'h1F1F;
		#40 ;
		clk_ena = 1'b1;
		#40 ;
		sclr_n = 1'b1;
		#40 ;
		datain = 16'h4567;
		clk_ena = 1'b0;
		#40 ;
		clk_ena = 1'b1;
		#40 ;
		sclr_n = 1'b0;
	end

    initial begin
        $dumpfile("reg16.vcd");
        $dumpvars;
    end


endmodule