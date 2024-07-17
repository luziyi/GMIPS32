/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\ID.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-05 16:16:38
 * Author:       Tommy Gong
 * description:  
 * ----------------------------------------------------
 * Last Modified: 2024-07-17 16:24:46
 */
`include "defines.v"
module ID (
    input        clk,
    input        rst_n,
    
    input [31:0] IF_PC,
    input [31:0] IF_PC_WIRE,
    input [31:0] IF_Instr,
    
    input        WB_RegWriteEn,
    input [ 4:0] WB_RegWriteID,
    input [31:0] WB_RegWriteData,

    input      [         31:0] EX_ALUOut,
    input      [          4:0] EX_RegWriteID,
    input                      EX_RegWriteEn,
    
    output     [         31:0] ID_nextPC,
    output reg [         31:0] ID_PC,
    output reg [         31:0] ID_Instr,
    output reg [          4:0] ID_RsID,
    output reg [          4:0] ID_RtID,
    output reg [          4:0] ID_RdID,
    output reg [         31:0] ID_RsData,
    output reg [         31:0] ID_RtData,
    output reg [         15:0] ID_Imm16,
    output reg [         31:0] ID_ExtImm32,
    output reg [          4:0] ID_shamt,
    
    output reg                 ID_RegWriteEn,
    output reg [          1:0] ID_RegDst,
    output reg [          1:0] ID_MemWriteEn,
    output reg [          1:0] ID_MemReadEn,
    output reg                 ID_MemtoReg,
    output                     ID_stall,
    
    output reg [`InstrNum-1:0] ID_OptBus,
    
    input                      IF_SRAM_stall
);

  wire [`InstrNum-1:0] OptBus;
  wire MemtoReg, RegWriteEn;
  wire [1:0] MemWriteEn, MemReadEn, RegDst;
  wire [4:0] RsID, RtID, RdID, shamt;
  wire [31:0] RsData, RtData, ExtImm32;
  wire [15:0] Imm16;
  wire [25:0] Imm26;
  wire        stall;

  assign ID_stall = stall;
  reg  EX_isOpt_LWorLB;
  wire ID_isOpt_LWorLB;

  assign ID_isOpt_LWorLB = ID_OptBus[2] || ID_OptBus[3];
  
  decoder D (
      .instruction(IF_Instr),
      .RsID       (RsID),
      .RtID       (RtID),
      .RdID       (RdID),
      .shamt      (shamt),
      .RegWriteEn (RegWriteEn),
      .RegDst     (RegDst),
      .MemWriteEn (MemWriteEn),
      .MemReadEn  (MemReadEn),
      .Imm16      (Imm16),
      .Imm26      (Imm26),
      .ExtImm32   (ExtImm32),
      .MemtoReg   (MemtoReg),
      .OptBus     (OptBus)
  );

  regfile REG (
      .clk         (clk),
      .rst_n       (rst_n),
      .RsID        (RsID),
      .RtID        (RtID),
      .RegWriteID  (WB_RegWriteID),
      .RegWriteData(WB_RegWriteData),
      .RegWriteEn  (WB_RegWriteEn),
      .d_out1      (RsData),
      .d_out2      (RtData)
  );

  call CNPC (
      .instruction     (IF_Instr),
      .PC              (IF_PC_WIRE),
      .RsData          (RsData),
      .RtData          (RtData),
      .RsID            (RsID),
      .RtID            (RtID),
      .WB_RegWriteData (WB_RegWriteData),
      .WB_RegWriteID   (WB_RegWriteID),
      .WB_RegWriteEn   (WB_RegWriteEn),
      .MEM_MemWriteAddr(EX_ALUOut),
      .MEM_RegWriteID  (EX_RegWriteID),
      .MEM_RegWriteEn  (EX_RegWriteEn),
      .nextPC          (ID_nextPC)
  );

  stall StallCtrl (
      .clk            (clk),
      .rst_n          (rst_n),
      .OptBus         (OptBus),
      .EX_isOpt_LWorLB(EX_isOpt_LWorLB),
      .EX_RegWriteEn  (EX_RegWriteEn),
      .EX_RegWriteID  (EX_RegWriteID),
      .ID_isOpt_LWorLB(ID_isOpt_LWorLB),
      .ID_RegWriteEn  (ID_RegWriteEn),
      .ID_RtID        (ID_RtID),
      .ID_RdID        (ID_RdID),
      .RsID           (RsID),
      .RtID           (RtID),
      .stall          (stall)
  );


  always @(posedge clk) begin
    if (rst_n || stall || IF_SRAM_stall) begin
      ID_PC           <= 0;
      ID_Instr        <= 0;
      ID_OptBus       <= 0;
      ID_RsID         <= 0;
      ID_RtID         <= 0;
      ID_RdID         <= 0;
      ID_RsData       <= 0;
      ID_RtData       <= 0;
      ID_ExtImm32     <= 0;
      ID_shamt        <= 0;
      ID_MemReadEn    <= 0;
      ID_MemWriteEn   <= 0;
      ID_RegDst       <= 0;
      ID_MemtoReg     <= 0;
      ID_RegWriteEn   <= 0;

      EX_isOpt_LWorLB <= 0;
    end else begin
      ID_PC           <= IF_PC;
      ID_Instr        <= IF_Instr;
      ID_RsID         <= RsID;
      ID_RtID         <= RtID;
      ID_RdID         <= RdID;
      ID_ExtImm32     <= ExtImm32;
      ID_Imm16        <= Imm16;
      ID_shamt        <= shamt;
      ID_MemReadEn    <= MemReadEn;
      ID_MemWriteEn   <= MemWriteEn;
      ID_RegDst       <= RegDst;
      ID_MemtoReg     <= MemtoReg;
      ID_RegWriteEn   <= RegWriteEn;
      ID_OptBus       <= OptBus;
      ID_RsData       <= RsData;
      ID_RtData       <= RtData;

      EX_isOpt_LWorLB <= ID_OptBus[2] || ID_OptBus[3];
    end
  end

endmodule
