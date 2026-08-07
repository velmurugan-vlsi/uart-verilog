`timescale 1ns/1ps

module uart_top_tb;

    //---------------------------------------------------------
    // Testbench Signals
    //---------------------------------------------------------

    reg         clk;
    reg         rst;

    reg         tx_start;
    reg [7:0]   tx_data;

    wire        tx;
    wire        tx_busy;
    wire        tx_done;

    wire [7:0]  rx_data;
    wire        rx_valid;

    //---------------------------------------------------------
    // Loopback Connection
    //---------------------------------------------------------

    wire rx;

    assign rx = tx;

    //---------------------------------------------------------
    // DUT
    //---------------------------------------------------------

    uart_top
    #(
        .CLK_FREQ (50_000_000),
        .BAUD_RATE(9600)
    )
    DUT
    (
        .clk(clk),
        .rst(rst),

        .tx_start(tx_start),
        .tx_data(tx_data),

        .tx(tx),
        .tx_busy(tx_busy),
        .tx_done(tx_done),

        .rx(rx),

        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

    //---------------------------------------------------------
    // Clock Generation (50 MHz)
    //---------------------------------------------------------

    initial
        clk = 0;

    always #10 clk = ~clk;

    //---------------------------------------------------------
    // Send Task
    //---------------------------------------------------------

    task send_byte;

        input [7:0] data;

        begin

            @(posedge clk);

            tx_data  = data;
            tx_start = 1'b1;

            @(posedge clk);

            tx_start = 1'b0;

            wait(tx_done);

            @(posedge clk);

        end

    endtask

    //---------------------------------------------------------
    // Check Task
    //---------------------------------------------------------

    task check_byte;

        input [7:0] expected;

        begin

            wait(rx_valid);

            if(rx_data == expected)
                $display("[%0t] PASS : Sent=%h  Received=%h",
                          $time, expected, rx_data);

            else
                $display("[%0t] FAIL : Sent=%h  Received=%h",
                          $time, expected, rx_data);

        end

    endtask

    //---------------------------------------------------------
    // Test Sequence
    //---------------------------------------------------------

    initial begin

        rst      = 1;
        tx_start = 0;
        tx_data  = 0;

        repeat(5) @(posedge clk);

        rst = 0;

        //-----------------------------------------------------
        // Test 1
        //-----------------------------------------------------

        fork
            send_byte(8'h55);
            check_byte(8'h55);
        join

        //-----------------------------------------------------
        // Test 2
        //-----------------------------------------------------

        fork
            send_byte(8'hAA);
            check_byte(8'hAA);
        join

        //-----------------------------------------------------
        // Test 3
        //-----------------------------------------------------

        fork
            send_byte(8'hA5);
            check_byte(8'hA5);
        join

        //-----------------------------------------------------
        // Test 4
        //-----------------------------------------------------

        fork
            send_byte(8'hFF);
            check_byte(8'hFF);
        join

        //-----------------------------------------------------
        // Test 5
        //-----------------------------------------------------

        fork
            send_byte(8'h00);
            check_byte(8'h00);
        join

        //-----------------------------------------------------

        #1000;

        $display("--------------------------------");
        $display("UART LOOPBACK TEST COMPLETED");
        $display("--------------------------------");

        $finish;

    end

endmodule