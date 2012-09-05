/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores Simple General Purpose IO core                   ////
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
//  $Id: simple_gpio.v,v 1.2 2002-12-22 16:10:17 rherveille Exp $
//
//  $Date: 2002-12-22 16:10:17 $
//  $Revision: 1.2 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//



//
// Very basic 8bit GPIO core
//
//
// Registers:
//
// 0x00: Control Register   <io[7:0]>
//       bits 7:0 R/W Input/Output    '1' = output mode
//                                    '0' = input mode
// 0x01: Line Register
//       bits 7:0 R   Status                Current GPIO pin level
//                W   Output                GPIO pin output level
//
//
// HOWTO:
//
// Use a pin as an input:
// Program the corresponding bit in the control register to 'input mode' ('0').
// The pin's state (input level) can be checked by reading the Line Register.
// Writing to the GPIO pin's Line Register bit while in input mode has no effect.
//
// Use a pin as an output:
// Program the corresponding bit in the control register to 'output mode' ('1').
// Program the GPIO pin's output level by writing to the corresponding bit in
// the Line Register.
// Reading the GPIO pin's Line Register bit while in output mode returns the
// current output level.
//
// Addapt the core for fewer GPIOs:
// If less than 8 GPIOs are required, than the 'io' parameter can be set to
// the amount of required interrupts. GPIOs are mapped starting at the LSBs.
// So only the 'io' LSBs per register are valid.
// All other bits (i.e. the 8-'io' MSBs) are set to zero '0'.
// Codesize is approximately linear to the amount of interrupts. I.e. using
// 4 instead of 8 GPIO sources reduces the size by approx. half.
//


// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module simple_gpio(
  clk_i, rst_i, cyc_i, stb_i, adr_i, we_i, dat_i, dat_o, ack_o,
  gpio, ibase, rst_o
);

  // 8bit WISHBONE bus slave interface
  input         clk_i;         // clock
  input         rst_i;         // reset (asynchronous active low)
  input         cyc_i;         // cycle
  input         stb_i;         // strobe
  input  [ 1:0] adr_i;         // address adr_i[1]
  input         we_i;          // write enable
  input  [ 7:0] dat_i;         // data output
  output [ 7:0] dat_o;         // data input
  output        ack_o;         // normal bus termination

  // GPIO pins
  inout  [7:0]  gpio;
  output [7:0]  ibase;
  output        rst_o;

  //
  // Module body
  //
  reg [7:0] ctrl, line;                  // ControlRegister, LineRegister
  reg [7:0] lgpio, llgpio;               // LatchedGPIO pins

  reg [7:0] instr_base      = 8'h01;     // Instruction base register
  reg       prev_instr_base = 1'b1;      // Previous Instruction base register

  integer reg_num;

  //
  // WISHBONE interface

  wire wb_acc = 1'b1; //cyc_i & stb_i;            // WISHBONE access
  wire wb_wr  = wb_acc & we_i;            // WISHBONE write access

  always @(posedge clk_i)
      if (rst_i)
        begin
            ctrl <= #1 8'b0;
            line <= #1 8'b0;
        end
      else if (wb_wr)
         case (adr_i) // synopsys full_case parallel_case
           2'b00:  ctrl       <= #1 dat_i[7:0];
           2'b01:  line       <= #1 dat_i[7:0];
           2'b10:  instr_base <= #1 dat_i[7:0];
           2'b11: ;
         endcase

  always @(posedge clk_i)
    prev_instr_base <= #1 instr_base[0];

  wire ibase_changed;
  assign ibase_changed = (instr_base[0] ^ prev_instr_base) & ~rst_i;

  wire [7:0] outregs [3:0];

  always @(adr_i)
    reg_num = adr_i;

  assign outregs[0] = ctrl;
  assign outregs[1] = llgpio;
  assign outregs[2] = instr_base;
  assign outregs[3] = 8'b0;

  reg [7:0] dat_o;
  always @(posedge clk_i)
    dat_o <= #1 outregs[reg_num]; 

  assign ack_o = wb_acc;

  reg rst_o;
  always @ (posedge clk_i)
    if (rst_i)
      rst_o <= #1 1'b0;
    else
      rst_o <= #1 ibase_changed;

  //
  // GPIO section

  // latch GPIO input pins
  always @(posedge clk_i)
    lgpio <= #1 gpio;

  // latch again (reduce meta-stability risc)
  always @(posedge clk_i)
    llgpio <= #1 lgpio;

  // assign GPIO outputs
  integer n;
  reg [7:0] igpio; // temporary internal signal

  always @(ctrl or line)
    for(n=0;n<8;n=n+1)
      igpio[n] <= #1 ctrl[n] ? line[n] : 1'bz;

  assign gpio = igpio;

  assign ibase = instr_base;

endmodule

