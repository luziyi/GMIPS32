/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\IF.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-05 11:07:27
 * Author:       Tommy Gong
 * description:  pc控制器
 * ----------------------------------------------------
 * Last Modified: 2024-07-17 15:26:36
 */

`define StartAddr 32'h80000000
module IF (
    input             clk,
    input             rst_n,
    input             ID_stall,
    input      [31:0] Instr,
    input      [31:0] ID_nextPC,
    output     [31:0] IF_PC_WIRE,
    output reg [31:0] IF_PC,
    output reg [31:0] IF_Instr,

    input IF_SRAM_stall
);
  reg  [31:0] IF_nextPC;
  wire [31:0] nextPC;

  assign nextPC     = ID_nextPC;
  assign IF_PC_WIRE = IF_nextPC;

  always @(posedge clk) begin
    if (rst_n) begin
      IF_nextPC <= `StartAddr;
      IF_PC     <= 0;
      IF_Instr  <= 0;
    end else if (ID_stall || IF_SRAM_stall) begin
      IF_PC     <= IF_PC;
      IF_nextPC <= IF_nextPC;
      IF_Instr  <= IF_Instr;
    end else begin
      IF_PC     <= IF_nextPC;
      IF_nextPC <= nextPC;
      IF_Instr  <= Instr;
    end
  end

endmodule
