/*
 * @Author: TommyGong 
 * @Date: 2024-07-05 10:58:16 
 * @Last Modified by: TommyGong
 * @Last Modified time: 2024-07-05 11:17:14
 */

module GMIPS (
    input wire clk,
    input wire reset,

    output wire [31:0] rom_addr_out,
    output wire        rom_ce_n,
    inout  wire [31:0] inst,

    input  wire [31:0] ram_data_in,
    output wire [31:0] ram_addr_out,
    output wire [31:0] ram_data_out,
    output wire        ram_wen,
    output wire [ 3:0] ram_seln,
    output wire        ram_cen,       //存储器使能

    input wire [1:0] state
);



endmodule
