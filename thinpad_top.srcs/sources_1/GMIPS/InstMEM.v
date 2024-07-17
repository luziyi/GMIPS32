/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\InstMEM
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-17 16:02:43
 * Author:       Tommy Gong
 * description:  
 * ----------------------------------------------------
 * Last Modified: 2024-07-17 16:02:53
 */

module InstMEM(
    input [31:0] addr,
    input rst_n,
    output [31:0] Instr
    );

    reg [7:0] inst_mem[1023:0];

    assign Instr = rst_n ? 32'b0 :
            {inst_mem[addr], inst_mem[addr+1], inst_mem[addr+2], inst_mem[addr+3]};
endmodule