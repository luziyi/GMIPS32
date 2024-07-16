/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\stall.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-12 09:56:33
 * Author:       Tommy Gong
 * description:  
 * ----------------------------------------------------
 * Last Modified: 2024-07-12 10:20:08
 */

module stall (
    input wire rst,
    input wire stallreq_from_id,
    input wire stallreq_from_baseram,
    output wire stall
);
  assign stall = stallreq_from_id | stallreq_from_baseram;
endmodule 
