module mux4(
    input      [3:0] mux_in_a  ,
    input      [3:0] mux_in_b  ,
    input            mux_sel   ,
    output reg [3:0] mux_out 
);

    always @* begin
        if (!mux_sel) 
            mux_out = mux_in_a;

        else 
            mux_out = mux_in_b;
    end

endmodule



`timescale 1 ns/1 ns

module mux4_tb();

	reg [3:0] mux_in_a, mux_in_b;
	reg mux_sel;
	wire [3:0] mux_out;
	
	mux4 mux4_1 (.mux_in_a(mux_in_a), .mux_in_b(mux_in_b), .mux_sel(mux_sel),
		.mux_out(mux_out));

	initial begin
		mux_in_a = 4'd9;  	
		mux_in_b = 4'd7;	
	end

	initial begin
		mux_sel = 1'b1;
		forever
			#50 mux_sel = (mux_sel ? 1'b0 : 1'b1);
	end

    initial begin
        $dumpfile("mux4.vcd");
        $dumpvars;
    end

endmodule