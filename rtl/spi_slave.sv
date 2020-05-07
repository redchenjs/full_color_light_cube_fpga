/*
 * spi_slave.sv
 *
 *  Created on: 2020-04-06 23:07
 *      Author: Jack Chen <redchenjs@live.com>
 */

module spi_slave(
    input logic clk_in,
    input logic rst_n_in,

    input logic spi_sclk_in,
    input logic spi_mosi_in,
    input logic spi_cs_n_in,

    output logic byte_rdy_out,
    output logic [7:0] byte_data_out
);

logic spi_cs;
logic spi_sclk;
logic [2:0] bit_sel;

wire byte_done = (bit_sel == 3'd7);
wire spi_rst_n = rst_n_in & spi_cs;

rst_sync spi_cs_sync(
    .clk_in(clk_in),
    .rst_n_in(~spi_cs_n_in),
    .rst_n_out(spi_cs)
);

edge_detect spi_sclk_edge(
   .clk_in(clk_in),
   .rst_n_in(spi_rst_n),
   .data_in(spi_sclk_in),
   .pos_edge_out(spi_sclk)
);

always @(posedge clk_in or negedge spi_rst_n)
begin
    if (!spi_rst_n) begin
        bit_sel <= 3'h0;

        byte_rdy_out <= 1'b0;
        byte_data_out <= 8'h00;
    end else begin
        bit_sel <= bit_sel + spi_sclk;

        byte_rdy_out <= spi_sclk & byte_done;
        byte_data_out <= spi_sclk ? {byte_data_out[6:0], spi_mosi_in} : byte_data_out;
    end
end

endmodule
