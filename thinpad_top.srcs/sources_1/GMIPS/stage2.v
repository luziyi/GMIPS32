/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\stage2.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-12 09:59:21
 * Author:       Tommy Gong
 * description:  
 * ----------------------------------------------------
 * Last Modified: 2024-07-12 10:01:06
 */

module stage2 (
    input wire rst,
    input wire clk,

    input wire [5:0] id_aluop,

    input wire [31:0] id_reg_1,
    input wire [31:0] id_reg_2,

    input wire [ 4:0] id_waddr,
    input wire        id_we,
    input wire [31:0] id_inst,
    input wire [31:0] id_pc,

    output reg [5:0] ex_aluop,

    output reg [31:0] ex_reg_1,
    output reg [31:0] ex_reg_2,

    output reg [ 4:0] ex_waddr,
    output reg        ex_we,
    output reg [31:0] ex_inst,
    output reg [31:0] ex_pc,

    input  wire [31:0] id_link_addr,
    output reg  [31:0] ex_link_addr,

    input wire stall
);

  always @(posedge clk) begin
    if (rst == 1'b1) begin
      ex_aluop     <= 6'b000000;
      ex_reg_1     <= 32'h00000000;
      ex_reg_2     <= 32'h00000000;
      ex_waddr     <= 5'b00000;
      ex_we        <= 1'b0;
      ex_inst      <= 32'h00000000;
      ex_pc        <= 32'h00000000;
      ex_link_addr <= 32'h00000000;
    end else if (stall == 1'b1) begin
      ex_aluop     <= 6'b000000;
      ex_reg_1     <= 32'h00000000;
      ex_reg_2     <= 32'h00000000;
      ex_waddr     <= 5'b00000;
      ex_we        <= 1'b0;
      ex_inst      <= 32'h00000000;
      ex_pc        <= 32'h00000000;
      ex_link_addr <= 32'h00000000;
    end else begin
      ex_aluop     <= id_aluop;
      ex_reg_1     <= id_reg_1;
      ex_reg_2     <= id_reg_2;
      ex_waddr     <= id_waddr;
      ex_we        <= id_we;
      ex_inst      <= id_inst;
      ex_pc        <= id_pc;
      ex_link_addr <= id_link_addr;
    end
  end

endmodule
