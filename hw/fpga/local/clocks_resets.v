
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
    input                       i_spdif_tx_clk_sel,
    output                      o_spdif_rx_clk,
    output                      o_spdif_tx_clk
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

wire int_spdif_48k_fb;
wire int_spdif_44k1_fb;

pll_spdif_48k u_clk_spdif_48k (
    .CLK_IN1    ( o_sys_clk         ),  // 36.864MHz system clock
    .CLKFB_IN   ( int_spdif_48k_fb  ),
    .CLK_OUT1   ( int_spdif_48k_clk ),
    .CLKFB_OUT  ( int_spdif_48k_fb  ),
    .RESET      ( pll23_reset       ),
    .LOCKED     ( pll2_locked       )
);

pll_spdif_44k1 u_clk_spdif_44k1 (
    .CLK_IN1    ( interm_spdif_clk   ), // 25.8048 MHz
    .CLKFB_IN   ( int_spdif_44k1_fb  ),
    .CLK_OUT1   ( int_spdif_44k1_clk ),
    .CLKFB_OUT  ( int_spdif_44k1_fb  ),
    .RESET      ( pll23_reset        ),
    .LOCKED     ( pll3_locked        )
);

assign pll23_reset = i_brd_rst | ~pll1_locked;

BUFGMUX u_spdif_tx_clk_mux (
    .I0     ( int_spdif_44k1_clk ),
    .I1     ( int_spdif_48k_clk  ),
    .O      ( o_spdif_tx_clk     ),
    .S      ( i_spdif_tx_clk_sel )
);

BUFG u_spdif_rx_clk (
    .I      ( int_spdif_48k_clk  ),
    .O      ( o_spdif_rx_clk     )
);

// ======================================
// Synchronous reset generation
// ======================================
reg [RST_SYNC_NUM-1:0]      rst0_sync_r    /* synthesis syn_maxfan = 10 */;
wire                        rst_tmp;
wire                        rst0;
wire                        pll_locked;

assign pll_locked = pll1_locked & pll2_locked & pll3_locked;

assign rst0 = rst0_sync_r[RST_SYNC_NUM-1];

assign rst_tmp = i_brd_rst | ~pll_locked;

  // synthesis attribute max_fanout of rst0_sync_r is 10
always @(posedge o_sys_clk or posedge rst_tmp)
    if (rst_tmp)
        rst0_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
        // logical left shift by one (pads with 0)
        rst0_sync_r <= rst0_sync_r << 1;

// BUFG u_rst_buf
//   (.O (o_sys_rst),
//    .I (rst0));

assign o_sys_rst = rst0;

endmodule

// vim:ts=4:sw=4:ai:et:si:sts=4
