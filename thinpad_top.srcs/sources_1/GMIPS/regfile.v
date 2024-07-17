/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\regfile.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-04 16:23:24
 * Author:       Tommy Gong
 * description:  寄存器文件，32*32位
 * ----------------------------------------------------
 * Last Modified: 2024-07-17 15:29:24
 */

module regfile (
    input         clk,
    input         rst_n,
    input  [ 4:0] RsID,
    input  [ 4:0] RtID,
    input  [ 4:0] RegWriteID,
    input  [31:0] RegWriteData,
    input         RegWriteEn,
    output [31:0] d_out1,
    output [31:0] d_out2
);

  reg [31:0] Reg[31:0];

  initial begin
    Reg[0] = 0;
  end

  assign d_out1 = (!RsID) ? 32'b0 :
 (RsID == RegWriteID) ? RegWriteData : Reg[RsID];

  assign d_out2 = (!RtID) ? 32'b0 :
 (RtID == RegWriteID) ? RegWriteData : Reg[RtID];

  integer i;
  always @(posedge clk) begin
    if (rst_n) begin
      for (i = 0; i < 32; i = i + 1'b1) Reg[i] = 32'b0;
    end else begin
      if (RegWriteEn && RegWriteID != 0) Reg[RegWriteID] <= RegWriteData;
    end
  end

endmodule
