/*
 * File: e:\NSCSCC\2024175\thinpad_top.srcs\sources_1\GMIPS\GMIPS.v
 * Project: e:\NSCSCC\2024175\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-05 10:37:43
 * Author: Tommy Gong
 * ----------------------------------------------------
 * Last Modified: 2024-07-12 10:42:01
 * Modified By: Tommy Gong
 * ----------------------------------------------------
 */



module GMIPS (
    input wire clk,
    input wire rst,


    output wire [31:0] rom_addr_o,
    output wire        rom_ce_o,
    input  wire [31:0] inst_i,

    input  wire [31:0] ram_data_i,
    output wire [31:0] ram_addr_o,
    output wire [31:0] ram_data_o,
    output wire        ram_we_n,
    output wire [ 3:0] ram_sel_n,
    output wire        ram_ce_o,

    input wire [1:0] state
);
  wire [31:0] mem_addr_o;
  wire [31:0] branch_address_i;
  wire        branch_flag_i;

  wire        stall;

  IF instruction_fetch (
      .clk             (clk),
      .reset           (reset),
      .branch_flag_i   (branch_flag_i),
      .branch_address_i(branch_address_i),
      .stall           (stall),

      .pc(rom_addr_o),
      .ce(rom_ce_o)
  );

  wire [31:0] id_pc;
  
  wire [31:0] id_inst;

  stage1 stage1 (
      .clk(clk),
      .rst(rst),

      .if_pc  (rom_addr_o),
      .if_inst(inst_i),
      .id_pc  (id_pc),
      .id_inst(id_inst),

      .stall(stall)
  );


  wire [ 4:0] wb_waddr_i;
  wire [31:0] wb_wdata_i;
  wire        wb_we_i;

  wire [ 4:0] reg_raddr_1_i;
  wire        reg_re_1_i;
  wire [31:0] reg_wdata_1_o;

  wire [ 4:0] reg_raddr_2_i;
  wire        reg_re_2_i;
  wire [31:0] reg_wdata_2_o;

  wire [31:0] last_store_addr;
  wire [31:0] last_store_data;
  wire        stallreq_from_id;


  regfile regfile_1 (
      .rst(rst),
      .clk(clk),

      .we   (wb_we_i),
      .waddr(wb_waddr_i),
      .wdata(wb_wdata_i),

      .re_1   (reg_re_1_i),
      .raddr_1(reg_raddr_1_i),
      .rdata_1(reg_wdata_1_o),

      .re_2   (reg_re_2_i),
      .raddr_2(reg_raddr_2_i),
      .rdata_2(reg_wdata_2_o)
  );


  wire [ 5:0] id_aluop_o;

  wire [31:0] id_reg_1_o;
  wire [31:0] id_reg_2_o;

  wire [ 4:0] id_waddr_o;
  wire        id_we_o;

  wire [31:0] ex_wdata_o;
  wire [ 4:0] ex_waddr_o;
  wire        ex_we_o;
  wire [ 3:0] mem_op;
  wire [31:0] id_link_addr_o;

  wire        mem_we_o;
  wire [ 4:0] mem_waddr_o;
  wire [31:0] mem_wdata_o;

  wire [31:0] id_inst_o;

  wire        this_inst_is_load;

  ID instruction_decode (
      .reset(rst),
      .clk(clk),

      .pc(id_pc),
      .inst (id_inst),

      .r_addr_1(reg_raddr_1_i),
      .r_e_1   (reg_re_1_i),

      .r_addr_2(reg_raddr_2_i),
      .r_e_2   (reg_re_2_i),

      .r_data_1(reg_wdata_1_o),
      .r_data_2(reg_wdata_2_o),

      .aluop(id_aluop_o),

      .reg_1(id_reg_1_o),
      .reg_2(id_reg_2_o),

      .w_addr(id_waddr_o),
      .w_e   (id_we_o),
      .w_data(id_inst_o),

      .ex_we_i   (ex_we_o),
      .ex_waddr_i(ex_waddr_o),
      .ex_wdata_i(ex_wdata_o),

      .mem_we_i   (mem_we_o),
      .mem_waddr_i(mem_waddr_o),
      .mem_wdata_i(mem_wdata_o),

      .last_store_addr(last_store_addr),
      .last_store_data(last_store_data),
      .ex_load_addr   (mem_addr_o),

      .state(state),

      .branch_flag_o   (pc_branch_flag_i),
      .branch_address_o(pc_branch_address_i),
      .link_addr_o     (id_link_addr_o),

      .pre_inst_is_load(this_inst_is_load),

      .stallreq(stallreq_from_id)

  );


  wire [ 5:0] id_ex_aluop_o;

  wire [31:0] id_ex_reg_1_o;
  wire [31:0] id_ex_reg_2_o;

  wire [ 4:0] id_ex_waddr_o;
  wire        id_ex_we_o;

  wire [31:0] id_ex_link_addr_o;

  wire [31:0] id_ex_inst_o;
  wire [31:0] id_ex_pc_o;

  stage2 stage2 (
      .rst(rst),
      .clk(clk),

      .id_pc   (id_pc),
      .id_aluop(id_aluop_o),

      .id_reg_1(id_reg_1_o),
      .id_reg_2(id_reg_2_o),

      .id_waddr(id_waddr_o),
      .id_we   (id_we_o),
      .id_inst (id_inst_o),

      .ex_pc   (id_ex_pc_o),
      .ex_aluop(id_ex_aluop_o),

      .ex_reg_1(id_ex_reg_1_o),
      .ex_reg_2(id_ex_reg_2_o),

      .ex_waddr(id_ex_waddr_o),
      .ex_we   (id_ex_we_o),
      .ex_inst (id_ex_inst_o),

      .id_link_addr(id_link_addr_o),
      .ex_link_addr(id_ex_link_addr_o),

      .stall(stall)
  );


  wire [31:0] mem_data_o;

  wire        stallreq_from_baseram;

  EX EXECUTE (
      .reset(rst),

      .aluop(id_ex_aluop_o),

      .reg_1(id_ex_reg_1_o),
      .reg_2(id_ex_reg_2_o),

      .waddr(id_ex_waddr_o),
      .we   (id_ex_we_o),
      .inst (id_ex_inst_o),
      .ex_pc(id_ex_pc_o),

      .link_addr(id_ex_link_addr_o),

      .mem_op           (mem_op),
      .mem_addr_o       (mem_addr_o),
      .mem_data_o       (mem_data_o),
      .this_inst_is_load(this_inst_is_load),

      .wdata_o(ex_wdata_o),
      .waddr_o(ex_waddr_o),
      .we_o   (ex_we_o)
  );


  wire        ex_mem_we_o;
  wire [ 4:0] ex_mem_waddr_o;
  wire [31:0] ex_mem_wdata_o;
  wire [31:0] ex_mem_pc_o;

  wire [ 3:0] mem_mem_op;
  wire [31:0] mem_mem_addr_o;
  wire [31:0] mem_mem_data_o;

  stage3 stage3 (
      .rst(rst),
      .clk(clk),

      .ex_pc   (id_ex_pc_o),
      .ex_we   (ex_we_o),
      .ex_waddr(ex_waddr_o),
      .ex_wdata(ex_wdata_o),

      .ex_mem_op  (mem_op),
      .ex_mem_addr(mem_addr_o),
      .ex_mem_data(mem_data_o),

      .mem_pc      (ex_mem_pc_o),
      .mem_mem_op  (mem_mem_op),
      .mem_mem_addr(mem_mem_addr_o),
      .mem_mem_data(mem_mem_data_o),

      .mem_we   (ex_mem_we_o),
      .mem_waddr(ex_mem_waddr_o),
      .mem_wdata(ex_mem_wdata_o),

      .last_store_addr(last_store_addr),
      .last_store_data(last_store_data)
  );


  MEM MEM_1 (
      .rst(rst),
      .clk(clk),

      .mem_pc    (ex_mem_pc_o),
      .we_i   (ex_mem_we_o),
      .waddr_i(ex_mem_waddr_o),
      .wdata_i(ex_mem_wdata_o),

      .mem_op    (mem_mem_op),
      .mem_addr_i(mem_mem_addr_o),
      .mem_data_i(mem_mem_data_o),

      .we_o   (mem_we_o),
      .waddr_o(mem_waddr_o),
      .wdata_o(mem_wdata_o),

      .mem_addr_o(ram_addr_o),
      .mem_data_o(ram_data_o),
      .mem_we_n  (ram_we_n),    // 是否为写操作

      .mem_sel_n(ram_sel_n),
      .mem_ce_o (ram_ce_o),   // 使能信号

      .ram_data_i(ram_data_i),  // 来自存储器

      .stallreq(stallreq_from_baseram)
  );

  stage4 stage4 (
      .clk(clk),
      .rst(rst),

      .stall(stall),

      .mem_waddr(mem_waddr_o),
      .mem_we   (mem_we_o),
      .mem_wdata(mem_wdata_o),

      .wb_waddr(wb_waddr_i),
      .wb_we   (wb_we_i),
      .wb_wdata(wb_wdata_i)
  );

  stall stall_m (
      .rst                  (rst),
      .stallreq_from_id     (stallreq_from_id),
      .stallreq_from_baseram(stallreq_from_baseram),
      .stall                (stall)
  );
endmodule
