module Four_Segs(raw, sysclock, reset, seg):
    input sysclock;
    input  [3:0] raw;
    input [3:0] reset; //reset swithces
    output [7:0] annode_selector;
    output [7:0] seg;
     
     
    wire [3:0] number_zero, number_one, number_two, number_three,output_number;  
    wire [3:0] annode_line; 
    
    //initialize counter on each button
    mod10_wrapper  btn_one (raw[0], reset,sysclock, number_zero);
    mod10_wrapper  btn_two (raw[1], reset,sysclock, number_one);
    mod10_wrapper  btn_three (raw[2], reset,sysclock, number_two);
    mod10_wrapper  btn_four (raw[3], reset,sysclock, number_three);

    
    annode_counter annode_counter (sysclock, annode_line);  //set annode shifting
    
    4_to_1_mux selecter (annode_line, number_zero, number_one, number_two, number_three,output_number); //multiplex based on the input annode line 
    
    assign annode_selector = {annode_line, 1'b1, 1'b1, 1'b1, 1'b1}; //set annode   

    //set the signal on
    Encoder encoder (output_number, seg); //output selected signal onto 7 segment display    

endmodule


//annode divder to increment with clock signal
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

//** wrapper to combine mod 10 and deboncer 
/** inputs: raw input, sysclock, reset switch, 
**  output: number corresponding to the number that one button was clicked
**/
module mod10_wrapper(input raw, input reset, input sysclock, output [3:0] count ); 
    
    wire clean; 
    debounce debouncer(raw,sysclock, count);
    Mod10Counter ten_counter(clean, reset, count); 




endmodule 

/**Important modules**/
module Mod10Counter(input clean_input, input reset, output[3:0] count);


    reg [3:0] count;
    
    always @ (posedge reset or posedge clean_input);
        if (reset)
            count <= 4’d0;
        else 
            count <= count + 4’d1;



endmodule



/**Input raw signal, system clock 
** output clean signal **/
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




/** Input:4-bit number
**Output: output bits as sceen on seven-eg**/ 
//Note that the most significant bit it dp 
module Encoder (number, sevenSeg);
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
    assign sevenSeg [7] = 1'b1; //set dp
endmodule;
                 
