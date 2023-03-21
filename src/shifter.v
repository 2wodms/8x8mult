module shifter(
    input       [7:0]  inp        ,
    input       [1:0]  shift_cntrl,
    output reg  [15:0] shift_out
);
    always@*begin
        case(shift_cntrl)
        2'd1 : shift_out = {4'b0000, inp, 4'b0000};
        2'd2 : shift_out = {inp, 8'b0000_0000};
        2'd0 : shift_out = {8'b0000_0000, inp};
        2'd3 : shift_out = {8'b0000_0000, inp};
        default : shift_out = 15'b0;
        endcase

    end

endmodule

`timescale 1 ns/1 ns

module shifter_tb();

	reg [7:0] inp;
	reg [1:0] shift_cntrl;
	wire [15:0] shift_out;
	
	// 인스턴스 네임
	shifter shifter1 (.inp(inp), .shift_cntrl(shift_cntrl), .shift_out(shift_out));

	initial begin
		shift_cntrl = 4'd0;  	// 초기값
		inp = 8'hF4;			// input값은 1111_0100
		forever
			#50 shift_cntrl = shift_cntrl + 1; //50ns 마다 1씩 증가함으로써 shift 확인
    end

    initial begin
        $dumpfile("shifter.vcd");
        $dumpvars;
    end

endmodule
