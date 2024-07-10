/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\ID.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-05 16:16:38
 * Author:       Tommy Gong
 * description:  
 * ----------------------------------------------------
 * Last Modified: 2024-07-10 09:45:04
 */

module ID (
    input wire clk,
    input wire reset,

    input wire [31:0] inst,
    input wire [31:0] pc,

    output reg  [ 4:0] r_addr_1,
    output reg         r_e_1,
    input  wire [31:0] r_data_1,

    output reg  [ 4:0] r_addr_2,
    output reg         r_e_2,
    input  wire [31:0] r_data_2,

    output reg [31:0] reg_1,
    output reg [31:0] reg_2,

    output reg [31:0] w_addr,
    output reg [31:0] w_data,
    output reg        w_e,

    output reg [5:0] aluop,

    output reg  [31:0] link_addr_o,
    output reg         branch_flag_o,
    output reg  [31:0] branch_address_o,
    //
    input  wire        ex_we_i,
    input  wire [ 4:0] ex_waddr_i,
    input  wire [31:0] ex_wdata_i,

    input wire        mem_we_i,
    input wire [ 4:0] mem_waddr_i,
    input wire [31:0] mem_wdata_i,

    input wire [31:0] last_store_addr,
    input wire [31:0] last_store_data,
    input wire [31:0] ex_load_addr,

    input  wire [1:0] state,             //串口状态
    //
    input  wire       pre_inst_is_load,
    output wire       stallreq           //暂停信号
);


  reg                                                       stallreq_for_reg1_loadrelate;
  reg                                                       stallreq_for_reg2_loadrelate;

  reg  [31:0]                                               imm_o;

  wire [ 5:0] op = inst[31:26];
  wire [ 4:0] rs = inst[25:21];
  wire [ 4:0] rt = inst[20:16];
  wire [ 4:0] rd = inst[15:11];
  wire [ 4:0] shamt = inst[10:6];
  wire [ 5:0] func = inst[5:0];


  wire [15:0] imm = inst[15:0];

  wire [25:0] j_addr = inst[25:0];

  wire [31:0] imm_u = {{16{1'b0}}, imm};
  wire [31:0] imm_s = {{16{imm[15]}}, imm};

  wire [31:0] next_pc = pc + 4'h4;

  wire [31:0] jump_addr = {next_pc[31:28], j_addr, 2'b00};
  wire [31:0] branch_addr = next_pc + {imm_s[29:0], 2'b00};

  always @(*) begin
    if (reset == 1'b1) begin
      aluop    = 6'b000000;
      r_e_1    = 1'b0;
      r_addr_1 = 5'b00000;
      r_e_2    = 1'b0;
      r_addr_2 = 5'b00000;
      w_e      = 1'b0;
      w_addr   = 5'b00000;
      imm_o    = 32'h00000000;
    end else begin
      aluop    = 6'b000000;
      r_e_1    = 1'b0;
      r_addr_1 = rs;
      r_e_2    = 1'b0;
      r_addr_2 = rt;
      w_e      = 1'b0;
      w_addr   = rd;
      imm_o    = 32'h00000000;
    end

    case (op)
      6'b001111: begin  //OR
        aluop  = 6'b000010;
        r_e_1  = 1'b1;
        r_e_2  = 1'b0;
        w_e    = 1'b1;
        w_addr = rt;
        imm_o  = {imm, 16'h0000};
      end

      6'b001101: begin  //ORI
        aluop  = 6'b000010;
        r_e_1  = 1'b1;
        r_e_2  = 1'b0;
        w_e    = 1'b1;
        w_addr = rt;
        imm_o  = imm_u;
      end

      6'b001111: begin  //LUI
        aluop  = 6'b000010;
        r_e_1  = 1'b1;
        r_e_2  = 1'b0;
        w_e    = 1'b1;
        w_addr = rt;
        imm_o  = {imm, 16'h0000};
      end

      6'b000101: begin  //BNE
        r_e_1 = 1'b1;
        r_e_2 = 1'b1;
        w_e   = 1'b0;
      end

      6'b100011: begin  //LW
        aluop  = 6'b001111;
        r_e_1  = 1'b1;
        r_e_2  = 1'b0;
        w_e    = 1'b1;
        w_addr = rt;
        imm_o  = imm_s;
      end

      6'b101011: begin
        aluop = 6'b010001;
        r_e_1 = 1'b1;
        r_e_2 = 1'b1;
        w_e   = 1'b0;
      end



      6'b000000: begin  //R型指令
        if (shamt == 5'b00000) begin
          case (func)
            6'b100001, 6'b100000: begin  //ADDU, ADD
              aluop = 6'b001010;
              r_e_1 = 1'b1;
              r_e_2 = 1'b1;
              w_e   = 1'b1;
            end

            default: begin
            end
          endcase
        end
      end



      default: begin
      end
    endcase
  end

  //确定是否跳转及跳转地址
  always @(*) begin
    if (reset == 1'b1) begin
      branch_flag_o    = 1'b0;
      branch_address_o = 32'h00000000;
      link_addr_o      = 32'h00000000;
    end else begin
      branch_flag_o    = 1'b0;
      branch_address_o = 32'h00000000;
      link_addr_o      = 32'h00000000;
    end
    case (op)

      6'b000101: begin
        if (reg_1 != reg_2) begin
          branch_flag_o    = 1'b1;
          branch_address_o = branch_addr;
        end else begin
        end
      end

      default: begin
        branch_flag_o    = 1'b0;
        branch_address_o = 32'h00000000;
        link_addr_o      = 32'h00000000;
      end
    endcase
  end


  //读取操作数1
  always @(*) begin
    reg_1                        = 32'h00000000;
    stallreq_for_reg1_loadrelate = 1'b0;
    if (reset == 1'b1) begin
      reg_1 = 32'h00000000;
    end else if (pre_inst_is_load && ex_waddr_i == r_addr_1 && r_e_1 == 1'b1 && ex_load_addr == last_store_addr) begin
      reg_1 = last_store_data;
      //发生load冒险需要暂停流水线
    end else if (pre_inst_is_load && ex_waddr_i == r_addr_1 && r_e_1 == 1'b1) begin
      stallreq_for_reg1_loadrelate = 1'b1;
      //ex阶段的数据直通
    end else if (r_e_1 == 1'b1 && ex_we_i == 1'b1 && ex_waddr_i == r_addr_1) begin
      reg_1 = ex_wdata_i;
      //mem阶段的数据直通
    end else if (r_e_1 == 1'b1 && mem_we_i == 1'b1 && mem_waddr_i == r_addr_1) begin
      reg_1 = mem_wdata_i;
      //正常情况
    end else if (r_e_1 == 1'b1) begin
      reg_1 = r_data_1;
    end else if (r_e_1 == 1'b0) begin
      reg_1 = imm_o;
    end else begin
      reg_1 = 32'h00000000;
    end
  end

  //确定操作数2
  always @(*) begin
    reg_2                        = 32'h00000000;
    stallreq_for_reg2_loadrelate = 1'b0;
    if (reset == 1'b1) begin
      reg_2 = 32'h00000000;
    end else if (pre_inst_is_load && ex_waddr_i == r_addr_2 && r_e_2 == 1'b1 && ex_load_addr == last_store_addr) begin
      reg_2 = last_store_data;
      //发生load冒险需要暂停流水线
    end else if (pre_inst_is_load && ex_waddr_i == r_addr_2 && r_e_2 == 1'b1) begin
      stallreq_for_reg2_loadrelate = 1'b1;
      //ex阶段的数据直通
    end else if (r_e_2 == 1'b1 && ex_we_i == 1'b1 && ex_waddr_i == r_addr_2) begin
      reg_2 = ex_wdata_i;
      //mem阶段的数据直通
    end else if (r_e_2 == 1'b1 && mem_we_i == 1'b1 && mem_waddr_i == r_addr_2) begin
      reg_2 = mem_wdata_i;
      //正常情况
    end else if (r_e_2 == 1'b1) begin
      reg_2 = r_data_2;
    end else if (r_e_2 == 1'b0) begin
      reg_2 = imm_o;
    end else begin
      reg_2 = 32'h00000000;
    end
  end


  //流水线暂停
  assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;

endmodule
