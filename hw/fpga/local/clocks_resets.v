
//
// Clocks and Resets Module
//

module clocks_resets  (
    input                       i_brd_rst,
    input                       i_brd_clk_n,  
    input                       i_brd_clk_p,  
    output                      o_sys_rst,
    output                      o_sys_clk
);


wire                        rst0;

assign o_sys_rst = rst0;


localparam                  RST_SYNC_NUM = 25;
wire                        pll_locked;
wire                        clkfbout_clkfbin;
reg [RST_SYNC_NUM-1:0]      rst0_sync_r    /* synthesis syn_maxfan = 10 */;
wire                        rst_tmp;
wire                        pll_clk;

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
         
         
assign rst0             = rst0_sync_r[RST_SYNC_NUM-1];


// ======================================
// Xilinx Spartan-6 PLL
// ======================================
PLL_ADV # (
    .BANDWIDTH          ( "OPTIMIZED"        ),
    .CLKIN1_PERIOD      ( 20                 ),   // 1/20ns = 50MHz
    .CLKIN2_PERIOD      ( 1                  ),
    .CLKOUT0_DIVIDE     ( 1                  ), 
    .CLKOUT1_DIVIDE     (                    ),
    .CLKOUT2_DIVIDE     ( 20                 ),   // 40Mhz = 800 MHz / 20
    .CLKOUT3_DIVIDE     ( 1                  ),
    .CLKOUT4_DIVIDE     ( 1                  ),
    .CLKOUT5_DIVIDE     ( 1                  ),
    .CLKOUT0_PHASE      ( 0.000              ),
    .CLKOUT1_PHASE      ( 0.000              ),
    .CLKOUT2_PHASE      ( 0.000              ),
    .CLKOUT3_PHASE      ( 0.000              ),
    .CLKOUT4_PHASE      ( 0.000              ),
    .CLKOUT5_PHASE      ( 0.000              ),
    .CLKOUT0_DUTY_CYCLE ( 0.500              ),
    .CLKOUT1_DUTY_CYCLE ( 0.500              ),
    .CLKOUT2_DUTY_CYCLE ( 0.500              ),
    .CLKOUT3_DUTY_CYCLE ( 0.500              ),
    .CLKOUT4_DUTY_CYCLE ( 0.500              ),
    .CLKOUT5_DUTY_CYCLE ( 0.500              ),
    .COMPENSATION       ( "INTERNAL"         ),
    .DIVCLK_DIVIDE      ( 1                  ),
    .CLKFBOUT_MULT      ( 16                 ),   // 50 MHz clock input, x16 to get 800 MHz MCB
    .CLKFBOUT_PHASE     ( 0.0                ),
    .REF_JITTER         ( 0.005000           )
)
u_pll_adv (
    .CLKFBIN     ( clkfbout_clkfbin  ),
    .CLKINSEL    ( 1'b1              ),
    .CLKIN1      ( brd_clk_ibufg     ),
    .CLKIN2      ( 1'b0              ),
    .DADDR       ( 5'b0              ),
    .DCLK        ( 1'b0              ),
    .DEN         ( 1'b0              ),
    .DI          ( 16'b0             ),           
    .DWE         ( 1'b0              ),
    .REL         ( 1'b0              ),
    .RST         ( i_brd_rst          ),
    .CLKFBDCM    (                   ),
    .CLKFBOUT    ( clkfbout_clkfbin  ),
    .CLKOUTDCM0  (                   ),
    .CLKOUTDCM1  (                   ),
    .CLKOUTDCM2  (                   ),
    .CLKOUTDCM3  (                   ),
    .CLKOUTDCM4  (                   ),
    .CLKOUTDCM5  (                   ),
    .CLKOUT0     (                   ),
    .CLKOUT1     (                   ),
    .CLKOUT2     ( pll_clk           ),
    .CLKOUT3     (                   ),
    .CLKOUT4     (                   ),
    .CLKOUT5     (                   ),
    .DO          (                   ),
    .DRDY        (                   ),
    .LOCKED      ( pll_locked        )
);


BUFG u_bufg_sys_clk (
    .O ( o_sys_clk  ),
    .I ( pll_clk    )
);


// ======================================
// Synchronous reset generation
// ======================================
assign rst_tmp = i_brd_rst | ~pll_locked;

  // synthesis attribute max_fanout of rst0_sync_r is 10
always @(posedge o_sys_clk or posedge rst_tmp)
    if (rst_tmp)
        rst0_sync_r <= {RST_SYNC_NUM{1'b1}};
    else
        // logical left shift by one (pads with 0)
        rst0_sync_r <= rst0_sync_r << 1;


endmodule

