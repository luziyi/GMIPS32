/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\IF.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-05 11:07:27
 * Author:       Tommy Gong
 * description:  pc控制器
 * ----------------------------------------------------
 * Last Modified: 2024-07-08 09:23:00
 */

module IF (
    input wire        clk,
    input wire        reset,
    input wire        branch_flag_i,
    input wire [31:0] branch_address_i,
    input wire        stall,             //暂停信号

    output reg [31:0] inst_addr,   //指令地址
    output reg        inst_en_out
);

  always @(posedge clk) begin  //同步复位
    if (reset == 1'b1) begin
      inst_en_out <= 1'b0;
    end else begin
      inst_en_out <= 1'b1;
    end
  end

  always @(posedge clk) begin
    if (inst_en_out == 1'b0) begin
      inst_addr <= 32'h80000000;  //pc指令起始地址
    end else if (stall == 1'b0) begin
      if (branch_flag_i) begin
        inst_addr <= branch_address_i;
      end else begin
        inst_addr <= inst_addr + 4'h4;
      end
    end
  end

endmodule
