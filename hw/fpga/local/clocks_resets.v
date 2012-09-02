
//
// Clocks and Resets Module
//

module clocks_resets  (
    input                       i_brd_rst,
    input                       i_brd_clk_n,  
    input                       i_brd_clk_p,  
    output                      o_sys_rst,
    output                      o_sys_clk,
    output                      o_uart_clk,
    input  [1:0]                i_spdif_clk_sel,
    output                      o_spdif_clk
);

localparam                  RST_SYNC_NUM = 25;

wire                        pll1_locked;
wire                        pll2_locked;
wire                        pll3_locked;

wire                        pll23_reset;

(* KEEP = "TRUE" *)  wire brd_clk_ibufg;

IBUFGDS # (  
    .DIFF_TERM  ( "TRUE"     ), 
    .IOSTANDARD ( "LVDS_25"  ))  // SP605 on chip termination of LVDS clock
u_ibufgds_brd
(
    .I  ( i_brd_clk_p    ),
    .IB ( i_brd_clk_n    ),
    .O  ( brd_clk_ibufg  )
);

wire interm_spdif_clk;  // 25.8048MHz to create 44.1kHz SPDIF Clk
 
clk_double u_clk_double (
    .CLK_IN1  ( brd_clk_ibufg    ),
    .CLK_OUT1 ( o_uart_clk       ),
    .CLK_OUT2 ( o_sys_clk        ),
    .CLK_OUT3 ( interm_spdif_clk ),
    .RESET    ( i_brd_rst        ),
    .LOCKED   ( pll1_locked      )
);

wire int_spdif_44k1_clk;    // 45.1584MHz = 44.1kHz SPDIF clk * 8
wire int_spdif_48k_clk;     // 49.152MHz = 48kHz SPDIF clk * 8
wire int_spdif_32k_clk;     // 32.768MHz = 32kHz SPDIF clk * 8

pll_spdif_48k u_clk_spdif_48k (
    .CLK_IN1    ( o_sys_clk         ),  // 36.864MHz system clock
    .CLK_OUT1   ( int_spdif_48k_clk ),
    .CLK_OUT2   ( int_spdif_32k_clk ),
    .RESET      ( pll23_reset       ),
    .LOCKED     ( pll2_locked       )
);

pll_spdif_44k1 u_clk_spdif_44k1 (
    .CLK_IN1    ( interm_spdif_clk   ), // 25.8048 MHz
    .CLK_OUT1   ( int_spdif_44k1_clk ),
    .RESET      ( pll23_reset        ),
    .LOCKED     ( pll3_locked        )
);

assign pll23_reset = i_brd_rst | ~pll1_locked;

wire int_spdif_clk;
assign int_spdif_clk = i_spdif_clk_sel == 2'b00 ? int_spdif_32k_clk  :
                       i_spdif_clk_sel == 2'b01 ? int_spdif_44k1_clk :
                       i_spdif_clk_sel == 2'b10 ? int_spdif_48k_clk  : 1'b0;

BUFG u_spdif_clk_buf
   (.O (o_spdif_clk),
    .I (int_spdif_clk));

// ======================================
// Synchronous reset generation
// ======================================
reg [RST_SYNC_NUM-1:0]      rst0_sync_r    /* synthesis syn_maxfan = 10 */;
wire                        rst_tmp;
wire                        rst0;
wire                        pll_locked;

assign pll_locked = pll1_locked & pll2_locked & pll3_locked;

assign rst0 = rst0_sync_r[RST_SYNC_NUM-1];
assign o_sys_rst = rst0;

assign rst_tmp = i_brd_rst | ~pll_locked;

  // synthesis attribute max_fanout of rst0_sync_r is 10
always @(posedge o_sys_clk or posedge rst_tmp)
    if (rst_tmp)
        rst0_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
        // logical left shift by one (pads with 0)
        rst0_sync_r <= rst0_sync_r << 1;

endmodule

// vim:ts=4:sw=4:ai:et:si:sts=4
