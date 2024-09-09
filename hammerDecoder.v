module hammerDecoder(
    input [11:0] code,
    output reg [7:0] data,
    output reg [3:0] syndrome    
);
    reg [3:0] recieved_check_bits;
    reg [7:0] recieved_data_bits;
    reg [3:0] calc_check_bits;
    reg calc_C0;
    reg calc_C1;
    reg calc_C2;
    reg calc_C3;
    
    always @(*) begin
        recieved_check_bits = {code[7], code[3] , code[1], code[0]};
        recieved_data_bits = {code[11], code[10], code[9], code[8] , code[6], code[5] , code[4], code[2]};
        
        calc_C0 = code[2] ^ code[4] ^ code[6] ^ code[8] ^ code[10];
        calc_C1 = code[2] ^ code[5] ^ code[6] ^ code[9] ^ code[10];
        calc_C2 = code[4] ^ code[5] ^ code[6] ^ code[11];
        calc_C3 = code[8] ^ code[9] ^ code[10] ^ code[11];

    	calc_check_bits = {calc_C3, calc_C2, calc_C1, calc_C0};
    
        //calculate the syndrome by comapring check bits
        syndrome[3] = calc_C3 ^ recieved_check_bits[3];
        syndrome[2] = calc_C2 ^ recieved_check_bits[2];
        syndrome[1] = calc_C1 ^ recieved_check_bits[1];
        syndrome[0] = calc_C0 ^ recieved_check_bits[0];
        
        data = recieved_data_bits;
        
        if(syndrome != 4'b0000) begin
            data = recieved_data_bits;
            case(syndrome)
                4'b0011: data[0] = ~data[0];
                4'b0101: data[1] = ~data[1]; 
                4'b0110: data[2] = ~data[2]; 
                4'b0111: data[3] = ~data[3]; 
                4'b1001: data[4] = ~data[4]; 
                4'b1010: data[5] = ~data[5]; 
                4'b1011: data[6] = ~data[6]; 
                4'b1100: data[7] = ~data[7];
            endcase        
        end 
   
    end
    
endmodule

module hammerDecoderTB();
    reg [11:0] code;  //input code word
    reg [7:0] data;  //corrected data
    reg [3:0] syndrome;  //syndrome
    
    reg [7:0] input_data;
    reg [3:0] input_check;
    
    hammerDecoder u1(.code(code), .data(data), .syndrome(syndrome));
    
    assign input_data = {code[11], code[10], code[9], code[8] , code[6], code[5] , code[4], code[2]};
    assign input_check = {code[7], code[3] , code[1], code[0]};
    
    initial
        begin
            $monitor($time, "ns input data bits: %b , input check bits: %b , corrected data: %b , calculated syndrome: %b",
                     input_data, input_check, data, syndrome);
            
            // Test case 1: No error
            code = 12'b001101001111; // Example encoded data with no error
            #10
            code = 12'b001101001110; // b0
            #10
            code = 12'b001101001101; // b1
            #10
            code = 12'b001101001011; // b2
            #10
            code = 12'b001101000111; // b3
            #10
            code = 12'b001101011111; // b4
            #10
            code = 12'b001101101111; // b5
            #10
            code = 12'b001100001111; // b6
            #10
            code = 12'b001111001111; // b7
            #10
            code = 12'b001001001111; // b8
            #10
            code = 12'b000101001111; // b9
            #10
            code = 12'b011101001111; // b10
            #10
            code = 12'b101101001111; // b11
            #10            

            $finish;
        end
    
endmodule
