
//set raw[1] to HIGH and raw[0] to LOW
module (input sysclock, input [1:0] raw_button);



endmodule


/**Some important modules**/



/*******************************************************************************************/


/**Input: clock, reset, T
	Outpt: 
**/
module toggle_flip_flop(input reset, input clock, input t_input, output q, output q_next);
	
	//intitial values
	reg q, q_next;
	initial
		begin
			q = 1'b1;
			q_next = 1'b0; 
		
		end


	always@ (posedge clock or posedge reset) begin
	
		if(t) begin 
			q_next<=~q; //toggle that
		
		end 
		else begin
			q_next <= q;
		
		end
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