/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE DMA Register File                                 ////
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
//  $Id: wb_dma_rf.v,v 1.4 2002-02-01 01:54:45 rudi Exp $
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
//               Revision 1.4  2001/06/14 08:50:46  rudi
//
//               Changed name of channel register file module.
//
//               Revision 1.3  2001/06/13 02:26:48  rudi
//
//
//               Small changes after running lint.
//
//               Revision 1.2  2001/06/05 10:22:37  rudi
//
//
//               - Added Support of up to 31 channels
//               - Added support for 2,4 and 8 priority levels
//               - Now can have up to 31 channels
//               - Added many configuration items
//               - Changed reset to async
//
//               Revision 1.1.1.1  2001/03/19 13:10:11  rudi
//               Initial Release
//
//
//

`include "wb_dma_defines.v"

module wb_dma_rf(clk, rst,

	// WISHBONE Access
	wb_rf_adr, wb_rf_din, wb_rf_dout, wb_rf_re, wb_rf_we,

	// WISHBONE Interrupt outputs
	inta_o, intb_o,

	// DMA Registers Outputs
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

	// DMA Engine Status
	pause_req, paused, dma_abort, dma_busy, dma_err, dma_done, dma_done_all,

	// DMA Engine Reg File Update ctrl signals
	de_csr, de_txsz, de_adr0, de_adr1,
	de_csr_we, de_txsz_we, de_adr0_we, de_adr1_we, de_fetch_descr, dma_rest,
	ptr_set
	);

////////////////////////////////////////////////////////////////////
//
// Module Parameters
//

// chXX_conf = { CBUF, ED, ARS, EN }
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

// WISHBONE Access
input	[7:0]	wb_rf_adr;
input	[31:0]	wb_rf_din;
output	[31:0]	wb_rf_dout;
input		wb_rf_re;
input		wb_rf_we;

// WISHBONE Interrupt outputs
output		inta_o, intb_o;

// Channel Registers Inputs
output	[31:0]	pointer0, pointer0_s, ch0_csr, ch0_txsz, ch0_adr0, ch0_adr1, ch0_am0, ch0_am1;
output	[31:0]	pointer1, pointer1_s, ch1_csr, ch1_txsz, ch1_adr0, ch1_adr1, ch1_am0, ch1_am1;
output	[31:0]	pointer2, pointer2_s, ch2_csr, ch2_txsz, ch2_adr0, ch2_adr1, ch2_am0, ch2_am1;
output	[31:0]	pointer3, pointer3_s, ch3_csr, ch3_txsz, ch3_adr0, ch3_adr1, ch3_am0, ch3_am1;
output	[31:0]	pointer4, pointer4_s, ch4_csr, ch4_txsz, ch4_adr0, ch4_adr1, ch4_am0, ch4_am1;
output	[31:0]	pointer5, pointer5_s, ch5_csr, ch5_txsz, ch5_adr0, ch5_adr1, ch5_am0, ch5_am1;
output	[31:0]	pointer6, pointer6_s, ch6_csr, ch6_txsz, ch6_adr0, ch6_adr1, ch6_am0, ch6_am1;
output	[31:0]	pointer7, pointer7_s, ch7_csr, ch7_txsz, ch7_adr0, ch7_adr1, ch7_am0, ch7_am1;

input	[2:0]	ch_sel;		// Write Back Channel Select
input	[7:0]	ndnr;		// Next Descriptor No Request

// DMA Engine Abort
output		dma_abort;

// DMA Engine Status
output		pause_req;
input		paused;
input		dma_busy, dma_err, dma_done, dma_done_all;

// DMA Engine Reg File Update ctrl signals
input	[31:0]	de_csr;
input	[11:0]	de_txsz;
input	[31:0]	de_adr0;
input	[31:0]	de_adr1;
input		de_csr_we, de_txsz_we, de_adr0_we, de_adr1_we, ptr_set;
input		de_fetch_descr;
input	[8:0]	dma_rest;

////////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

reg	[31:0]	wb_rf_dout;
reg		inta_o, intb_o;
reg	[8:0]	int_maska_r, int_maskb_r;
wire	[31:0]	int_maska, int_maskb;
wire	[31:0]	int_srca, int_srcb;
wire		int_maska_we, int_maskb_we;
wire	[8:0]	ch_int;
wire		csr_we;
wire	[31:0]	csr;
reg	[7:0]	csr_r;

wire	[8:0]	ch_stop;
wire	[8:0]	ch_dis;

wire	[31:0]	ch0_csr, ch0_txsz, ch0_adr0, ch0_adr1, ch0_am0, ch0_am1;
wire	[31:0]	ch1_csr, ch1_txsz, ch1_adr0, ch1_adr1, ch1_am0, ch1_am1;
wire	[31:0]	ch2_csr, ch2_txsz, ch2_adr0, ch2_adr1, ch2_am0, ch2_am1;
wire	[31:0]	ch3_csr, ch3_txsz, ch3_adr0, ch3_adr1, ch3_am0, ch3_am1;
wire	[31:0]	ch4_csr, ch4_txsz, ch4_adr0, ch4_adr1, ch4_am0, ch4_am1;
wire	[31:0]	ch5_csr, ch5_txsz, ch5_adr0, ch5_adr1, ch5_am0, ch5_am1;
wire	[31:0]	ch6_csr, ch6_txsz, ch6_adr0, ch6_adr1, ch6_am0, ch6_am1;
wire	[31:0]	ch7_csr, ch7_txsz, ch7_adr0, ch7_adr1, ch7_am0, ch7_am1;

wire	[31:0]	sw_pointer0, sw_pointer1, sw_pointer2, sw_pointer3;
wire	[31:0]	sw_pointer4, sw_pointer5, sw_pointer6, sw_pointer7;

////////////////////////////////////////////////////////////////////
//
// Aliases
//

assign int_maska = {1'h0, int_maska_r};
assign int_maskb = {1'h0, int_maskb_r};
assign csr = {31'h0, paused};

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

assign dma_abort = |ch_stop;
assign pause_req = csr_r[0];

////////////////////////////////////////////////////////////////////
//
// WISHBONE Register Read Logic
//

always @(posedge clk)
	case(wb_rf_adr)		// synopsys parallel_case full_case
	   8'h0:	wb_rf_dout <= #1 csr;
	   8'h1:	wb_rf_dout <= #1 int_maska;
	   8'h2:	wb_rf_dout <= #1 int_maskb;
	   8'h3:	wb_rf_dout <= #1 int_srca;
	   8'h4:	wb_rf_dout <= #1 int_srcb;

	   8'h8:	wb_rf_dout <= #1 ch0_csr;
	   8'h9:	wb_rf_dout <= #1 ch0_txsz;
	   8'ha:	wb_rf_dout <= #1 ch0_adr0;
	   8'hb:	wb_rf_dout <= #1 ch0_am0;
	   8'hc:	wb_rf_dout <= #1 ch0_adr1;
	   8'hd:	wb_rf_dout <= #1 ch0_am1;
	   8'he:	wb_rf_dout <= #1 pointer0;
	   8'hf:	wb_rf_dout <= #1 sw_pointer0;

	   8'h10:	wb_rf_dout <= #1 ch1_conf[0] ? ch1_csr    : 32'h0;
	   8'h11:	wb_rf_dout <= #1 ch1_conf[0] ? ch1_txsz   : 32'h0;
	   8'h12:	wb_rf_dout <= #1 ch1_conf[0] ? ch1_adr0   : 32'h0;
	   8'h13:	wb_rf_dout <= #1 ch1_conf[0] ? ch1_am0    : 32'h0;
	   8'h14:	wb_rf_dout <= #1 ch1_conf[0] ? ch1_adr1   : 32'h0;
	   8'h15:	wb_rf_dout <= #1 ch1_conf[0] ? ch1_am1    : 32'h0;
	   8'h16:	wb_rf_dout <= #1 ch1_conf[0] ? pointer1   : 32'h0;
	   8'h17:	wb_rf_dout <= #1 ch1_conf[0] ? sw_pointer1   : 32'h0;

	   8'h18:	wb_rf_dout <= #1 ch2_conf[0] ? ch2_csr    : 32'h0;
	   8'h19:	wb_rf_dout <= #1 ch2_conf[0] ? ch2_txsz   : 32'h0;
	   8'h1a:	wb_rf_dout <= #1 ch2_conf[0] ? ch2_adr0   : 32'h0;
	   8'h1b:	wb_rf_dout <= #1 ch2_conf[0] ? ch2_am0    : 32'h0;
	   8'h1c:	wb_rf_dout <= #1 ch2_conf[0] ? ch2_adr1   : 32'h0;
	   8'h1d:	wb_rf_dout <= #1 ch2_conf[0] ? ch2_am1    : 32'h0;
	   8'h1e:	wb_rf_dout <= #1 ch2_conf[0] ? pointer2   : 32'h0;
	   8'h1f:	wb_rf_dout <= #1 ch2_conf[0] ? sw_pointer2   : 32'h0;

	   8'h20:	wb_rf_dout <= #1 ch3_conf[0] ? ch3_csr    : 32'h0;
	   8'h21:	wb_rf_dout <= #1 ch3_conf[0] ? ch3_txsz   : 32'h0;
	   8'h22:	wb_rf_dout <= #1 ch3_conf[0] ? ch3_adr0   : 32'h0;
	   8'h23:	wb_rf_dout <= #1 ch3_conf[0] ? ch3_am0    : 32'h0;
	   8'h24:	wb_rf_dout <= #1 ch3_conf[0] ? ch3_adr1   : 32'h0;
	   8'h25:	wb_rf_dout <= #1 ch3_conf[0] ? ch3_am1    : 32'h0;
	   8'h26:	wb_rf_dout <= #1 ch3_conf[0] ? pointer3   : 32'h0;
	   8'h27:	wb_rf_dout <= #1 ch3_conf[0] ? sw_pointer3   : 32'h0;

	   8'h28:	wb_rf_dout <= #1 ch4_conf[0] ? ch4_csr    : 32'h0;
	   8'h29:	wb_rf_dout <= #1 ch4_conf[0] ? ch4_txsz   : 32'h0;
	   8'h2a:	wb_rf_dout <= #1 ch4_conf[0] ? ch4_adr0   : 32'h0;
	   8'h2b:	wb_rf_dout <= #1 ch4_conf[0] ? ch4_am0    : 32'h0;
	   8'h2c:	wb_rf_dout <= #1 ch4_conf[0] ? ch4_adr1   : 32'h0;
	   8'h2d:	wb_rf_dout <= #1 ch4_conf[0] ? ch4_am1    : 32'h0;
	   8'h2e:	wb_rf_dout <= #1 ch4_conf[0] ? pointer4   : 32'h0;
	   8'h2f:	wb_rf_dout <= #1 ch4_conf[0] ? sw_pointer4   : 32'h0;

	   8'h30:	wb_rf_dout <= #1 ch5_conf[0] ? ch5_csr    : 32'h0;
	   8'h31:	wb_rf_dout <= #1 ch5_conf[0] ? ch5_txsz   : 32'h0;
	   8'h32:	wb_rf_dout <= #1 ch5_conf[0] ? ch5_adr0   : 32'h0;
	   8'h33:	wb_rf_dout <= #1 ch5_conf[0] ? ch5_am0    : 32'h0;
	   8'h34:	wb_rf_dout <= #1 ch5_conf[0] ? ch5_adr1   : 32'h0;
	   8'h35:	wb_rf_dout <= #1 ch5_conf[0] ? ch5_am1    : 32'h0;
	   8'h36:	wb_rf_dout <= #1 ch5_conf[0] ? pointer5   : 32'h0;
	   8'h37:	wb_rf_dout <= #1 ch5_conf[0] ? sw_pointer5   : 32'h0;

	   8'h38:	wb_rf_dout <= #1 ch6_conf[0] ? ch6_csr    : 32'h0;
	   8'h39:	wb_rf_dout <= #1 ch6_conf[0] ? ch6_txsz   : 32'h0;
	   8'h3a:	wb_rf_dout <= #1 ch6_conf[0] ? ch6_adr0   : 32'h0;
	   8'h3b:	wb_rf_dout <= #1 ch6_conf[0] ? ch6_am0    : 32'h0;
	   8'h3c:	wb_rf_dout <= #1 ch6_conf[0] ? ch6_adr1   : 32'h0;
	   8'h3d:	wb_rf_dout <= #1 ch6_conf[0] ? ch6_am1    : 32'h0;
	   8'h3e:	wb_rf_dout <= #1 ch6_conf[0] ? pointer6   : 32'h0;
	   8'h3f:	wb_rf_dout <= #1 ch6_conf[0] ? sw_pointer6   : 32'h0;

	   8'h40:	wb_rf_dout <= #1 ch7_conf[0] ? ch7_csr    : 32'h0;
	   8'h41:	wb_rf_dout <= #1 ch7_conf[0] ? ch7_txsz   : 32'h0;
	   8'h42:	wb_rf_dout <= #1 ch7_conf[0] ? ch7_adr0   : 32'h0;
	   8'h43:	wb_rf_dout <= #1 ch7_conf[0] ? ch7_am0    : 32'h0;
	   8'h44:	wb_rf_dout <= #1 ch7_conf[0] ? ch7_adr1   : 32'h0;
	   8'h45:	wb_rf_dout <= #1 ch7_conf[0] ? ch7_am1    : 32'h0;
	   8'h46:	wb_rf_dout <= #1 ch7_conf[0] ? pointer7   : 32'h0;
	   8'h47:	wb_rf_dout <= #1 ch7_conf[0] ? sw_pointer7   : 32'h0;

	endcase


////////////////////////////////////////////////////////////////////
//
// WISHBONE Register Write Logic
// And DMA Engine register Update Logic
//

// Global Registers
assign csr_we		= wb_rf_we & (wb_rf_adr == 8'h0);
assign int_maska_we	= wb_rf_we & (wb_rf_adr == 8'h1);
assign int_maskb_we	= wb_rf_we & (wb_rf_adr == 8'h2);

// ---------------------------------------------------

always @(posedge clk or negedge rst)
	if(!rst)		csr_r <= #1 8'h0;
	else
	if(csr_we)		csr_r <= #1 wb_rf_din[7:0];

// ---------------------------------------------------
// INT_MASK
always @(posedge clk or negedge rst)
	if(!rst)		int_maska_r <= #1 31'h0;
	else
	if(int_maska_we)	int_maska_r <= #1 wb_rf_din[7:0];

always @(posedge clk or negedge rst)
	if(!rst)		int_maskb_r <= #1 31'h0;
	else
	if(int_maskb_we)	int_maskb_r <= #1 wb_rf_din[7:0];

////////////////////////////////////////////////////////////////////
//
// Interrupts
//

assign int_srca = {1'b0, (int_maska_r & ch_int) };
assign int_srcb = {1'b0, (int_maskb_r & ch_int) };

// Interrupt Outputs
always @(posedge clk)
	inta_o <= #1 |int_srca;

always @(posedge clk)
	intb_o <= #1 |int_srcb;

////////////////////////////////////////////////////////////////////
//
// Channel Register File
//

// chXX_conf = { CBUF, ED, ARS, EN }

wb_dma_ch_rf #(0, ch0_conf[0], ch0_conf[1], ch0_conf[2], ch0_conf[3]) u0(
		.clk(		clk		),
		.rst(		rst		),
		.pointer(	pointer0	),
		.pointer_s(	pointer0_s	),
		.ch_csr(	ch0_csr		),
		.ch_txsz(	ch0_txsz	),
		.ch_adr0(	ch0_adr0	),
		.ch_adr1(	ch0_adr1	),
		.ch_am0(	ch0_am0		),
		.ch_am1(	ch0_am1		),
		.sw_pointer(	sw_pointer0	),
		.ch_stop(	ch_stop[0]	),
		.ch_dis(	ch_dis[0]	),
		.int(		ch_int[0]	),
		.wb_rf_din(	wb_rf_din	),
		.wb_rf_adr(	wb_rf_adr	),
		.wb_rf_we(	wb_rf_we	),
		.wb_rf_re(	wb_rf_re	),
		.ch_sel(	ch_sel		),
		.ndnr(		ndnr[0]		),
		.dma_busy(	dma_busy	),
		.dma_err(	dma_err		),
		.dma_done(	dma_done	),
		.dma_done_all(	dma_done_all	),
		.de_csr(	de_csr		),
		.de_txsz(	de_txsz		),
		.de_adr0(	de_adr0		),
		.de_adr1(	de_adr1		),
		.de_csr_we(	de_csr_we	),
		.de_txsz_we(	de_txsz_we	),
		.de_adr0_we(	de_adr0_we	),
		.de_adr1_we(	de_adr1_we	),
		.de_fetch_descr(de_fetch_descr	),
		.dma_rest(	dma_rest[0]	),
		.ptr_set(	ptr_set		)
		);

wb_dma_ch_rf #(1, ch1_conf[0], ch1_conf[1], ch1_conf[2], ch1_conf[3]) u1(
		.clk(		clk		),
		.rst(		rst		),
		.pointer(	pointer1	),
		.pointer_s(	pointer1_s	),
		.ch_csr(	ch1_csr		),
		.ch_txsz(	ch1_txsz	),
		.ch_adr0(	ch1_adr0	),
		.ch_adr1(	ch1_adr1	),
		.ch_am0(	ch1_am0		),
		.ch_am1(	ch1_am1		),
		.sw_pointer(	sw_pointer1	),
		.ch_stop(	ch_stop[1]	),
		.ch_dis(	ch_dis[1]	),
		.int(		ch_int[1]	),
		.wb_rf_din(	wb_rf_din	),
		.wb_rf_adr(	wb_rf_adr	),
		.wb_rf_we(	wb_rf_we	),
		.wb_rf_re(	wb_rf_re	),
		.ch_sel(	ch_sel		),
		.ndnr(		ndnr[1]		),
		.dma_busy(	dma_busy	),
		.dma_err(	dma_err		),
		.dma_done(	dma_done	),
		.dma_done_all(	dma_done_all	),
		.de_csr(	de_csr		),
		.de_txsz(	de_txsz		),
		.de_adr0(	de_adr0		),
		.de_adr1(	de_adr1		),
		.de_csr_we(	de_csr_we	),
		.de_txsz_we(	de_txsz_we	),
		.de_adr0_we(	de_adr0_we	),
		.de_adr1_we(	de_adr1_we	),
		.de_fetch_descr(de_fetch_descr	),
		.dma_rest(	dma_rest[1]	),
		.ptr_set(	ptr_set		)
		);

wb_dma_ch_rf #(2, ch2_conf[0], ch2_conf[1], ch2_conf[2], ch2_conf[3]) u2(
		.clk(		clk		),
		.rst(		rst		),
		.pointer(	pointer2	),
		.pointer_s(	pointer2_s	),
		.ch_csr(	ch2_csr		),
		.ch_txsz(	ch2_txsz	),
		.ch_adr0(	ch2_adr0	),
		.ch_adr1(	ch2_adr1	),
		.ch_am0(	ch2_am0		),
		.ch_am1(	ch2_am1		),
		.sw_pointer(	sw_pointer2	),
		.ch_stop(	ch_stop[2]	),
		.ch_dis(	ch_dis[2]	),
		.int(		ch_int[2]	),
		.wb_rf_din(	wb_rf_din	),
		.wb_rf_adr(	wb_rf_adr	),
		.wb_rf_we(	wb_rf_we	),
		.wb_rf_re(	wb_rf_re	),
		.ch_sel(	ch_sel		),
		.ndnr(		ndnr[2]		),
		.dma_busy(	dma_busy	),
		.dma_err(	dma_err		),
		.dma_done(	dma_done	),
		.dma_done_all(	dma_done_all	),
		.de_csr(	de_csr		),
		.de_txsz(	de_txsz		),
		.de_adr0(	de_adr0		),
		.de_adr1(	de_adr1		),
		.de_csr_we(	de_csr_we	),
		.de_txsz_we(	de_txsz_we	),
		.de_adr0_we(	de_adr0_we	),
		.de_adr1_we(	de_adr1_we	),
		.de_fetch_descr(de_fetch_descr	),
		.dma_rest(	dma_rest[2]	),
		.ptr_set(	ptr_set		)
		);

wb_dma_ch_rf #(3, ch3_conf[0], ch3_conf[1], ch3_conf[2], ch3_conf[3]) u3(
		.clk(		clk		),
		.rst(		rst		),
		.pointer(	pointer3	),
		.pointer_s(	pointer3_s	),
		.ch_csr(	ch3_csr		),
		.ch_txsz(	ch3_txsz	),
		.ch_adr0(	ch3_adr0	),
		.ch_adr1(	ch3_adr1	),
		.ch_am0(	ch3_am0		),
		.ch_am1(	ch3_am1		),
		.sw_pointer(	sw_pointer3	),
		.ch_stop(	ch_stop[3]	),
		.ch_dis(	ch_dis[3]	),
		.int(		ch_int[3]	),
		.wb_rf_din(	wb_rf_din	),
		.wb_rf_adr(	wb_rf_adr	),
		.wb_rf_we(	wb_rf_we	),
		.wb_rf_re(	wb_rf_re	),
		.ch_sel(	ch_sel		),
		.ndnr(		ndnr[3]		),
		.dma_busy(	dma_busy	),
		.dma_err(	dma_err		),
		.dma_done(	dma_done	),
		.dma_done_all(	dma_done_all	),
		.de_csr(	de_csr		),
		.de_txsz(	de_txsz		),
		.de_adr0(	de_adr0		),
		.de_adr1(	de_adr1		),
		.de_csr_we(	de_csr_we	),
		.de_txsz_we(	de_txsz_we	),
		.de_adr0_we(	de_adr0_we	),
		.de_adr1_we(	de_adr1_we	),
		.de_fetch_descr(de_fetch_descr	),
		.dma_rest(	dma_rest[3]	),
		.ptr_set(	ptr_set		)
		);

wb_dma_ch_rf #(4, ch4_conf[0], ch4_conf[1], ch4_conf[2], ch4_conf[3]) u4(
		.clk(		clk		),
		.rst(		rst		),
		.pointer(	pointer4	),
		.pointer_s(	pointer4_s	),
		.ch_csr(	ch4_csr		),
		.ch_txsz(	ch4_txsz	),
		.ch_adr0(	ch4_adr0	),
		.ch_adr1(	ch4_adr1	),
		.ch_am0(	ch4_am0		),
		.ch_am1(	ch4_am1		),
		.sw_pointer(	sw_pointer4	),
		.ch_stop(	ch_stop[4]	),
		.ch_dis(	ch_dis[4]	),
		.int(		ch_int[4]	),
		.wb_rf_din(	wb_rf_din	),
		.wb_rf_adr(	wb_rf_adr	),
		.wb_rf_we(	wb_rf_we	),
		.wb_rf_re(	wb_rf_re	),
		.ch_sel(	ch_sel		),
		.ndnr(		ndnr[4]		),
		.dma_busy(	dma_busy	),
		.dma_err(	dma_err		),
		.dma_done(	dma_done	),
		.dma_done_all(	dma_done_all	),
		.de_csr(	de_csr		),
		.de_txsz(	de_txsz		),
		.de_adr0(	de_adr0		),
		.de_adr1(	de_adr1		),
		.de_csr_we(	de_csr_we	),
		.de_txsz_we(	de_txsz_we	),
		.de_adr0_we(	de_adr0_we	),
		.de_adr1_we(	de_adr1_we	),
		.de_fetch_descr(de_fetch_descr	),
		.dma_rest(	dma_rest[4]	),
		.ptr_set(	ptr_set		)
		);

wb_dma_ch_rf #(5, ch5_conf[0], ch5_conf[1], ch5_conf[2], ch5_conf[3]) u5(
		.clk(		clk		),
		.rst(		rst		),
		.pointer(	pointer5	),
		.pointer_s(	pointer5_s	),
		.ch_csr(	ch5_csr		),
		.ch_txsz(	ch5_txsz	),
		.ch_adr0(	ch5_adr0	),
		.ch_adr1(	ch5_adr1	),
		.ch_am0(	ch5_am0		),
		.ch_am1(	ch5_am1		),
		.sw_pointer(	sw_pointer5	),
		.ch_stop(	ch_stop[5]	),
		.ch_dis(	ch_dis[5]	),
		.int(		ch_int[5]	),
		.wb_rf_din(	wb_rf_din	),
		.wb_rf_adr(	wb_rf_adr	),
		.wb_rf_we(	wb_rf_we	),
		.wb_rf_re(	wb_rf_re	),
		.ch_sel(	ch_sel		),
		.ndnr(		ndnr[5]		),
		.dma_busy(	dma_busy	),
		.dma_err(	dma_err		),
		.dma_done(	dma_done	),
		.dma_done_all(	dma_done_all	),
		.de_csr(	de_csr		),
		.de_txsz(	de_txsz		),
		.de_adr0(	de_adr0		),
		.de_adr1(	de_adr1		),
		.de_csr_we(	de_csr_we	),
		.de_txsz_we(	de_txsz_we	),
		.de_adr0_we(	de_adr0_we	),
		.de_adr1_we(	de_adr1_we	),
		.de_fetch_descr(de_fetch_descr	),
		.dma_rest(	dma_rest[5]	),
		.ptr_set(	ptr_set		)
		);

wb_dma_ch_rf #(6, ch6_conf[0], ch6_conf[1], ch6_conf[2], ch6_conf[3]) u6(
		.clk(		clk		),
		.rst(		rst		),
		.pointer(	pointer6	),
		.pointer_s(	pointer6_s	),
		.ch_csr(	ch6_csr		),
		.ch_txsz(	ch6_txsz	),
		.ch_adr0(	ch6_adr0	),
		.ch_adr1(	ch6_adr1	),
		.ch_am0(	ch6_am0		),
		.ch_am1(	ch6_am1		),
		.sw_pointer(	sw_pointer6	),
		.ch_stop(	ch_stop[6]	),
		.ch_dis(	ch_dis[6]	),
		.int(		ch_int[6]	),
		.wb_rf_din(	wb_rf_din	),
		.wb_rf_adr(	wb_rf_adr	),
		.wb_rf_we(	wb_rf_we	),
		.wb_rf_re(	wb_rf_re	),
		.ch_sel(	ch_sel		),
		.ndnr(		ndnr[6]		),
		.dma_busy(	dma_busy	),
		.dma_err(	dma_err		),
		.dma_done(	dma_done	),
		.dma_done_all(	dma_done_all	),
		.de_csr(	de_csr		),
		.de_txsz(	de_txsz		),
		.de_adr0(	de_adr0		),
		.de_adr1(	de_adr1		),
		.de_csr_we(	de_csr_we	),
		.de_txsz_we(	de_txsz_we	),
		.de_adr0_we(	de_adr0_we	),
		.de_adr1_we(	de_adr1_we	),
		.de_fetch_descr(de_fetch_descr	),
		.dma_rest(	dma_rest[6]	),
		.ptr_set(	ptr_set		)
		);

wb_dma_ch_rf #(7, ch7_conf[0], ch7_conf[1], ch7_conf[2], ch7_conf[3]) u7(
		.clk(		clk		),
		.rst(		rst		),
		.pointer(	pointer7	),
		.pointer_s(	pointer7_s	),
		.ch_csr(	ch7_csr		),
		.ch_txsz(	ch7_txsz	),
		.ch_adr0(	ch7_adr0	),
		.ch_adr1(	ch7_adr1	),
		.ch_am0(	ch7_am0		),
		.ch_am1(	ch7_am1		),
		.sw_pointer(	sw_pointer7	),
		.ch_stop(	ch_stop[7]	),
		.ch_dis(	ch_dis[7]	),
		.int(		ch_int[7]	),
		.wb_rf_din(	wb_rf_din	),
		.wb_rf_adr(	wb_rf_adr	),
		.wb_rf_we(	wb_rf_we	),
		.wb_rf_re(	wb_rf_re	),
		.ch_sel(	ch_sel		),
		.ndnr(		ndnr[7]		),
		.dma_busy(	dma_busy	),
		.dma_err(	dma_err		),
		.dma_done(	dma_done	),
		.dma_done_all(	dma_done_all	),
		.de_csr(	de_csr		),
		.de_txsz(	de_txsz		),
		.de_adr0(	de_adr0		),
		.de_adr1(	de_adr1		),
		.de_csr_we(	de_csr_we	),
		.de_txsz_we(	de_txsz_we	),
		.de_adr0_we(	de_adr0_we	),
		.de_adr1_we(	de_adr1_we	),
		.de_fetch_descr(de_fetch_descr	),
		.dma_rest(	dma_rest[7]	),
		.ptr_set(	ptr_set		)
		);


endmodule
