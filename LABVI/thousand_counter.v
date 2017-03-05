`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2017 11:58:55 AM
// Design Name: 
// Module Name: thousandCounter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module thousandCounter(raw, sysclock, reset,segs, annode_select,led);
    output [3:0] led;
    wire [3:0]annode_line;
    input sysclock, reset;
    input [1:0] raw;
    output [7:0] segs;
    output [7:0] annode_select; 
   
    //wire [3:0] c_zero, c_one, c_two, c_three;
    wire clean_up, clean_down;
    wire [3:0] signal_out;
    wire clock_div;
    
	
	input sysclock;
	output [3:0] count_zero, count_one, count_two, count_three;
	input up_btn, down_btn, reset;
	
	//wires to dictated up or down logic
	wire trigger_up_zero, trigger_down_zero;
	wire trigger_up_one, trigger_down_one ;
	wire trigger_up_two, trigger_down_two;
	
	
	


    //input and output button
    debounce D1(raw[0], sysclock, clean_up);
    debounce D2(raw[1], sysclock, clean_down);
   
    clock_divider div (sysclock, clock_div);
    
    //combo_counter C1(sysclock,clean_up, clean_down, reset, c_zero,c_one,c_two,c_three);
	    
    Mod10Counter M_zero(sysclock, clean_up, clean_down, reset, count_zero, trigger_up_zero, trigger_down_zero);
    Mod10Counter M_one(sysclock,trigger_up_zero, trigger_down_zero, reset, count_one, trigger_up_one, trigger_down_one);
    Mod10Counter M_two(sysclock,trigger_up_one, trigger_down_one, reset, count_two, trigger_up_two, trigger_down_two);
    Mod10Counter M_three(sysclock,trigger_up_two, trigger_down_two, reset, count_three, trigger_up_three, trigger_down_four);
	
	annode_counter counter1 (clock_div, annode_line);
    four_to_one_mux M1(annode_line, c_zero, c_one, c_two, c_three, signal_out);
    Encoder encode_out(signal_out, segs);
        
    assign annode_select = { annode_line, 4'b1111};
   assign led = c_zero;
endmodule

module combo_counter(sysclock, up_btn, down_btn, reset, count_zero, count_one, count_two, count_three);
	input sysclock;
	output [3:0] count_zero, count_one, count_two, count_three;
	input up_btn, down_btn, reset;
	
	//wires to dictated up or down logic
	wire trigger_up_zero, trigger_down_zero;
	wire trigger_up_one, trigger_down_one ;
	wire trigger_up_two, trigger_down_two;
	
	
	
   Mod10Counter M_zero(sysclock, up_btn, down_btn, reset, count_zero, trigger_up_zero, trigger_down_zero);
   Mod10Counter M_one(sysclock,trigger_up_zero, trigger_down_zero, reset, count_one, trigger_up_one, trigger_down_one);
   Mod10Counter M_two(sysclock,trigger_up_one, trigger_down_one, reset, count_two, trigger_up_two, trigger_down_two);
   Mod10Counter M_three(sysclock,trigger_up_two, trigger_down_two, reset, count_three, trigger_up_three, trigger_down_four);
endmodule

/**input system clock
    output divided clock**/
module clock_divider(input sysclock, output divided_clock);
    
    reg [15:0] counter;
    reg divided_clock;
   
    always@ (posedge sysclock) begin 
        counter<=counter + 16'd1;
        divided_clock<=1'd0;
        if(counter == 16'hffff)
            begin
            counter<=16'h0;
            divided_clock<=1'd1;
            end 
    
    end


endmodule

module annode_counter(input sysclock, output [3:0] annode); 

    reg [1:0] counter;

    always @ (posedge sysclock) begin 
        counter<=counter +  2'd1;
        if(counter == 2'd3) 
            counter<= 2'd0; 
    end

    assign annode = { ~(counter==2'd3), ~(counter==2'd2) , ~(counter==2'd1), ~(counter==2'd0)};

endmodule

module four_to_one_mux(input [3:0] annode_line, 
        input [3:0] signal_zero, input [3:0] signal_one,
        input[3:0] signal_two, input[3:0] signal_three, output [3:0] selected_sig);

        assign selected_sig = signal_zero&{4{~annode_line[0]}} |
                              signal_one& {4{~annode_line[1]}}  |
                              signal_two &{4{~annode_line[2]}} |
                              signal_three& {4{~annode_line[3]}};
endmodule


module Mod10Counter(input sysclock,input up_input, input down_input, input reset, output[3:0] count, output trigger_up, output trigger_down);
  
    reg [3:0]  count;
    //wire trigger_up;
    //wire trigger_down;
    
    reg new_clock; 
    reg trigger_up;
    reg trigger_down;
  
    
    always @ (posedge( up_input | down_input )) begin
    
       if (reset)
           count <= 4'd0; //reset all mod10s
       else begin
            if (up_input) begin
              	count <= count + 4'd1; 
                if(count == 4'd9) begin   
                    count<= 4'd0;
                    trigger_up<= 1'd1; //set trigger to 1          
                end
				else 
                   trigger_up<= 1'd0; //set trigger up to 0
            end else if (down_input) begin
               count<= count - 4'd1;
               if(count == 4'd0) begin
                   count <= 4'd9;
                   trigger_down <= 1'd1;
                end
                else 
                   trigger_down<=1'd0;  
		    end
        end
           
    end
       
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

module Encoder (number, sevenSeg);
    input [3:0] number;
    output [7:0] sevenSeg;
    assign sevenSeg [0] = (number == 4'd1) | (number == 4'd4);
    assign sevenSeg [1] = (number == 4'd5) | (number == 4'd6);
    assign sevenSeg [2] = (number == 4'd2);
    assign sevenSeg [3] = (number == 4'd1) | (number == 4'd4) | (number == 4'd7);
    assign sevenSeg [4] = (number == 4'd1) | (number == 4'd3) | (number == 4'd4) | 
                            (number == 4'd5) | (number == 4'd7) | (number == 4'd9);
    assign sevenSeg [5] = (number == 4'd1) | (number == 4'd2) | (number == 4'd3) | 
                                (number == 4'd7);
    assign sevenSeg [6] = (number == 4'd0) | (number == 4'd1) | (number == 4'd7);
    assign sevenSeg [7] = 1'b1; 
endmodule
