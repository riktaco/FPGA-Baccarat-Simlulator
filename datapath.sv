module datapath(input logic slow_clock, input logic fast_clock, input logic resetb,
                input logic load_pcard1, input logic load_pcard2, input logic load_pcard3,
                input logic load_dcard1, input logic load_dcard2, input logic load_dcard3,
                output logic [3:0] pcard3_out,
                output logic [3:0] pscore_out, output logic [3:0] dscore_out,
                output logic [6:0] HEX5, output logic [6:0] HEX4, output logic [6:0] HEX3,
                output logic [6:0] HEX2, output logic [6:0] HEX1, output logic [6:0] HEX0);

// The code describing your datapath will go here.  Your datapath 
// will hierarchically instantiate six card7seg blocks, two scorehand
// blocks, and a dealcard block.  The registers may either be instatiated
// or included as sequential always blocks directly in this file.
//
// Follow the block diagram in the Lab 1 handout closely as you write this code.

    logic [3:0] pcard1, pcard2, pcard3, dcard1, dcard2, dcard3, new_card;

    assign pcard3_out = pcard3;

    card7seg card7seg0(.card(pcard1), .seg7(HEX0));
    card7seg card7seg1(.card(pcard2), .seg7(HEX1));
    card7seg card7seg2(.card(pcard3), .seg7(HEX2));
    card7seg card7seg3(.card(dcard1), .seg7(HEX3));
    card7seg card7seg4(.card(dcard2), .seg7(HEX4));
    card7seg card7seg5(.card(dcard3), .seg7(HEX5));

    scorehand scorehand0(.card1(pcard1), .card2(pcard2), .card3(pcard3), .total(pscore_out));
    scorehand scorehand1(.card1(dcard1), .card2(dcard2), .card3(dcard3), .total(dscore_out));

    dealcard dealcard(.clock(fast_clock), .resetb(resetb), .new_card(new_card));

    // reg4 for all player and dealer cards
    always_ff @(negedge slow_clock)
        if (~resetb) begin
            pcard1 <= 4'b0000;
            pcard2 <= 4'b0000;
            pcard3 <= 4'b0000;
            dcard1 <= 4'b0000;
            dcard2 <= 4'b0000;
            dcard3 <= 4'b0000;
        end else begin
            if (load_pcard1) begin
                pcard1 <= new_card;
            end 
            if (load_pcard2) begin
                pcard2 <= new_card;
            end
            if (load_pcard3) begin
                pcard3 <= new_card;
            end
            if (load_dcard1) begin
                dcard1 <= new_card;
            end
            if (load_dcard2) begin
                dcard2 <= new_card;
            end
            if (load_dcard3) begin
                dcard3 <= new_card;
            end
        end
endmodule

