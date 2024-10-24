module tb_scorehand();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").
    logic err;
    logic [3:0] card1, card2, card3, total;

    scorehand scorehand(.card1(card1), .card2(card2), .card3(card3), .total(total));

    task assign_cards(input [3:0] card1_val, input [3:0] card2_val, input [3:0] card3_val);
    begin
        card1 = card1_val;
        card2 = card2_val;
        card3 = card3_val;
    end
    endtask

    task check_total(input [3:0] expected_total);
    begin
        if(total !== expected_total) begin
            $display("ERROR ** output is %b, expected %b", total, expected_total);
            err = 1'b1;
        end else begin
            $display("output is %b, expected %b", total, expected_total);
        end
    end
    endtask

    initial begin
        err = 1'b0;
        card1 = 4'b0000;
        card2 = 4'b0000;
        card3 = 4'b0000;

        $display("checking 2+3+4");
        assign_cards(4'b0010, 4'b0011, 4'b0100);
        #1;
        check_total(4'b1001);

        #10;

        $display("checking 10+1+3");
        assign_cards(4'b1010, 4'b0001, 4'b0011);
        #1;
        check_total(4'b0100);

        #10;

        $display("checking 10+J+Q");
        assign_cards(4'b1010, 4'b1011, 4'b1100);
        #1;
        check_total(4'b0000);

        #10;

        $display("checking J+Q+K");
        assign_cards(4'b1011, 4'b1100, 4'b1101);
        #1;
        check_total(4'b0000);

        #10;

        $display("checking Q+K+10");
        assign_cards(4'b1100, 4'b1101, 4'b1010);
        #1;
        check_total(4'b0000);

        #10;

        $display("checking K+10+J");
        assign_cards(4'b1101, 4'b1010, 4'b1011);
        #1;
        check_total(4'b0000);

        #10;

        $display("checking A+2+3");
        assign_cards(4'b0001, 4'b0010, 4'b0011);
        #1;
        check_total(4'b0110);

        #10;

        $display("checking 3+4+5");
        assign_cards(4'b0011, 4'b0100, 4'b0101);
        #1;
        check_total(4'b0010);

        #10;

        $display("checking 5+6+7");
        assign_cards(4'b0101, 4'b0110, 4'b0111);
        #1;
        check_total(4'b1000);

        #10;

        $display("checking 7+8+9");
        assign_cards(4'b0111, 4'b1000, 4'b1001);
        #1;
        check_total(4'b0100);

        #10;

        $display("checking 9+10+J");
        assign_cards(4'b1001, 4'b1010, 4'b1011);
        #1;
        check_total(4'b1001);

        //test for wrong total
        #10

        $display("checking 7+7+7");
        assign_cards(4'b0111, 4'b0111, 4'b0111);
        #1;
        check_total(4'b0000);

        $display("checking 8+8+8");
        assign_cards(4'b1000, 4'b1000, 4'b1000);
        #1;
        check_total(4'b0000);

        $display("checking 1+3+3");
        assign_cards(4'b0001, 4'b0011, 4'b0011);
        #1;
        check_total(4'b0000);

        $display("checking 2+2+4");
        assign_cards(4'b0010, 4'b0010, 4'b0100);
        #1;
        check_total(4'b0000);

        err = 1'b0;
        #10;
        $stop;
    end
endmodule
