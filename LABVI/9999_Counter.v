module 9999_Counter(raw, sysclock, reset, segs);
	input sysclock, reset;
	input [1:0] raw;
	output [7:0] seg;
	debounce D1(raw[0], sysclock, clean_up);
	debounce D2(raw[1], sysclock, clean_down);
	combo_counter C1(clean_up, clean_down, reset, c_zero,c_one,c_two,c_three);
	annode_counter(sysclock, a1);
	4_to_1_mux M1(a1, c_zero, c_one, c_two, c_three, signal_out);
	Decoder D1(signal_out, segs);
endmodule
	
module combo_counter(up_btn, down_btn, reset, count_zero, count_one, count_two, count_three);
	output [3:0] count_zero, count_one, count_two, count_three;
	input up_btn, down_btn, reset;
	
	always @ (posedge up_btn or posedge down_button);
		Mod10Counter M_zero(up_btn, down_btn, reset, count_zero, tup_zero, tdown_zero);
		Mod10Counter M_one(tup_zero, tdown_zero, reset, count_one, tup_one, tdown_one);
		Mod10Counter M_two(tup_one, tdown_one, reset, count_two, tup_two, tdown_two);
		Mod10Counter M_three(tup_two, tdown_two, reset, count_three, tup_four, tdown_four);
endmodule


module annode_counter(input sysclock, output [3:0] annode); 

    reg [3:0]annode;
    reg [1:0] counter;

    always @ (posedge sysclock) begin 
        counter<=counter +  2'd1;
        if(counter == 2'd3) 
            counter<= 2'd0; 
    end

    assign annode = { ~(counter==2'd3), ~(counter==2'd2) , ~(counter==2'd1), ~(counter--2'd0)};

endmodule

module 4_to_1_mux(input [3:0] annode_line, 
        input [3:0] signal_zero, input [3:0] signal_one,
        input[3:0] signal_two, input[3:0] signal_three, output [3:0] selected_sig);

        assign selected_sig = signal_zero&{4{~anode_line[0]}} |
                              signal_one& {4{~anode_line[1]}}  |
                              signal_two {4{~anode_line[2]}} |
                              signal_three& {4{~anode_line[3]}};
endmodule


module Mod10Counter(input up_input, input down_input, input reset, output[3:0] count, output trigger_up, output trigger_down);
    reg [3:0] count;
    wire trigger_up;
    wire trigger_down;
    
    always @ (posedge reset or posedge up_input or posedge down_input);
       	
        	if (reset)
            	count <= 4’d0;
        	else if (up_input) 
            	count <= count + 4’d1;
            	assign trigger_up <= 1'd0;
            	assign trigger_down <= 1'd0;
            else if (up_input & count == 4'd9)
            	count <= 4'd0;
            	assign trigger_up <= 1'd1;
            	assign trigger_down <= 1'd0;
        	else if (down_input & count ~= 4'd0)
        		count <= count - 4'd1;
        		assign trigger_down <= 1'd0;
        		assign trigger_up <= 1'd0;
        	else if (down_input & count == 4'd0)
        		count <= 4'd9;
        		assign trigger_down <= 1'd1;
        		assign trigger_up <= 1'd0;
    		else
    			count <= 4'd0;
    		
endmodule

module debounce(input raw, 
    input sysclock,
    output clean );
    
    reg [15:0] count;
    reg clean;
    
//debouncing button 
    always@ (posedge sysclock or posedge raw)
        if(~raw) 
            begin
            count <= 16'd0;
            clean <=1'd0;
            end
        else 
            begin
            count<=count + 16'd1; //add one to counter
            //when count maxes out
            if(count == 16'hffff) 
                clean<= 1'd1; //set button out but on
            else 
                clean<= clean;
            end
endmodule

module Decoder (number, sevenSeg);
    input [3:0] number;
    output [7:0] sevenSeg;
    assign sevenSeg [0] = (number == 4’d1) | (number == 4’d4);
    assign sevenSeg [1] = (number == 4’d5) | (number == 4’d6);
    assign sevenSeg [2] = (number == 4’d2);
    assign sevenSeg [3] = (number == 4’d1) | (number == 4’d4) | (number == 4’d7);
    assign sevenSeg [4] = (number == 4’d1) | (number == 4’d3) | (number == 4’d4) | 
                            (number == 4’d5) | (number == 4’d7) | (number == 4’d9);
    assign sevenSeg [5] = (number == 4’d1) | (number == 4’d2) | (number == 4’d3) | 
                                (number == 4’d7);
    assign sevenSeg [6] = (number == 4’d0) | (number == 4’d1) | (number == 4’d7);
    assign sevenSeg [7] = 1'b1; 
endmodule;
	
	
