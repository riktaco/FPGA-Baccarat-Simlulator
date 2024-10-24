module scorehand(input logic [3:0] card1, input logic [3:0] card2, input logic [3:0] card3, output logic [3:0] total);

// The code describing scorehand will go here.  Remember this is a combinational
// block. The function is described in the handout. Be sure to review Verilog
// notes on bitwidth mismatches and signed/unsigned numbers.

    logic [3:0] card1_val, card2_val, card3_val;

    // if card is a 10, Jack, Queen, or King, set value to 0, then calculate total
    always_comb begin
        case(card1)
            4'b1010, 4'b1011, 4'b1100, 4'b1101: card1_val = 4'b0000;
            default: card1_val = card1;
        endcase

        case(card2)
            4'b1010, 4'b1011, 4'b1100, 4'b1101: card2_val = 4'b0000;
            default: card2_val = card2;
        endcase

        case(card3)
            4'b1010, 4'b1011, 4'b1100, 4'b1101: card3_val = 4'b0000;
            default: card3_val = card3;
        endcase

        // calculate total
        total = (card1_val + card2_val + card3_val) % 10;
    end
endmodule

