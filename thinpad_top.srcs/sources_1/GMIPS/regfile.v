/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\regfile.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-04 16:23:24
 * Author:       Tommy Gong
 * description:  寄存器文件，32*32位
 * ----------------------------------------------------
 * Last Modified: 2024-07-10 10:32:22
 */

module regfile(
    input wire clk,
    input wire rst,

    //mem阶段传递的参数
    input wire        we,
    input wire [ 4:0] waddr,
    input wire [31:0] wdata,

    //id阶段传递的参数及取得的信息
    input  wire        re_1,
    input  wire [ 4:0] raddr_1,
    output reg  [31:0] rdata_1,

    input  wire        re_2,
    input  wire [ 4:0] raddr_2,
    output reg  [31:0] rdata_2
);

  reg     [31:0] regs[0:31];  // 32个32位通用寄存器

  integer        i;

  //写入操作（本模块相当于wb阶段）
  always @(posedge clk) begin
    if (rst == 1'b1) begin
      for (i = 0; i < 32; i = i + 1) begin
        regs[i] <= 32'h00000000;
      end
    end else begin
      if (we == 1'b1 && waddr != 5'b00000) begin
        regs[waddr] <= wdata;  //0号寄存器不可写入
      end
    end
  end

  //读端口1 组合逻辑
  always @(*) begin
    if (rst == 1'b1) begin
      rdata_1 = 32'h00000000;
    end else begin
      if (re_1 == 1'b1) begin
        if (raddr_1 == 5'b00000) begin
          rdata_1 = 32'h00000000;
        end else if (raddr_1 == waddr && we == 1'b1) begin
          rdata_1 = wdata;  //处理数据冒险
        end else begin
          rdata_1 = regs[raddr_1];
        end
      end else begin
        rdata_1 = 32'h00000000;
      end
    end
  end

  //读端口2 组合逻辑
  always @(*) begin
    if (rst == 1'b1) begin
      rdata_2 = 32'h00000000;
    end else begin
      if (re_2 == 1'b1) begin
        if (raddr_2 == 5'b00000) begin
          rdata_2 = 32'h00000000;
        end else if (raddr_2 == waddr && we == 1'b1) begin
          rdata_2 = wdata;  //处理数据冒险
        end else begin
          rdata_2 = regs[raddr_2];
        end
      end else begin
        rdata_2 = 32'h00000000;
      end
    end
  end
endmodule
