`define RESET 3'b000
`define DEALP1 3'b001
`define DEALD1 3'b010
`define DEALP2 3'b011
`define DEALD2 3'b100
`define DEALP3 3'b101
`define DEALD3 3'b110
`define WINNER 3'b111

module statemachine(input logic slow_clock, input logic resetb,
                    input logic [3:0] dscore, input logic [3:0] pscore, input logic [3:0] pcard3,
                    output logic load_pcard1, output logic load_pcard2, output logic load_pcard3,
                    output logic load_dcard1, output logic load_dcard2, output logic load_dcard3,
                    output logic player_win_light, output logic dealer_win_light);

// The code describing your state machine will go here.  Remember that
// a state machine consists of next state logic, output logic, and the 
// registers that hold the state.  You will want to review your notes from
// CPEN 211 or equivalent if you have forgotten how to write a state machine.

    logic [2:0] present_state;

    always_ff @(posedge slow_clock) begin
        if (~resetb) begin
            present_state <= `RESET;
        end else begin
            case(present_state)
                `RESET: present_state <= `DEALP1;
                `DEALP1: present_state <= `DEALD1;
                `DEALD1: present_state <= `DEALP2;
                `DEALP2: present_state <= `DEALD2; // both player and dealer are dealt 2 cards
                `DEALD2: 
                    if (pscore == 4'b1000 || pscore == 4'b1001 || dscore == 4'b1000 || dscore == 4'b1001) begin // natural (score is 8 or 9)
                        present_state <= `WINNER;
                    end else if (pscore >= 4'b0000 && pscore <= 4'b0101) begin // if pscore is between 0 and 5 deal player 3rd card
                        present_state <= `DEALP3;
                    end else if ((pscore == 4'b0110 || pscore == 4'b0111) && (dscore >= 4'b0000 && dscore <= 4'b0101)) begin // pscore is 6 or 7 and dscore is between 0 and 5
                        present_state <= `DEALD3;
                    end else begin // default (goes straight to winner state)
                        present_state <= `WINNER;
                    end
                `DEALP3:
                    case(dscore)
                        // If the banker’s score from the first two cards is 7, the banker does not take another card
                        4'b0111: present_state <= `WINNER;
                        // If the banker’s score from the first two cards is 6, the banker gets a third card if the face value of the player’s third card was a 6 or 7
                        4'b0110: 
                            if(pcard3 == 4'b0110 || pcard3 == 4'b0111) begin
                                present_state <= `DEALD3;
                            end else begin
                                present_state <= `WINNER;
                            end
                        // If the banker’s score from the first two cards is 5, the banker gets a third card if the face value of the player’s third card was 4, 5, 6, or 7
                        4'b0101: 
                            if(pcard3 >= 4'b0100 && pcard3 <= 4'b0111) begin
                                present_state <= `DEALD3;
                            end else begin
                                present_state <= `WINNER;
                            end
                        // If the banker’s score from the first two cards is 4, the banker gets a third card if the face value of player’s third card was 2, 3, 4, 5, 6, or 7
                        4'b0100: 
                            if(pcard3 >= 4'b0010 && pcard3 <= 4'b0111) begin
                                present_state <= `DEALD3;
                            end else begin
                                present_state <= `WINNER;
                            end
                        // If the banker’s score from the first two cards is 3, the banker gets a third card if the face value of player’s third card was anything but an 8
                        4'b0011: 
                            if(pcard3 != 4'b1000) begin
                                present_state <= `DEALD3;
                            end else begin
                                present_state <= `WINNER;
                            end
                        // If the banker’s score from the first two cards is 0, 1, or 2, the banker gets a third card.
                        default: present_state <= `DEALD3;
                    endcase
                `DEALD3: present_state <= `WINNER;
                default: present_state <= `WINNER; // stay in winner state until reset
            endcase
        end
    end

    always_comb begin
        // reset everything
        load_pcard1 = 1'b0;
        load_pcard2 = 1'b0;
        load_pcard3 = 1'b0;
        load_dcard1 = 1'b0;
        load_dcard2 = 1'b0;
        load_dcard3 = 1'b0;
        player_win_light = 1'b0;
        dealer_win_light = 1'b0;
        case(present_state)
            `RESET: begin
            end
            `DEALP1: begin
                load_pcard1 = 1'b1;
            end
            `DEALD1: begin
                load_dcard1 = 1'b1;
            end
            `DEALP2: begin
                load_pcard2 = 1'b1;
            end
            `DEALD2: begin
                load_dcard2 = 1'b1;
            end
            `DEALP3: begin
                load_pcard3 = 1'b1;
            end
            `DEALD3: begin
                load_dcard3 = 1'b1;
            end
            `WINNER: begin
                if (pscore > dscore) begin
                    player_win_light = 1'b1;
                end else if(pscore == dscore) begin
                    player_win_light = 1'b1;
                    dealer_win_light = 1'b1;
                end else begin
                    dealer_win_light = 1'b1;
                end
            end
        endcase
    end
endmodule

