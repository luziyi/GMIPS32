/*
 * File: e:\NSCSCC\2024175\thinpad_top.srcs\sources_1\GMIPS\GMIPS.v
 * Project: e:\NSCSCC\2024175\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-05 10:37:43
 * Author: Tommy Gong
 * ----------------------------------------------------
 * Last Modified: 2024-07-17 16:34:01
 * Modified By: Tommy Gong
 * ----------------------------------------------------
 */
`include "defines.v"
module GMIPS (
    input              clk,
    input              rst_n,
    //////////////////
    //BaseRAM信号
    inout  wire [31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共�?
    output wire [19:0] base_ram_addr,  //BaseRAM地址
    output wire [ 3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持�?0
    output wire        base_ram_ce_n,  //BaseRAM片�?�，低有�?
    output wire        base_ram_oe_n,  //BaseRAM读使能，低有�?
    output wire        base_ram_we_n,  //BaseRAM写使能，低有�?

    //ExtRAM信号
    inout  wire [31:0] ext_ram_data,  //ExtRAM数据
    output wire [19:0] ext_ram_addr,  //ExtRAM地址
    output wire [ 3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持�?0
    output wire        ext_ram_ce_n,  //ExtRAM片�?�，低有�?
    output wire        ext_ram_oe_n,  //ExtRAM读使能，低有�?
    output wire        ext_ram_we_n,  //ExtRAM写使能，低有�?  

    //串口
    input  wire rxd,
    output wire txd
);

  (* mark_debug = "TRUE" *) wire [31:0] IF_PC, IF_Instr;
  wire [31:0] IF_PC_WIRE,
  // IF_Instr,
  ID_nextPC, MEM_MemWriteAddr;
  wire ID_stall, IF_SRAM_stall;
  (* mark_debug = "TRUE" *) wire [1:0] EX_MemWriteEn, EX_MemReadEn;
  (* mark_debug = "TRUE" *) wire [2:0] SRAMCtrl;
  /////////////////////////////////////
  wire [31:0] InstrMemOut, DataMemOut, EX_ALUOut, Instr;
  wire is_using_uart = (EX_ALUOut == 32'hBFD003F8) || (EX_ALUOut == 32'hBFD003FC);


  RamCtrl MEM_Ctrl (
      .PC              (IF_PC),
      .MEM_MemWriteAddr(EX_ALUOut),
      .MEM_MemWriteEn  (EX_MemWriteEn),
      .MEM_MemReadEn   (EX_MemReadEn),
      .is_using_uart   (is_using_uart),
      .IF_SRAM_stall   (IF_SRAM_stall),
      .SRAMCtrl        (SRAMCtrl)
  );

  assign Instr = base_ram_data;

  IF InstrFetch (
      .clk          (clk),
      .rst_n        (rst_n),
      .ID_stall     (ID_stall),
      .ID_nextPC    (ID_nextPC),
      .Instr        (Instr),
      .IF_PC_WIRE   (IF_PC_WIRE),
      .IF_PC        (IF_PC),
      .IF_Instr     (IF_Instr),
      .IF_SRAM_stall(IF_SRAM_stall)
  );

  ///////////////////////////////////////////
  wire [`InstrNum-1:0] ID_OptBus;
  wire [31:0] ID_PC, ID_Instr, ID_RsData, ID_RtData, ID_ExtImm32, WB_RegWriteData;
  //ID_nextPC在IF级定�?

  wire [4:0] ID_shamt, ID_RsID, ID_RtID, ID_RdID, WB_RegWriteID, EX_RegWriteID;

  wire [15:0] ID_Imm16;
  wire [1:0] ID_RegDst, ID_MemWriteEn, ID_MemReadEn;
  wire ID_RegWriteEn, ID_MemtoReg;
  wire EX_RegWriteEn, WB_RegWriteEn;

  ID InstrDecode (
      .clk            (clk),
      .rst_n          (rst_n),
      .IF_PC          (IF_PC),
      .IF_PC_WIRE     (IF_PC_WIRE),
      .IF_Instr       (IF_Instr),
      .WB_RegWriteEn  (WB_RegWriteEn),
      .WB_RegWriteID  (WB_RegWriteID),
      .WB_RegWriteData(WB_RegWriteData),
      .EX_ALUOut      (EX_ALUOut),
      .EX_RegWriteID  (EX_RegWriteID),
      .EX_RegWriteEn  (EX_RegWriteEn),
      .ID_nextPC      (ID_nextPC),
      .ID_PC          (ID_PC),
      .ID_Instr       (ID_Instr),
      .ID_RsID        (ID_RsID),
      .ID_RtID        (ID_RtID),
      .ID_RdID        (ID_RdID),
      .ID_RsData      (ID_RsData),
      .ID_RtData      (ID_RtData),
      .ID_Imm16       (ID_Imm16),
      .ID_ExtImm32    (ID_ExtImm32),
      .ID_shamt       (ID_shamt),
      .ID_RegWriteEn  (ID_RegWriteEn),
      .ID_RegDst      (ID_RegDst),
      .ID_MemWriteEn  (ID_MemWriteEn),
      .ID_MemReadEn   (ID_MemReadEn),
      .ID_MemtoReg    (ID_MemtoReg),
      .ID_stall       (ID_stall),
      .ID_OptBus      (ID_OptBus),
      .IF_SRAM_stall  (IF_SRAM_stall)
  );

  //////////////////////////////////////////////////
  wire [31:0] EX_PC, EX_Instr, EX_MemWriteData;
  //EX_ALUOut在RAMCtrl处定�?

  //EX_RegWriteID在ID级定�?


  wire [3:0] EX_base_ram_be_n;

  //EX_MemReadEn,EX_MemWriteEn在RAMCtrl处定�?
  //EX_RegWriteEn，WB_RegWriteEn在ID级定�?

  EX ExcuteState (
      .clk          (clk),
      .rst_n        (rst_n),
      .ID_PC        (ID_PC),
      .ID_Instr     (ID_Instr),
      .ID_OptBus    (ID_OptBus),
      .ID_RsID      (ID_RsID),
      .ID_RtID      (ID_RtID),
      .ID_RdID      (ID_RdID),
      .ID_RtData    (ID_RtData),
      .ID_RsData    (ID_RsData),
      .ID_shamt     (ID_shamt),
      .ID_Imm16     (ID_Imm16),
      .ID_ExtImm32  (ID_ExtImm32),
      .ID_RegWriteEn(ID_RegWriteEn),
      .ID_MemWriteEn(ID_MemWriteEn),
      .ID_MemReadEn (ID_MemReadEn),
      .ID_MemtoReg  (ID_MemtoReg),

      .WB_RegWriteEn  (WB_RegWriteEn),
      .WB_RegWriteID  (WB_RegWriteID),
      .WB_RegWriteData(WB_RegWriteData),
      .EX_PC          (EX_PC),
      .EX_Instr       (EX_Instr),
      .EX_ALUOut      (EX_ALUOut),
      .EX_MemWriteData(EX_MemWriteData),
      .EX_RegWriteID  (EX_RegWriteID),
      .EX_RegWriteEn  (EX_RegWriteEn),
      .EX_MemWriteEn  (EX_MemWriteEn),
      .EX_MemReadEn   (EX_MemReadEn),
      .EX_MemtoReg    (EX_MemtoReg),

      .EX_base_ram_be_n(EX_base_ram_be_n)
  );

  //////////////////////////////////////////////////////////////

  wire [31:0] MEM_PC, MEM_Instr, MEM_MemWriteData, MEM_MemtoRegData;
  ///            MEM_MemWriteAddr,  在RAMCtrl处定�?
  wire [4:0] MEM_RegWriteID;
  wire MEM_RegWriteEn, MEM_MemtoReg;

  MEM MemoryState (
      .clk             (clk),
      .rst_n           (rst_n),
      .EX_PC           (EX_PC),
      .EX_Instr        (EX_Instr),
      .EX_ALUOut       (EX_ALUOut),
      .EX_MemWriteData (EX_MemWriteData),
      .EX_RegWriteID   (EX_RegWriteID),
      .EX_RegWriteEn   (EX_RegWriteEn),
      // .EX_MemWriteEn(EX_MemWriteEn),
      .EX_MemReadEn    (EX_MemReadEn),
      .EX_MemtoReg     (EX_MemtoReg),
      .MEM_PC          (MEM_PC),
      .MEM_Instr       (MEM_Instr),
      .MEM_MemtoRegData(MEM_MemtoRegData),
      .MEM_MemWriteAddr(MEM_MemWriteAddr),
      .MEM_MemWriteData(MEM_MemWriteData),
      .MEM_RegWriteID  (MEM_RegWriteID),
      .MEM_RegWriteEn  (MEM_RegWriteEn),
      .MEM_MemtoReg    (MEM_MemtoReg),
      .is_using_uart   (is_using_uart),
      .EX_base_ram_be_n(EX_base_ram_be_n),
      .DataMemOut      (DataMemOut)
  );

  WB Writeback (
      .MEM_MemtoRegData(MEM_MemtoRegData),
      .MEM_RegWriteData(MEM_MemWriteAddr),
      .MEM_RegWriteID  (MEM_RegWriteID),
      .MEM_MemtoReg    (MEM_MemtoReg),
      .MEM_RegWriteEn  (MEM_RegWriteEn),
      .WB_RegWriteEn   (WB_RegWriteEn),
      .WB_RegWriteID   (WB_RegWriteID),
      .WB_RegWriteData (WB_RegWriteData)
  );

  wire TX_FIFO_full, TX_FIFO_empty, RX_FIFO_full, RX_FIFO_empty;
  wire TX_FIFO_WriteEn, TX_FIFO_ReadEn, RX_FIFO_WriteEn, RX_FIFO_ReadEn;
  (* mark_debug = "TRUE" *) wire TX_Start, TX_Busy, RX_Ready, RX_Clear;
  wire [7:0] TX_FIFO_DataOut, TX_FIFO_DataIn, RX_FIFO_DataOut, RX_FIFO_DataIn;
  wire [7:0] TX_Data2Send, RX_DataRecv;

  /////////////////////////////////////////////////////
  assign TX_Start        = (!TX_Busy) && (!TX_FIFO_empty);
  assign TX_FIFO_WriteEn = (EX_ALUOut == 32'hBFD003F8) && EX_MemWriteEn;
  assign TX_FIFO_ReadEn  = TX_Start;
  assign TX_FIFO_DataIn  = EX_MemWriteData[7:0];
  assign TX_Data2Send    = TX_Busy ? TX_Data2Send : TX_FIFO_DataOut;
  /////////////////////////////////////////////////////

  assign RX_FIFO_WriteEn = RX_Ready;
  assign RX_FIFO_ReadEn  = (EX_ALUOut == 32'hBFD003F8) && EX_MemReadEn;
  assign RX_FIFO_DataIn  = RX_DataRecv;
  assign RX_Clear        = RX_Ready && !RX_FIFO_full;


  async_receiver #(
      .ClkFrequency(62000000),
      .Baud(9600)
  ) ext_uart_r (
      .clk           (clk),
      .RxD           (rxd),         //rxd
      .RxD_data_ready(RX_Ready),    //数据接收到的标志
      .RxD_clear     (RX_Clear),    //数据清除的标�?
      .RxD_data      (RX_DataRecv)  //接收数据
  );

  async_transmitter #(
      .ClkFrequency(62000000),
      .Baud(9600)
  ) ext_uart_t (
      .clk      (clk),
      .TxD      (txd),          //txd
      .TxD_busy (TX_Busy),      //发�?�忙标志
      .TxD_start(TX_Start),     //�?始发送的标志
      .TxD_data (TX_Data2Send)  //发�?�的数据
  );

  fifo_generator_0 TX_FIFO (
      .clk  (clk),
      .rst  (rst_n),
      .full (TX_FIFO_full),
      .din  (TX_FIFO_DataIn),
      .wr_en(TX_FIFO_WriteEn),
      .empty(TX_FIFO_empty),
      .rd_en(TX_FIFO_ReadEn),
      .dout (TX_FIFO_DataOut)
  );

  fifo_generator_0 RX_FIFO (
      .clk  (clk),
      .rst  (rst_n),
      .full (RX_FIFO_full),
      .din  (RX_FIFO_DataIn),
      .wr_en(RX_FIFO_WriteEn),
      .empty(RX_FIFO_empty),
      .rd_en(RX_FIFO_ReadEn),
      .dout (RX_FIFO_DataOut)
  );

  /////////////////////////////////////////////////////
  always @(posedge clk) begin
    if (~ext_ram_we_n) $display("Writing %x to Ext:%x", $signed(ext_ram_data), {ext_ram_addr, 2'b0});
    if (~ext_ram_oe_n) $display("Reading %x from Ext:%x", $signed(ext_ram_data), {ext_ram_addr, 2'b0});
  end

  assign base_ram_addr = (SRAMCtrl == 3'b000 || SRAMCtrl == 3'b101) ? IF_PC_WIRE[21:2] : ((SRAMCtrl == 3'b100) || (SRAMCtrl == 3'b110)) ? EX_ALUOut[21:2] : 20'b0;
  assign base_ram_oe_n = !((SRAMCtrl == 3'b000) || (SRAMCtrl == 3'b101) || (((SRAMCtrl == 3'b100) || (SRAMCtrl == 3'b110)) && (EX_MemReadEn != 0)));
  // assign  base_ram_oe_n = !((SRAMCtrl == 3'b000) || (SRAMCtrl == 3'b101) || (SRAMCtrl == 3'b100) || (SRAMCtrl == 3'b110));

  assign base_ram_be_n = ((SRAMCtrl == 3'b000) || (SRAMCtrl == 3'b101)) ? 4'b0 : (((SRAMCtrl == 3'b100) || (SRAMCtrl == 3'b110))) ? EX_base_ram_be_n : 4'b1111;
  assign base_ram_ce_n = 1'b0;
  assign base_ram_we_n = !(((SRAMCtrl == 3'b100) || (SRAMCtrl == 3'b110)) && (EX_MemWriteEn != 0) && !is_using_uart);
  assign base_ram_data = (!base_ram_we_n && ((SRAMCtrl == 3'b110) || (SRAMCtrl == 3'b100))) ? EX_MemWriteData : 32'bzzzz_z;

  assign ext_ram_addr = (SRAMCtrl == 3'b010) ? IF_PC_WIRE[21:2] : ((SRAMCtrl == 3'b111) || (SRAMCtrl == 3'b101)) ? EX_ALUOut[21:2] : 20'b0;
  assign ext_ram_be_n = (SRAMCtrl == 3'b010) ? 4'b0 : ((SRAMCtrl == 3'b101) || (SRAMCtrl == 3'b111)) ? EX_base_ram_be_n : 4'b1111;
  //    assign  ext_ram_be_n = 0;
  assign ext_ram_ce_n = 1'b0;
  //    assign  ext_ram_oe_n = !(ext_ram_we_n && EX_MemReadEn);
  assign ext_ram_oe_n = !((SRAMCtrl == 3'b010) || (((SRAMCtrl == 3'b101) || (SRAMCtrl == 3'b111)) && (EX_MemReadEn != 0) && !is_using_uart));
  // assign  ext_ram_oe_n =  (SRAMCtrl == 3'b010) ? 1'b0 :
  //                         ((SRAMCtrl == 3'b101) || (SRAMCtrl == 3'b111)) ? (EX_MemReadEn == 0) :
  //                         1'b1;
  assign ext_ram_we_n = !(((SRAMCtrl == 3'b101) || (SRAMCtrl == 3'b111)) && (EX_MemWriteEn != 0) && !is_using_uart);
  assign ext_ram_data = (!ext_ram_we_n && ((SRAMCtrl == 3'b111) || (SRAMCtrl == 3'b101))) ? EX_MemWriteData : 32'bzzzz_z;

  assign DataMemOut = (is_using_uart && EX_ALUOut == 32'hBFD003F8) ? {24'b0, RX_FIFO_DataOut} :
                        (is_using_uart && EX_ALUOut == 32'hBFD003FC) ? {30'b0, !RX_FIFO_empty, !TX_FIFO_full} : 
                        ((SRAMCtrl == 3'b100) || (SRAMCtrl == 3'b110) && !EX_MemWriteEn && (EX_ALUOut <= 32'h80400000)) ? base_ram_data :
                        ((SRAMCtrl == 3'b101) || (SRAMCtrl == 3'b111) && !EX_MemWriteEn && (EX_ALUOut <= 32'h80800000)) ? ext_ram_data :
                        32'hffffffff;
  assign InstrMemOut = (((SRAMCtrl == 3'b000) || (SRAMCtrl == 3'b101)) || ((SRAMCtrl == 3'b100) && !IF_SRAM_stall && !ID_stall)) ? base_ram_data : (((SRAMCtrl == 3'b010) || (SRAMCtrl == 3'b110)) || ((SRAMCtrl == 3'b111) && !IF_SRAM_stall && !ID_stall)) ? ext_ram_data : 32'h00000000;



endmodule
