module baud_gen
#(
    parameter CLK_FREQ = 50_000_000,
    parameter BAUD_RATE = 9600
)
(
    input  wire clk,
    input  wire rst,

    output reg  baud_tick
);

    localparam integer DIVIDER = CLK_FREQ / BAUD_RATE;

    reg [12:0] count;

    always @(posedge clk) begin

        if (rst) begin
            count     <= 13'd0;
            baud_tick <= 1'b0;
        end

        else begin

            if (count == DIVIDER-1) begin
                count     <= 13'd0;
                baud_tick <= 1'b1;
            end

            else begin
                count     <= count + 1'b1;
                baud_tick <= 1'b0;
            end

        end

    end

endmodule