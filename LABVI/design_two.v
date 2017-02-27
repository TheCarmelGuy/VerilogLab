module four_seg_four_select(raw, sysclock,switch_select, reset, seg):
    input sysclock;
    input  raw;
    input [1:0] select_switch;
    input [3:0] reset; //reset swithces
    
    output [7:0] annode_selector;
    output [7:0] seg;
     
    wire [3:0] number_zero, number_one, number_two, number_three,output_number;  
    wire [3:0] annode_line; 
    wire [3:0] demux_out;
    wire div_clock;
    

    clock_divider div(sysclock, div_clock); 
    annode_counter annode_counter (div_clock, annode_line);  //set annode shifting
    
    demux deplex (raw, sysclock, switch,  select_switch,demux_out);

    
    Mod10Counter display_zero(demux_out[3], reset, number_zero);      
    Mod10Counter display_one(demux_out[2], reset, number_one);
    Mod10Counter display_one(demux_out[1], reset, number_two);
    Mod10Counter display_one(demux_out[0], reset, number_three);
    
    4_to_1_mux selecter (annode_line, number_zero, number_one, number_two, number_three,output_number); //multiplex based on the input annode line 
    
    assign annode_selector = {annode_line, 1'b1, 1'b1, 1'b1, 1'b1}; //set annode   

    //set the signal on
    Encoder encoder (output_number, seg); //output selected signal onto 7 segment display    

endmodule


//annode divder to increment with clock signal
module annode_counter(input div_clock, output [3:0] annode); 

    reg [3:0]annode;

    reg [1:0] counter;

    always @ (posedge div_clock) begin 
        counter<=counter +  2'd1;
        if(counter == 2'd3) 
            counter<= 2'd0; 
    end

   //1110, 1101, 1011,0111 pattern
    assign annode = { ~(counter==2'd3), ~(counter==2'd2) , ~(counter==2'd1), ~(counter--2'd0)};


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




module 4_to_1_mux(input [3:0] annode_line, 
        input [3:0] signal_zero, input [3:0] signal_one,
        input[3:0] signal_two, input[3:0] signal_three, output [3:0] selected_sig);

        assign selected_sig = signal_zero&{4{~anode_line[0]}} |
                              signal_one& {4{~anode_line[1]}}  |
                              signal_two {4{~anode_line[2]}} |
                              signal_three& {4{~anode_line[3]}};


endmodule


//**module to demux the input **/
module demux (input raw, input sysclock,input [1:0] switch, output [3:0] demux_out);
    
    wire clean;
    reg [3:0] demux_out;
    debounce debouncer (raw,  sysclock, clean);

    always @ (posedge clean) begin
        demux <= {switch ==2'b00,switch==2'b01, switch==2'b10, switch==2'b11}  
    end

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
                 
