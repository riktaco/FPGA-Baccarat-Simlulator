module tb_datapath();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").

    logic slow_clock, fast_clock, resetb, load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3, err;
    logic [3:0] pcard3_out, pscore_out, dscore_out;
    logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

    datapath datapath(.slow_clock(slow_clock), .fast_clock(fast_clock), .resetb(resetb),
                       .load_pcard1(load_pcard1), .load_pcard2(load_pcard2), .load_pcard3(load_pcard3),
                       .load_dcard1(load_dcard1), .load_dcard2(load_dcard2), .load_dcard3(load_dcard3),
                       .pcard3_out(pcard3_out), .pscore_out(pscore_out), .dscore_out(dscore_out),
                       .HEX5(HEX5), .HEX4(HEX4), .HEX3(HEX3), .HEX2(HEX2), .HEX1(HEX1), .HEX0(HEX0));


    task toggle_slow_clock(input integer num_toggles);
        integer i;
        for (i = 0; i < num_toggles; i = i + 1) begin
            slow_clock = 1;
            #10;
            slow_clock = 0;
            #10;
        end
    endtask

    task toggle_fast_clock(input integer num_toggles);
        integer i;
        for (i = 0; i < num_toggles; i = i + 1) begin
            #10 fast_clock = 1;
            #10 fast_clock = 0;
        end
    endtask

    task my_checker(input [3:0] expected_value, input [6:0] expected_hex);
        reg [3:0] actual_value;
        reg [6:0] actual_hex;
        begin
            load_pcard1 = 1;
            load_pcard2 = 1;
            load_pcard3 = 1;
            load_dcard1 = 1;
            load_dcard2 = 1;
            load_dcard3 = 1;
            toggle_slow_clock(1);
            load_pcard1 = 0;
            load_pcard2 = 0;
            load_pcard3 = 0;
            load_dcard1 = 0;
            load_dcard2 = 0;
            load_dcard3 = 0;
            actual_value = tb_datapath.datapath.pcard1;
            actual_hex = tb_datapath.datapath.HEX0;
            if (expected_value !== actual_value) begin
                $display("ERROR ** player card 1 is %b, expected %b", actual_value, expected_value);
                err = 1'b1;
            end
            if (expected_hex !== actual_hex) begin
                $display("ERROR ** HEX0 is %b, expected %b", actual_hex, expected_hex);
                err = 1'b1;
            end
            actual_value = tb_datapath.datapath.pcard2;
            actual_hex = tb_datapath.datapath.HEX1;
            if (expected_value !== actual_value) begin
                $display("ERROR ** player card 2 is %b, expected %b", actual_value, expected_value);
                err = 1'b1;
            end
            if (expected_hex !== actual_hex) begin
                $display("ERROR ** HEX1 is %b, expected %b", actual_hex, expected_hex);
                err = 1'b1;
            end
            actual_value = tb_datapath.datapath.pcard3;
            actual_hex = tb_datapath.datapath.HEX2;
            if (expected_value !== actual_value) begin
                $display("ERROR ** player card 3 is %b, expected %b", actual_value, expected_value);
                err = 1'b1;
            end
            if (expected_hex !== actual_hex) begin
                $display("ERROR ** HEX2 is %b, expected %b", actual_hex, expected_hex);
                err = 1'b1;
            end
            actual_value = tb_datapath.datapath.dcard1;
            actual_hex = tb_datapath.datapath.HEX3;
            if (expected_value !== actual_value) begin
                $display("ERROR ** dealer card 1 is %b, expected %b", actual_value, expected_value);
                err = 1'b1;
            end
            if (expected_hex !== actual_hex) begin
                $display("ERROR ** HEX3 is %b, expected %b", actual_hex, expected_hex);
                err = 1'b1;
            end
            actual_value = tb_datapath.datapath.dcard2;
            actual_hex = tb_datapath.datapath.HEX4;
            if (expected_value !== actual_value) begin
                $display("ERROR ** dealer card 2 is %b, expected %b", actual_value, expected_value);
                err = 1'b1;
            end
            if (expected_hex !== actual_hex) begin
                $display("ERROR ** HEX4 is %b, expected %b", actual_hex, expected_hex);
                err = 1'b1;
            end
            actual_value = tb_datapath.datapath.dcard3;
            actual_hex = tb_datapath.datapath.HEX5;
            if (expected_value !== actual_value) begin
                $display("ERROR ** dealer card 3 is %b, expected %b", actual_value, expected_value);
                err = 1'b1;
            end
            if (expected_hex !== actual_hex) begin
                $display("ERROR ** HEX5 is %b, expected %b", actual_hex, expected_hex);
                err = 1'b1;
            end
        end
    endtask

    //control new card and load card, make sure 7 seg display is correct

    initial begin
        fast_clock = 0;
        slow_clock = 0;
        err = 1'b0;
        load_dcard1 = 0;
        load_dcard2 = 0;
        load_dcard3 = 0;
        load_pcard1 = 0;
        load_pcard2 = 0;
        load_pcard3 = 0;

        resetb = 0;
        toggle_slow_clock(1);
        toggle_fast_clock(1);
        resetb = 1;

        // set all player and dealer cards to A
        my_checker(4'b0001, 7'b0001000);

        toggle_fast_clock(1);

        // set all player and dealer cards to 2
        my_checker(4'b0010, 7'b0100100);

        toggle_fast_clock(1);

        // set all player and dealer cards to 3
        my_checker(4'b0011, 7'b0110000);

        toggle_fast_clock(1);

        // set all player and dealer cards to 4
        my_checker(4'b0100, 7'b0011001);

        toggle_fast_clock(1);

        // set all player and dealer cards to 5
        my_checker(4'b0101, 7'b0010010);

        toggle_fast_clock(1);

        // set all player and dealer cards to 6
        my_checker(4'b0110, 7'b0000010);

        toggle_fast_clock(1);

        // set all player and dealer cards to 7
        my_checker(4'b0111, 7'b1111000);

        toggle_fast_clock(1);

        // set all player and dealer cards to 8
        my_checker(4'b1000, 7'b0000000);

        toggle_fast_clock(1);

        // set all player and dealer cards to 9
        my_checker(4'b1001, 7'b0010000);

        toggle_fast_clock(1);

        // set all player and dealer cards to 10
        my_checker(4'b1010, 7'b1000000);

        toggle_fast_clock(1);

        // set all player and dealer cards to J
        my_checker(4'b1011, 7'b1110001);

        toggle_fast_clock(1);

        // set all player and dealer cards to Q
        my_checker(4'b1100, 7'b0011000);

        toggle_fast_clock(1);

        // set all player and dealer cards to K
        my_checker(4'b1101, 7'b0001001);

        toggle_fast_clock(1);

        // force a card with value 15 (invalid)
        force tb_datapath.datapath.dealcard.new_card = 4'b1111;
        my_checker(4'b1111, 7'b1111111);
        release tb_datapath.datapath.dealcard.new_card;

        // clock with load enables off
        toggle_slow_clock(1);

        // test my testbench
        my_checker(4'b1111, 7'b1111111);
        my_checker(4'b0110, 7'b0000000);

        #10;
        err = 1'b0;
        resetb = 0;
        #10;
        $stop;
    end
endmodule