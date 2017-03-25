module testACCII;
  
    reg pulse;
    reg sysclock;
    wire txD;
    wire [3:0] counter;
    wire [8:0] Accii;
    
    initial 
      begin 
        sysclock = 1'b0;
        pulse = 1'b0;
    end
    
    always 
      begin
         sysclock = #5 ~sysclock; 

      end 
 /*   always 
      begin 
        pulse = #100 1'b1;  
        pulse = #10  1'b0;
       end
*/
    UATR uart(pulse, sysclock, txD, counter, Accii);
  
  
endmodule




module UATR(pulse,sysclock, txD,counter,AcciiOut);
  
  input pulse;
  input sysclock;
  output reg [3:0] counter = 4'd0;

  output txD;
   
 output  reg [7:0] Accii = 8'b01100001;
  
  
    
  //increment counter with clock
  always@(posedge sysclock or pulse) 
    begin
    if(counter == 4'd9)
      begin
      if (pulse) 
        begin
        counter<= 4'd0;
        Accii<= Accii + 8'd1;
        end
      else 
          counter <= counter;
        end 
     else 
      counter<=counter +4'd1;
    end  


    
      
    assign txD = (counter == 4'd1)&Accii[7] | (counter == 4'd2)&Accii[6] | (counter == 4'd3)&Accii[5]
                  | (counter == 4'd4)&Accii[4] | (counter == 4'd5)&Accii[3] | (counter == 4'd6)&Accii[2]
                  | (counter == 4'd7)&Accii[1] | (counter == 4'd8)&Accii[0] | (counter == 4'd9);
                  
    /*((counter == 4'd0)&AcciiOut[0] | (counter == 4'd1)&AcciiOut[1] | (counter == 4'd2)&AcciiOut[2]
                  | (counter == 4'd2)&AcciiOut[2] | (counter == 4'd3)&AcciiOut[3] | (counter == 4'd4)&AcciiOut[4]
                  | (counter == 4'd5)&AcciiOut[5] | (counter == 4'd6)&AcciiOut[6] | (counter == 4'd7)&AcciiOut[7]
                  | (counter == 4'd8)&AcciiOut[8] ;counter == 4'd0)&AcciiOut[0] | (counter == 4'd1)&AcciiOut[1] | (counter == 4'd2)&AcciiOut[2]
                  | (counter == 4'd2)&AcciiOut[2] | (counter == 4'd3)&AcciiOut[3] | (counter == 4'd4)&AcciiOut[4]
                  | (counter == 4'd5)&AcciiOut[5] | (counter == 4'd6)&AcciiOut[6] | (counter == 4'd7)&AcciiOut[7]
                  | (counter == 4'd8)&AcciiOut[8] ; */
endmodule
