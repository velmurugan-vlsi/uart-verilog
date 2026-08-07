# UART in Verilog

A synthesizable **UART (Universal Asynchronous Receiver/Transmitter)** IP core written in **Verilog HDL**. This project implements a basic **8-N-1 UART** consisting of a baud rate generator, transmitter, receiver, top-level integration, and simulation testbenches.

This project was developed for learning RTL design, FPGA development, and digital verification concepts.

---

## Features

- Synthesizable Verilog RTL
- Configurable baud rate using parameters
- 8-bit data transmission
- 1 Start Bit
- 1 Stop Bit
- No Parity (8-N-1)
- UART Transmitter (TX)
- UART Receiver (RX)
- Baud Rate Generator
- Top-Level UART Integration
- Individual TX Testbench
- Individual RX Testbench
- UART Loopback Testbench

---


# UART Frame Format

This UART implements the standard **8-N-1** frame.

```
Idle | Start | D0 | D1 | D2 | D3 | D4 | D5 | D6 | D7 | Stop

  1      0      LSB ---------------------------> MSB      1
```

- Idle Line = HIGH
- Start Bit = LOW
- Data Bits = 8
- Stop Bit = HIGH
- Data transmitted LSB First

---

# Architecture

```
                 +---------------------+
                 |     baud_gen.v      |
                 +----------+----------+
                            |
                        baud_tick
                            |
          +-----------------+-----------------+
          |                                   |
          |                                   |
+---------+---------+             +-----------+----------+
|   uart_tx.v       |             |    uart_rx.v         |
+---------+---------+             +-----------+----------+
          |                                   |
          |                                   |
         TX                                  RX
          |                                   |
          +---------------+-------------------+
                          |
                    uart_top.v
```

---

# Modules

## 1. Baud Rate Generator

**File**

```
rtl/baud_gen.v
```

Responsible for generating the baud tick used by both the transmitter and receiver.

### Inputs

- clk
- rst

### Output

- baud_tick

---

## 2. UART Transmitter

**File**

```
rtl/uart_tx.v
```

Converts 8-bit parallel data into serial UART data.

### Inputs

- clk
- rst
- baud_tick
- tx_start
- tx_data[7:0]

### Outputs

- tx
- tx_busy
- tx_done

---

## 3. UART Receiver

**File**

```
rtl/uart_rx.v
```

Receives serial UART data and reconstructs the original byte.

### Inputs

- clk
- rst
- baud_tick
- rx

### Outputs

- rx_data[7:0]
- rx_valid

---

## 4. UART Top

**File**

```
rtl/uart_top.v
```

Instantiates

- Baud Generator
- UART TX
- UART RX

and connects them together.

---

# Simulation

Three testbenches are included.

## UART TX Testbench

```
tb/uart_tx_tb.v
```

Verifies

- Reset
- Start Bit
- Data Transmission
- Stop Bit
- tx_busy
- tx_done

---

## UART RX Testbench

```
tb/uart_rx_tb.v
```

Verifies

- Start Bit Detection
- Data Reception
- rx_valid
- Received Data

---

## UART Loopback Testbench

```
tb/uart_top_tb.v
```

The transmitter output is connected directly to the receiver input.

```
TX -------------> RX
```

The following bytes are transmitted:

```
0x55

0xAA

0xA5

0xFF

0x00
```

Expected output:

```
TX Data == RX Data
```

---

# Example Simulation Result

| TX Data | RX Data | Result |
|---------|---------|--------|
| 0x55 | 0x55 | PASS |
| 0xAA | 0xAA | PASS |
| 0xA5 | 0xA5 | PASS |
| 0xFF | 0xFF | PASS |
| 0x00 | 0x00 | PASS |

---

# How to Simulate (ModelSim)

Compile:

```
vlib work

vlog rtl/*.v

vlog tb/*.v
```

Run:

```
vsim uart_top_tb

add wave *

run -all
```

---

# Future Improvements

The current implementation is a basic educational UART.

Future enhancements include:

- 16× Oversampling Receiver
- Parity Support
- Configurable Stop Bits
- Configurable Data Width
- Framing Error Detection
- Overrun Error Detection
- Break Detection
- TX FIFO
- RX FIFO
- APB Interface
- AXI-Lite Interface
- SystemVerilog Assertions
- Functional Coverage
- UVM Verification Environment

---

# Tools Used

- Verilog HDL
- ModelSim
- FPGA/ASIC RTL Design Flow
- Git
- GitHub

---

# Learning Objectives

This project demonstrates:

- RTL Design
- Finite State Machine (FSM)
- Shift Registers
- Counters
- Serial Communication
- UART Protocol
- Testbench Development
- Digital Verification
- Loopback Testing

---

# License

This project is released under the MIT License.

---

# Author

Developed by **VELMURUGAN R** as part of a Digital Design and RTL Design learning journey focused on FPGA, ASIC Design, and Design Verification.
