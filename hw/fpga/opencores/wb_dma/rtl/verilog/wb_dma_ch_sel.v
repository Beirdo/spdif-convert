/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE DMA Channel Select                                ////
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
//  $Id: wb_dma_ch_sel.v,v 1.4 2002-02-01 01:54:45 rudi Exp $
//
//  $Date: 2002-02-01 01:54:45 $
//  $Revision: 1.4 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.3  2001/10/19 04:35:04  rudi
//
//               - Made the core parameterized
//
//               Revision 1.2  2001/08/15 05:40:30  rudi
//
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//               - Added Section 3.10, describing DMA restart.
//
//               Revision 1.1  2001/07/29 08:57:02  rudi
//
//
//               1) Changed Directory Structure
//               2) Added restart signal (REST)
//
//               Revision 1.4  2001/06/14 08:52:00  rudi
//
//
//               Changed arbiter module name.
//
//               Revision 1.3  2001/06/13 02:26:48  rudi
//
//
//               Small changes after running lint.
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
//               Revision 1.1.1.1  2001/03/19 13:10:35  rudi
//               Initial Release
//
//
//

`include "wb_dma_defines.v"

module wb_dma_ch_sel(clk, rst,

	// DMA Request Lines
	req_i, ack_o, nd_i,

	// DMA Registers Inputs
	pointer0, pointer0_s, ch0_csr, ch0_txsz, ch0_adr0, ch0_adr1, ch0_am0, ch0_am1,
	pointer1, pointer1_s, ch1_csr, ch1_txsz, ch1_adr0, ch1_adr1, ch1_am0, ch1_am1,
	pointer2, pointer2_s, ch2_csr, ch2_txsz, ch2_adr0, ch2_adr1, ch2_am0, ch2_am1,
	pointer3, pointer3_s, ch3_csr, ch3_txsz, ch3_adr0, ch3_adr1, ch3_am0, ch3_am1,
	pointer4, pointer4_s, ch4_csr, ch4_txsz, ch4_adr0, ch4_adr1, ch4_am0, ch4_am1,
	pointer5, pointer5_s, ch5_csr, ch5_txsz, ch5_adr0, ch5_adr1, ch5_am0, ch5_am1,
	pointer6, pointer6_s, ch6_csr, ch6_txsz, ch6_adr0, ch6_adr1, ch6_am0, ch6_am1,
	pointer7, pointer7_s, ch7_csr, ch7_txsz, ch7_adr0, ch7_adr1, ch7_am0, ch7_am1,

	// DMA Registers Write Back Channel Select
	ch_sel, ndnr,

	// DMA Engine Interface
	de_start, ndr, csr, pointer, txsz, adr0, adr1, am0, am1,
	pointer_s, next_ch, de_ack, dma_busy
	);

////////////////////////////////////////////////////////////////////
//
// Module Parameters
//

// chXX_conf = { CBUF, ED, ARS, EN }
parameter	[1:0]	pri_sel  = 2'h0;
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

input		clk, rst;

// DMA Request Lines
input	[7:0]	req_i;
output	[7:0]	ack_o;
input	[7:0]	nd_i;

// Channel Registers Inputs
input	[31:0]	pointer0, pointer0_s, ch0_csr, ch0_txsz, ch0_adr0, ch0_adr1, ch0_am0, ch0_am1;
input	[31:0]	pointer1, pointer1_s, ch1_csr, ch1_txsz, ch1_adr0, ch1_adr1, ch1_am0, ch1_am1;
input	[31:0]	pointer2, pointer2_s, ch2_csr, ch2_txsz, ch2_adr0, ch2_adr1, ch2_am0, ch2_am1;
input	[31:0]	pointer3, pointer3_s, ch3_csr, ch3_txsz, ch3_adr0, ch3_adr1, ch3_am0, ch3_am1;
input	[31:0]	pointer4, pointer4_s, ch4_csr, ch4_txsz, ch4_adr0, ch4_adr1, ch4_am0, ch4_am1;
input	[31:0]	pointer5, pointer5_s, ch5_csr, ch5_txsz, ch5_adr0, ch5_adr1, ch5_am0, ch5_am1;
input	[31:0]	pointer6, pointer6_s, ch6_csr, ch6_txsz, ch6_adr0, ch6_adr1, ch6_am0, ch6_am1;
input	[31:0]	pointer7, pointer7_s, ch7_csr, ch7_txsz, ch7_adr0, ch7_adr1, ch7_am0, ch7_am1;

output	[2:0]	ch_sel;		// Write Back Channel Select
output	[7:0]	ndnr;		// Next Descriptor No Request

output		de_start;	// Start DMA Engine Indicator
output		ndr;		// Next Descriptor With Request (for current channel)
output	[31:0]	csr;		// Selected Channel CSR
output	[31:0]	pointer;	// LL Descriptor pointer
output	[31:0]	pointer_s;	// LL Descriptor previous pointer
output	[31:0]	txsz;		// Selected Channel Transfer Size
output	[31:0]	adr0, adr1;	// Selected Channel Addresses
output	[31:0]	am0, am1;	// Selected Channel Address Masks

input		next_ch;	// Indicates the DMA Engine is done
				// with current transfer
input		de_ack;		// DMA engine ack output

input		dma_busy;

////////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

reg	[7:0]	ack_o;
wire	[7:0]	valid;		// Indicates which channel is valid
reg		valid_sel;
reg	[7:0]	req_r;		// Channel Request inputs
reg	[7:0]	ndr_r;		// Next Descriptor Registered (and Request)
reg	[7:0]	ndnr;		// Next Descriptor Registered (and Not Request)
wire	[2:0]	pri_out;	// Highest unserviced priority
wire	[2:0]	pri0, pri1, pri2, pri3;		// Channel Priorities
wire	[2:0]	pri4, pri5, pri6, pri7;
reg	[2:0]	ch_sel_d;
reg	[2:0]	ch_sel_r;

reg		ndr;
reg		next_start;
reg		de_start_r;
reg	[31:0]	csr;		// Selected Channel CSR
reg	[31:0]	pointer;
reg	[31:0]	pointer_s;
reg	[31:0]	txsz;		// Selected Channel Transfer Size
reg	[31:0]	adr0, adr1;	// Selected Channel Addresses
reg	[31:0]	am0, am1;	// Selected Channel Address Masks

				// Arbiter Request Inputs
wire	[7:0]	req_p0, req_p1, req_p2, req_p3;
wire	[7:0]	req_p4, req_p5, req_p6, req_p7;
				// Arbiter Grant Outputs
wire	[2:0]	gnt_p0_d, gnt_p1_d, gnt_p2_d, gnt_p3_d;
wire	[2:0]	gnt_p4_d, gnt_p5_d, gnt_p6_d, gnt_p7_d;
wire	[2:0]	gnt_p0, gnt_p1, gnt_p2, gnt_p3;
wire	[2:0]	gnt_p4, gnt_p5, gnt_p6, gnt_p7;


////////////////////////////////////////////////////////////////////
//
// Aliases
//

assign pri0[0] = ch0_csr[13];
assign pri0[1] = (pri_sel == 2'd0) ? 1'b0 : ch0_csr[14];
assign pri0[2] = (pri_sel == 2'd2) ? ch0_csr[15] : 1'b0;
assign pri1[0] = ch1_csr[13];
assign pri1[1] = (pri_sel == 2'd0) ? 1'b0 : ch1_csr[14];
assign pri1[2] = (pri_sel == 2'd2) ? ch1_csr[15] : 1'b0;
assign pri2[0] = ch2_csr[13];
assign pri2[1] = (pri_sel == 2'd0) ? 1'b0 : ch2_csr[14];
assign pri2[2] = (pri_sel == 2'd2) ? ch2_csr[15] : 1'b0;
assign pri3[0] = ch3_csr[13];
assign pri3[1] = (pri_sel == 2'd0) ? 1'b0 : ch3_csr[14];
assign pri3[2] = (pri_sel == 2'd2) ? ch3_csr[15] : 1'b0;
assign pri4[0] = ch4_csr[13];
assign pri4[1] = (pri_sel == 2'd0) ? 1'b0 : ch4_csr[14];
assign pri4[2] = (pri_sel == 2'd2) ? ch4_csr[15] : 1'b0;
assign pri5[0] = ch5_csr[13];
assign pri5[1] = (pri_sel == 2'd0) ? 1'b0 : ch5_csr[14];
assign pri5[2] = (pri_sel == 2'd2) ? ch5_csr[15] : 1'b0;
assign pri6[0] = ch6_csr[13];
assign pri6[1] = (pri_sel == 2'd0) ? 1'b0 : ch6_csr[14];
assign pri6[2] = (pri_sel == 2'd2) ? ch6_csr[15] : 1'b0;
assign pri7[0] = ch7_csr[13];
assign pri7[1] = (pri_sel == 2'd0) ? 1'b0 : ch7_csr[14];
assign pri7[2] = (pri_sel == 2'd2) ? ch7_csr[15] : 1'b0;

////////////////////////////////////////////////////////////////////
//
// Misc logic
//

// Chanel Valid flag
// The valid flag is asserted when the channel is enabled,
// and is either in "normal mode" (software control) or
// "hw handshake mode" (reqN control)
// validN = ch_enabled & (sw_mode | (hw_mode & reqN) )

always @(posedge clk)
	req_r <= #1 req_i & ~ack_o;

assign valid[0] = ch0_conf[0] & ch0_csr[`WDMA_CH_EN] & (ch0_csr[`WDMA_MODE] ? (req_r[0] & !ack_o[0]) : 1'b1);
assign valid[1] = ch1_conf[0] & ch1_csr[`WDMA_CH_EN] & (ch1_csr[`WDMA_MODE] ? (req_r[1] & !ack_o[1]) : 1'b1);
assign valid[2] = ch2_conf[0] & ch2_csr[`WDMA_CH_EN] & (ch2_csr[`WDMA_MODE] ? (req_r[2] & !ack_o[2]) : 1'b1);
assign valid[3] = ch3_conf[0] & ch3_csr[`WDMA_CH_EN] & (ch3_csr[`WDMA_MODE] ? (req_r[3] & !ack_o[3]) : 1'b1);
assign valid[4] = ch4_conf[0] & ch4_csr[`WDMA_CH_EN] & (ch4_csr[`WDMA_MODE] ? (req_r[4] & !ack_o[4]) : 1'b1);
assign valid[5] = ch5_conf[0] & ch5_csr[`WDMA_CH_EN] & (ch5_csr[`WDMA_MODE] ? (req_r[5] & !ack_o[5]) : 1'b1);
assign valid[6] = ch6_conf[0] & ch6_csr[`WDMA_CH_EN] & (ch6_csr[`WDMA_MODE] ? (req_r[6] & !ack_o[6]) : 1'b1);
assign valid[7] = ch7_conf[0] & ch7_csr[`WDMA_CH_EN] & (ch7_csr[`WDMA_MODE] ? (req_r[7] & !ack_o[7]) : 1'b1);

always @(posedge clk)
	ndr_r <= #1 nd_i & req_i;

always @(posedge clk)
	ndnr <= #1 nd_i & ~req_i;

// Start Signal for DMA engine
assign de_start = (valid_sel & !de_start_r ) | next_start;

always @(posedge clk)
	de_start_r <= #1 valid_sel;

always @(posedge clk)
	next_start <= #1 next_ch & valid_sel;

// Ack outputs for HW handshake mode
always @(posedge clk)
	ack_o[0] <= #1 ch0_conf[0] & (ch_sel == 3'h0) & ch0_csr[`WDMA_MODE] & de_ack;

always @(posedge clk)
	ack_o[1] <= #1 ch1_conf[0] & (ch_sel == 3'h1) & ch1_csr[`WDMA_MODE] & de_ack;

always @(posedge clk)
	ack_o[2] <= #1 ch2_conf[0] & (ch_sel == 3'h2) & ch2_csr[`WDMA_MODE] & de_ack;

always @(posedge clk)
	ack_o[3] <= #1 ch3_conf[0] & (ch_sel == 3'h3) & ch3_csr[`WDMA_MODE] & de_ack;

always @(posedge clk)
	ack_o[4] <= #1 ch4_conf[0] & (ch_sel == 3'h4) & ch4_csr[`WDMA_MODE] & de_ack;

always @(posedge clk)
	ack_o[5] <= #1 ch5_conf[0] & (ch_sel == 3'h5) & ch5_csr[`WDMA_MODE] & de_ack;

always @(posedge clk)
	ack_o[6] <= #1 ch6_conf[0] & (ch_sel == 3'h6) & ch6_csr[`WDMA_MODE] & de_ack;

always @(posedge clk)
	ack_o[7] <= #1 ch7_conf[0] & (ch_sel == 3'h7) & ch7_csr[`WDMA_MODE] & de_ack;

// Channel Select
always @(posedge clk or negedge rst)
	if(!rst)	ch_sel_r <= #1 0;
	else
	if(de_start)	ch_sel_r <= #1 ch_sel_d;

assign ch_sel = !dma_busy ? ch_sel_d : ch_sel_r;

////////////////////////////////////////////////////////////////////
//
// Select Registers based on arbiter (and priority) outputs
//

always @(ch_sel or valid)
	case(ch_sel)		// synopsys parallel_case full_case
	   3'h0:	valid_sel = valid[0];
	   3'h1:	valid_sel = valid[1];
	   3'h2:	valid_sel = valid[2];
	   3'h3:	valid_sel = valid[3];
	   3'h4:	valid_sel = valid[4];
	   3'h5:	valid_sel = valid[5];
	   3'h6:	valid_sel = valid[6];
	   3'h7:	valid_sel = valid[7];
	endcase

always @(ch_sel or ndr_r)
	case(ch_sel)		// synopsys parallel_case full_case
	   3'h0:	ndr = ndr_r[0];
	   3'h1:	ndr = ndr_r[1];
	   3'h2:	ndr = ndr_r[2];
	   3'h3:	ndr = ndr_r[3];
	   3'h4:	ndr = ndr_r[4];
	   3'h5:	ndr = ndr_r[5];
	   3'h6:	ndr = ndr_r[6];
	   3'h7:	ndr = ndr_r[7];
	endcase

always @(ch_sel or pointer0 or pointer1 or pointer2 or pointer3 or pointer4
		or pointer5 or pointer6 or pointer7 )
	case(ch_sel)		// synopsys parallel_case full_case
	   3'h0:	pointer = pointer0;
	   3'h1:	pointer = pointer1;
	   3'h2:	pointer = pointer2;
	   3'h3:	pointer = pointer3;
	   3'h4:	pointer = pointer4;
	   3'h5:	pointer = pointer5;
	   3'h6:	pointer = pointer6;
	   3'h7:	pointer = pointer7;
	endcase

always @(ch_sel or pointer0_s or pointer1_s or pointer2_s or pointer3_s or pointer4_s
		or pointer5_s or pointer6_s or pointer7_s )
	case(ch_sel)		// synopsys parallel_case full_case
	   3'h0:	pointer_s = pointer0_s;
	   3'h1:	pointer_s = pointer1_s;
	   3'h2:	pointer_s = pointer2_s;
	   3'h3:	pointer_s = pointer3_s;
	   3'h4:	pointer_s = pointer4_s;
	   3'h5:	pointer_s = pointer5_s;
	   3'h6:	pointer_s = pointer6_s;
	   3'h7:	pointer_s = pointer7_s;
	endcase

always @(ch_sel or ch0_csr or ch1_csr or ch2_csr or ch3_csr or ch4_csr
		or ch5_csr or ch6_csr or ch7_csr )
	case(ch_sel)		// synopsys parallel_case full_case
	   3'h0:	csr = ch0_csr;
	   3'h1:	csr = ch1_csr;
	   3'h2:	csr = ch2_csr;
	   3'h3:	csr = ch3_csr;
	   3'h4:	csr = ch4_csr;
	   3'h5:	csr = ch5_csr;
	   3'h6:	csr = ch6_csr;
	   3'h7:	csr = ch7_csr;
	endcase

always @(ch_sel or ch0_txsz or ch1_txsz or ch2_txsz or ch3_txsz or ch4_txsz
		or ch5_txsz or ch6_txsz or ch7_txsz )
	case(ch_sel)		// synopsys parallel_case full_case
	   3'h0:	txsz = ch0_txsz;
	   3'h1:	txsz = ch1_txsz;
	   3'h2:	txsz = ch2_txsz;
	   3'h3:	txsz = ch3_txsz;
	   3'h4:	txsz = ch4_txsz;
	   3'h5:	txsz = ch5_txsz;
	   3'h6:	txsz = ch6_txsz;
	   3'h7:	txsz = ch7_txsz;
	endcase

always @(ch_sel or ch0_adr0 or ch1_adr0 or ch2_adr0 or ch3_adr0 or ch4_adr0
		or ch5_adr0 or ch6_adr0 or ch7_adr0 )
	case(ch_sel)		// synopsys parallel_case full_case
	   3'h0:	adr0 = ch0_adr0;
	   3'h1:	adr0 = ch1_adr0;
	   3'h2:	adr0 = ch2_adr0;
	   3'h3:	adr0 = ch3_adr0;
	   3'h4:	adr0 = ch4_adr0;
	   3'h5:	adr0 = ch5_adr0;
	   3'h6:	adr0 = ch6_adr0;
	   3'h7:	adr0 = ch7_adr0;
	endcase

always @(ch_sel or ch0_adr1 or ch1_adr1 or ch2_adr1 or ch3_adr1 or ch4_adr1
		or ch5_adr1 or ch6_adr1 or ch7_adr1 )
	case(ch_sel)		// synopsys parallel_case full_case
	   3'h0:	adr1 = ch0_adr1;
	   3'h1:	adr1 = ch1_adr1;
	   3'h2:	adr1 = ch2_adr1;
	   3'h3:	adr1 = ch3_adr1;
	   3'h4:	adr1 = ch4_adr1;
	   3'h5:	adr1 = ch5_adr1;
	   3'h6:	adr1 = ch6_adr1;
	   3'h7:	adr1 = ch7_adr1;
	endcase

always @(ch_sel or ch0_am0 or ch1_am0 or ch2_am0 or ch3_am0 or ch4_am0
		or ch5_am0 or ch6_am0 or ch7_am0 )
	case(ch_sel)		// synopsys parallel_case full_case
	   3'h0:	am0 = ch0_am0;
	   3'h1:	am0 = ch1_am0;
	   3'h2:	am0 = ch2_am0;
	   3'h3:	am0 = ch3_am0;
	   3'h4:	am0 = ch4_am0;
	   3'h5:	am0 = ch5_am0;
	   3'h6:	am0 = ch6_am0;
	   3'h7:	am0 = ch7_am0;
	endcase

always @(ch_sel or ch0_am1 or ch1_am1 or ch2_am1 or ch3_am1 or ch4_am1
		or ch5_am1 or ch6_am1 or ch7_am1 )
	case(ch_sel)		// synopsys parallel_case full_case
	   3'h0:	am1 = ch0_am1;
	   3'h1:	am1 = ch1_am1;
	   3'h2:	am1 = ch2_am1;
	   3'h3:	am1 = ch3_am1;
	   3'h4:	am1 = ch4_am1;
	   3'h5:	am1 = ch5_am1;
	   3'h6:	am1 = ch6_am1;
	   3'h7:	am1 = ch7_am1;
	endcase

////////////////////////////////////////////////////////////////////
//
// Actual Chanel Arbiter and Priority Encoder
//

// Select the arbiter for current highest priority
always @(pri_out or gnt_p0 or gnt_p1 or gnt_p2 or gnt_p3 or gnt_p4
		or gnt_p5 or gnt_p6 or gnt_p7 )
	case(pri_out)		// synopsys parallel_case full_case
	   3'h0:	ch_sel_d = gnt_p0;
	   3'h1:	ch_sel_d = gnt_p1;
	   3'h2:	ch_sel_d = gnt_p2;
	   3'h3:	ch_sel_d = gnt_p3;
	   3'h4:	ch_sel_d = gnt_p4;
	   3'h5:	ch_sel_d = gnt_p5;
	   3'h6:	ch_sel_d = gnt_p6;
	   3'h7:	ch_sel_d = gnt_p7;
	endcase


// Priority Encoder
wb_dma_ch_pri_enc
	#(	pri_sel,
		ch0_conf,
		ch1_conf,
		ch2_conf,
		ch3_conf,
		ch4_conf,
		ch5_conf,
		ch6_conf,
		ch7_conf)
		u0(
		.clk(		clk		),
		.valid(		valid		),
		.pri0(		pri0		),
		.pri1(		pri1		),
		.pri2(		pri2		),
		.pri3(		pri3		),
		.pri4(		pri4		),
		.pri5(		pri5		),
		.pri6(		pri6		),
		.pri7(		pri7		),
		.pri_out(	pri_out		)
		);

// Arbiter request lines
// Generate request depending on priority and valid bits

assign req_p0[0] = valid[0] & (pri0==3'h0);
assign req_p0[1] = valid[1] & (pri1==3'h0);
assign req_p0[2] = valid[2] & (pri2==3'h0);
assign req_p0[3] = valid[3] & (pri3==3'h0);
assign req_p0[4] = valid[4] & (pri4==3'h0);
assign req_p0[5] = valid[5] & (pri5==3'h0);
assign req_p0[6] = valid[6] & (pri6==3'h0);
assign req_p0[7] = valid[7] & (pri7==3'h0);

assign req_p1[0] = valid[0] & (pri0==3'h1);
assign req_p1[1] = valid[1] & (pri1==3'h1);
assign req_p1[2] = valid[2] & (pri2==3'h1);
assign req_p1[3] = valid[3] & (pri3==3'h1);
assign req_p1[4] = valid[4] & (pri4==3'h1);
assign req_p1[5] = valid[5] & (pri5==3'h1);
assign req_p1[6] = valid[6] & (pri6==3'h1);
assign req_p1[7] = valid[7] & (pri7==3'h1);

assign req_p2[0] = valid[0] & (pri0==3'h2);
assign req_p2[1] = valid[1] & (pri1==3'h2);
assign req_p2[2] = valid[2] & (pri2==3'h2);
assign req_p2[3] = valid[3] & (pri3==3'h2);
assign req_p2[4] = valid[4] & (pri4==3'h2);
assign req_p2[5] = valid[5] & (pri5==3'h2);
assign req_p2[6] = valid[6] & (pri6==3'h2);
assign req_p2[7] = valid[7] & (pri7==3'h2);

assign req_p3[0] = valid[0] & (pri0==3'h3);
assign req_p3[1] = valid[1] & (pri1==3'h3);
assign req_p3[2] = valid[2] & (pri2==3'h3);
assign req_p3[3] = valid[3] & (pri3==3'h3);
assign req_p3[4] = valid[4] & (pri4==3'h3);
assign req_p3[5] = valid[5] & (pri5==3'h3);
assign req_p3[6] = valid[6] & (pri6==3'h3);
assign req_p3[7] = valid[7] & (pri7==3'h3);

assign req_p4[0] = valid[0] & (pri0==3'h4);
assign req_p4[1] = valid[1] & (pri1==3'h4);
assign req_p4[2] = valid[2] & (pri2==3'h4);
assign req_p4[3] = valid[3] & (pri3==3'h4);
assign req_p4[4] = valid[4] & (pri4==3'h4);
assign req_p4[5] = valid[5] & (pri5==3'h4);
assign req_p4[6] = valid[6] & (pri6==3'h4);
assign req_p4[7] = valid[7] & (pri7==3'h4);

assign req_p5[0] = valid[0] & (pri0==3'h5);
assign req_p5[1] = valid[1] & (pri1==3'h5);
assign req_p5[2] = valid[2] & (pri2==3'h5);
assign req_p5[3] = valid[3] & (pri3==3'h5);
assign req_p5[4] = valid[4] & (pri4==3'h5);
assign req_p5[5] = valid[5] & (pri5==3'h5);
assign req_p5[6] = valid[6] & (pri6==3'h5);
assign req_p5[7] = valid[7] & (pri7==3'h5);

assign req_p6[0] = valid[0] & (pri0==3'h6);
assign req_p6[1] = valid[1] & (pri1==3'h6);
assign req_p6[2] = valid[2] & (pri2==3'h6);
assign req_p6[3] = valid[3] & (pri3==3'h6);
assign req_p6[4] = valid[4] & (pri4==3'h6);
assign req_p6[5] = valid[5] & (pri5==3'h6);
assign req_p6[6] = valid[6] & (pri6==3'h6);
assign req_p6[7] = valid[7] & (pri7==3'h6);

assign req_p7[0] = valid[0] & (pri0==3'h7);
assign req_p7[1] = valid[1] & (pri1==3'h7);
assign req_p7[2] = valid[2] & (pri2==3'h7);
assign req_p7[3] = valid[3] & (pri3==3'h7);
assign req_p7[4] = valid[4] & (pri4==3'h7);
assign req_p7[5] = valid[5] & (pri5==3'h7);
assign req_p7[6] = valid[6] & (pri6==3'h7);
assign req_p7[7] = valid[7] & (pri7==3'h7);

// RR Arbiter for priority 0
wb_dma_ch_arb u1(
	.clk(		clk		),
	.rst(		rst		),
	.req(		req_p0		),
	.gnt(		gnt_p0_d	),
	.advance(	next_ch		)
	);
// RR Arbiter for priority 1
wb_dma_ch_arb u2(
	.clk(		clk		),
	.rst(		rst		),
	.req(		req_p1		),
	.gnt(		gnt_p1_d	),
	.advance(	next_ch		)
	);

// RR Arbiter for priority 2
wb_dma_ch_arb u3(
	.clk(		clk		),
	.rst(		rst		),
	.req(		req_p2		),
	.gnt(		gnt_p2_d	),
	.advance(	next_ch		)
	);
// RR Arbiter for priority 3
wb_dma_ch_arb u4(
	.clk(		clk		),
	.rst(		rst		),
	.req(		req_p3		),
	.gnt(		gnt_p3_d	),
	.advance(	next_ch		)
	);
// RR Arbiter for priority 4
wb_dma_ch_arb u5(
	.clk(		clk		),
	.rst(		rst		),
	.req(		req_p4		),
	.gnt(		gnt_p4_d	),
	.advance(	next_ch		)
	);
// RR Arbiter for priority 5
wb_dma_ch_arb u6(
	.clk(		clk		),
	.rst(		rst		),
	.req(		req_p5		),
	.gnt(		gnt_p5_d	),
	.advance(	next_ch		)
	);
// RR Arbiter for priority 6
wb_dma_ch_arb u7(
	.clk(		clk		),
	.rst(		rst		),
	.req(		req_p6		),
	.gnt(		gnt_p6_d	),
	.advance(	next_ch		)
	);
// RR Arbiter for priority 7
wb_dma_ch_arb u8(
	.clk(		clk		),
	.rst(		rst		),
	.req(		req_p7		),
	.gnt(		gnt_p7_d	),
	.advance(	next_ch		)
	);

// Select grant based on number of priorities
assign gnt_p0 = gnt_p0_d;
assign gnt_p1 = gnt_p1_d;
assign gnt_p2 = (pri_sel==2'd0) ? 3'h0 : gnt_p2_d;
assign gnt_p3 = (pri_sel==2'd0) ? 3'h0 : gnt_p3_d;
assign gnt_p4 = (pri_sel==2'd2) ? gnt_p4_d : 3'h0;
assign gnt_p5 = (pri_sel==2'd2) ? gnt_p5_d : 3'h0;
assign gnt_p6 = (pri_sel==2'd2) ? gnt_p6_d : 3'h0;
assign gnt_p7 = (pri_sel==2'd2) ? gnt_p7_d : 3'h0;

endmodule
