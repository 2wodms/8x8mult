module mult8x8(
    input [7:0] dataa,
    input [7:0] datab,
    input       start,
    input       reset_a,
    input       clk,

    output  done_flag,
    output [15:0] product8x8_out,
    output  seg_a,
    output  seg_b,
    output  seg_c,
    output  seg_d,
    output  seg_e,
    output  seg_f,
    output  seg_g
	);
//아래 와이어는 top module 안에서 연결해 주는 와이어들

    wire [3:0] 	aout_wire; // used
    wire [3:0] 	bout_wire; //used
    wire [7:0] 	product_wire; //used
    wire [15:0] shift_out_wire;//used
    wire [15:0] sum_wire; //usde
    wire [1:0] 	count_wire; //used 
    wire [2:0] 	state_out_wire; //used

    wire [1:0]	sel_wire; //used
    wire [1:0] 	shift_wire; //used
    wire       	clk_ena_wire; //used
    wire       	sclr_n_wire; //used
    wire [15:0] product8x8_out_wire; //used (adder)
    wire        doneout_wire; //used

//인스턴스 네임 이름 연결

//mux 1번 연결
mux4 mux4_u0(.mux_in_a(dataa[3:0]), 
			 .mux_in_b(dataa[7:4]), 
			 .mux_sel(sel_wire[1]), 
			 .mux_out(aout_wire[3:0])
			 );
//mux 2번 연결 
mux4 mux4_u1(.mux_in_a(datab[3:0]), 
			 .mux_in_b(datab[7:4]), 
			 .mux_sel(sel_wire[0]), 
			 .mux_out(bout_wire[3:0])
			 );
//Mult 4x4 연결
mult4x4 mult4x4_u0(.dataa(aout_wire[3:0]), 
				   .datab(bout_wire[3:0]), 
				   .product(product_wire[7:0])
				   );
//shift 연결
shifter shifter_u0(.inp(product_wire[7:0]), 
				   .shift_cntrl(shift_wire[1:0]),
				   .shift_out(shift_out_wire[15:0])
				  );
//adder 연결
adder adder_u0(.dataa(shift_out_wire[15:0]), 
			   .datab(product8x8_out_wire[15:0]), 
			   .sum(sum_wire)
			   );
//reg 16 연결
reg16 reg16_u0(.clk(clk), 
			   .sclr_n(sclr_n_wire), 
			   .clk_ena(clk_ena_wire), 
			   .datain(sum_wire), 
			   .reg_out(product8x8_out_wire)
			   );
//fsm(mult_control) 연결
fsm mult_control_u0(.clk(clk),
							 .reset_a(reset_a), 
							 .start(start), 
							 .count(count_wire), 
							 .input_sel(sel_wire), 
							 .shift_sel(shift_wire), 
							 .state_out(state_out_wire), 
							 .done(doneout_wire),					
							 .clk_ena(clk_ena_wire), 
							 .sclr_n(sclr_n_wire)
							);

//counter 연결
counter counter_u0(.clk(clk), 
				   .aclr_n(!start), 
				   .count_out(count_wire)
				   );
//seven_seg 연결
seven_segment_cntrl seven_segment_cntrl_u0(.inp(state_out_wire), 
									       .seg_a(seg_a), 
										   .seg_b(seg_b), 
										   .seg_c(seg_c), 
										   .seg_d(seg_d), 
										   .seg_e(seg_e), 
										   .seg_f(seg_f), 
										   .seg_g(seg_g)
										   );


assign product8x8_out = product8x8_out_wire;
assign done_flag = doneout_wire;

endmodule

//테스트 벤치
`timescale 1 ns/1 ns

module mult8x8_tb();

	reg clk, reset_a, start;
	reg [7:0] dataa, datab;
	wire [15:0] product8x8_out;
	wire seg_a, seg_b, seg_c, seg_d, seg_e, seg_f, seg_g;
	

	mult8x8 mult8x8_1 (.clk(clk), .reset_a(reset_a), .dataa(dataa), .datab(datab),
		.product8x8_out(product8x8_out), .done_flag(done_flag), .start(start), 
		.seg_a(seg_a), .seg_b(seg_b), .seg_c(seg_c), .seg_d(seg_d), 
		.seg_e(seg_e), .seg_f(seg_f), .seg_g(seg_g));
		
	initial begin
		clk = 0;
		forever clk = #25 ~clk;
	end

	initial begin
		reset_a = 1'b1;
		#50 reset_a = 1'b0;
	end

	initial begin
		start = 1'b1;
		#50 ;
		forever begin
			start = 1'b1;
			#50 start = 1'b0;
			@(negedge done_flag) ;
			#25 ;
		end
	end
	
	initial begin
		dataa = 8'hFF;
		datab = 8'hFF;
		#50 ;
		forever begin
			@(negedge done_flag)
			#25 dataa = dataa + 24;
			datab = datab + 51;
		end
	end
	
    initial begin
        $dumpfile("jaeeun.vcd");
        $dumpvars;
    end
endmodule



//인스턴스로 불러올 모듈들

//adder
module adder(
    input  [15:0] dataa,
    input  [15:0] datab,
    output [15:0] sum
);
    assign sum = dataa + datab;
endmodule

//multiplex
module mult4x4(
    input  [3:0] dataa   ,
    input  [3:0] datab   ,
    output [7:0] product
);

    assign product = dataa * datab;
endmodule

//mux
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


//shiter
module shifter(
	input	[7:0]	inp,
	input	[1:0]	shift_cntrl,
	output reg 	[15:0]	shift_out
);
	always @(*) begin
		if(shift_cntrl == 2'b01)
			shift_out = {4'b0000, inp, 4'b000};
			
		else if(shift_cntrl == 2'b10)
			shift_out = {inp, 8'b0000_0000};
	
		else
			shift_out = {8'b0000_0000, inp};
    end
endmodule


//seven_segment_cntrl
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

//16bit register
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


//counter
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




//mult control fsm 밀리 머신
module fsm(
    input start,
    input [1:0] count,
    input reset_a,
    input clk,

    output reg [1:0] input_sel,
    output reg [1:0] shift_sel,
    output reg [2:0] state_out,
    output reg done,
    output reg clk_ena,
    output reg sclr_n
);

    reg [2:0] current_state;
    reg [2:0] next_state;
    
localparam idle = 3'b000;
localparam lsb = 3'b001;
localparam mid = 3'b010;
localparam msb = 3'b011;
localparam calc_done = 3'b100;
localparam err = 3'b101;


//ff
always@(posedge clk, posedge reset_a) begin
    if(reset_a)
        current_state <= idle;
    else
        current_state <= next_state; 
end

//스타트와 카운터 상태에 따라 현재상태와 다음상태를 결정해주는 곳.
always@*begin
    case(current_state)
        idle : 
            if(start)
                next_state = lsb;
            else
                next_state = idle;

        lsb : 
            if((!start) && (count == 2'b00))
                next_state = mid;
            else
                next_state = err;

        mid :
            if((!start) && (count == 2'b01))
                next_state = mid;
            else if((!start) && (count == 2'b10))
                next_state = msb;
            else
                next_state = err;

        msb :
            if((!start) && (count == 2'b11))
                next_state = calc_done;
            else
                next_state = err;

        calc_done :
            if(!start)
                next_state = idle;
            else
                next_state = err; 
    endcase
end

//아웃풋 결정되는 곳

always@* begin
    //초기값
    input_sel = 2'bxx;
    shift_sel = 2'bxx;
    done = 0;
    clk_ena = 0;
    sclr_n = 1;

    case(current_state)
        idle : 
            if(!start) begin
                input_sel = 2'bxx;
                shift_sel = 2'bxx;
                done = 0;
                clk_ena = 0;
                sclr_n = 1; 
            end   
            else if(start) begin
                input_sel = 2'bxx;
                shift_sel = 2'bxx;
                done = 0;
                clk_ena = 1;
                sclr_n = 0;
            end

        lsb : 
            if((!start) && (count == 2'b00)) begin
                input_sel = 2'b00;
                shift_sel = 2'b00;
                done = 0;
                clk_ena = 1;
                sclr_n = 1; 
            end   
            else begin
                input_sel = 2'bxx;
                shift_sel = 2'bxx;
                done = 0;
                clk_ena = 0;
                sclr_n = 1;
            end

        mid :
            if((!start) && (count == 2'b01)) begin
                input_sel = 2'b01;
                shift_sel = 2'b01;
                done = 0;
                clk_ena = 1;
                sclr_n = 1; 
            end   
            else if ((!start) && (count == 2'b10))begin
                input_sel = 2'b10;
                shift_sel = 2'b01;
                done = 0;
                clk_ena = 1;
                sclr_n = 1;
            end
            else begin
                input_sel = 2'bxx;
                shift_sel = 2'bxx;
                done = 0;
                clk_ena = 0;
                sclr_n = 1;                
            end

            msb :
            if((!start) && (count == 2'b11)) begin
                input_sel = 2'b11;
                shift_sel = 2'b10;
                done = 0;
                clk_ena = 1;
                sclr_n = 1; 
            end
            else begin
                input_sel = 2'bxx;
                shift_sel = 2'bxx;
                done = 0;
                clk_ena = 0;
                sclr_n = 1;                
            end

            calc_done :
            if(!start) begin
                input_sel = 2'bxx;
                shift_sel = 2'bxx;
                done = 1;
                clk_ena = 0;
                sclr_n = 1;
            end
            else begin
                input_sel = 2'bxx;
                shift_sel = 2'bxx;
                done = 0;
                clk_ena = 0;
                sclr_n = 1;                      
            end

            err :
            if(start) begin
                input_sel = 2'bxx;
                shift_sel = 2'bxx;
                done = 0;
                clk_ena = 1;
                sclr_n = 0;
            end
            else begin
                input_sel = 2'bxx;
                shift_sel = 2'bxx;
                done = 0;
                clk_ena = 0;
                sclr_n = 1;                      
            end            
    endcase

end
//state 아웃풋 상태를 결정하는 부분
//reg로 current state랑 next state 를 만들어주고, local param으로 idle ~ calc_done까지 state를 결정
//이후 어느 값이 들어오는지에 따라서 상태를 out으로 보내줌
always@* begin
    state_out = 3'b000;
    case(current_state)
        idle : state_out = 3'b000;
        lsb : state_out = 3'b001;
        mid : state_out = 3'b010;
        msb : state_out = 3'b011;
        calc_done : state_out = 3'b100;
        err : state_out = 3'b101;
    endcase
end
endmodule


/*mux4 mux4_u0(.mux_in_a(dataa[3:0]), .mux_in_b(dataa[7:4]), .mux_sel(sel[1]), .mux_out(aout[3:0]));
mux4 mux4_u1(.mux_in_a(datab[3:0]), .mux_in_b(datab[7:4]), .mux_sel(sel[0]), .mux_out(bout[3:0]));
mult4x4 mult4x4_u0(.dataa(aout), .datab(bout), .product(product[7:0]));
shifter shifter_u0(.inp(product), .shift_cntrl(shift[1:0]), .shift_out(shift_out));


adder adder_u0(.dataa(shift_out[15:0]), .datab(product8x8_out_wire), .sum(sum[15:0]));
reg16 reg16_u0(.clk(clk), .sclr_n(sclr_n), .clk_ena(clk_ena), .datain(sum), .reg_out(product8x8_out_wire));
mult_control mult_control_u0(.clk(clk), .reset_a(reset_a), .start(start), .count(count), .input_sel(sel), .shift_sel(shift), .state_out(state_out), .done(doneout), .clk_ena(clk_ena), .sclr_n(sclr_n));

counter counter_u0(.clk(clk), .aclr_n(~start), .count_out(count));
seven_segment_cntrl seven_segment_cntrl_u0(.inp(state_out), .seg_a(seg_a), .seg_b(seg_b), .seg_c(seg_c), .seg_d(seg_d), .seg_e(seg_e), .seg_f(seg_f), .seg_g(seg_g));*/