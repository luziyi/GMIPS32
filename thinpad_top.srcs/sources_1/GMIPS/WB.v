/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\WB.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-17 15:30:02
 * Author:       Tommy Gong
 * description:  
 * ----------------------------------------------------
 * Last Modified: 2024-07-17 15:30:17
 */

module WB(
    input [31:0] MEM_MemtoRegData,
    input [31:0] MEM_RegWriteData,
    input [4:0] MEM_RegWriteID,
    input MEM_MemtoReg, MEM_RegWriteEn,
    
    output wire WB_RegWriteEn,
    output wire [4:0] WB_RegWriteID,
    output wire [31:0] WB_RegWriteData
    );
    
    assign WB_RegWriteData = MEM_MemtoReg ? MEM_MemtoRegData : MEM_RegWriteData;
    assign WB_RegWriteID = MEM_RegWriteID;
    assign WB_RegWriteEn = MEM_RegWriteEn;

endmodule