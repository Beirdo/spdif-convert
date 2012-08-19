/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE DMA Top Level                                     ////
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
//  $Id: wb_dma_top.v,v 1.5 2002-02-01 01:54:45 rudi Exp $
//
//  $Date: 2002-02-01 01:54:45 $
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
//               Revision 1.3  2001/09/07 15:34:38  rudi
//
//               Changed reset to active high.
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
//               Revision 1.3  2001/06/13 02:26:50  rudi
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
//               Revision 1.1.1.1  2001/03/19 13:10:23  rudi
//               Initial Release
//
//
//

`include "wb_dma_defines.v"

module wb_dma_top(clk_i, rst_i,

	wb0s_data_i, wb0s_data_o, wb0_addr_i, wb0_sel_i, wb0_we_i, wb0_cyc_i,
	wb0_stb_i, wb0_ack_o, wb0_err_o, wb0_rty_o,
	wb0m_data_i, wb0m_data_o, wb0_addr_o, wb0_sel_o, wb0_we_o, wb0_cyc_o,
	wb0_stb_o, wb0_ack_i, wb0_err_i, wb0_rty_i,

	wb1s_data_i, wb1s_data_o, wb1_addr_i, wb1_sel_i, wb1_we_i, wb1_cyc_i,
	wb1_stb_i, wb1_ack_o, wb1_err_o, wb1_rty_o,
	wb1m_data_i, wb1m_data_o, wb1_addr_o, wb1_sel_o, wb1_we_o, wb1_cyc_o,
	wb1_stb_o, wb1_ack_i, wb1_err_i, wb1_rty_i,

	dma_req_i, dma_ack_o, dma_nd_i, dma_rest_i,

	inta_o, intb_o
	);

////////////////////////////////////////////////////////////////////
//
// Module Parameters
//

// chXX_conf = { CBUF, ED, ARS, EN }
parameter		rf_addr = 0;
parameter	[1:0]	pri_sel = 2'h0;
parameter		ch_count = 1;
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

input		clk_i, rst_i;

// --------------------------------------
// WISHBONE INTERFACE 0

// Slave Interface
input	[31:0]	wb0s_data_i;
output	[31:0]	wb0s_data_o;
input	[31:0]	wb0_addr_i;
input	[3:0]	wb0_sel_i;
input		wb0_we_i;
input		wb0_cyc_i;
input		wb0_stb_i;
output		wb0_ack_o;
output		wb0_err_o;
output		wb0_rty_o;

// Master Interface
input	[31:0]	wb0m_data_i;
output	[31:0]	wb0m_data_o;
output	[31:0]	wb0_addr_o;
output	[3:0]	wb0_sel_o;
output		wb0_we_o;
output		wb0_cyc_o;
output		wb0_stb_o;
input		wb0_ack_i;
input		wb0_err_i;
input		wb0_rty_i;

// --------------------------------------
// WISHBONE INTERFACE 1

// Slave Interface
input	[31:0]	wb1s_data_i;
output	[31:0]	wb1s_data_o;
input	[31:0]	wb1_addr_i;
input	[3:0]	wb1_sel_i;
input		wb1_we_i;
input		wb1_cyc_i;
input		wb1_stb_i;
output		wb1_ack_o;
output		wb1_err_o;
output		wb1_rty_o;

// Master Interface
input	[31:0]	wb1m_data_i;
output	[31:0]	wb1m_data_o;
output	[31:0]	wb1_addr_o;
output	[3:0]	wb1_sel_o;
output		wb1_we_o;
output		wb1_cyc_o;
output		wb1_stb_o;
input		wb1_ack_i;
input		wb1_err_i;
input		wb1_rty_i;

// --------------------------------------
// Misc Signals
input	[ch_count-1:0]	dma_req_i;
input	[ch_count-1:0]	dma_nd_i;
output	[ch_count-1:0]	dma_ack_o;
input	[ch_count-1:0]	dma_rest_i;
output			inta_o;
output			intb_o;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

wire	[31:0]	pointer0, pointer0_s, ch0_csr, ch0_txsz, ch0_adr0, ch0_adr1, ch0_am0, ch0_am1;
wire	[31:0]	pointer1, pointer1_s, ch1_csr, ch1_txsz, ch1_adr0, ch1_adr1, ch1_am0, ch1_am1;
wire	[31:0]	pointer2, pointer2_s, ch2_csr, ch2_txsz, ch2_adr0, ch2_adr1, ch2_am0, ch2_am1;
wire	[31:0]	pointer3, pointer3_s, ch3_csr, ch3_txsz, ch3_adr0, ch3_adr1, ch3_am0, ch3_am1;
wire	[31:0]	pointer4, pointer4_s, ch4_csr, ch4_txsz, ch4_adr0, ch4_adr1, ch4_am0, ch4_am1;
wire	[31:0]	pointer5, pointer5_s, ch5_csr, ch5_txsz, ch5_adr0, ch5_adr1, ch5_am0, ch5_am1;
wire	[31:0]	pointer6, pointer6_s, ch6_csr, ch6_txsz, ch6_adr0, ch6_adr1, ch6_am0, ch6_am1;
wire	[31:0]	pointer7, pointer7_s, ch7_csr, ch7_txsz, ch7_adr0, ch7_adr1, ch7_am0, ch7_am1;

wire	[2:0]	ch_sel;		// Write Back Channel Select
wire	[7:0]	ndnr;		// Next Descriptor No Request
wire		de_start;	// Start DMA Engine
wire		ndr;		// Next Descriptor With Request
wire	[31:0]	csr;		// Selected Channel CSR
wire	[31:0]	pointer;
wire	[31:0]	pointer_s;
wire	[31:0]	txsz;		// Selected Channel Transfer Size
wire	[31:0]	adr0, adr1;	// Selected Channel Addresses
wire	[31:0]	am0, am1;	// Selected Channel Address Masks
wire		next_ch;	// Indicates the DMA Engine is done

wire		inta_o, intb_o;
wire		dma_abort;
wire		dma_busy, dma_err, dma_done, dma_done_all;
wire	[31:0]	de_csr;
wire	[11:0]	de_txsz;
wire	[31:0]	de_adr0;
wire	[31:0]	de_adr1;
wire		de_csr_we, de_txsz_we, de_adr0_we, de_adr1_we; 
wire		de_fetch_descr;
wire		ptr_set;
wire		de_ack;
wire		pause_req;
wire		paused;

wire		mast0_go;	// Perform a Master Cycle (as long as this
wire		mast0_we;	// Read/Write
wire	[31:0]	mast0_adr;	// Address for the transfer
wire	[31:0]	mast0_din;	// Internal Input Data
wire	[31:0]	mast0_dout;	// Internal Output Data
wire		mast0_err;	// Indicates an error has occurred
wire		mast0_drdy;	// Indicated that either data is available
wire		mast0_wait;	// Tells the master to insert wait cycles

wire	[31:0]	slv0_adr;	// Slave Address
wire	[31:0]	slv0_din;	// Slave Input Data
wire	[31:0]	slv0_dout;	// Slave Output Data
wire		slv0_re;	// Slave Read Enable
wire		slv0_we;	// Slave Write Enable

wire		pt0_sel_i;	// Pass Through Mode Selected
wire	[70:0]	mast0_pt_in;	// Grouped WISHBONE inputs
wire	[34:0]	mast0_pt_out;	// Grouped WISHBONE outputs

wire		pt0_sel_o;	// Pass Through Mode Active
wire	[70:0]	slv0_pt_out;	// Grouped WISHBONE out signals
wire	[34:0]	slv0_pt_in;	// Grouped WISHBONE in signals

wire		mast1_go;	// Perform a Master Cycle (as long as this
wire		mast1_we;	// Read/Write
wire	[31:0]	mast1_adr;	// Address for the transfer
wire	[31:0]	mast1_din;	// Internal Input Data
wire	[31:0]	mast1_dout;	// Internal Output Data
wire		mast1_err;	// Indicates an error has occurred
wire		mast1_drdy;	// Indicated that either data is available
wire		mast1_wait;	// Tells the master to insert wait cycles

wire	[31:0]	slv1_adr;	// Slave Address
wire	[31:0]	slv1_dout;	// Slave Output Data
wire		slv1_re;	// Slave Read Enable
wire		slv1_we;	// Slave Write Enable

wire		pt1_sel_i;	// Pass Through Mode Selected
wire	[70:0]	mast1_pt_in;	// Grouped WISHBONE inputs
wire	[34:0]	mast1_pt_out;	// Grouped WISHBONE outputs

wire		pt1_sel_o;	// Pass Through Mode Active
wire	[70:0]	slv1_pt_out;	// Grouped WISHBONE out signals
wire	[34:0]	slv1_pt_in;	// Grouped WISHBONE in signals

wire	[7:0]	dma_req;
wire	[7:0]	dma_nd;
wire	[7:0]	dma_ack;
wire	[7:0]	dma_rest;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

wire	[31:0]	tmp_gnd = 32'h0;

assign dma_req[ch_count-1:0] = dma_req_i;
assign dma_nd[ch_count-1:0] = dma_nd_i;
assign dma_rest[ch_count-1:0] = dma_rest_i;
assign dma_ack_o = {tmp_gnd[31-ch_count:0], dma_ack[ch_count-1:0]};

// --------------------------------------------------
// This should go in to a separate Pass Through Block
assign pt1_sel_i = pt0_sel_o;
assign pt0_sel_i = pt1_sel_o;
assign mast1_pt_in = slv0_pt_out;
assign slv0_pt_in  = mast1_pt_out;
assign mast0_pt_in = slv1_pt_out;
assign slv1_pt_in  = mast0_pt_out;
// --------------------------------------------------

////////////////////////////////////////////////////////////////////
//
// Modules
//

// DMA Register File
wb_dma_rf   #(	ch0_conf,
		ch1_conf,
		ch2_conf,
		ch3_conf,
		ch4_conf,
		ch5_conf,
		ch6_conf,
		ch7_conf)
		u0(
		.clk(		clk_i		),
		.rst(		~rst_i		),
		.wb_rf_adr(	slv0_adr[9:2]	),
		.wb_rf_din(	slv0_dout	),
		.wb_rf_dout(	slv0_din	),
		.wb_rf_re(	slv0_re		),
		.wb_rf_we(	slv0_we		),
		.inta_o(	inta_o		),
		.intb_o(	intb_o		),
		.pointer0(	pointer0	),
		.pointer0_s(	pointer0_s	),
		.ch0_csr(	ch0_csr		),
		.ch0_txsz(	ch0_txsz	),
		.ch0_adr0(	ch0_adr0	),
		.ch0_adr1(	ch0_adr1	),
		.ch0_am0(	ch0_am0		),
		.ch0_am1(	ch0_am1		),
		.pointer1(	pointer1	),
		.pointer1_s(	pointer1_s	),
		.ch1_csr(	ch1_csr		),
		.ch1_txsz(	ch1_txsz	),
		.ch1_adr0(	ch1_adr0	),
		.ch1_adr1(	ch1_adr1	),
		.ch1_am0(	ch1_am0		),
		.ch1_am1(	ch1_am1		),
		.pointer2(	pointer2	),
		.pointer2_s(	pointer2_s	),
		.ch2_csr(	ch2_csr		),
		.ch2_txsz(	ch2_txsz	),
		.ch2_adr0(	ch2_adr0	),
		.ch2_adr1(	ch2_adr1	),
		.ch2_am0(	ch2_am0		),
		.ch2_am1(	ch2_am1		),
		.pointer3(	pointer3	),
		.pointer3_s(	pointer3_s	),
		.ch3_csr(	ch3_csr		),
		.ch3_txsz(	ch3_txsz	),
		.ch3_adr0(	ch3_adr0	),
		.ch3_adr1(	ch3_adr1	),
		.ch3_am0(	ch3_am0		),
		.ch3_am1(	ch3_am1		),
		.pointer4(	pointer4	),
		.pointer4_s(	pointer4_s	),
		.ch4_csr(	ch4_csr		),
		.ch4_txsz(	ch4_txsz	),
		.ch4_adr0(	ch4_adr0	),
		.ch4_adr1(	ch4_adr1	),
		.ch4_am0(	ch4_am0		),
		.ch4_am1(	ch4_am1		),
		.pointer5(	pointer5	),
		.pointer5_s(	pointer5_s	),
		.ch5_csr(	ch5_csr		),
		.ch5_txsz(	ch5_txsz	),
		.ch5_adr0(	ch5_adr0	),
		.ch5_adr1(	ch5_adr1	),
		.ch5_am0(	ch5_am0		),
		.ch5_am1(	ch5_am1		),
		.pointer6(	pointer6	),
		.pointer6_s(	pointer6_s	),
		.ch6_csr(	ch6_csr		),
		.ch6_txsz(	ch6_txsz	),
		.ch6_adr0(	ch6_adr0	),
		.ch6_adr1(	ch6_adr1	),
		.ch6_am0(	ch6_am0		),
		.ch6_am1(	ch6_am1		),
		.pointer7(	pointer7	),
		.pointer7_s(	pointer7_s	),
		.ch7_csr(	ch7_csr		),
		.ch7_txsz(	ch7_txsz	),
		.ch7_adr0(	ch7_adr0	),
		.ch7_adr1(	ch7_adr1	),
		.ch7_am0(	ch7_am0		),
		.ch7_am1(	ch7_am1		),
		.ch_sel(	ch_sel		),
		.ndnr(		ndnr		),
		.pause_req(	pause_req	),
		.paused(	paused		),
		.dma_abort(	dma_abort	),
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
		.dma_rest(	dma_rest	),
		.ptr_set(	ptr_set		)
		);

// Channel Select
wb_dma_ch_sel #(pri_sel,
		ch0_conf,
		ch1_conf,
		ch2_conf,
		ch3_conf,
		ch4_conf,
		ch5_conf,
		ch6_conf)
		u1(
		.clk(		clk_i		),
		.rst(		~rst_i		),
		.req_i(		dma_req		),
		.ack_o(		dma_ack		),
		.nd_i(		dma_nd		),

		.pointer0(	pointer0	),
		.pointer0_s(	pointer0_s	),
		.ch0_csr(	ch0_csr		),
		.ch0_txsz(	ch0_txsz	),
		.ch0_adr0(	ch0_adr0	),
		.ch0_adr1(	ch0_adr1	),
		.ch0_am0(	ch0_am0		),
		.ch0_am1(	ch0_am1		),
		.pointer1(	pointer1	),
		.pointer1_s(	pointer1_s	),
		.ch1_csr(	ch1_csr		),
		.ch1_txsz(	ch1_txsz	),
		.ch1_adr0(	ch1_adr0	),
		.ch1_adr1(	ch1_adr1	),
		.ch1_am0(	ch1_am0		),
		.ch1_am1(	ch1_am1		),
		.pointer2(	pointer2	),
		.pointer2_s(	pointer2_s	),
		.ch2_csr(	ch2_csr		),
		.ch2_txsz(	ch2_txsz	),
		.ch2_adr0(	ch2_adr0	),
		.ch2_adr1(	ch2_adr1	),
		.ch2_am0(	ch2_am0		),
		.ch2_am1(	ch2_am1		),
		.pointer3(	pointer3	),
		.pointer3_s(	pointer3_s	),
		.ch3_csr(	ch3_csr		),
		.ch3_txsz(	ch3_txsz	),
		.ch3_adr0(	ch3_adr0	),
		.ch3_adr1(	ch3_adr1	),
		.ch3_am0(	ch3_am0		),
		.ch3_am1(	ch3_am1		),
		.pointer4(	pointer4	),
		.pointer4_s(	pointer4_s	),
		.ch4_csr(	ch4_csr		),
		.ch4_txsz(	ch4_txsz	),
		.ch4_adr0(	ch4_adr0	),
		.ch4_adr1(	ch4_adr1	),
		.ch4_am0(	ch4_am0		),
		.ch4_am1(	ch4_am1		),
		.pointer5(	pointer5	),
		.pointer5_s(	pointer5_s	),
		.ch5_csr(	ch5_csr		),
		.ch5_txsz(	ch5_txsz	),
		.ch5_adr0(	ch5_adr0	),
		.ch5_adr1(	ch5_adr1	),
		.ch5_am0(	ch5_am0		),
		.ch5_am1(	ch5_am1		),
		.pointer6(	pointer6	),
		.pointer6_s(	pointer6_s	),
		.ch6_csr(	ch6_csr		),
		.ch6_txsz(	ch6_txsz	),
		.ch6_adr0(	ch6_adr0	),
		.ch6_adr1(	ch6_adr1	),
		.ch6_am0(	ch6_am0		),
		.ch6_am1(	ch6_am1		),
		.pointer7(	pointer7	),
		.pointer7_s(	pointer7_s	),
		.ch7_csr(	ch7_csr		),
		.ch7_txsz(	ch7_txsz	),
		.ch7_adr0(	ch7_adr0	),
		.ch7_adr1(	ch7_adr1	),
		.ch7_am0(	ch7_am0		),
		.ch7_am1(	ch7_am1		),

		.ch_sel(	ch_sel		),
		.ndnr(		ndnr		),
		.de_start(	de_start	),
		.ndr(		ndr		),
		.csr(		csr		),
		.pointer(	pointer		),
		.txsz(		txsz		),
		.adr0(		adr0		),
		.adr1(		adr1		),
		.am0(		am0		),
		.am1(		am1		),
		.pointer_s(	pointer_s	),
		.next_ch(	next_ch		),
		.de_ack(	de_ack		),
		.dma_busy(	dma_busy	)
		);


// DMA Engine
wb_dma_de	u2(
		.clk(		clk_i		),
		.rst(		~rst_i		),
		.mast0_go(	mast0_go	),
		.mast0_we(	mast0_we	),
		.mast0_adr(	mast0_adr	),
		.mast0_din(	mast0_dout	),
		.mast0_dout(	mast0_din	),
		.mast0_err(	mast0_err	),
		.mast0_drdy(	mast0_drdy	),
		.mast0_wait(	mast0_wait	),
		.mast1_go(	mast1_go	),
		.mast1_we(	mast1_we	),
		.mast1_adr(	mast1_adr	),
		.mast1_din(	mast1_dout	),
		.mast1_dout(	mast1_din	),
		.mast1_err(	mast1_err	),
		.mast1_drdy(	mast1_drdy	),
		.mast1_wait(	mast1_wait	),
		.de_start(	de_start	),
		.nd(		ndr		),
		.csr(		csr		),
		.pointer(	pointer		),
		.pointer_s(	pointer_s	),
		.txsz(		txsz		),
		.adr0(		adr0		),
		.adr1(		adr1		),
		.am0(		am0		),
		.am1(		am1		),
		.de_csr_we(	de_csr_we	),
		.de_txsz_we(	de_txsz_we	),
		.de_adr0_we(	de_adr0_we	),
		.de_adr1_we(	de_adr1_we	),
		.de_fetch_descr(de_fetch_descr	),
		.ptr_set(	ptr_set		),
		.de_csr(	de_csr		),
		.de_txsz(	de_txsz		),
		.de_adr0(	de_adr0		),
		.de_adr1(	de_adr1		),
		.next_ch(	next_ch		),
		.de_ack(	de_ack		),
		.pause_req(	pause_req	),
		.paused(	paused		),
		.dma_abort(	dma_abort	),
		.dma_busy(	dma_busy	),
		.dma_err(	dma_err		),
		.dma_done(	dma_done	),
		.dma_done_all(	dma_done_all	)
		);

// Wishbone Interface 0
wb_dma_wb_if	#(rf_addr)	u3(
		.clk(		clk_i		),
		.rst(		~rst_i		),
		.wbs_data_i(	wb0s_data_i	),
		.wbs_data_o(	wb0s_data_o	),
		.wb_addr_i(	wb0_addr_i	),
		.wb_sel_i(	wb0_sel_i	),
		.wb_we_i(	wb0_we_i	),
		.wb_cyc_i(	wb0_cyc_i	),
		.wb_stb_i(	wb0_stb_i	),
		.wb_ack_o(	wb0_ack_o	),
		.wb_err_o(	wb0_err_o	),
		.wb_rty_o(	wb0_rty_o	),
		.wbm_data_i(	wb0m_data_i	),
		.wbm_data_o(	wb0m_data_o	),
		.wb_addr_o(	wb0_addr_o	),
		.wb_sel_o(	wb0_sel_o	),
		.wb_we_o(	wb0_we_o	),
		.wb_cyc_o(	wb0_cyc_o	),
		.wb_stb_o(	wb0_stb_o	),
		.wb_ack_i(	wb0_ack_i	),
		.wb_err_i(	wb0_err_i	),
		.wb_rty_i(	wb0_rty_i	),
		.mast_go(	mast0_go	),
		.mast_we(	mast0_we	),
		.mast_adr(	mast0_adr	),
		.mast_din(	mast0_din	),
		.mast_dout(	mast0_dout	),
		.mast_err(	mast0_err	),
		.mast_drdy(	mast0_drdy	),
		.mast_wait(	mast0_wait	),
		.pt_sel_i(	pt0_sel_i	),
		.mast_pt_in(	mast0_pt_in	),
		.mast_pt_out(	mast0_pt_out	),
		.slv_adr(	slv0_adr	),
		.slv_din(	slv0_din	),
		.slv_dout(	slv0_dout	),
		.slv_re(	slv0_re		),
		.slv_we(	slv0_we		),
		.pt_sel_o(	pt0_sel_o	),
		.slv_pt_out(	slv0_pt_out	),
		.slv_pt_in(	slv0_pt_in	)
		);

// Wishbone Interface 1
wb_dma_wb_if	#(rf_addr) u4(
		.clk(		clk_i		),
		.rst(		~rst_i		),
		.wbs_data_i(	wb1s_data_i	),
		.wbs_data_o(	wb1s_data_o	),
		.wb_addr_i(	wb1_addr_i	),
		.wb_sel_i(	wb1_sel_i	),
		.wb_we_i(	wb1_we_i	),
		.wb_cyc_i(	wb1_cyc_i	),
		.wb_stb_i(	wb1_stb_i	),
		.wb_ack_o(	wb1_ack_o	),
		.wb_err_o(	wb1_err_o	),
		.wb_rty_o(	wb1_rty_o	),
		.wbm_data_i(	wb1m_data_i	),
		.wbm_data_o(	wb1m_data_o	),
		.wb_addr_o(	wb1_addr_o	),
		.wb_sel_o(	wb1_sel_o	),
		.wb_we_o(	wb1_we_o	),
		.wb_cyc_o(	wb1_cyc_o	),
		.wb_stb_o(	wb1_stb_o	),
		.wb_ack_i(	wb1_ack_i	),
		.wb_err_i(	wb1_err_i	),
		.wb_rty_i(	wb1_rty_i	),
		.mast_go(	mast1_go	),
		.mast_we(	mast1_we	),
		.mast_adr(	mast1_adr	),
		.mast_din(	mast1_din	),
		.mast_dout(	mast1_dout	),
		.mast_err(	mast1_err	),
		.mast_drdy(	mast1_drdy	),
		.mast_wait(	mast1_wait	),
		.pt_sel_i(	pt1_sel_i	),
		.mast_pt_in(	mast1_pt_in	),
		.mast_pt_out(	mast1_pt_out	),
		.slv_adr(	slv1_adr	),
		.slv_din(	32'h0		),	// Not Connected
		.slv_dout(	slv1_dout	),	// Not Connected
		.slv_re(	slv1_re		),	// Not Connected
		.slv_we(	slv1_we		),	// Not Connected
		.pt_sel_o(	pt1_sel_o	),
		.slv_pt_out(	slv1_pt_out	),
		.slv_pt_in(	slv1_pt_in	)
		);


endmodule
