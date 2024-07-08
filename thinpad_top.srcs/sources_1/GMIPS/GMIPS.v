/*
 * File: e:\NSCSCC\2024175\thinpad_top.srcs\sources_1\GMIPS\GMIPS.v
 * Project: e:\NSCSCC\2024175\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-05 10:37:43
 * Author: Tommy Gong
 * ----------------------------------------------------
 * Last Modified: 2024-07-08 10:19:25
 * Modified By: Tommy Gong
 * ----------------------------------------------------
 */



module GMIPS (
    input wire clk,
    input wire reset,

    //将指令交给RamCtrl，读取
    output wire [31:0] inst_addr_out,
    output wire        inst_en_out,
    inout  wire [31:0] inst_in,   //获取到的指令

    //
    input  wire [31:0] ram_data_in,
    output wire [31:0] ram_addr_out,
    output wire [31:0] ram_data_out,
    output wire        ram_wen,
    output wire [ 3:0] ram_seln,
    output wire        ram_cen,       //存储器使能

    input wire [1:0] state
);

  wire        stall;
  wire [31:0] branch_address_i;
  wire        branch_flag_i;
  
  IF instruction_fetch (
      .clk             (clk),
      .reset           (reset),
      .branch_flag_i   (branch_flag_i),
      .branch_address_i(branch_address_i),
      .stall           (stall),
      
      .inst_en_out     (inst_en_out),
      .inst_addr       (inst_addr_out)
  );

  ID instruction_decode (
    .clk (clk),
    .reset (reset),
    .inst(inst_in),
    .

  

  
endmodule
