/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\MemCtrl.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-06 09:41:23
 * Author:       Tommy Gong
 * description:  ExtRam和baseRam的控制模块,负责指令读取和数据写入工作
 * ----------------------------------------------------
 * Last Modified: 2024-07-17 16:11:53
 */
module RamCtrl (
    input [31:0] PC,
    input [31:0] MEM_MemWriteAddr,
    input [ 1:0] MEM_MemWriteEn,
    input [ 1:0] MEM_MemReadEn,
    input        is_using_uart,

    output reg       IF_SRAM_stall,  //指令存储器正在MEM级中被需要，此时需让IF级阻塞
    output reg [2:0] SRAMCtrl        //第2位为1时表示MEM级需要操作RAM，第1位代表IF级正在取指的sram，第0位代表MEM级正在写入或读取的sram
                                     //0表示正在操作的是BaseRam，1表示正在操作的是ExtRam，如10表示IF使用ExtRam，MEM使用BaseRam
);

  always @(PC, MEM_MemWriteAddr, MEM_MemWriteEn, MEM_MemReadEn) begin
    if (MEM_MemWriteEn || MEM_MemReadEn) begin
      if (PC < 32'h80400000) begin
        if (MEM_MemWriteAddr < 32'h80400000 && MEM_MemWriteAddr > 32'h80000000) begin
          IF_SRAM_stall <= 1;
          SRAMCtrl      <= 3'b100;  //IF和MEM都需要操作BaseRam，此时阻塞IF级
        end else begin
          IF_SRAM_stall <= !is_using_uart;
          SRAMCtrl      <= 3'b101;
        end
      end else if (PC < 32'h80800000) begin
        if (MEM_MemWriteAddr < 32'h80400000 && MEM_MemWriteAddr > 32'h80000000) begin
          IF_SRAM_stall <= 0;
          SRAMCtrl      <= 3'b110;
        end else begin
          IF_SRAM_stall <= !is_using_uart;
          SRAMCtrl      <= 3'b111;
        end
      end else begin
        IF_SRAM_stall <= 1;  //PC越界
        SRAMCtrl      <= 3'b000;
      end
    end else begin
      if (PC < 32'h80400000) begin
        IF_SRAM_stall <= 0;
        SRAMCtrl      <= 3'b000;
      end else if (PC < 32'h80800000) begin
        IF_SRAM_stall <= 0;
        SRAMCtrl      <= 3'b010;
      end else begin
        IF_SRAM_stall <= 1;
        SRAMCtrl      <= 3'b000;
      end
    end
  end
endmodule
