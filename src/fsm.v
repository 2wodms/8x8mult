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


//tb
`timescale 1 ns/1 ns

module fsm_tb();

	reg clk, reset_a, start;
	reg [1:0] count;
	wire [2:0] state_out;
	wire [1:0] input_sel, shift_sel;
	wire done, clk_ena, sclr_n;
	integer i;
	
	fsm fsm1 (.clk(clk), .reset_a(reset_a), .count(count),
		.input_sel(input_sel), .shift_sel(shift_sel), .state_out(state_out),
		.done(done), .clk_ena(clk_ena), .sclr_n(sclr_n), .start(start));

	initial begin
		clk = 0;
		forever clk = #20 ~clk;
	end

	initial begin
		reset_a = 1'b1;
		#50 reset_a = 1'b0;
	end

	initial begin
		count = 2'd0;
		#125 ;
		for (i=0; i<4; i=i+1) begin
			count = count + 1;
			#50 ;
		end
	end
	
	initial begin
		start = 1'b0;
		#50 start = 1'b1;
		#50 start = 1'b0;
	end

    initial begin
        $dumpfile("jack.vcd");
        $dumpvars;
    end

endmodule