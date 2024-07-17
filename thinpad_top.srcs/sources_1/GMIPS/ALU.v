/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\ALU.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-14 14:55:18
 * Author:       Tommy Gong
 * description:  
 * ----------------------------------------------------
 * Last Modified: 2024-07-17 15:23:15
 */
`include "defines.v"
module ALU (
    input wire [         31:0] ALU_Data_1,
    input wire [         31:0] ALU_Data_2,
    input wire [`InstrNum-1:0] OptBus,
    input wire [         15:0] Imm16,

    output [31:0] ALU_Out
);

  wire `OperationSet;
  wire addOverFlow, subOverFlow;

  wire [31:0] AddResult;  //加法结果
  wire [31:0] SubResult;  //减法结果
  wire [31:0] SlResult;  //逻辑左移结果
  wire [31:0] SrResult;  //逻辑右移结果
  wire [31:0] ASrResult;  //算术右移结果
  wire [31:0] OrResult;  //或运算结果
  wire [31:0] AndResult;  //与运算结果
  wire [31:0] XorResult;  //异或运算结果     
  wire [31:0] LuiResult;  //LUI指令结果
  wire [63:0] MulResult;  //乘法结果

  assign {`OperationSet}          = OptBus;

  assign {addOverflow, AddResult} = {ALU_Data_1[31], ALU_Data_1} + {ALU_Data_2[31], ALU_Data_2};
  assign {subOverflow, SubResult} = {ALU_Data_1[31], ALU_Data_1} - {ALU_Data_2[31], ALU_Data_2};
  assign SlResult                 = ALU_Data_2 << ALU_Data_1[4:0];
  assign UsrResult                = ALU_Data_2 >> ALU_Data_1[4:0];
  assign ASrResult                = $signed(ALU_Data_2) >>> ALU_Data_1[4:0];
  assign SrResult                 = ALU_Data_2 >> ALU_Data_1[4:0];
  assign OrResult                 = ALU_Data_1 | ALU_Data_2;
  assign AndResult                = ALU_Data_1 & ALU_Data_2;
  assign XorResult                = ALU_Data_1 ^ ALU_Data_2;
  assign LuiResult                = Imm16 << 16;

  mult_gen_0 multer (
      .A(ALU_Data_1),
      .B(ALU_Data_2),
      .P(MulResult)
  );

  assign ALU_Out = (ADD || ADDI || ADDU || ADDIU || LB || LW || SB || SW) ? AddResult :
                     (SUB) ? SubResult :
                     (AND || ANDI) ? AndResult:
                     (OR || ORI ) ? OrResult :
                     (XOR || XORI) ? XorResult :
                     (SLLV || SLL ) ? SlResult :
                     (SRLV || SRL) ? SrResult :
                     (SRAV || SRA) ? ASrResult :
                     (LUI) ? LuiResult :
                     (MUL) ? MulResult :
                     (SLT) ? ($signed(
      ALU_Data_1
  ) < $signed(
      ALU_Data_2
  )) : 32'o7777;

endmodule
