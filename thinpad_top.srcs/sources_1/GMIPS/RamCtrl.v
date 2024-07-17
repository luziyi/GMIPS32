/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\MemCtrl.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-06 09:41:23
 * Author:       Tommy Gong
 * description:  ExtRam和baseRam的控制模块,负责指令读取和数据写入工作
 * ----------------------------------------------------
 * Last Modified: 2024-07-17 09:12:52
 */

module MemCtrl (
    input wire clk,
    input wire reset,

    //InstRAM信号
    input  wire [31:0] inst_addr_in,
    input  wire        inst_en_in,
    output reg  [31:0] inst_out,

    //BaseRAM信号
    inout  wire [31:0] base_ram_data,  //BaseRAM数据
    output reg  [19:0] base_ram_addr,  //BaseRAM地址
    output reg  [ 3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。
    output reg         base_ram_ce_n,  //BaseRAM片选，低有效
    output reg         base_ram_oe_n,  //BaseRAM读使能，低有效
    output reg         base_ram_we_n,  //BaseRAM写使能，低有效

    //ExtRAM信号
    inout  wire [31:0] ext_ram_data,  //ExtRAM数据
    output reg  [19:0] ext_ram_addr,  //ExtRAM地址
    output reg  [ 3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。
    output reg         ext_ram_ce_n,  //ExtRAM片选，低有效
    output reg         ext_ram_oe_n,  //ExtRAM读使能，低有效
    output reg         ext_ram_we_n,  //ExtRAM写使能，低有效

    //CPU与Mem的串口信号
    output reg  [31:0] mem_rdata_o,  //读取的数据
    input  wire [31:0] mem_wdata_i,  //写入的数据
    input  wire [31:0] mem_addr_i,   //地址
    input  wire        mem_we_n,     //写使能，低有效
    input  wire [ 3:0] mem_sel_n,    //字节选择信号
    input  wire        mem_ce_i,     //片选信号

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd   //直连串口接收端


);

  wire [ 7:0] RxD_data;  //接收到的数据
  wire [ 7:0] TxD_data;  //待发送的数据
  wire        RxD_data_ready;  //接收器收到数据完成之后，置为1
  wire        TxD_busy;  //发送器状态是否忙碌，1为忙碌，0为不忙碌
  wire        TxD_start;  //发送器是否可以发送数据，1代表可以发送
  wire        RxD_clear;  //为1时将清除接收标志（ready信号）

  wire        RxD_FIFO_wr_en;
  wire        RxD_FIFO_full;
  wire [ 7:0] RxD_FIFO_din;
  reg         RxD_FIFO_rd_en;
  wire        RxD_FIFO_empty;
  wire [ 7:0] RxD_FIFO_dout;

  reg         TxD_FIFO_wr_en;
  wire        TxD_FIFO_full;
  reg  [ 7:0] TxD_FIFO_din;
  wire        TxD_FIFO_rd_en;
  wire        TxD_FIFO_empty;
  wire [ 7:0] TxD_FIFO_dout;

  reg  [31:0] serial_o;  //串口输出数据
  wire [31:0] base_ram_o;  //baseram输出数据
  wire [31:0] ext_ram_o;  //extram输出数据

  async_receiver #(
      .ClkFrequency(59000000),
      .Baud(9600)
  )  //接收模块
      ext_uart_r (
      .clk           (clk),             //外部时钟信号
      .RxD           (rxd),             //外部串行信号输入
      .RxD_data_ready(RxD_data_ready),  //数据接收到标志
      .RxD_clear     (RxD_clear),       //清除接收标志
      .RxD_data      (RxD_data)         //接收到的一字节数据
  );

  async_transmitter #(
      .ClkFrequency(59000000),
      .Baud(9600)
  )  //发送模块
      ext_uart_t (
      .clk      (clk),        //外部时钟信号
      .TxD      (txd),        //串行信号输出
      .TxD_busy (TxD_busy),   //发送器忙状态指示
      .TxD_start(TxD_start),  //开始发送信号
      .TxD_data (TxD_data)    //待发送的数据
  );

  //fifo接收模块
  fifo_generator_0 RXD_FIFO (
      .rst  (reset),
      .clk  (clk),
      .wr_en(RxD_FIFO_wr_en),  //写使能
      .din  (RxD_FIFO_din),    //接收到的数据
      .full (RxD_FIFO_full),   //判满标志

      .rd_en(RxD_FIFO_rd_en),  //读使能
      .dout (RxD_FIFO_dout),   //传递给mem阶段读出的数据
      .empty(RxD_FIFO_empty)   //判空标志
  );

  //fifo发送模块
  fifo_generator_0 TXD_FIFO (
      .rst  (reset),
      .clk  (clk),
      .wr_en(TxD_FIFO_wr_en),  //写使能
      .din  (TxD_FIFO_din),    //需要发送的数据
      .full (TxD_FIFO_full),   //判满标志

      .rd_en(TxD_FIFO_rd_en),  //读使能，为1时串口取出数据发送
      .dout (TxD_FIFO_dout),   //传递给串口待发送的数据
      .empty(TxD_FIFO_empty)   //判空标志
  );


  wire is_base_addr = (mem_addr_i >= 32'h80000000) && (mem_addr_i < 32'h80400000);
  wire is_ext_addr = (mem_addr_i >= 32'h80400000) && (mem_addr_i < 32'h80800000);

  assign ext_ram_data = is_ext_addr ? ((mem_we_n == 1'b0) ? mem_wdata_i : 32'hzzzzzzzz) : 32'hzzzzzzzz;
  assign ext_ram_o    = ext_ram_data;

  always @(*) begin
    ext_ram_addr = 20'h00000;
    ext_ram_be_n = 4'b0000;
    ext_ram_ce_n = 1'b0;
    ext_ram_oe_n = 1'b1;
    ext_ram_we_n = 1'b1;
    if (is_ext_addr) begin  //涉及到extRam的相关数据操作
      ext_ram_addr = mem_addr_i[21:2];  //有对齐要求，低两位舍去
      ext_ram_be_n = mem_sel_n;
      ext_ram_ce_n = 1'b0;
      ext_ram_oe_n = !mem_we_n;
      ext_ram_we_n = mem_we_n;
    end else begin
      ext_ram_addr = 20'h00000;
      ext_ram_be_n = 4'b0000;
      ext_ram_ce_n = 1'b0;
      ext_ram_oe_n = 1'b1;
      ext_ram_we_n = 1'b1;
    end
  end

  assign base_ram_data = is_base_addr ? ((mem_we_n == 1'b0) ? mem_wdata_i : 32'hzzzzzzzz) : 32'hzzzzzzzz;
  assign base_ram_o    = base_ram_data;  //读取到的BaseRam数据

  always @(*) begin
    base_ram_addr = 20'h00000;
    base_ram_be_n = 4'b0000;
    base_ram_ce_n = 1'b0;
    base_ram_oe_n = 1'b1;
    base_ram_we_n = 1'b1;
    inst_out      = 32'h00000000;
    if (is_base_addr) begin  //需要暂停流水线
      base_ram_addr = mem_addr_i[21:2];  //有对齐要求，低两位舍去
      base_ram_be_n = mem_sel_n;
      base_ram_ce_n = 1'b0;
      base_ram_oe_n = !mem_we_n;
      base_ram_we_n = mem_we_n;
      inst_out      = 32'h00000000;
    end else begin  //继续取指令
      base_ram_addr = inst_addr_in[21:2];  //有对齐要求，低两位舍去
      base_ram_be_n = 4'b0000;
      base_ram_ce_n = 1'b0;
      base_ram_oe_n = 1'b0;
      base_ram_we_n = 1'b1;
      inst_out      = base_ram_o;
    end
  end

  wire is_SerialState = (mem_addr_i == 32'hBFD003FC);
  wire is_SerialData = (mem_addr_i == 32'hBFD003F8);

  always @(*) begin
    mem_rdata_o = 32'h00000000;
    if (is_SerialState || is_SerialData) begin
      mem_rdata_o = serial_o;
    end else if (is_base_addr) begin
      case (mem_sel_n)
        4'b1110: begin
          mem_rdata_o = {{24{base_ram_o[7]}}, base_ram_o[7:0]};
        end
        4'b1101: begin
          mem_rdata_o = {{24{base_ram_o[15]}}, base_ram_o[15:8]};
        end
        4'b1011: begin
          mem_rdata_o = {{24{base_ram_o[23]}}, base_ram_o[23:16]};
        end
        4'b0111: begin
          mem_rdata_o = {{24{base_ram_o[31]}}, base_ram_o[31:24]};
        end
        4'b0000: begin
          mem_rdata_o = base_ram_o;
        end
        default: begin
          mem_rdata_o = base_ram_o;
        end
      endcase
    end else if (is_ext_addr) begin
      case (mem_sel_n)
        4'b1110: begin
          mem_rdata_o = {{24{ext_ram_o[7]}}, ext_ram_o[7:0]};
        end
        4'b1101: begin
          mem_rdata_o = {{24{ext_ram_o[15]}}, ext_ram_o[15:8]};
        end
        4'b1011: begin
          mem_rdata_o = {{24{ext_ram_o[23]}}, ext_ram_o[23:16]};
        end
        4'b0111: begin
          mem_rdata_o = {{24{ext_ram_o[31]}}, ext_ram_o[31:24]};
        end
        4'b0000: begin
          mem_rdata_o = ext_ram_o;
        end
        default: begin
          mem_rdata_o = ext_ram_o;
        end
      endcase
    end else begin
      mem_rdata_o = 32'h00000000;
    end
  end


  //   //直连串口接收发送演示，从直连串口收到的数据再发送出去
  //   wire [7:0] ext_uart_rx;
  //   reg [7:0] ext_uart_buffer, ext_uart_tx;
  //   wire ext_uart_ready, ext_uart_clear, ext_uart_busy;
  //   reg ext_uart_start, ext_uart_avai;

  //   assign number = ext_uart_buffer;

  //   //接收模块，9600无检验位
  //   async_receiver #(
  //       .ClkFrequency(50000000),
  //       .Baud(9600)
  //   ) ext_uart_r (
  //       .clk           (clk_50M),         //外部时钟信号
  //       .RxD           (rxd),             //外部串行信号输入
  //       .RxD_data_ready(ext_uart_ready),  //数据接收到标志
  //       .RxD_clear     (ext_uart_clear),  //清除接收标志
  //       .RxD_data      (ext_uart_rx)      //接收到的一字节数据
  //   );

  //   assign ext_uart_clear = ext_uart_ready;  //收到数据的同时，清除标志，因为数据已取到ext_uart_buffer中
  //   always @(posedge clk_50M) begin  //接收到缓冲区ext_uart_buffer
  //     if (ext_uart_ready) begin
  //       ext_uart_buffer <= ext_uart_rx;
  //       ext_uart_avai   <= 1;
  //     end else if (!ext_uart_busy && ext_uart_avai) begin
  //       ext_uart_avai <= 0;
  //     end
  //   end
  //   always @(posedge clk_50M) begin  //将缓冲区ext_uart_buffer发送出去
  //     if (!ext_uart_busy && ext_uart_avai) begin
  //       ext_uart_tx    <= ext_uart_buffer;
  //       ext_uart_start <= 1;
  //     end else begin
  //       ext_uart_start <= 0;
  //     end
  //   end

  //   async_transmitter #(
  //       .ClkFrequency(50000000),
  //       .Baud(9600)
  //   )  //发送模块，9600无检验位
  //       ext_uart_t (
  //       .clk      (clk_50M),         //外部时钟信号
  //       .TxD      (txd),             //串行信号输出
  //       .TxD_busy (ext_uart_busy),   //发送器忙状态指示
  //       .TxD_start(ext_uart_start),  //开始发送信号
  //       .TxD_data (ext_uart_tx)      //待发送的数据
  //   );


endmodule
