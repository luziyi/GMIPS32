/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\stage1
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-12 09:58:05
 * Author:       Tommy Gong
 * description:  
 * ----------------------------------------------------
 * Last Modified: 2024-07-12 10:01:21
 */

module stage1 (
    input wire clk,
    input wire rst,

    input wire [31:0] if_pc,
    input wire [31:0] if_inst,

    output reg [31:0] id_pc,
    output reg [31:0] id_inst,

    input wire stall  //流水线暂停
);

  always @(posedge clk) begin
    if (rst == 1'b1) begin
      id_pc   <= 32'h00000000;
      id_inst <= 32'h00000000;
    end else if (stall == 1'b0) begin
      id_pc   <= if_pc;
      id_inst <= if_inst;
    end
  end

endmodule
