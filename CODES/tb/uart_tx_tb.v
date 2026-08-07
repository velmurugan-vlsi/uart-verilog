`timescale 1ns/1ps

module uart_tx_tb;

    reg         clk;
    reg         rst;
    reg         baud_tick;
    reg         tx_start;
    reg [7:0]   tx_data;

    wire        tx;
    wire        tx_busy;
    wire        tx_done;

    //----------------------------------------------------------
    // DUT
    //----------------------------------------------------------

    uart_tx DUT
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

    //----------------------------------------------------------
    // Clock
    //----------------------------------------------------------

    initial clk = 0;
    always #10 clk = ~clk;

    //----------------------------------------------------------
    // Baud Tick Generator
    //----------------------------------------------------------

    initial begin
        baud_tick = 0;
        forever begin
            #160;
            baud_tick = 1;
            #20;
            baud_tick = 0;
        end
    end

    //----------------------------------------------------------
    // Task
    //----------------------------------------------------------

    task send_byte(input [7:0] data);

    begin

        @(posedge clk);

        tx_data  = data;
        tx_start = 1;

        @(posedge clk);

        tx_start = 0;

        wait(tx_done);

        @(posedge clk);

    end

    endtask

    //----------------------------------------------------------
    // Test
    //----------------------------------------------------------

    initial begin

        rst = 1;
        tx_start = 0;
        tx_data = 0;

        repeat(5) @(posedge clk);

        rst = 0;

        send_byte(8'h55);

        send_byte(8'hAA);

        send_byte(8'hA5);

        send_byte(8'hFF);

        #1000;

        $finish;

    end

endmodule