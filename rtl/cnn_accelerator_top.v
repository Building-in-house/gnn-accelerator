/***************************/
// Created June 8th, 2025
/***************************/

module cnn_accel_top (
    input  wire        clk,
    input  wire        reset,

    // interface for tilelink in rocket chip
    input  wire        mmio_write_en,
    input  wire        mmio_read_en,
    input  wire [31:0] mmio_addr,
    input  wire [31:0] mmio_wdata,
    output reg  [31:0] mmio_rdata,

    output wire        intr  // interrupt to RocketChip
);



endmodule