/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\EX.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-10 09:47:51
 * Author:       Tommy Gong
 * description:  
 * ----------------------------------------------------
 * Last Modified: 2024-07-10 10:10:11
 */

module EX (
    input wire reset,

    //从id阶段获得的信息
    input wire [5:0] aluop,

    input wire [31:0] reg_1,
    input wire [31:0] reg_2,

    input wire [ 4:0] waddr,
    input wire        we,
    input wire [31:0] inst,
    input wire [31:0] ex_pc,

    //分支跳转存储
    input wire [31:0] link_addr,

    //送往mem阶段的信息
    output reg  [ 3:0] mem_op,            //存储类型,同时要送往id阶段以判断load相关
    output reg  [31:0] mem_addr_o,        //存储地址
    output reg  [31:0] mem_data_o,        //存储数据
    output wire        this_inst_is_load,

    //送往wb阶段的信息
    output reg [31:0] wdata_o,
    output reg [ 4:0] waddr_o,  //同时要送往id阶段以判断load相关
    output reg        we_o
);
  assign this_inst_is_load = (aluop == 6'b001110) | (aluop == 6'b001111);

  //执行阶段
  always @(*) begin
    if (reset == 1'b1) begin
      wdata_o = 32'h00000000;
      waddr_o = 5'b00000;
      we_o    = 1'b0;
    end else begin
      wdata_o = 32'h00000000;
      waddr_o = waddr;
      we_o    = we;
      case (aluop)
        6'b000001: begin
          wdata_o = reg_1 & reg_2;
        end
        6'b000010: begin
          wdata_o = reg_1 | reg_2;
        end
        6'b000011: begin
          wdata_o = reg_1 ^ reg_2;
        end
        6'b000100: begin
          wdata_o = ~(reg_1 | reg_2);
        end

        6'b000101: begin
          wdata_o = reg_2 << reg_1[4:0];
        end
        6'b000110: begin
          wdata_o = reg_2 >> reg_1[4:0];
        end
        6'b000111: begin
          wdata_o = ($signed(reg_2)) >>> reg_1[4:0];
        end
        6'b001000: begin
          wdata_o = ($signed(reg_1) < $signed(reg_2)) ? 1 : 0;
        end
        6'b001001: begin
          wdata_o = (reg_1 < reg_2) ? 1 : 0;
        end
        6'b001010: begin
          wdata_o = reg_1 + reg_2;
        end
        6'b001011: begin
          wdata_o = reg_1 + (~reg_2) + 1;
        end
        6'b001100: begin
          wdata_o = reg_1 * reg_2;  //无符号乘法代替有符号乘法
        end
        6'b001101: begin
          wdata_o = link_addr;
        end
      endcase
    end
  end

  //送往mem阶段的信息

  wire [31:0] imm_s = {{16{inst[15]}}, inst[15:0]};

  always @(*) begin
    if (reset == 1'b1) begin
      mem_op     = 4'b0000;
      mem_addr_o = 32'h00000000;
      mem_data_o = 32'h00000000;
    end else begin
      case (aluop)
        6'b001110: begin
          mem_op     = 4'b0001;
          mem_addr_o = reg_1 + imm_s;
          mem_data_o = 32'h00000000;
        end
        6'b001111: begin
          mem_op     = 4'b0010;
          mem_addr_o = reg_1 + imm_s;
          mem_data_o = 32'h00000000;
        end
        6'b010000: begin
          mem_op     = 4'b0011;
          mem_addr_o = reg_1 + imm_s;
          mem_data_o = reg_2;
        end
        6'b010001: begin
          mem_op     = 4'b0100;
          mem_addr_o = reg_1 + imm_s;
          mem_data_o = reg_2;
        end
        default: begin
          mem_op     = 4'b0000;
          mem_addr_o = 32'h00000000;
          mem_data_o = 32'h00000000;
        end
      endcase
    end
  end




endmodule
