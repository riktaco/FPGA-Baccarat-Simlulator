`define RESET 3'b000
`define DEALP1 3'b001
`define DEALD1 3'b010
`define DEALP2 3'b011
`define DEALD2 3'b100
`define DEALP3 3'b101
`define DEALD3 3'b110
`define WINNER 3'b111

module tb_statemachine();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").
    logic slow_clock, resetb, err;
    logic [3:0] dscore, pscore, pcard3;
    logic load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3;
    logic player_win_light, dealer_win_light;


    statemachine statemachine(.slow_clock(slow_clock), .resetb(resetb),
                            .dscore(dscore), .pscore(pscore), .pcard3(pcard3),
                            .load_pcard1(load_pcard1), .load_pcard2(load_pcard2), .load_pcard3(load_pcard3),
                            .load_dcard1(load_dcard1), .load_dcard2(load_dcard2), .load_dcard3(load_dcard3),
                            .player_win_light(player_win_light), .dealer_win_light(dealer_win_light));

    task check_state(input [2:0] expected_state);
        if (tb_statemachine.statemachine.present_state !== expected_state) begin
            $display("ERROR ** state is %b, expected %b", tb_statemachine.statemachine.present_state, expected_state);
            err = 1'b1;
        end
    endtask

    task check_winner(input string expected_winner);
        if (expected_winner == "dealer" && dealer_win_light !== 1) begin
            $display("ERROR ** dealer_win_light is not set as expected");
            err = 1'b1;
        end else if (expected_winner == "player" && player_win_light !== 1) begin
            $display("ERROR ** player_win_light is not set as expected");
            err = 1'b1;
        end else if (expected_winner == "tie" && (player_win_light !== 1 || dealer_win_light !== 1)) begin
            $display("ERROR ** player_win_light and dealer_win_light are not set as expected");
            err = 1'b1;
        end
    endtask

    task toggle_slow_clock(input integer num_toggles);
        for (int i = 0; i < num_toggles; i = i + 1) begin
            #10 slow_clock = 1;
            #10 slow_clock = 0;
        end
    endtask
    
    task run_test(input [3:0] pscore_init, input [3:0] dscore_init, input [3:0] pcard3_init, input [3:0] dcard3, input string expected_winner);
        pscore = pscore_init;
        dscore = dscore_init;
        pcard3 = pcard3_init;

        toggle_slow_clock(5);
        pscore = pscore + pcard3;
        check_state(`DEALP3);
        toggle_slow_clock(1);
        check_state(`DEALD3);
        dscore = dscore + dcard3;
        toggle_slow_clock(1);
        check_state(`WINNER);
        check_winner(expected_winner);
    endtask

    task reset();
        resetb = 0;
        toggle_slow_clock(1);
        resetb = 1;
    endtask

    initial begin
        load_pcard1 = 0;
        load_pcard2 = 0;
        load_pcard3 = 0;
        load_dcard1 = 0;
        load_dcard2 = 0;
        load_dcard3 = 0;
        player_win_light = 0;
        dealer_win_light = 0;
        err = 1'b0;
        slow_clock = 0;
        reset();

        //If the player’s or banker’s hand has a score of 9, the game is over (this is called a “natural”) and whoever has the higher score wins (if the scores are the same, it is a tie)
        $display("checking natural");
        pscore = 4'b1001;
        dscore = 4'b1000;

        toggle_slow_clock(5);
        check_state(`WINNER);
        check_winner("player");

        reset();

        //If the player’s or banker’s hand has a score of 8, the game is over (this is called a “natural”) and whoever has the higher score wins (if the scores are the same, it is a tie)
        $display("checking natural");
        pscore = 4'b1000;
        dscore = 4'b1001;

        toggle_slow_clock(5);
        check_state(`WINNER);
        check_winner("dealer");

        reset();

        //Otherwise, if the player’s score from his/her first two cards was 0 to 5: the player gets a third card 
        
        //If the banker’s score from the first two cards is 7, the banker does not take another card
        $display("checking player score 0 to 5, banker score 7 (no third banker card)");
        pscore = 4'b0000; 
        dscore = 4'b0111;
        pcard3 = 4'b0001;

        toggle_slow_clock(5);
        pscore = pscore + pcard3;
        check_state(`DEALP3);
        toggle_slow_clock(1);
        check_state(`WINNER);
        check_winner("dealer");

        reset();

        //If the banker’s score from the first two cards is 6, the banker gets a third card if the face value of the player’s third card was a 6 or 7
        $display("checking player score 0 to 5, banker score 6 and value of player third card is 6 or 7 (third banker card)");
        run_test(4'b0000, 4'b0110, 4'b0110, 4'b0000, "tie");

        reset();

        //If the banker’s score from the first two cards is 6, the banker gets a third card if the face value of the player’s third card was a 6 or 7
        $display("checking player score 0 to 5, banker score 6 and value of player third card is not 6 or 7 (no third banker card)");
        pscore = 4'b0000; 
        dscore = 4'b0110;
        pcard3 = 4'b0000;

        toggle_slow_clock(5);
        pscore = pscore + pcard3;
        check_state(`DEALP3);
        toggle_slow_clock(1);
        check_state(`WINNER);
        check_winner("dealer");

        reset();

        //If the banker’s score from the first two cards is 5, the banker gets a third card if the face value of the player’s third card was 4, 5, 6, or 7
        $display("checking player score 0 to 5, banker score 5 and value of player third card is 4, 5, 6, or 7 (third banker card)");
        run_test(4'b0001, 4'b0101, 4'b0110, 4'b0001, "player");

        reset();

        //If the banker’s score from the first two cards is 5, the banker gets a third card if the face value of the player’s third card was 4, 5, 6, or 7
        $display("checking player score 0 to 5, banker score 5 and value of player third card is not 4, 5, 6, or 7 (no third banker card)");
        pscore = 4'b0000; 
        dscore = 4'b0101;
        pcard3 = 4'b0011;

        toggle_slow_clock(5);
        pscore = pscore + pcard3;
        check_state(`DEALP3);
        toggle_slow_clock(1);
        check_state(`WINNER);
        check_winner("dealer");
        
        reset();

        //If the banker’s score from the first two cards is 4, the banker gets a third card if the face value of player’s third card was 2, 3, 4, 5, 6, or 7
        $display("checking player score 0 to 5, banker score 4 and value of player third card is 2, 3, 4, 5, 6, or 7 (third banker card)");
        run_test(4'b0001, 4'b0100, 4'b0010, 4'b0001, "dealer");

        reset();

        //If the banker’s score from the first two cards is 4, the banker gets a third card if the face value of player’s third card was 2, 3, 4, 5, 6, or 7
        $display("checking player score 0 to 5, banker score 4 and value of player third card is not 2, 3, 4, 5, 6, or 7 (no third banker card)");
        pscore = 4'b0000; 
        dscore = 4'b0100;
        pcard3 = 4'b0001;

        toggle_slow_clock(5);
        pscore = pscore + pcard3;
        check_state(`DEALP3);
        toggle_slow_clock(1);
        check_state(`WINNER);
        check_winner("dealer");

        reset();

        //If the banker’s score from the first two cards is 3, the banker gets a third card if the face value of player’s third card was anything but an 8
        $display("checking player score 0 to 5, banker score 3 and value of player third card is not 8 (third banker card)");
        run_test(4'b0101, 4'b0011, 4'b0010, 4'b0001, "player");

        reset();

        //If the banker’s score from the first two cards is 3, the banker gets a third card if the face value of player’s third card was anything but an 8
        $display("checking player score 0 to 5, banker score 3 and value of player third card is 8 (no third banker card)");
        pscore = 4'b0000; 
        dscore = 4'b0011;
        pcard3 = 4'b1000;

        toggle_slow_clock(5);
        pscore = pscore + pcard3;
        check_state(`DEALP3);
        toggle_slow_clock(1);
        check_state(`WINNER);
        check_winner("player");

        reset();

        //If the banker’s score from the first two cards is 0, 1, or 2, the banker gets a third card.
        $display("checking player score 0 to 5, banker score 0, 1, or 2 (third banker card)");
        run_test(4'b0001, 4'b0000, 4'b0010, 4'b0111, "dealer");

        reset();

        //If the player’s score from his/her first two cards was 6 or 7: the player does not take another card

        //if the banker’s score from his/her first two cards was 0 to 5, the banker gets a third card
        $display("checking player score 6 or 7, banker score 0 to 5 (third banker card)");
        pscore = 4'b0110; 
        dscore = 4'b0100;

        toggle_slow_clock(5);
        dscore = pscore + 4'b0000;
        check_state(`DEALD3);
        toggle_slow_clock(1);
        check_state(`WINNER);
        check_winner("winner");

        reset();

        //otherwise the banker does not get a third card
        $display("checking player score 6, banker score not 0-5 (no third banker card)");
        pscore = 4'b0110;
        dscore = 4'b0110;

        toggle_slow_clock(5);
        check_state(`WINNER);
        check_winner("tie");

        reset();

        //otherwise the banker does not get a third card
        $display("checking player score 7, banker score not 0-5 (no third banker card)");
        pscore = 4'b0111;
        dscore = 4'b0110;

        toggle_slow_clock(5);
        check_state(`WINNER);
        check_winner("player");

        reset();

        //test for winner->winner
        $display("test for winner->winner");
        pscore = 4'b1000;
        dscore = 4'b1000;

        toggle_slow_clock(5);
        check_state(`WINNER);
        check_winner("tie");
        toggle_slow_clock(2);
        check_state(`WINNER);

        reset();

        //test pscore, dscore > 9
        run_test(4'b1111, 4'b1111, 4'b1010, 4'b1010, "tie");
        reset();
        run_test(4'b1101, 4'b1110, 4'b0000, 4'b0000, "player");

        //test the testbench
        run_test(4'b1000, 4'b0111, 4'b1000, 4'b1000, "player");
        reset();
        run_test(4'b0111, 4'b1001, 4'b0111, 4'b0111, "dealer");
        reset();
        run_test(4'b0110, 4'b0111, 4'b0000, 4'b0000, "tie"); 
        reset();

        err = 1'b0;
    end
endmodule