`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 15:44:10
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    input [11:0] alu_control,
    input [31:0] alu_src1,
    input [31:0] alu_src2,
    output [31:0] alu_result,
    output [31:0] mem_addr
    );

    wire op_add; //加法
    wire op_sub; //减法
    wire op_slt; //小于
    wire op_sltu; //小于无符号
    wire op_and; //按位与
    wire op_nor;  //按位或非
    wire op_or; //按位或
    wire op_xor; //按位异或
    wire op_sll; //逻辑左移
    wire op_srl; //逻辑右移
    wire op_sra; //算术右移
    wire op_lui; //低位补零 高位加载
    
    assign op_add = alu_control[0];
    assign op_sub = alu_control[1];
    assign op_slt = alu_control[2];
    assign op_sltu = alu_control[3];
    assign op_and = alu_control[4];
    assign op_nor = alu_control[5];
    assign op_or = alu_control[6];
    assign op_xor = alu_control[7];
    assign op_sll = alu_control[8];
    assign op_srl = alu_control[9];
    assign op_sra = alu_control[10];
    assign op_lui = alu_control[11];

    wire [31:0] add_sub_result;
    wire [31:0] slt_result;
    wire [31:0] sltu_result;
    wire [31:0] and_result;
    wire [31:0] nor_result;
    wire [31:0] or_result;
    wire [31:0] xor_result;
    wire [31:0] sll_result;
    wire [31:0] srl_result;
    wire [31:0] sra_result;
    wire [31:0] lui_result;

    assign and_result = alu_src1 & alu_src2;
    assign or_result = alu_src1 | alu_src2;
    assign nor_result = ~or_result;
    assign xor_result = alu_src1 ^ alu_src2;
    assign lui_result = {alu_src2[15:0], 16'b0};

    wire [31:0] adder_a;
    wire [31:0] adder_b;
    wire        adder_cin;
    wire [31:0] adder_result;
    wire        adder_cout;

    assign adder_a = alu_src1;
    assign adder_b = (op_sub | op_slt | op_sltu) ? ~alu_src2 : alu_src2;
    assign adder_cin = (op_sub | op_slt | op_sltu) ? 1'b0 : 1'b1;
    assign {adder_cout, adder_result} = adder_a +adder_b+adder_cin;
    
    assign add_sub_result = adder_result;

    assign slt_result[31:1] = 31'b0;
    assign slt_result[0] = (alu_src1[31] & ~alu_src2[31]) | (~(alu_src1[31]^alu_src2[31]) & adder_result[31]);

    assign sltu_result[31:1]=31'b0;
    assign sltu_result[0] = ~adder_cout;

    assign sll_result = alu_src2 << alu_src1[4:0];

    assign srl_result = alu_src2 >> alu_src1[4:0];

    assign sra_result = ($signed (alu_src2) >>> alu_src1[4:0]);

    assign alu_result = ({32{op_add|op_sub}}  &  add_sub_result)
    | ({32{op_slt}} & slt_result)
    | ({32{op_sltu}} & sltu_result)
    | ({32{op_and}} & and_result)
    | ({32{op_nor}} & nor_result)
    | ({32{op_or}} & or_result)
    | ({32{op_xor}} & xor_result)
    | ({32{op_sll}} & sll_result)
    | ({32{op_srl}} & srl_result)
    | ({32{op_sra}} & sra_result)
    | ({32{op_lui}} & lui_result);

    assign mem_addr = add_sub_result;

    

endmodule
