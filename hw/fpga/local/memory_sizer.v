
module memory_sizer (
  clk_i,
  reset_i,

  master_sel_i,
  master_adr_i,
  master_we_i,
  master_dat_i,
  master_dat_o,
  master_ack_o,

  slave_sel_o,
  slave_adr_o,              // Same width as adr_i (only lsbs are modified)
  slave_we_o,
  slave_dat_i,
  slave_dat_o,
  slave_ack_i
);

// Parameters
parameter ADR_WIDTH               = 16;  // # of bits in adr buses

// I/O declarations
input clk_i;           // Memory sub-system clock input
input reset_i;         // Reset signal for this module

input                  master_sel_i;    // activates memory_sizer
input  [ADR_WIDTH-1:0] master_adr_i;    // Address bus input
input                  master_we_i;     // type of access
input  [7:0]           master_dat_i;    // processor data bus
output [7:0]           master_dat_o;    // processor data bus
output                 master_ack_o;    // shows that access is completed


output                 slave_sel_o;     // byte enables to memory
output [ADR_WIDTH-1:0] slave_adr_o;     // address bus to memory
output                 slave_we_o;      // we to memory
input  [31:0]          slave_dat_i;     // data bus to memory
output [31:0]          slave_dat_o;     // data bus to memory
input                  slave_ack_i;     // Ack from memory
                                        // (delay for wait states)

// Internal signal declarations
reg  [7:0]  int_byte_r [3:0];
reg  [3:0]  int_byte_r_used;

reg  [7:0]  int_byte_w [3:0];
reg  [3:0]  int_byte_w_used;

reg  [13:0] prev_addr_base;
wire [13:0] addr_base;
reg         addr_base_changed;
wire [1:0]  reg_addr;
integer     reg_num;
reg  [3:0]  reg_mask;

localparam RSTATE_SIZE = 3;
localparam WSTATE_SIZE = 4;

parameter R_INIT = 3'b001, R_RD_WORD = 3'b010, R_RD_BYTE = 3'b100;
parameter W_INIT = 4'b0001, W_WR_BYTE = 4'b0010, W_RD_WORD = 4'b0100,
          W_WR_WORD = 4'b1000;

(* signal_encoding = "user" *)
(* fsm_encoding = "user" *)
reg  [RSTATE_SIZE-1:0] rstate = R_INIT; // synthesis syn_encoding="onehot"
(* signal_encoding = "user" *)
wire [RSTATE_SIZE-1:0] rstate_next;

(* signal_encoding = "user" *)
(* fsm_encoding = "user" *)
reg  [WSTATE_SIZE-1:0] wstate = W_INIT; // synthesis syn_encoding="onehot"
(* signal_encoding = "user" *)
wire [WSTATE_SIZE-1:0] wstate_next;

wire                   m_rd;
wire                   m_wr;
wire                   s_busy;

//--------------------------------------------------------------------------
// Instantiations
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
// Functions & Tasks
//--------------------------------------------------------------------------
function [RSTATE_SIZE-1:0] rstate_fsm;
    input [RSTATE_SIZE-1:0] state;
    input                   read;
    input                   write;
    input                   busy;
    input                   addr_changed;
    input [3:0]             bytes_used;
    input                   ack;

    case (state)
        R_INIT: 
            if (read & ~busy) begin
                rstate_fsm = R_RD_WORD;
            end
        R_RD_WORD:
            if (ack) begin
                rstate_fsm = R_RD_BYTE;
            end
        R_RD_BYTE:
            if (write | addr_changed | &bytes_used ) begin
                rstate_fsm = R_INIT;
            end
        default:
            rstate_fsm = R_INIT;
    endcase
endfunction

function [WSTATE_SIZE-1:0] wstate_fsm;
    input [WSTATE_SIZE-1:0] state;
    input                   read;
    input                   write;
    input                   busy;
    input                   addr_changed;
    input [3:0]             bytes_used;
    input                   ack;

    case (state)
        W_INIT: 
            if (write) begin
                wstate_fsm = W_WR_BYTE;
            end
        W_WR_BYTE:
            if (read) begin
                wstate_fsm = W_INIT;
            end else if (&bytes_used) begin
                wstate_fsm = W_WR_WORD;
            end else if (addr_changed) begin
                wstate_fsm = W_RD_WORD;
            end
        W_RD_WORD:
            if (ack) begin
                wstate_fsm = W_WR_WORD;
            end
        W_WR_WORD:
            if (ack) begin
                wstate_fsm = W_INIT;
            end
        default:
            wstate_fsm = W_INIT;
    endcase
endfunction

//--------------------------------------------------------------------------
// Module code
//--------------------------------------------------------------------------

assign m_rd = master_sel_i & ~master_we_i;
assign m_wr = master_sel_i &  master_we_i;
assign s_busy = (wstate == W_RD_WORD || wstate == W_WR_WORD);

assign rstate_next = rstate_fsm(rstate, m_rd, m_wr, s_busy, addr_base_changed,
                                int_byte_r_used, slave_ack_i);
assign wstate_next = wstate_fsm(wstate, m_rd, m_wr, s_busy, addr_base_changed,
                                int_byte_w_used, slave_ack_i);

assign addr_base = master_adr_i[15:2];
assign reg_addr  = master_adr_i[1:0];

always @(posedge clk_i)
begin
    if (reset_i)
        prev_addr_base <= 14'b0;
    else
        prev_addr_base <= #1 addr_base;
end

always @(addr_base or prev_addr_base or reset_i)
begin
    if (reset_i)
        addr_base_changed <= 1'b1;
    else
        addr_base_changed <= (addr_base != prev_addr_base);
end

always @(reg_addr)
    reg_num = reg_addr;

always @(reg_num)
    reg_mask <= (1 << reg_num) & 4'b1111;

always @(posedge clk_i)
begin
    if (reset_i) begin
        rstate <= R_INIT;
        wstate <= W_INIT;
    end else begin
        rstate <= rstate_next;
        wstate <= wstate_next;
    end
end

// Generate master_ack_o
assign master_ack_o = master_sel_i &
                      (rstate == R_RD_BYTE || wstate == W_WR_BYTE);

// Generate slave_adr_o
assign slave_adr_o = { addr_base, 2'b0 };

// Generate slave_dat_o
assign slave_dat_o = { int_byte_w[3], int_byte_w[2], int_byte_w[1],
                       int_byte_w[0] };

// Generate int_byte_r
always @(posedge clk_i)
begin
    if (reset_i || (rstate == R_INIT)) begin
        int_byte_r[3] <= 8'b0;
        int_byte_r[2] <= 8'b0;
        int_byte_r[1] <= 8'b0;
        int_byte_r[0] <= 8'b0;
    end else if (rstate == R_RD_WORD) begin
        int_byte_r[3] <= slave_dat_i[31:24];
        int_byte_r[2] <= slave_dat_i[23:16];
        int_byte_r[1] <= slave_dat_i[15:8];
        int_byte_r[0] <= slave_dat_i[7:0];
    end
end

// Generate int_byte_r_used
always @(posedge clk_i)
begin
    if (reset_i || (rstate == R_INIT)) begin
        int_byte_r_used <= 4'b0;
    end else if ((rstate == R_RD_BYTE) & m_rd) begin
        int_byte_r_used <= int_byte_r_used | reg_mask;
    end
end

// Generate int_byte_w
always @(posedge clk_i)
begin
    if (reset_i || (wstate == W_INIT)) begin
        int_byte_w[3] <= 8'b0;
        int_byte_w[2] <= 8'b0;
        int_byte_w[1] <= 8'b0;
        int_byte_w[0] <= 8'b0;
    end else if ((wstate == W_WR_BYTE) & m_wr) begin
        int_byte_w[reg_num] <= master_dat_i;
    end else if (wstate == W_RD_WORD) begin
        if (~int_byte_w_used[3])
            int_byte_w[3] <= slave_dat_i[31:24];
        if (~int_byte_w_used[2])
            int_byte_w[2] <= slave_dat_i[23:16];
        if (~int_byte_w_used[1])
            int_byte_w[1] <= slave_dat_i[15:8];
        if (~int_byte_w_used[0])
            int_byte_w[0] <= slave_dat_i[7:0];
    end
end

// Generate int_byte_w_used
always @(posedge clk_i)
begin
    if (reset_i || (wstate == W_INIT)) begin
        int_byte_w_used <= 4'b0;
    end else if ((wstate == W_WR_BYTE) & m_wr) begin
        int_byte_w_used <= int_byte_w_used | reg_mask;
    end
end

// Generate master_dat_o
assign master_dat_o = int_byte_r[reg_num];

// Generate slave_sel_o
assign slave_sel_o = master_sel_i &
                     (rstate == R_RD_WORD || wstate == W_RD_WORD ||
                      wstate == W_WR_WORD);

// Generate slave_we_o
assign slave_we_o  = m_wr & (wstate == W_WR_WORD);

endmodule

// vim:ts=4:sw=4:ai:et:si:sts=4
