/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\MEM.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-10 10:18:31
 * Author:       Tommy Gong
 * description:  
 * ----------------------------------------------------
 * Last Modified: 2024-07-10 10:21:46
 */

module MEM (
    input wire rst,
    input wire clk,

    //来自ex阶段的信息
    input wire [31:0] mem_pc,
    input wire        we_i,
    input wire [ 4:0] waddr_i,
    input wire [31:0] wdata_i,

    input wire [ 3:0] mem_op,
    input wire [31:0] mem_addr_i,
    input wire [31:0] mem_data_i,

    //送往wb阶段的信息
    output reg        we_o,
    output reg [ 4:0] waddr_o,
    output reg [31:0] wdata_o,

    //送到数据存储器的信息
    //LB,LW,SB,SW
    output reg [31:0] mem_addr_o,
    output reg [31:0] mem_data_o,
    output reg        mem_we_n,    //读使能，低有效
    //LB,SB
    output reg [ 3:0] mem_sel_n,   //字节选择信号，低有效
    output reg        mem_ce_o,    //是否可以访问存储器

    //从数据存储器读取的信息（LB,LW）
    input wire [31:0] ram_data_i,

    output wire stallreq

);

  assign stallreq = (mem_addr_i >= 32'h80000000) && (mem_addr_i < 32'h80400000);


  always @(*) begin
    if (rst == 1'b1) begin
      we_o       = 1'b0;
      waddr_o    = 5'b00000;
      wdata_o    = 32'h00000000;

      mem_addr_o = 32'h00000000;
      mem_data_o = 32'h00000000;
      mem_we_n   = 1'b1;
      mem_sel_n  = 4'b1111;
      mem_ce_o   = 1'b0;
    end else begin
      we_o    = we_i;
      waddr_o = waddr_i;
    end
    case (mem_op)
      4'b0001: begin  //LB
        wdata_o    = ram_data_i;
        mem_addr_o = mem_addr_i;
        mem_data_o = 32'h00000000;
        mem_we_n   = 1'b1;
        mem_ce_o   = 1'b1;
        case (mem_addr_i[1:0])
          2'b00: begin
            mem_sel_n = 4'b1110;
          end
          2'b01: begin
            mem_sel_n = 4'b1101;
          end
          2'b10: begin
            mem_sel_n = 4'b1011;
          end
          2'b11: begin
            mem_sel_n = 4'b0111;
          end
          default: begin
            mem_sel_n = 4'b1111;
          end
        endcase
      end
      4'b0010: begin  //LW
        wdata_o    = ram_data_i;
        mem_addr_o = mem_addr_i;
        mem_data_o = 32'h00000000;
        mem_we_n   = 1'b1;
        mem_ce_o   = 1'b1;
        mem_sel_n  = 4'b0000;
      end
      4'b0011: begin  //SB
        wdata_o    = 32'h00000000;
        mem_addr_o = mem_addr_i;
        mem_data_o = {4{mem_data_i[7:0]}};  //低字节存储到指定位置
        mem_we_n   = 1'b0;
        mem_ce_o   = 1'b1;
        case (mem_addr_i[1:0])
          2'b00: begin
            mem_sel_n = 4'b1110;
          end
          2'b01: begin
            mem_sel_n = 4'b1101;
          end
          2'b10: begin
            mem_sel_n = 4'b1011;
          end
          2'b11: begin
            mem_sel_n = 4'b0111;
          end
          default: begin
            mem_sel_n = 4'b1111;
          end
        endcase
      end
      4'b0100: begin  //SW
        wdata_o    = 32'h00000000;
        mem_addr_o = mem_addr_i;
        mem_data_o = mem_data_i;
        mem_we_n   = 1'b0;
        mem_ce_o   = 1'b1;
        mem_sel_n  = 4'b0000;
      end
      default: begin
        wdata_o    = wdata_i;
        mem_addr_o = 32'h00000000;
        mem_data_o = 32'h00000000;
        mem_we_n   = 1'b1;
        mem_ce_o   = 1'b0;
        mem_sel_n  = 4'b1111;
      end
    endcase
  end

endmodule
