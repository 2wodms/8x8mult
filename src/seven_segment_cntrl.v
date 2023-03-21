module seven_segment_cntrl(
    input   [2:0]   inp,
    output reg      seg_a,
    output reg      seg_b,
    output reg      seg_c,
    output reg      seg_d,
    output reg      seg_e,
    output reg      seg_f,
    output reg      seg_g
);
    always@* begin
        case(inp)
            3'b000  : {seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g} = 7'b1111110; //LED Display 1; 
            3'b001  : {seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g} = 7'b0110000; //LED Display 2;
            3'b010  : {seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g} = 7'b1101101; //LED Display 3;
            3'b011  : {seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g} = 7'b1111001; //LED Display 4;
            default : {seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g} = 7'b1001111; //LED Display 4;
        endcase 
    end
endmodule

`timescale 1 ns/1 ns

module seven_segment_cntrl_tb();

	reg [2:0] inp;
	wire seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g;
	
	seven_segment_cntrl seven_segment_cntrl1 (.inp(inp), .seg_a(seg_a), .seg_b(seg_b),
		.seg_c(seg_c), .seg_d(seg_d), .seg_e(seg_e), .seg_f(seg_f), .seg_g(seg_g));
	
	initial begin
		inp = 3'd0;  
		forever
			#50 inp = inp + 1; 
	end

    initial begin
        $dumpfile("seven_segment_cntrl.vcd");
        $dumpvars;
    end

endmodule