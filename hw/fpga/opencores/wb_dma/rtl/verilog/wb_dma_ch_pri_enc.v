/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE DMA Priority Encoder                              ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/wb_dma/    ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: wb_dma_ch_pri_enc.v,v 1.5 2002-02-01 01:54:44 rudi Exp $
//
//  $Date: 2002-02-01 01:54:44 $
//  $Revision: 1.5 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.4  2001/10/19 04:35:04  rudi
//
//               - Made the core parameterized
//
//               Revision 1.3  2001/08/15 05:40:30  rudi
//
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//               - Added Section 3.10, describing DMA restart.
//
//               Revision 1.2  2001/08/07 08:00:43  rudi
//
//
//               Split up priority encoder modules to separate files
//
//               Revision 1.1  2001/07/29 08:57:02  rudi
//
//
//               1) Changed Directory Structure
//               2) Added restart signal (REST)
//
//               Revision 1.2  2001/06/05 10:22:36  rudi
//
//
//               - Added Support of up to 31 channels
//               - Added support for 2,4 and 8 priority levels
//               - Now can have up to 31 channels
//               - Added many configuration items
//               - Changed reset to async
//
//               Revision 1.1.1.1  2001/03/19 13:10:50  rudi
//               Initial Release
//
//
//

`include "wb_dma_defines.v"

// Priority Encoder
//
// Determines the channel with the highest priority, also takes
// the valid bit in consideration

module wb_dma_ch_pri_enc(clk, valid,
		pri0, pri1, pri2, pri3,
		pri4, pri5, pri6, pri7,
		pri_out);

////////////////////////////////////////////////////////////////////
//
// Module Parameters
//

// chXX_conf = { CBUF, ED, ARS, EN }
parameter	[1:0]	pri_sel = 2'd0;
parameter	[3:0]	ch0_conf = 4'h1;
parameter	[3:0]	ch1_conf = 4'h0;
parameter	[3:0]	ch2_conf = 4'h0;
parameter	[3:0]	ch3_conf = 4'h0;
parameter	[3:0]	ch4_conf = 4'h0;
parameter	[3:0]	ch5_conf = 4'h0;
parameter	[3:0]	ch6_conf = 4'h0;
parameter	[3:0]	ch7_conf = 4'h0;

////////////////////////////////////////////////////////////////////
//
// Module IOs
//

input		clk;
input	[7:0]	valid;				// Channel Valid bits
input	[2:0]	pri0, pri1, pri2, pri3;		// Channel Priorities
input	[2:0]	pri4, pri5, pri6, pri7;
output	[2:0]	pri_out;			// Highest unserviced priority

wire	[7:0]	pri0_out, pri1_out, pri2_out, pri3_out;
wire	[7:0]	pri4_out, pri5_out, pri6_out, pri7_out;

wire	[7:0]	pri_out_tmp;
reg	[2:0]	pri_out;
reg	[2:0]	pri_out2;
reg	[2:0]	pri_out1;
reg	[2:0]	pri_out0;

wb_dma_pri_enc_sub #(ch1_conf,pri_sel) u0(	// Use channel config 1 for channel 0 encoder
		.valid(		valid[0]	),
		.pri_in(	pri0		),
		.pri_out(	pri0_out	)
		);
wb_dma_pri_enc_sub #(ch1_conf,pri_sel) u1(
		.valid(		valid[1]	),
		.pri_in(	pri1		),
		.pri_out(	pri1_out	)
		);
wb_dma_pri_enc_sub #(ch2_conf,pri_sel) u2(
		.valid(		valid[2]	),
		.pri_in(	pri2		),
		.pri_out(	pri2_out	)
		);
wb_dma_pri_enc_sub #(ch3_conf,pri_sel) u3(
		.valid(		valid[3]	),
		.pri_in(	pri3		),
		.pri_out(	pri3_out	)
		);
wb_dma_pri_enc_sub #(ch4_conf,pri_sel) u4(
		.valid(		valid[4]	),
		.pri_in(	pri4		),
		.pri_out(	pri4_out	)
		);
wb_dma_pri_enc_sub #(ch5_conf,pri_sel) u5(
		.valid(		valid[5]	),
		.pri_in(	pri5		),
		.pri_out(	pri5_out	)
		);
wb_dma_pri_enc_sub #(ch6_conf,pri_sel) u6(
		.valid(		valid[6]	),
		.pri_in(	pri6		),
		.pri_out(	pri6_out	)
		);
wb_dma_pri_enc_sub #(ch7_conf,pri_sel) u7(
		.valid(		valid[7]	),
		.pri_in(	pri7		),
		.pri_out(	pri7_out	)
		);

assign pri_out_tmp =	pri0_out | pri1_out | pri2_out | pri3_out |
			pri4_out | pri5_out | pri6_out | pri7_out;

// 8 Priority Levels
always @(posedge clk)
	if(pri_out_tmp[7])	pri_out2 <= #1 3'h7;
	else
	if(pri_out_tmp[6])	pri_out2 <= #1 3'h6;
	else
	if(pri_out_tmp[5])	pri_out2 <= #1 3'h5;
	else
	if(pri_out_tmp[4])	pri_out2 <= #1 3'h4;
	else
	if(pri_out_tmp[3])	pri_out2 <= #1 3'h3;
	else
	if(pri_out_tmp[2])	pri_out2 <= #1 3'h2;
	else
	if(pri_out_tmp[1])	pri_out2 <= #1 3'h1;
	else			pri_out2 <= #1 3'h0;

// 4 Priority Levels
always @(posedge clk)
	if(pri_out_tmp[3])	pri_out1 <= #1 3'h3;
	else
	if(pri_out_tmp[2])	pri_out1 <= #1 3'h2;
	else
	if(pri_out_tmp[1])	pri_out1 <= #1 3'h1;
	else			pri_out1 <= #1 3'h0;

// 2 Priority Levels
always @(posedge clk)
	if(pri_out_tmp[1])	pri_out0 <= #1 3'h1;
	else			pri_out0 <= #1 3'h0;

// Select configured priority
always @(pri_sel or pri_out0 or pri_out1 or  pri_out2)
	case(pri_sel)		// synopsys parallel_case full_case
	   2'd0: pri_out = pri_out0;
	   2'd1: pri_out = pri_out1;
	   2'd2: pri_out = pri_out2;
	endcase

endmodule
