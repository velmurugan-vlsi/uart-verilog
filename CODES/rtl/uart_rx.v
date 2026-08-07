module uart_rx
(
    input  wire       clk,
    input  wire       rst,
    input  wire       baud_tick,

    input  wire       rx,

    output reg [7:0]  rx_data,
    output reg        rx_valid
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
    // UART Receiver
    //=========================================================

    always @(posedge clk) begin

        if (rst) begin

            state      <= IDLE;
            shift_reg  <= 8'd0;
            bit_count  <= 3'd0;
            rx_data    <= 8'd0;
            rx_valid   <= 1'b0;

        end

        else begin

            // One-clock pulse
            rx_valid <= 1'b0;

            case(state)

            //=========================================
            // IDLE
            //=========================================

            IDLE: begin

                bit_count <= 3'd0;

                // Detect Start Bit
                if (rx == 1'b0)
                    state <= START;

            end

            //=========================================
            // START
            //=========================================

            START: begin

                if (baud_tick) begin

                    if (rx == 1'b0)
                        state <= DATA;
                    else
                        state <= IDLE;

                end

            end

            //=========================================
            // DATA
            //=========================================

            DATA: begin

                if (baud_tick) begin

                    shift_reg[bit_count] <= rx;

                    if (bit_count == 3'd7)
                        state <= STOP;
                    else
                        bit_count <= bit_count + 1'b1;

                end

            end

            //=========================================
            // STOP
            //=========================================

            STOP: begin

                if (baud_tick) begin

                    if (rx == 1'b1) begin

                        rx_data  <= shift_reg;
                        rx_valid <= 1'b1;

                    end

                    state <= IDLE;

                end

            end

            default:

                state <= IDLE;

            endcase

        end

    end

endmodule