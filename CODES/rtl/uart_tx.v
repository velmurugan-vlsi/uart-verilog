module uart_tx
(
    input  wire       clk,
    input  wire       rst,
    input  wire       baud_tick,

    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output reg        tx,
    output reg        tx_busy,
    output reg        tx_done
);

    //=========================================================
    // State Encoding
    //=========================================================

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] state;

    //=========================================================
    // Internal Registers
    //=========================================================

    reg [7:0] shift_reg;
    reg [2:0] bit_count;

    //=========================================================
    // UART Transmitter
    //=========================================================

    always @(posedge clk) begin

        if (rst) begin

            state     <= IDLE;
            shift_reg <= 8'd0;
            bit_count <= 3'd0;

            tx         <= 1'b1;   // Idle Line
            tx_busy    <= 1'b0;
            tx_done    <= 1'b0;

        end

        else begin

            // tx_done is a one clock pulse
            tx_done <= 1'b0;

            case(state)

            //=================================================
            // IDLE
            //=================================================

            IDLE: begin

                tx      <= 1'b1;
                tx_busy <= 1'b0;

                if(tx_start) begin

                    shift_reg <= tx_data;
                    bit_count <= 3'd0;

                    tx_busy <= 1'b1;

                    state <= START;

                end

            end

            //=================================================
            // START BIT
            //=================================================

            START: begin

                tx <= 1'b0;

                if(baud_tick) begin

                    state <= DATA;

                end

            end

            //=================================================
            // DATA BITS
            //=================================================

            DATA: begin

                tx <= shift_reg[0];

                if(baud_tick) begin

                    shift_reg <= shift_reg >> 1;

                    if(bit_count == 3'd7) begin

                        state <= STOP;

                    end

                    else begin

                        bit_count <= bit_count + 1'b1;

                    end

                end

            end

            //=================================================
            // STOP BIT
            //=================================================

            STOP: begin

                tx <= 1'b1;

                if(baud_tick) begin

                    tx_done <= 1'b1;
                    tx_busy <= 1'b0;

                    state <= IDLE;

                end

            end

            default: begin

                state <= IDLE;

            end

            endcase

        end

    end

endmodule