/*
 * File: e:\NSCSCC\2024175\thinpad_top.srcs\sources_1\GMIPS\IF.v
 * Project: e:\NSCSCC\2024175\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-05 11:07:27
 * Author: Tommy Gong
 * ----------------------------------------------------
 * Last Modified: 2024-07-05 16:34:58
 * Modified By: Tommy Gong
 * ----------------------------------------------------
 */

include "defines.v";
module IF (
    input  wire        clk,
    input  wire        reset,
    input  wire        branch_flag_i,
    input  wire        branch_address_i,
    input  wire        stall,             //暂停信号
    output reg  [31:0] pc,                //指令地址
    output reg         ce
);

  always @(posedge clk) begin  //同步复位
    if (reset == `RstEnable) begin
      ce <= `ChipDisable;
    end else begin
      ce <= `ChipEnable;
    end
  end

  always @(posedge clk) begin
    if (ce == `ChipDisable) begin
      pc <= `PC_START_ADDR;
    end else if (stall == 1'b0) begin
      if (branch_flag_i) begin
        pc <= branch_address_i;
      end else begin
        pc <= pc + 4'h4;
      end
    end
  end

endmodule
