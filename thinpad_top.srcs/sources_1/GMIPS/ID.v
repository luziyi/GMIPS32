/*
 * File: e:\NSCSCC\2024175\thinpad_top.srcs\sources_1\GMIPS\ID.v
 * Project: e:\NSCSCC\2024175\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-05 16:16:38
 * Author: Tommy Gong
 * ----------------------------------------------------
 * Last Modified: 2024-07-05 16:35:06
 * Modified By: Tommy Gong
 * ----------------------------------------------------
 */



module ID (
    input wire clk,
    input wire reset,
    
    input wire [31:0] inst
    
);


  wire [5:0] op = inst[31:26];
  wire [4:0] rs = inst[25:21];
  wire [4:0] rt = inst[20:16];
  wire [4:0] rd = inst[15:11];
  wire [4:0] shamt = inst[10:6];
  wire [5:0] func = inst[5:0];


  wire [15:0] imm = inst[15:0];
  
  wire [25:0] j_addr = inst[25:0];

endmodule
