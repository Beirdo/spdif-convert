/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores         Simple Programmable Interrupt Controller ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2002 Richard Herveille                        ////
////                    richard@asics.ws                         ////
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
//  $Id: simple_pic.v,v 1.3 2002-12-24 10:26:51 rherveille Exp $
//
//  $Date: 2002-12-24 10:26:51 $
//  $Revision: 1.3 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.2  2002/12/22 16:11:03  rherveille
//               *** empty log message ***
//
//



//
// This is a simple Programmable Interrupt Controller.
// The number of interrupts is depending on the databus size.
// There's one interrupt input per databit (i.e. 16 interrupts for a 16
// bit databus).
// All attached devices share the same CPU priority level.
//
//
//
// Registers:
//
// 0x00: EdgeEnable Register
//       bits 7:0 R/W  Edge Enable '1' = edge triggered interrupt source
//                                 '0' = level triggered interrupt source
// 0x01: PolarityRegister
//       bits 7:0 R/W Polarity     '1' = high level / rising edge
//                                 '0' = low level / falling edge
// 0x02: MaskRegister
//       bits 7:0 R/W Mask         '1' = interrupt masked (disabled)
//                                 '0' = interrupt not masked (enabled)
// 0x03: PendingRegister
//       bits 7:0 R/W Pending      '1' = interrupt pending
//                                 '0' = no interrupt pending
//
// A CPU interrupt is generated when an interrupt is pending and its
// MASK bit is cleared.
//
//
//
// HOWTO:
//
// Clearing pending interrupts:
// Writing a '1' to a bit in the interrupt pending register clears the
// interrupt. Make sure to clear the interrupt at the source before
// writing to the interrupt pending register. Otherwise the interrupt
// will be set again.
//
// Priority based interrupts:
// Upon reception of an interrupt, check the interrupt register and
// determine the highest priority interrupt. Mask all interrupts from the
// current level to the lowest level. This negates the interrupt line, and
// makes sure only interrupts with a higher level are triggered. After
// completion of the interrupt service routine, clear the interrupt source,
// the interrupt bit in the pending register, and restore the MASK register
// to it's previous state.
//
// Addapt the core for fewer interrupt sources:
// If less than 8 interrupt sources are required, than the 'is' parameter
// can be set to the amount of required interrupts. Interrupts are mapped
// starting at the LSBs. So only the 'is' LSBs per register are valid. All
// other bits (i.e. the 8-'is' MSBs) are set to zero '0'.
// Codesize is approximately linear to the amount of interrupts. I.e. using
// 4 instead of 8 interrupt sources reduces the size by approx. half.
//


// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module simple_pic(
  clk_i, rst_i, cyc_i, stb_i, adr_i, we_i, dat_i, dat_o, ack_o, int_o,
  irq
);

  // ========================================================
  // Log 2
  // ========================================================

  function [31:0] log2;
  input    [31:0] num;
  integer i;

  begin
    log2 = 32'd0;
    for (i=0; i<30; i=i+1)
      if ((2**i > num) && (log2 == 0))
        log2 = i-1;
  end
  endfunction


  parameter SOURCE_COUNT = 16;  // Number of interrupt sources
  parameter REG_WIDTH = 8;	// Number of sources per interrupt out
  localparam BANKS = SOURCE_COUNT / REG_WIDTH;
  localparam BANK_ADDR_WIDTH = log2(BANKS);
  localparam REG_ADDR_WIDTH  = 2 + log2(REG_WIDTH) - 3;
  localparam ADDR_WIDTH = BANK_ADDR_WIDTH + REG_ADDR_WIDTH;

initial
begin
   $display("SOURCE_COUNT: %d, REG_WIDTH: %d", SOURCE_COUNT, REG_WIDTH);
   $display("BANKS: %d, BANK_ADDR_WIDTH: %d, REG_ADDR_WIDTH: %d, ADDR_WIDTH: %d", BANKS, BANK_ADDR_WIDTH, REG_ADDR_WIDTH, ADDR_WIDTH);
end

  //
  // Inputs & outputs
  //

  // 8bit WISHBONE bus slave interface
  input                      clk_i;  // clock
  input                      rst_i;  // reset (asynchronous active low)
  input                      cyc_i;  // cycle
  input                      stb_i;  // strobe  (cycle and strobe are same signal)
  input  [ADDR_WIDTH-1:0]    adr_i;  // address
  input                      we_i;   // write enable
  input  [REG_WIDTH-1:0]     dat_i;  // data output
  output [REG_WIDTH-1:0]     dat_o;  // data input
  output                     ack_o;  // normal bus termination

  output [BANKS-1:0]         int_o;  // interrupt output

  //
  // Interrupt sources
  //
  input  [SOURCE_COUNT-1:0] irq; // interrupt request inputs

  wire  [REG_WIDTH-1:0] irqs [BANKS-1:0]; // interrupt request inputs

  genvar j; 
  generate for (j=0; j<BANKS; j=j+1)
  begin : irqsplit
    assign irqs[j] = irq[REG_WIDTH*j+(REG_WIDTH-1):REG_WIDTH*j];
  end
  endgenerate

  //
  //  Module body
  //
  reg  [REG_WIDTH-1:0] pol    [BANKS-1:0],
                       edgen  [BANKS-1:0],
                       pending[BANKS-1:0],
                       mask   [BANKS-1:0];  // register bank
  reg  [REG_WIDTH-1:0] lirq   [BANKS-1:0],  // latched irqd
                       dirq   [BANKS-1:0];  // delayed latched irqs

  integer i;
  integer irqbank;

  wire [BANK_ADDR_WIDTH-1:0] bank_addr;
  wire [1:0]                 reg_addr;

  assign bank_addr = adr_i[ADDR_WIDTH-1 -: BANK_ADDR_WIDTH];
  assign reg_addr  = adr_i[REG_ADDR_WIDTH-1 -: 2];

  always @(bank_addr)
    irqbank = bank_addr;

  always @(posedge clk_i)
  begin
    for (i=0;i<BANKS;i=i+1)
    begin
      // latch interrupt inputs
      lirq[i] <= #1 irqs[i];
    end
  end

  always @(posedge clk_i)
  begin
    for (i=0;i<BANKS;i=i+1)
    begin
      // generate delayed latched irqs
      dirq[i] <= #1 lirq[i];
    end
  end

  //
  // generate actual triggers
  function trigger;
    input edgen, pol, lirq, dirq;

    reg   edge_irq, level_irq;
  begin
      edge_irq  = pol ? (lirq & ~dirq) : (dirq & ~lirq);
      level_irq = pol ? lirq : ~lirq;

      trigger = edgen ? edge_irq : level_irq;
  end
  endfunction

  reg  [REG_WIDTH-1:0] irq_event [BANKS-1:0];
  integer n;
  always @(posedge clk_i)
  begin
    for(i=0; i<BANKS; i=i+1)
    begin    
      for(n=0; n<REG_WIDTH; n=n+1)
      begin
        irq_event[i][n] <= #1 trigger(edgen[i][n], pol[i][n], lirq[i][n],
                                      dirq[i][n]);
      end
    end
  end

  //
  // generate wishbone register bank writes
  wire wb_acc = cyc_i & stb_i;                   // WISHBONE access
  wire wb_wr  = wb_acc & we_i;                   // WISHBONE write access

  always @(posedge clk_i)
  begin
    if (~rst_i)
    begin
      for (i=0; i<BANKS; i=i+1)
      begin
        pol[i]   <= #1 {{REG_WIDTH}{1'b0}}; // clear polarity register
        edgen[i] <= #1 {{REG_WIDTH}{1'b0}}; // clear edge enable register
        mask[i]  <= #1 {{REG_WIDTH}{1'b1}}; // mask all interrupts
      end
    end
    else if(wb_wr) // wishbone write cycle??
    begin
      case (reg_addr) // synopsys full_case parallel_case
        2'b00: edgen[irqbank] <= #1 dat_i; // EDGE-ENABLE register
        2'b01: pol[irqbank]   <= #1 dat_i; // POLARITY register
        2'b10: mask[irqbank]  <= #1 dat_i; // MASK register
        2'b11: ;             // PENDING register is a special case (see below)
      endcase
    end
  end

  // pending register is a special case
  always @(posedge clk_i)
  begin
    for (i=0; i<BANKS; i=i+1)
    begin
      if (~rst_i)
        pending[i] <= #1 {{REG_WIDTH}{1'b0}};  // clear all pending interrupts
      else if ( wb_wr & (&reg_addr) )
        pending[i] <= #1 (pending[i] & ~dat_i) | irq_event[i];
      else
        pending[i] <= #1 pending[i] | irq_event[i];
    end
  end

  //
  // generate dat_o
  reg [REG_WIDTH-1:0] dat_o;  // data input
  always @(posedge clk_i)
  begin
    case (reg_addr) // synopsys full_case parallel_case
      2'b00: dat_o <= #1 edgen[irqbank];
      2'b01: dat_o <= #1 pol[irqbank];
      2'b10: dat_o <= #1 mask[irqbank];
      2'b11: dat_o <= #1 pending[irqbank];
    endcase
  end

  //
  // generate ack_o
  reg ack_o;
  always @(posedge clk_i)
    if (~rst_i)
      ack_o <= 1'b0;
    else
      ack_o <= #1 wb_acc & !ack_o;

  //
  // generate CPU interrupt signal
  reg [BANKS-1:0] int_o;
  always @(posedge clk_i)
    for (i=0;i<BANKS;i=i+1)
    begin
      int_o[i] <= #1 |(pending[i] & ~mask[i]);
    end

endmodule

