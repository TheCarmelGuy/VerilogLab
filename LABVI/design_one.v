module Four_Segs(raw, systclk, reset, seg)
    input systclk;
    input  [3:0] raw;
    output [7:0] selector;
    output [7:0] seg;



endmodule





//** wrapper to combine mod 10 and deboncer 
/** inputs: raw input, sysclock, reset switch, 
**  output: number corresponding to the number that one button was clicked
**/
module Mod10_wrapper(input raw, input reset, input sysclock, output [3:0] count ) 
    
    wire clean; 
    debounce debouncer(raw,sysclock, count);
    Mod10Counter ten_counter(clean, reset, count); 




endmodule 

/**Important modules**/
module Mod10Counter(input clean_input, input reset, output[3:0] count):


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
endmodule;
                 
