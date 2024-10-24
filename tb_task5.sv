`define RESET 3'b000
`define DEALP1 3'b001
`define DEALD1 3'b010
`define DEALP2 3'b011
`define DEALD2 3'b100
`define DEALP3 3'b101
`define DEALD3 3'b110
`define WINNER 3'b111

module tb_task5();
    logic CLOCK_50, err;
    logic [3:0] KEY;
    logic [9:0] LEDR;
    logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
    task5 task5(.CLOCK_50(CLOCK_50), .KEY(KEY), .LEDR(LEDR), .HEX5(HEX5), .HEX4(HEX4), .HEX3(HEX3), .HEX2(HEX2), .HEX1(HEX1), .HEX0(HEX0));

    task toggle_slow_clock(input integer num_toggles);
        for (int i = 0; i < num_toggles; i = i + 1) begin
            KEY[0] = 1;
            #10;
            KEY[0] = 0;
            #10;
        end
    endtask

    task toggle_fast_clock(input integer num_toggles);
        for (int i = 0; i < num_toggles; i = i + 1) begin
            #10 CLOCK_50 = 1;
            #10 CLOCK_50 = 0;
        end
    endtask

    task reset();
        KEY[3] = 0;
        toggle_slow_clock(1);
        KEY[3] = 1;
    endtask

    task check_card(input string id, input [3:0] expected_card);
        reg [3:0] actual_card;
        begin
            if (id == "p1") begin
                actual_card = tb_task5.task5.dp.pcard1;
            end else if (id == "p2") begin
                actual_card = tb_task5.task5.dp.pcard2;
            end else if (id == "p3") begin
                actual_card = tb_task5.task5.dp.pcard3;
            end else if (id == "d1") begin
                actual_card = tb_task5.task5.dp.dcard1;
            end else if (id == "d2") begin
                actual_card = tb_task5.task5.dp.dcard2;
            end else if (id == "d3") begin
                actual_card = tb_task5.task5.dp.dcard3;
            end
            if (expected_card !== actual_card) begin
                $display("ERROR ** %s card is %b, expected %b", id, actual_card, expected_card);
                err = 1'b1;
            end
        end
    endtask

    task set_new_card(input integer new_card);
        KEY[3] = 0;
        toggle_fast_clock(1);
        KEY[3] = 1;
        for(int i = 1; i < new_card; i = i + 1) begin
            toggle_fast_clock(1);
        end
    endtask

    task test7seg();
        //go to 14 to check default cases
        for(int card = 1; card <= 15; card = card + 1) begin
            // no third card
            set_new_card(card);
            toggle_slow_clock(1);
            check_7seg("p1", card);
            toggle_slow_clock(1);
            check_7seg("d1", card);
            toggle_slow_clock(1);
            check_7seg("p2", card);
            toggle_slow_clock(1);
            check_7seg("d2", card);
            toggle_slow_clock(1);
            reset();

            //third card dealer
            set_new_card(2);
            toggle_slow_clock(1);
            check_7seg("p1", 4'b0010);
            toggle_slow_clock(1);
            check_7seg("d1", 4'b0010);
            toggle_slow_clock(1);
            check_7seg("p2", 4'b0010);
            toggle_slow_clock(1);
            check_7seg("d2", 4'b0010);
            toggle_slow_clock(1);
            check_7seg("p3", 4'b0010);
            set_new_card(card);
            toggle_slow_clock(1);
            check_7seg("d3", card);
            toggle_slow_clock(1);
            reset();

            //third card player
            set_new_card(10);
            toggle_slow_clock(1);
            check_7seg("p1", 4'b1010);
            toggle_slow_clock(1);
            check_7seg("d1", 4'b1010);
            toggle_slow_clock(1);
            check_7seg("p2", 4'b1010);
            toggle_slow_clock(1);
            check_7seg("d2", 4'b1010);
            set_new_card(card);
            toggle_slow_clock(1);
            check_7seg("p3", card);
            toggle_slow_clock(1);
            reset();
        end
    endtask

    task check_7seg(input string id, input integer card);
        reg [6:0] actual_hex;
        begin
            if (id == "p1") begin
                actual_hex = HEX0;
            end else if (id == "p2") begin
                actual_hex = HEX1;
            end else if (id == "p3") begin
                actual_hex = HEX2;
            end else if (id == "d1") begin
                actual_hex = HEX3;
            end else if (id == "d2") begin
                actual_hex = HEX4;
            end else if (id == "d3") begin
                actual_hex = HEX5;
            end
            case(card)
                1: if(actual_hex !== 7'b0001000)begin
                    err = 1;
                    $display("ERROR ** %s hex is %b, expected %b", id, actual_hex, 7'b0001000);
                end
                2: if(actual_hex !== 7'b0100100)begin
                    err = 1;
                    $display("ERROR ** %s hex is %b, expected %b", id, actual_hex, 7'b0100100);
                end
                3: if(actual_hex !== 7'b0110000)begin
                    err = 1;
                    $display("ERROR ** %s hex is %b, expected %b", id, actual_hex, 7'b0110000);
                end
                4: if(actual_hex !== 7'b0011001)begin
                    err = 1;
                    $display("ERROR ** %s hex is %b, expected %b", id, actual_hex, 7'b0011001);
                end
                5: if(actual_hex !== 7'b0010010)begin
                    err = 1;
                    $display("ERROR ** %s hex is %b, expected %b", id, actual_hex, 7'b0010010);
                end
                6: if(actual_hex !== 7'b0000010)begin
                    err = 1;
                    $display("ERROR ** %s hex is %b, expected %b", id, actual_hex, 7'b0000010);
                end
                7: if(actual_hex !== 7'b1111000)begin
                    err = 1;
                    $display("ERROR ** %s hex is %b, expected %b", id, actual_hex, 7'b1111000);
                end
                8: if(actual_hex !== 7'b0000000)begin
                    err = 1;
                    $display("ERROR ** %s hex is %b, expected %b", id, actual_hex, 7'b0000000);
                end
                9: if(actual_hex !== 7'b0010000)begin
                    err = 1;
                    $display("ERROR ** %s hex is %b, expected %b", id, actual_hex, 7'b0010000);
                end
                10: if(actual_hex !== 7'b1000000)begin
                    err = 1;
                    $display("ERROR ** %s hex is %b, expected %b", id, actual_hex, 7'b1000000);
                end
                11: if(actual_hex !== 7'b1110001)begin
                    err = 1;
                    $display("ERROR ** %s hex is %b, expected %b", id, actual_hex, 7'b1110001);
                end
                12: if(actual_hex !== 7'b0011000)begin
                    err = 1;
                    $display("ERROR ** %s hex is %b, expected %b", id, actual_hex, 7'b0011000);
                end
                13: if(actual_hex !== 7'b0001001)begin
                    err = 1;
                    $display("ERROR ** %s hex is %b, expected %b", id, actual_hex, 7'b0001001);
                end
                default: begin
                    err = 1;
                    $display("ERROR, value is not between 1 and 13");
                end
            endcase
        end
    endtask

    // i already tested state machine and datapath so i know they work, tb_task5 is only to test if they work together (dont need check_state, check total, check card, etc)
    initial begin
        err = 0;
        KEY[1] = 1;
        KEY[2] = 1;
        #10;
        KEY[1] = 0;
        KEY[2] = 0;
        #10;
        KEY[1] = 1;
        KEY[2] = 1;
        reset();

        //If the player’s or banker’s hand has a score of 8 or 9, the game is over (this is called a “natural”) and whoever has the higher score wins (if the scores are the same, it is a tie)
        // natural tie 8 vs 8
        set_new_card(8);

        toggle_slow_clock(1);
        check_card("p1", 4'b1000);
        toggle_slow_clock(1);
        check_card("d1", 4'b1000);

        set_new_card(10);

        toggle_slow_clock(1);
        check_card("p2", 4'b1010);
        toggle_slow_clock(1);
        check_card("d2", 4'b1010);
        toggle_slow_clock(1);

        reset();

        //natural win
        set_new_card(9);
        toggle_slow_clock(1);
        check_card("p1", 4'b1000);
        set_new_card(8);
        toggle_slow_clock(1);
        check_card("d1", 4'b1000);

        set_new_card(10);
        toggle_slow_clock(1);
        check_card("p2", 4'b1010);
        toggle_slow_clock(1);
        check_card("d2", 4'b1010);
        toggle_slow_clock(1);

        reset();

        // if pscore is between 0 and 5 deal player 3rd card

        //If the banker’s score from the first two cards is 7, the banker does not take another card

        set_new_card(2);
        toggle_slow_clock(1);
        check_card("p1", 4'b0010);

        set_new_card(2);
        toggle_slow_clock(1);
        check_card("d1", 4'b0010);

        set_new_card(2);
        toggle_slow_clock(1);
        check_card("p2", 4'b0010);

        set_new_card(5);
        toggle_slow_clock(1);
        check_card("d2", 4'b0101);

        set_new_card(7);
        toggle_slow_clock(1);
        check_card("p3", 4'b0111);

        toggle_slow_clock(1);
        reset();

        //If the banker’s score from the first two cards is 6, the banker gets a third card if the face value of the player’s third card was a 6 or 7

        set_new_card(8);
        toggle_slow_clock(1);
        check_card("p1", 4'b1000);

        set_new_card(8);
        toggle_slow_clock(1);
        check_card("d1", 4'b1000);

        set_new_card(7);
        toggle_slow_clock(1);
        check_card("p2", 4'b0111);

        set_new_card(8);
        toggle_slow_clock(1);
        check_card("d2", 4'b1000);

        set_new_card(7);
        toggle_slow_clock(1);
        check_card("p3", 4'b0111);

        set_new_card(8);
        toggle_slow_clock(1);
        check_card("d3", 4'b1000);

        toggle_slow_clock(1);
        reset();

        //If the banker’s score from the first two cards is 6, the banker doesnt get a third card if the face value of the player’s third card wasnt a 6 or 7

        set_new_card(7);
        toggle_slow_clock(1);
        check_card("p1", 4'b0111);

        set_new_card(3);
        toggle_slow_clock(1);
        check_card("d1", 4'b0011);

        set_new_card(8);
        toggle_slow_clock(1);
        check_card("p2", 4'b1000);

        set_new_card(3);
        toggle_slow_clock(1);
        check_card("d2", 4'b0011);

        set_new_card(10);
        toggle_slow_clock(1);
        check_card("p3", 4'b1010);

        toggle_slow_clock(1);
        reset();

        //If the banker’s score from the first two cards is 5, the banker gets a third card if the face value of the player’s third card was 4, 5, 6, or 7

        set_new_card(5);
        toggle_slow_clock(1);
        check_card("p1", 4'b0101);

        set_new_card(13);
        toggle_slow_clock(1);
        check_card("d1", 4'b1101);

        set_new_card(5);
        toggle_slow_clock(1);
        check_card("p2", 4'b0101);

        set_new_card(5);
        toggle_slow_clock(1);
        check_card("d2", 4'b0101);

        set_new_card(4);
        toggle_slow_clock(1);
        check_card("p3", 4'b0100);

        set_new_card(13);
        toggle_slow_clock(1);
        check_card("d3", 4'b1101);

        toggle_slow_clock(1);
        reset();

        //If the banker’s score from the first two cards is 5, the banker doesnt get a third card if the face value of the player’s third card wasnt 4, 5, 6, or 7

        set_new_card(1);
        toggle_slow_clock(1);
        check_card("p1", 4'b0001);

        set_new_card(10);
        toggle_slow_clock(1);
        check_card("d1", 4'b1010);

        set_new_card(1);
        toggle_slow_clock(1);
        check_card("p2", 4'b0001);

        set_new_card(5);
        toggle_slow_clock(1);
        check_card("d2", 4'b0101);

        set_new_card(3);
        toggle_slow_clock(1);
        check_card("p3", 4'b0011);

        toggle_slow_clock(1);
        reset();

        //If the banker’s score from the first two cards is 4, the banker gets a third card if the face value of player’s third card was 2, 3, 4, 5, 6, or 7

        set_new_card(2);
        toggle_slow_clock(1);
        check_card("p1", 4'b0010);

        set_new_card(4);
        toggle_slow_clock(1);
        check_card("d1", 4'b0100);

        set_new_card(2);
        toggle_slow_clock(1);
        check_card("p2", 4'b0010);

        set_new_card(12);
        toggle_slow_clock(1);
        check_card("d2", 4'b1100);

        set_new_card(2);
        toggle_slow_clock(1);
        check_card("p3", 4'b0010);

        set_new_card(2);
        toggle_slow_clock(1);
        check_card("d3", 4'b0010);

        toggle_slow_clock(1);
        reset();

        //If the banker’s score from the first two cards is 4, the banker doesnt get a third card if the face value of player’s third card wasnt 2, 3, 4, 5, 6, or 7

        set_new_card(6);
        toggle_slow_clock(1);
        check_card("p1", 4'b0110);

        set_new_card(1);
        toggle_slow_clock(1);
        check_card("d1", 4'b0001);

        set_new_card(6);
        toggle_slow_clock(1);
        check_card("p2", 4'b0110);

        set_new_card(3);
        toggle_slow_clock(1);
        check_card("d2", 4'b0011);

        set_new_card(8);
        toggle_slow_clock(1);
        check_card("p3", 4'b1000);

        toggle_slow_clock(1);
        reset();

        //If the banker’s score from the first two cards is 3, the banker gets a third card if the face value of player’s third card was anything but an 8

        set_new_card(2);
        toggle_slow_clock(1);
        check_card("p1", 4'b0010);

        set_new_card(1);
        toggle_slow_clock(1);
        check_card("d1", 4'b0001);

        set_new_card(2);
        toggle_slow_clock(1);
        check_card("p2", 4'b0010);

        set_new_card(2);
        toggle_slow_clock(1);
        check_card("d2", 4'b0010);

        set_new_card(5);
        toggle_slow_clock(1);
        check_card("p3", 4'b0101);

        set_new_card(8);
        toggle_slow_clock(1);
        check_card("d3", 4'b1000);

        toggle_slow_clock(1);
        reset();

        //If the banker’s score from the first two cards is 3, the banker doesnt get a third card if the face value of player’s third card was an 8

        set_new_card(1);
        toggle_slow_clock(1);
        check_card("p1", 4'b0001);

        set_new_card(2);
        toggle_slow_clock(1);
        check_card("d1", 4'b0010);

        set_new_card(1);
        toggle_slow_clock(1);
        check_card("p2", 4'b0001);

        set_new_card(1);
        toggle_slow_clock(1);
        check_card("d2", 4'b0001);

        set_new_card(8);
        toggle_slow_clock(1);
        check_card("p3", 4'b1000);

        toggle_slow_clock(1);
        reset();

        //If the banker’s score from the first two cards is 0, 1, or 2, the banker gets a third card.

        set_new_card(13);
        toggle_slow_clock(1);
        check_card("p1", 4'b1101);

        set_new_card(13);
        toggle_slow_clock(1);
        check_card("d1", 4'b1101);

        set_new_card(13);
        toggle_slow_clock(1);
        check_card("p2", 4'b1101);

        set_new_card(13);
        toggle_slow_clock(1);
        check_card("d2", 4'b1101);

        set_new_card(10);
        toggle_slow_clock(1);
        check_card("p3", 4'b1010);

        set_new_card(7);
        toggle_slow_clock(1);
        check_card("d3", 4'b0111);

        toggle_slow_clock(1);
        reset();

        // Otherwise, if the player’s score from his/her first two cards was 6 or 7: the player does not get a third card

        // if the banker’s score from his/her first two cards was 0 to 5: the banker gets a third card

        set_new_card(3);
        toggle_slow_clock(1);
        check_card("p1", 4'b0011);

        set_new_card(13);
        toggle_slow_clock(1);
        check_card("d1", 4'b1101);

        set_new_card(3);
        toggle_slow_clock(1);
        check_card("p2", 4'b0011);

        set_new_card(13);
        toggle_slow_clock(1);
        check_card("d2", 4'b1101);

        set_new_card(7);
        toggle_slow_clock(1);
        check_card("d3", 4'b0111);

        toggle_slow_clock(1);
        reset();

        // otherwise the banker does not get a third card
        set_new_card(7);

        toggle_slow_clock(1);
        check_card("p1", 4'b0111);
        toggle_slow_clock(1);
        check_card("d1", 4'b0111);

        set_new_card(10);

        toggle_slow_clock(1);
        check_card("p2", 4'b1010);
        toggle_slow_clock(1);
        check_card("d2", 4'b1010);

        toggle_slow_clock(1);
        // test winner->winner
        toggle_slow_clock(2);
        reset();
        

        $display("Now testing testbench");
        //test 7seg
        test7seg();

        //test dealcard
        toggle_fast_clock(20);

        //test my testbench
        check_card("fake", 4'b0000);
        check_7seg("fake", 20);

        //third card dealer
        force HEX0 = 7'b11111111;
        check_7seg("p1", 1);
        check_7seg("p1", 2);     
        check_7seg("p1", 3);
        check_7seg("p1", 4);
        check_7seg("p1", 5);
        check_7seg("p1", 6);
        check_7seg("p1", 7);
        check_7seg("p1", 8);
        check_7seg("p1", 9);
        check_7seg("p1", 10);
        check_7seg("p1", 11);
        check_7seg("p1", 12);
        check_7seg("p1", 13);  
        check_7seg("p1", 14); 
        release HEX0;

        err = 0;
    end
endmodule