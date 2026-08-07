module uart_top
#(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600
)
(
    input  wire       clk,
    input  wire       rst,

    // TX Interface
    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output wire       tx,
    output wire       tx_busy,
    output wire       tx_done,

    // RX Interface
    input  wire       rx,

    output wire [7:0] rx_data,
    output wire       rx_valid
);

    //---------------------------------------------------------
    // Internal Signal
    //---------------------------------------------------------

    wire baud_tick;

    //---------------------------------------------------------
    // Baud Generator
    //---------------------------------------------------------

    baud_gen
    #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    )
    u_baud_gen
    (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    //---------------------------------------------------------
    // UART TX
    //---------------------------------------------------------

    uart_tx u_uart_tx
    (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),

        .tx_start(tx_start),
        .tx_data(tx_data),

        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done)
    );

    //---------------------------------------------------------
    // UART RX
    //---------------------------------------------------------

    uart_rx u_uart_rx
    (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),

        .rx(rx),

        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

endmodule