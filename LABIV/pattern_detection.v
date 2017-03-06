
//set raw[1] to HIGH and raw[0] to LOW
module (input sysclock, input [1:0] raw_button, output z);
	
	

	wire p1_clean;
	wire p2_clean;
	//dbounce input
	debounce p1_deb (raw_button[0],sysclock, p1_clean);
	debounce p2_deb (raw_button[1], sysclock, p2_clean);

	reg clock_x1;
	reg clock_x2;
	reg clock_x3;

	reg q1,q2,q3; //output of toggles

	
	always @ (posedge sysclock) begin
		clock_x1<= p1_clean&q3&q1 | p2_clean&q2;
		clock_x2 <= p2_clean&~q1&q2 | p1_clean&~q2&q3;
		clock_x3 <= p1_clean&~q1&~q2 | p1_clean & ~q3 &~q2 | p2_clean&q3;

	end 
 		
	//set toggle flipflop
	toggle_flip_flop_high q1_flip(clock_x1, q1);
	toggle_flip_flop_high q2_flip(clock_x2,q2);
	toggle_flip_flop_high q3_flip(clock_x3,q3);

	

	assign z = q1 | ~q1&q2&q3;


endmodule


/**Some important modules**/



/*******************************************************************************************/


/**Input: clock, reset, T
	Outpt: 
**/
module toggle_flip_flop_high(input clock,  output q);
	
	//intitial values
	reg q, q_next;
	initial
		begin
			q = 1'b0;
		
		end


	always@ (negedge clock) begin
		
		q<=~q;	
	end


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
