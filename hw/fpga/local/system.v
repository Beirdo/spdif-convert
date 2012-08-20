module system  
(
    input                       brd_rst,
    input                       brd_clk_n,  
    input                       brd_clk_p,  

    // UART 0 Interface
    input                       i_uart0_cts,
    output                      o_uart0_tx,
    output                      o_uart0_rts,
    input                       i_uart0_rx,
    output                      o_uart0_dtr,
    input                       i_uart0_dsr,
    input                       i_uart0_ri,
    input                       i_uart0_dcd,

    //
    // LCD interface
    //
    output	[3:0]		    lcd_sf_d,
    output			    lcd_e,
    output			    lcd_rs,
    output			    lcd_rw,

    //
    // SPI
    //
    output  [7:0]               spi_ss,
    output                      spi_clk,
    output                      spi_mosi,
    input                       spi_miso,

    //
    // SPDIF
    //
    input                       spdif_rx,
    output                      spdif_tx,

    //
    // I2S
    //
    input                       i2s_rx_sd,
    output                      i2s_rx_sck,
    output                      i2s_rx_ws,

    output                      i2s_tx_sd,
    output                      i2s_tx_sck,
    output                      i2s_tx_ws,

    inout  [7:0]                gpio
);


wire            sys_clk;    // System clock
wire            sys_rst;    // Active low reset, synchronous to sys_clk
wire            clk_200;    // 200MHz from board


// ======================================
// Wishbone Buses
// ======================================

wire            wb_clk;
wire            wb_rst;

localparam WB0_MASTERS = 3;
localparam WB0_SLAVES  = 9;
localparam WB0_DWIDTH  = 32;
localparam WB0_SWIDTH  = 4;

localparam WB1_MASTERS = 1;
localparam WB1_SLAVES  = 4;
localparam WB1_DWIDTH  = 32;
localparam WB1_SWIDTH  = 4;

localparam WB2_MASTERS = 2;
localparam WB2_SLAVES  = 3;
localparam WB2_DWIDTH  = 16;
localparam WB2_SWIDTH  = 4;


// Wishbone 0 Master Buses
wire      [31:0]            m_wb0_adr      [WB0_MASTERS-1:0];
wire      [WB0_SWIDTH-1:0]  m_wb0_sel      [WB0_MASTERS-1:0];
wire      [WB0_MASTERS-1:0] m_wb0_we                        ;
wire      [WB0_DWIDTH-1:0]  m_wb0_dat_w    [WB0_MASTERS-1:0];
wire      [WB0_DWIDTH-1:0]  m_wb0_dat_r    [WB0_MASTERS-1:0];
wire      [WB0_MASTERS-1:0] m_wb0_cyc                       ;
wire      [WB0_MASTERS-1:0] m_wb0_stb                       ;
wire      [WB0_MASTERS-1:0] m_wb0_ack                       ;
wire      [WB0_MASTERS-1:0] m_wb0_err                       ;
wire      [WB0_MASTERS-1:0] m_wb0_rty                       ;
wire      [1:0]             m_wb0_bte      [WB0_MASTERS-1:0];
wire      [2:0]             m_wb0_cti      [WB0_MASTERS-1:0];

// Wishbone 0 Slave Buses
wire      [31:0]            s_wb0_adr      [WB0_SLAVES-1:0];
wire      [WB0_SWIDTH-1:0]  s_wb0_sel      [WB0_SLAVES-1:0];
wire      [WB0_SLAVES-1:0]  s_wb0_we                       ;
wire      [WB0_DWIDTH-1:0]  s_wb0_dat_w    [WB0_SLAVES-1:0];
wire      [WB0_DWIDTH-1:0]  s_wb0_dat_r    [WB0_SLAVES-1:0];
wire      [WB0_SLAVES-1:0]  s_wb0_cyc                      ;
wire      [WB0_SLAVES-1:0]  s_wb0_stb                      ;
wire      [WB0_SLAVES-1:0]  s_wb0_ack                      ;
wire      [WB0_SLAVES-1:0]  s_wb0_err                      ;
wire      [WB0_SLAVES-1:0]  s_wb0_rty                      ;
wire      [1:0]             s_wb0_bte      [WB0_SLAVES-1:0];
wire      [2:0]             s_wb0_cti      [WB0_SLAVES-1:0];

// Wishbone 1 Master Buses
wire      [31:0]            m_wb1_adr      [WB1_MASTERS-1:0];
wire      [WB1_SWIDTH-1:0]  m_wb1_sel      [WB1_MASTERS-1:0];
wire      [WB1_MASTERS-1:0] m_wb1_we                        ;
wire      [WB1_DWIDTH-1:0]  m_wb1_dat_w    [WB1_MASTERS-1:0];
wire      [WB1_DWIDTH-1:0]  m_wb1_dat_r    [WB1_MASTERS-1:0];
wire      [WB1_MASTERS-1:0] m_wb1_cyc                       ;
wire      [WB1_MASTERS-1:0] m_wb1_stb                       ;
wire      [WB1_MASTERS-1:0] m_wb1_ack                       ;
wire      [WB1_MASTERS-1:0] m_wb1_err                       ;
wire      [WB1_MASTERS-1:0] m_wb1_rty                       ;
wire      [1:0]             m_wb1_bte      [WB1_MASTERS-1:0];
wire      [2:0]             m_wb1_cti      [WB1_MASTERS-1:0];

// Wishbone 1 Slave Buses
wire      [31:0]            s_wb1_adr      [WB1_SLAVES-1:0];
wire      [WB1_SWIDTH-1:0]  s_wb1_sel      [WB1_SLAVES-1:0];
wire      [WB1_SLAVES-1:0]  s_wb1_we                       ;
wire      [WB1_DWIDTH-1:0]  s_wb1_dat_w    [WB1_SLAVES-1:0];
wire      [WB1_DWIDTH-1:0]  s_wb1_dat_r    [WB1_SLAVES-1:0];
wire      [WB1_SLAVES-1:0]  s_wb1_cyc                      ;
wire      [WB1_SLAVES-1:0]  s_wb1_stb                      ;
wire      [WB1_SLAVES-1:0]  s_wb1_ack                      ;
wire      [WB1_SLAVES-1:0]  s_wb1_err                      ;
wire      [WB1_SLAVES-1:0]  s_wb1_rty                      ;
wire      [1:0]             s_wb1_bte      [WB1_SLAVES-1:0];
wire      [2:0]             s_wb1_cti      [WB1_SLAVES-1:0];

// Wishbone 2 Master Buses (20 bit address instruction bus)
wire      [31:0]            m_wb2_adr      [WB2_MASTERS-1:0];
wire      [WB2_SWIDTH-1:0]  m_wb2_sel      [WB2_MASTERS-1:0];
wire      [WB2_MASTERS-1:0] m_wb2_we                        ;
wire      [WB2_DWIDTH-1:0]  m_wb2_dat_w    [WB2_MASTERS-1:0];
wire      [WB2_DWIDTH-1:0]  m_wb2_dat_r    [WB2_MASTERS-1:0];
wire      [WB2_MASTERS-1:0] m_wb2_cyc                       ;
wire      [WB2_MASTERS-1:0] m_wb2_stb                       ;
wire      [WB2_MASTERS-1:0] m_wb2_ack                       ;
wire      [WB2_MASTERS-1:0] m_wb2_err                       ;
wire      [WB2_MASTERS-1:0] m_wb2_rty                       ;
wire      [1:0]             m_wb2_bte      [WB2_MASTERS-1:0];
wire      [2:0]             m_wb2_cti      [WB2_MASTERS-1:0];

// Wishbone 2 Slave Buses (20 bit address instruction bus)
wire      [31:0]            s_wb2_adr      [WB2_SLAVES-1:0];
wire      [WB2_SWIDTH-1:0]  s_wb2_sel      [WB2_SLAVES-1:0];
wire      [WB2_SLAVES-1:0]  s_wb2_we                       ;
wire      [WB2_DWIDTH-1:0]  s_wb2_dat_w    [WB2_SLAVES-1:0];
wire      [WB2_DWIDTH-1:0]  s_wb2_dat_r    [WB2_SLAVES-1:0];
wire      [WB2_SLAVES-1:0]  s_wb2_cyc                      ;
wire      [WB2_SLAVES-1:0]  s_wb2_stb                      ;
wire      [WB2_SLAVES-1:0]  s_wb2_ack                      ;
wire      [WB2_SLAVES-1:0]  s_wb2_err                      ;
wire      [WB2_SLAVES-1:0]  s_wb2_rty                      ;
wire      [1:0]             s_wb2_bte      [WB2_SLAVES-1:0];
wire      [2:0]             s_wb2_cti      [WB2_SLAVES-1:0];


wire dma0_req;
wire dma0_ack;
wire dma0_nd;
wire dma0_rest;

wire dma1_req;
wire dma1_ack;
wire dma1_nd;
wire dma1_rest;

// ======================================
// Interrupts
// ======================================
wire      [1:0]             ae_irq;
wire      [1:0]             ae_irqe;

wire      [31:0]            irq_in;

// In IRQ0
wire                        uart0_int;
wire                        spi_int;
wire                        spdif_rx_int;
wire                        spdif_tx_int;
wire                        i2s_rx_int;
wire                        i2s_tx_int;

// In IRQ1
wire                        dma0_a_int;
wire                        dma0_b_int;
wire                        dma1_a_int;
wire                        dma1_b_int;
wire			    wb0_exc_be;
wire                        wb0_exc_wdt;
wire			    wb1_exc_be;
wire                        wb1_exc_wdt;
wire			    wb2_exc_be;
wire                        wb2_exc_wdt;

assign ae_irqe = 2'd3;      // Assuming active high interrupt enables

// IRQ0
assign irq_in[0] = uart0_int;
assign irq_in[1] = spi_int;
assign irq_in[2] = spdif_rx_int;
assign irq_in[3] = spdif_tx_int;
assign irq_in[4] = i2s_rx_int;
assign irq_in[5] = i2s_tx_int;
assign irq_in[15:6] = 10'd0;

// IRQ1
assign irq_in[16] = dma0_a_int;
assign irq_in[17] = dma0_b_int;
assign irq_in[18] = dma0_a_int;
assign irq_in[19] = dma0_b_int;
assign irq_in[20] = wb0_exc_be;
assign irq_in[21] = wb0_exc_wdt;
assign irq_in[22] = wb1_exc_be;
assign irq_in[23] = wb1_exc_wdt;
assign irq_in[24] = wb2_exc_be;
assign irq_in[25] = wb2_exc_wdt;
assign irq_in[31:26] = 6'd0;

// ======================================
// Clocks and Resets Module
// ======================================
clocks_resets u_clocks_resets (
    .i_brd_rst          ( brd_rst           ),
    .i_brd_clk_n        ( brd_clk_n         ),  
    .i_brd_clk_p        ( brd_clk_p         ),  
    .o_sys_rst          ( sys_rst           ),
    .o_sys_clk          ( sys_clk           )
);
                

// -------------------------------------------------------------
// Instantiate AE18 Processor Core
// -------------------------------------------------------------
ae18_core u_ae18 (
    .wb_clk_o ( wb_clk ),
    .wb_rst_o ( wb_rst ),

    // Instruction bus
    .iwb_adr_o ( m_wb2_adr  [0] ),
    .iwb_dat_i ( m_wb2_dat_w[0] ),
    .iwb_dat_o ( m_wb2_dat_r[0] ),
    .iwb_stb_o ( m_wb2_stb  [0] ),
    .iwb_we_o  ( m_wb2_we   [0] ),
    .iwb_ack_i ( m_wb2_ack  [0] ),
    .iwb_sel_o ( m_wb2_sel  [0] ),

    // Data Bus
    .dwb_ext_adr_o ( m_wb0_adr  [0] ),
    .dwb_dat_o     ( m_wb0_dat_r[0] ),
    .dwb_stb_o     ( m_wb0_stb  [0] ),
    .dwb_we_o      ( m_wb0_we   [0] ),
    .dwb_dat_i     ( m_wb0_dat_w[0] ),
    .dwb_ack_i     ( m_wb0_ack  [0] ),

    // I/O
    .int_i  ( ae_irq ),
    .inte_i ( ae_irqe ),
    .clk_i  ( sys_clk ),
    .rst_i  ( sys_rst )
);

assign m_wb0_sel[0] = 4'd1;	// Always selected, only 8bits wide


// -------------------------------------------------------------
// Instantiate DMA Controller (to WB1)
// -------------------------------------------------------------

wb_dma_top #( 4'h0, // register file address
              2'h0, // Number of priorities (1)
              8, // Number of channels
              4'hf, // Channel 0 Configuration:
                    // [0]=1 - Channel Exists
                    // [1]=1 - Channel Supports ARS
                    // [2]=1 - Channel Supports ED
                    // [3]=1 - Channel Supports CBUF
              4'hf, // Channel 1 Configuration
              4'hf, // Channel 2 Configuration
              4'hf, // Channel 3 Configuration
              4'hf, // Channel 4 Configuration
              4'hf, // Channel 5 Configuration
              4'hf, // Channel 6 Configuration
              4'hf  // Channel 7 Configuration
)
u_dma_wb1 (
    .clk_i ( wb_clk ),
    .rst_i ( wb_rst ),

    // Wishbone Bus 0 Slave
    .wb0s_data_i ( s_wb0_dat_w[0] ),
    .wb0s_data_o ( s_wb0_dat_r[0] ),
    .wb0_addr_i  ( s_wb0_adr  [0] ),
    .wb0_sel_i   ( s_wb0_sel  [0] ),
    .wb0_we_i    ( s_wb0_we   [0] ),
    .wb0_cyc_i   ( s_wb0_cyc  [0] ),
    .wb0_stb_i   ( s_wb0_stb  [0] ),
    .wb0_ack_o   ( s_wb0_ack  [0] ),
    .wb0_err_o   ( s_wb0_err  [0] ),
    .wb0_rty_o   ( s_wb0_rty  [0] ),

    // Wishbone Bus 0 Master
    .wb0m_data_i ( m_wb0_dat_r[1] ),
    .wb0m_data_o ( m_wb0_dat_w[1] ),
    .wb0_addr_o  ( m_wb0_adr  [1] ),
    .wb0_sel_o   ( m_wb0_sel  [1] ),
    .wb0_we_o    ( m_wb0_we   [1] ),
    .wb0_cyc_o   ( m_wb0_cyc  [1] ),
    .wb0_stb_o   ( m_wb0_stb  [1] ),
    .wb0_ack_i   ( m_wb0_ack  [1] ),
    .wb0_err_i   ( m_wb0_err  [1] ),
    .wb0_rty_i   ( m_wb0_rty  [1] ),

    // Wishbone Bus 1 Slave
    .wb1s_data_i ( s_wb1_dat_w[0] ),
    .wb1s_data_o ( s_wb1_dat_r[0] ),
    .wb1_addr_i  ( s_wb1_adr  [0] ),
    .wb1_sel_i   ( s_wb1_sel  [0] ),
    .wb1_we_i    ( s_wb1_we   [0] ),
    .wb1_cyc_i   ( s_wb1_cyc  [0] ),
    .wb1_stb_i   ( s_wb1_stb  [0] ),
    .wb1_ack_o   ( s_wb1_ack  [0] ),
    .wb1_err_o   ( s_wb1_err  [0] ),
    .wb1_rty_o   ( s_wb1_rty  [0] ),

    // Wishbone Bus 1 Master
    .wb1m_data_i ( m_wb1_dat_r[0] ),
    .wb1m_data_o ( m_wb1_dat_w[0] ),
    .wb1_addr_o  ( m_wb1_adr  [0] ),
    .wb1_sel_o   ( m_wb1_sel  [0] ),
    .wb1_we_o    ( m_wb1_we   [0] ),
    .wb1_cyc_o   ( m_wb1_cyc  [0] ),
    .wb1_stb_o   ( m_wb1_stb  [0] ),
    .wb1_ack_i   ( m_wb1_ack  [0] ),
    .wb1_err_i   ( m_wb1_err  [0] ),
    .wb1_rty_i   ( m_wb1_rty  [0] ),

    // DMA Dignals
    .dma_req_i  ( dma0_req ),
    .dma_ack_o  ( dma0_ack ),
    .dma_nd_i   ( dma0_nd ),
    .dma_rest_i ( dma0_rest ),

    // Interrupts
    .inta_o ( dma0_a_int ),
    .intb_o ( dma0_b_int )
);


// -------------------------------------------------------------
// Instantiate DMA Controller (to WB2)
// -------------------------------------------------------------
wire [31:0] wb2m1_dat_w;
wire [31:0] wb2m1_dat_r;
wire        wb2m1_ack;
wire [3:0]  wb2m1_sel;
wire [31:0] wb2m1_adr;
wire        wb2m1_we;
wire [31:0] wb2m1_acc_dat;
wire [31:0] wb2m1_mem_dat;

wb_dma_top #( 4'h1, // register file address
              2'h0, // Number of priorities (1)
              2, // Number of channels
              4'hf, // Channel 0 Configuration:
                    // [0]=1 - Channel Exists
                    // [1]=1 - Channel Supports ARS
                    // [2]=1 - Channel Supports ED
                    // [3]=1 - Channel Supports CBUF
              4'hf // Channel 1 Configuration
)
u_dma_wb2 (
    .clk_i ( wb_clk ),
    .rst_i ( wb_rst ),

    // Wishbone Bus 0 Slave
    .wb0s_data_i ( s_wb0_dat_w[1] ),
    .wb0s_data_o ( s_wb0_dat_r[1] ),
    .wb0_addr_i  ( s_wb0_adr  [1] ),
    .wb0_sel_i   ( s_wb0_sel  [1] ),
    .wb0_we_i    ( s_wb0_we   [1] ),
    .wb0_cyc_i   ( s_wb0_cyc  [1] ),
    .wb0_stb_i   ( s_wb0_stb  [1] ),
    .wb0_ack_o   ( s_wb0_ack  [1] ),
    .wb0_err_o   ( s_wb0_err  [1] ),
    .wb0_rty_o   ( s_wb0_rty  [1] ),

    // Wishbone Bus 0 Master
    .wb0m_data_i ( m_wb0_dat_r[2] ),
    .wb0m_data_o ( m_wb0_dat_w[2] ),
    .wb0_addr_o  ( m_wb0_adr  [2] ),
    .wb0_sel_o   ( m_wb0_sel  [2] ),
    .wb0_we_o    ( m_wb0_we   [2] ),
    .wb0_cyc_o   ( m_wb0_cyc  [2] ),
    .wb0_stb_o   ( m_wb0_stb  [2] ),
    .wb0_ack_i   ( m_wb0_ack  [2] ),
    .wb0_err_i   ( m_wb0_err  [2] ),
    .wb0_rty_i   ( m_wb0_rty  [2] ),

    // Wishbone Bus 2 Slave
    .wb1s_data_i ( s_wb2_dat_w[2] ),
    .wb1s_data_o ( s_wb2_dat_r[2] ),
    .wb1_addr_i  ( s_wb2_adr  [2] ),
    .wb1_sel_i   ( s_wb2_sel  [2] ),
    .wb1_we_i    ( s_wb2_we   [2] ),
    .wb1_cyc_i   ( s_wb2_cyc  [2] ),
    .wb1_stb_i   ( s_wb2_stb  [2] ),
    .wb1_ack_o   ( s_wb2_ack  [2] ),
    .wb1_err_o   ( s_wb2_err  [2] ),
    .wb1_rty_o   ( s_wb2_rty  [2] ),

    // Wishbone Bus 2 Master
    .wb1m_data_i ( wb2m1_dat_r ),
    .wb1m_data_o ( wb2m1_dat_w ),
    .wb1_addr_o  ( wb2m1_adr   ),
    .wb1_sel_o   ( wb2m1_sel   ),
    .wb1_we_o    ( wb2m1_we    ),
    .wb1_cyc_o   ( m_wb2_cyc  [1] ),
    .wb1_stb_o   ( m_wb2_stb  [1] ),
    .wb1_ack_i   ( wb2m1_ack      ),
    .wb1_err_i   ( m_wb2_err  [1] ),
    .wb1_rty_i   ( m_wb2_rty  [1] ),

    // DMA Signals
    .dma_req_i  ( dma1_req ),
    .dma_ack_o  ( dma1_ack ),
    .dma_nd_i   ( dma1_nd ),
    .dma_rest_i ( dma1_rest ),

    // Interrupts
    .inta_o ( dma1_a_int ),
    .intb_o ( dma1_b_int )
);


//
// Memory sizer for WB2
//
memory_sizer_dual_path u_wb2_sizer (
    .clk_i ( wb_clk ),
    .reset_i ( wb_rst ),
    .sel_i ( wb2m1_sel ),
    .memory_ack_i ( m_wb2_ack[1] ),
    .memory_has_be_i ( 1'b1  ),
    .memory_width_i ( 4'b0010 ),   // All memories are 16-bit
    .access_width_i ( 4'b0100 ),   // DMA Master is 32-bit
    .access_big_endian_i ( 1'b0 ),
    .adr_i ( wb2m1_adr ),
    .we_i ( wb2m1_we ),
    .dat_io ( wb2m1_acc_dat ),
    .memory_dat_io ( wb2m1_mem_dat ),
    .memory_adr_o ( m_wb2_adr[1] ),
    .memory_we_o ( m_wb2_we[1] ),
    .memory_be_o ( m_wb2_sel[1] ),
    .access_ack_o ( wb2m1_ack ),
    .exception_be_o ( wb2_exc_be ),
    .exception_watchdog_o ( wb2_exc_wdt )
);

assign wb2m1_dat_r    = ~wb2m1_we ? wb2_acc_dat    : 32'bZ;
assign wb2_acc_dat    =  wb2m1_we ? wb2m1_dat_w    : 32'bZ;
assign wb2_mem_dat    = ~wb2m1_we ? m_wb2_dat_r[1] : 32'bZ;
assign m_wb2_dat_w[1] =  wb2m1_we ? wb2_mem_dat    : 32'bZ;

// -------------------------------------------------------------
// Instantiate 4kx8 Data Memory
// -------------------------------------------------------------

block_ram #(
    .ADDR_WIDTH ( 12 ),
    .DATA_WIDTH ( 8 ),
    .SEL_WIDTH ( 1 )
)
u_dmem (
    .wb_clk_i ( wb_clk ),
    .wb_rst_i ( wb_rst ),
    .wb_cyc_i ( s_wb0_cyc  [2] ),
    .wb_stb_i ( s_wb0_stb  [2] ),
    .wb_sel_i ( s_wb0_sel  [2] ),
    .wb_adr_i ( s_wb0_adr  [2] ),
    .wb_we_i  ( s_wb0_we   [2] ),
    .wb_dat_i ( s_wb0_dat_w[2] ),
    .wb_dat_o ( s_wb0_dat_r[2] ),
    .wb_ack_o ( s_wb0_ack  [2] )
);


// -------------------------------------------------------------
// Instantiate UART0
// -------------------------------------------------------------
uart_top u_uart (
    .wb_clk_i               ( wb_clk        ),
    .wb_rst_i               ( wb_rst        ),

    .int_o                  ( uart0_int      ),
    
    .cts_pad_i              ( i_uart0_cts    ),
    .stx_pad_o              ( o_uart0_tx     ),
    .rts_pad_o              ( o_uart0_rts    ),
    .srx_pad_i              ( i_uart0_rx     ),
    .dtr_pad_o              ( o_uart0_dtr    ),
    .dsr_pad_i              ( i_uart0_dsr    ),
    .ri_pad_i               ( i_uart0_ri     ),
    .dcd_pad_i              ( i_uart0_dcd    ),
    
    .wb_adr_i               ( s_wb0_adr  [3]  ),
    .wb_sel_i               ( s_wb0_sel  [3]  ),
    .wb_we_i                ( s_wb0_we   [3]  ),
    .wb_dat_o               ( s_wb0_dat_r[3]  ),
    .wb_dat_i               ( s_wb0_dat_w[3]  ),
    .wb_cyc_i               ( s_wb0_cyc  [3]  ),
    .wb_stb_i               ( s_wb0_stb  [3]  ),
    .wb_ack_o               ( s_wb0_ack  [3]  )
);



// -------------------------------------------------------------
// Instantiate LCD Interface
// -------------------------------------------------------------
wb_lcd u_wb_lcd (
    //
    // I/O Ports
    //
    .wb_clk_i		( wb_clk ),
    .wb_rst_i		( wb_rst ),

    //
    // WB slave interface
    //
    .wb_dat_i ( s_wb0_dat_w[4] ),
    .wb_dat_o ( s_wb0_dat_r[4] ),
    .wb_adr_i ( s_wb0_adr  [4] ),
    .wb_sel_i ( s_wb0_sel  [4] ),
    .wb_we_i  ( s_wb0_we   [4] ),
    .wb_cyc_i ( s_wb0_cyc  [4] ),
    .wb_stb_i ( s_wb0_stb  [4] ),
    .wb_ack_o ( s_wb0_ack  [4] ),
    .wb_err_o ( s_wb0_err  [4] ),
	
    //
    // LCD interface
    //
    .SF_D   ( lcd_sf_d ),
    .LCD_E  ( lcd_e ),
    .LCD_RS ( lcd_rs ),
    .LCD_RW ( lcd_rw )
);
	
// -------------------------------------------------------------
// Instantiate SPDIF Reciever 
// -------------------------------------------------------------
rx_spdif #(
    .data_width ( WB0_DWIDTH ),
    .addr_width ( 9 ),  // gives 1kB of buffer
    .ch_st_capture ( 8 ),
    .wishbone_freq ( 40 )  // Assume a 40MHz wb_clk for now
)
u_spdif_rx (
    .wb_clk_i ( wb_clk ),
    .wb_rst_i ( wb_rst ),
    .wb_sel_i ( s_wb0_sel  [5] ),
    .wb_stb_i ( s_wb0_stb  [5] ),
    .wb_we_i  ( s_wb0_we   [5] ),
    .wb_cyc_i ( s_wb0_cyc  [5] ),
    .wb_bte_i ( s_wb0_bte  [5] ),
    .wb_cti_i ( s_wb0_cti  [5] ),
    .wb_adr_i ( s_wb0_adr  [5] ),
    .wb_dat_i ( s_wb0_dat_w[5] ),
    .wb_ack_o ( s_wb0_ack  [5] ),
    .wb_dat_o ( s_wb0_dat_r[5] ),
    // Interrupt line
    .rx_int_o ( spdif_rx_int ),
    // SPDIF input signal
    .spdif_rx_i ( spdif_rx )
);


// -------------------------------------------------------------
// Instantiate SPI Controller Module
// -------------------------------------------------------------
spi_top u_spi
(
    // Wishbone signals
    .wb_clk_i ( wb_clk ),
    .wb_rst_i ( wb_rst ),
    .wb_adr_i ( s_wb0_adr  [6] ),
    .wb_dat_i ( s_wb0_dat_w[6] ),
    .wb_dat_o ( s_wb0_dat_r[6] ),
    .wb_sel_i ( s_wb0_sel  [6] ),
    .wb_we_i  ( s_wb0_we   [6] ),
    .wb_stb_i ( s_wb0_stb  [6] ),
    .wb_cyc_i ( s_wb0_cyc  [6] ),
    .wb_ack_o ( s_wb0_ack  [6] ),
    .wb_err_o ( s_wb0_err  [6] ),
    .wb_int_o ( spi_int ),

    // SPI signals
    .ss_pad_o   ( spi_ss ),
    .sclk_pad_o ( spi_clk ),
    .mosi_pad_o ( spi_mosi ),
    .miso_pad_i ( spi_miso )
);

// -------------------------------------------------------------
// Instantiate Interrupt Controller Module
// -------------------------------------------------------------
simple_pic u_simple_pic (
    .clk_i ( wb_clk ),
    .rst_i ( wb_rst ),
    .cyc_i ( s_wb0_cyc  [7] ),
    .stb_i ( s_wb0_stb  [7] ),
    .adr_i ( s_wb0_adr  [7] ),
    .we_i  ( s_wb0_we   [7] ),
    .dat_i ( s_wb0_dat_w[7] ),
    .dat_o ( s_wb0_dat_r[7] ),
    .ack_o ( s_wb0_ack  [7] ),
    .int_o ( ae_irq ),
    .irq   ( irq_in ) 
);

// -------------------------------------------------------------
// Instantiate I2S Receiver 
// -------------------------------------------------------------
rx_i2s_topm #(
    .data_width ( WB0_DWIDTH ),
    .addr_width ( 9 )  // gives 1kB of buffer
)
u_i2s_rx (
    .wb_clk_i ( wb_clk ),
    .wb_rst_i ( wb_rst ),
    .wb_sel_i ( s_wb0_sel  [8] ),
    .wb_stb_i ( s_wb0_stb  [8] ),
    .wb_we_i  ( s_wb0_we   [8] ),
    .wb_cyc_i ( s_wb0_cyc  [8] ),
    .wb_bte_i ( s_wb0_bte  [8] ),
    .wb_cti_i ( s_wb0_cti  [8] ),
    .wb_adr_i ( s_wb0_adr  [8] ),
    .wb_dat_i ( s_wb0_dat_w[8] ),
    .wb_ack_o ( s_wb0_ack  [8] ),
    .wb_dat_o ( s_wb0_dat_r[8] ),
    // Interrupt line
    .rx_int_o  ( i2s_rx_int ),
    // SPDIF input signal
    .i2s_sd_i  ( i2s_rx_sd ),
    .i2s_sck_o ( i2s_rx_sck ),
    .i2s_ws_o  ( i2s_rx_ws )
);


// -------------------------------------------------------------
// Instantiate SPDIF Transmitter 
// -------------------------------------------------------------
tx_spdif #(
    .data_width ( WB1_DWIDTH ),
    .addr_width ( 9 ),  // gives 1kB of buffer
    .user_data_buf ( 1 ),
    .ch_stat_buf ( 1 )
)
u_spdif_tx (
    .wb_clk_i ( wb_clk ),
    .wb_rst_i ( wb_rst ),
    .wb_sel_i ( s_wb1_sel  [1] ),
    .wb_stb_i ( s_wb1_stb  [1] ),
    .wb_we_i  ( s_wb1_we   [1] ),
    .wb_cyc_i ( s_wb1_cyc  [1] ),
    .wb_bte_i ( s_wb1_bte  [1] ),
    .wb_cti_i ( s_wb1_cti  [1] ),
    .wb_adr_i ( s_wb1_adr  [1] ),
    .wb_dat_i ( s_wb1_dat_w[1] ),
    .wb_ack_o ( s_wb1_ack  [1] ),
    .wb_dat_o ( s_wb1_dat_r[1] ),
    // Interrupt line
    .tx_int_o ( spdif_tx_int ),
    // SPDIF input signal
    .spdif_tx_o ( spdif_tx )
);


// -------------------------------------------------------------
// Instantiate I2S Transmitter 
// -------------------------------------------------------------
tx_i2s_topm #(
    .data_width ( WB1_DWIDTH ),
    .addr_width ( 9 )  // gives 1kB of buffer
)
u_i2s_tx (
    .wb_clk_i  ( wb_clk ),
    .wb_rst_i  ( wb_rst ),
    .wb_sel_i  ( s_wb1_sel  [2] ),
    .wb_stb_i  ( s_wb1_stb  [2] ),
    .wb_we_i   ( s_wb1_we   [2] ),
    .wb_cyc_i  ( s_wb1_cyc  [2] ),
    .wb_bte_i  ( s_wb1_bte  [2] ),
    .wb_cti_i  ( s_wb1_cti  [2] ),
    .wb_adr_i  ( s_wb1_adr  [2] ),
    .wb_dat_i  ( s_wb1_dat_w[2] ),
    .wb_ack_o  ( s_wb1_ack  [2] ),
    .wb_dat_o  ( s_wb1_dat_r[2] ),
    // Interrupt line
    .tx_int_o  ( i2s_tx_int ),
    // SPDIF input signal
    .i2s_sd_o  ( i2s_tx_sd ),
    .i2s_sck_o ( i2s_tx_sck ),
    .i2s_ws_o  ( i2s_tx_ws )
);


// -------------------------------------------------------------
// Instantiate GPIO controller
// -------------------------------------------------------------

simple_gpio u_gpio(
    .clk_i ( wb_clk ),
    .rst_i ( wb_rst ),
    .cyc_i ( s_wb1_cyc  [3] ),
    .stb_i ( s_wb1_stb  [3] ),
    .adr_i ( s_wb1_adr  [3] ),
    .we_i  ( s_wb1_we   [3] ),
    .dat_i ( s_wb1_dat_w[3] ),
    .dat_o ( s_wb1_dat_r[3] ),
    .ack_o ( s_wb1_ack  [3] ),
    .gpio  ( gpio )
);

// -------------------------------------------------------------
// Instantiate 16kx16 Instruction Memory
// -------------------------------------------------------------

block_ram #(
    .ADDR_WIDTH ( 14 ),
    .DATA_WIDTH ( 16 ),
    .SEL_WIDTH ( 2)
)
u_imem (
    .wb_clk_i ( wb_clk ),
    .wb_rst_i ( wb_rst ),
    .wb_cyc_i ( s_wb2_cyc  [0] ),
    .wb_stb_i ( s_wb2_stb  [0] ),
    .wb_sel_i ( s_wb2_sel  [0] ),
    .wb_adr_i ( s_wb2_adr  [0] ),
    .wb_we_i  ( s_wb2_we   [0] ),
    .wb_dat_i ( s_wb2_dat_w[0] ),
    .wb_dat_o ( s_wb2_dat_r[0] ),
    .wb_ack_o ( s_wb2_ack  [0] )
);

// -------------------------------------------------------------
// Instantiate 4kx16 Boot Instruction Memory
// -------------------------------------------------------------

block_ram #(
    .ADDR_WIDTH ( 12 ),
    .DATA_WIDTH ( 16 ),
    .SEL_WIDTH ( 2 )
)
u_bmem (
    .wb_clk_i ( wb_clk ),
    .wb_rst_i ( wb_rst ),
    .wb_cyc_i ( s_wb2_cyc  [1] ),
    .wb_stb_i ( s_wb2_stb  [1] ),
    .wb_sel_i ( s_wb2_sel  [1] ),
    .wb_adr_i ( s_wb2_adr  [1] ),
    .wb_we_i  ( s_wb2_we   [1] ),
    .wb_dat_i ( s_wb2_dat_w[1] ),
    .wb_dat_o ( s_wb2_dat_r[1] ),
    .wb_ack_o ( s_wb2_ack  [1] )
);


// -------------------------------------------------------------
// Instantiate Wishbone 0 Arbiter
// -------------------------------------------------------------
intercon0 u_wb0_arb (
    // wishbone master port(s)
    // wb0m0 - AE18 Data Bus
    .wb0m0_dat_i ( m_wb0_dat_r[0] ),
    .wb0m0_ack_i ( m_wb0_ack  [0] ),
    .wb0m0_dat_o ( m_wb0_dat_w[0] ),
    .wb0m0_we_o  ( m_wb0_we   [0] ),
    .wb0m0_sel_o ( m_wb0_sel  [0] ),
    .wb0m0_adr_o ( m_wb0_adr  [0] ),
    .wb0m0_cyc_o ( m_wb0_cyc  [0] ),
    .wb0m0_stb_o ( m_wb0_stb  [0] ),
    // wb0m1
    .wb0m1_dat_i ( m_wb0_dat_r[1] ),
    .wb0m1_ack_i ( m_wb0_ack  [1] ),
    .wb0m1_err_i ( m_wb0_err  [1] ),
    .wb0m1_rty_i ( m_wb0_rty  [1] ),
    .wb0m1_dat_o ( m_wb0_dat_w[1] ),
    .wb0m1_we_o  ( m_wb0_we   [1] ),
    .wb0m1_sel_o ( m_wb0_sel  [1] ),
    .wb0m1_adr_o ( m_wb0_adr  [1] ),
    .wb0m1_cyc_o ( m_wb0_cyc  [1] ),
    .wb0m1_stb_o ( m_wb0_stb  [1] ),
    // wb0m2
    .wb0m2_dat_i ( m_wb0_dat_r[2] ),
    .wb0m2_ack_i ( m_wb0_ack  [2] ),
    .wb0m2_err_i ( m_wb0_err  [2] ),
    .wb0m2_rty_i ( m_wb0_rty  [2] ),
    .wb0m2_dat_o ( m_wb0_dat_w[2] ),
    .wb0m2_we_o  ( m_wb0_we   [2] ),
    .wb0m2_sel_o ( m_wb0_sel  [2] ),
    .wb0m2_adr_o ( m_wb0_adr  [2] ),
    .wb0m2_cyc_o ( m_wb0_cyc  [2] ),
    .wb0m2_stb_o ( m_wb0_stb  [2] ),
    // wishbone slave port(s)
    // wb0s0
    .wb0s0_dat_o ( s_wb0_dat_r[0] ),
    .wb0s0_ack_o ( s_wb0_ack  [0] ),
    .wb0s0_err_o ( s_wb0_err  [0] ),
    .wb0s0_rty_o ( s_wb0_rty  [0] ),
    .wb0s0_dat_i ( s_wb0_dat_w[0] ),
    .wb0s0_we_i  ( s_wb0_we   [0] ),
    .wb0s0_sel_i ( s_wb0_sel  [0] ),
    .wb0s0_adr_i ( s_wb0_adr  [0] ),
    .wb0s0_cyc_i ( s_wb0_cyc  [0] ),
    .wb0s0_stb_i ( s_wb0_stb  [0] ),
    // wb0s1
    .wb0s1_dat_o ( s_wb0_dat_r[1] ),
    .wb0s1_ack_o ( s_wb0_ack  [1] ),
    .wb0s1_err_o ( s_wb0_err  [1] ),
    .wb0s1_rty_o ( s_wb0_rty  [1] ),
    .wb0s1_dat_i ( s_wb0_dat_w[1] ),
    .wb0s1_we_i  ( s_wb0_we   [1] ),
    .wb0s1_sel_i ( s_wb0_sel  [1] ),
    .wb0s1_adr_i ( s_wb0_adr  [1] ),
    .wb0s1_cyc_i ( s_wb0_cyc  [1] ),
    .wb0s1_stb_i ( s_wb0_stb  [1] ),
    // wb0s2
    .wb0s2_dat_o ( s_wb0_dat_r[2] ),
    .wb0s2_ack_o ( s_wb0_ack  [2] ),
    .wb0s2_dat_i ( s_wb0_dat_w[2] ),
    .wb0s2_we_i  ( s_wb0_we   [2] ),
    .wb0s2_sel_i ( s_wb0_sel  [2] ),
    .wb0s2_adr_i ( s_wb0_adr  [2] ),
    .wb0s2_cyc_i ( s_wb0_cyc  [2] ),
    .wb0s2_stb_i ( s_wb0_stb  [2] ),
    // wb0s3
    .wb0s3_dat_o ( s_wb0_dat_r[3] ),
    .wb0s3_ack_o ( s_wb0_ack  [3] ),
    .wb0s3_dat_i ( s_wb0_dat_w[3] ),
    .wb0s3_we_i  ( s_wb0_we   [3] ),
    .wb0s3_sel_i ( s_wb0_sel  [3] ),
    .wb0s3_adr_i ( s_wb0_adr  [3] ),
    .wb0s3_cyc_i ( s_wb0_cyc  [3] ),
    .wb0s3_stb_i ( s_wb0_stb  [3] ),
    // wb0s4
    .wb0s4_dat_o ( s_wb0_dat_r[4] ),
    .wb0s4_ack_o ( s_wb0_ack  [4] ),
    .wb0s4_err_o ( s_wb0_err  [4] ),
    .wb0s4_dat_i ( s_wb0_dat_w[4] ),
    .wb0s4_we_i  ( s_wb0_we   [4] ),
    .wb0s4_sel_i ( s_wb0_sel  [4] ),
    .wb0s4_adr_i ( s_wb0_adr  [4] ),
    .wb0s4_cyc_i ( s_wb0_cyc  [4] ),
    .wb0s4_stb_i ( s_wb0_stb  [4] ),
    // wb0s5
    .wb0s5_dat_o ( s_wb0_dat_r[5] ),
    .wb0s5_ack_o ( s_wb0_ack  [5] ),
    .wb0s5_dat_i ( s_wb0_dat_w[5] ),
    .wb0s5_we_i  ( s_wb0_we   [5] ),
    .wb0s5_sel_i ( s_wb0_sel  [5] ),
    .wb0s5_adr_i ( s_wb0_adr  [5] ),
    .wb0s5_cti_i ( s_wb0_cti  [5] ),
    .wb0s5_bte_i ( s_wb0_bte  [5] ),
    .wb0s5_cyc_i ( s_wb0_cyc  [5] ),
    .wb0s5_stb_i ( s_wb0_stb  [5] ),
    // wb0s6
    .wb0s6_dat_o ( s_wb0_dat_r[6] ),
    .wb0s6_ack_o ( s_wb0_ack  [6] ),
    .wb0s6_err_o ( s_wb0_err  [6] ),
    .wb0s6_dat_i ( s_wb0_dat_w[6] ),
    .wb0s6_we_i  ( s_wb0_we   [6] ),
    .wb0s6_sel_i ( s_wb0_sel  [6] ),
    .wb0s6_adr_i ( s_wb0_adr  [6] ),
    .wb0s6_cyc_i ( s_wb0_cyc  [6] ),
    .wb0s6_stb_i ( s_wb0_stb  [6] ),
    // wb0s7
    .wb0s7_dat_o ( s_wb0_dat_r[7] ),
    .wb0s7_ack_o ( s_wb0_ack  [7] ),
    .wb0s7_dat_i ( s_wb0_dat_w[7] ),
    .wb0s7_we_i  ( s_wb0_we   [7] ),
    .wb0s7_sel_i ( s_wb0_sel  [7] ),
    .wb0s7_adr_i ( s_wb0_adr  [7] ),
    .wb0s7_cyc_i ( s_wb0_cyc  [7] ),
    .wb0s7_stb_i ( s_wb0_stb  [7] ),
    // wb0s8
    .wb0s8_dat_o ( s_wb0_dat_r[8] ),
    .wb0s8_ack_o ( s_wb0_ack  [8] ),
    .wb0s8_dat_i ( s_wb0_dat_w[8] ),
    .wb0s8_we_i  ( s_wb0_we   [8] ),
    .wb0s8_sel_i ( s_wb0_sel  [8] ),
    .wb0s8_adr_i ( s_wb0_adr  [8] ),
    .wb0s8_cti_i ( s_wb0_cti  [8] ),
    .wb0s8_bte_i ( s_wb0_bte  [8] ),
    .wb0s8_cyc_i ( s_wb0_cyc  [8] ),
    .wb0s8_stb_i ( s_wb0_stb  [8] ),
    // clock and reset
    .clk   ( wb_clk ),
    .reset ( wb_rst )
);


// -------------------------------------------------------------
// Instantiate Wishbone 1 Arbiter
// -------------------------------------------------------------
intercon1 u_wb1_arb (
    // wishbone master port(s)
    // wb1m0
    .wb1m0_dat_i ( m_wb1_dat_r[0] ),
    .wb1m0_ack_i ( m_wb1_ack  [0] ),
    .wb1m0_err_i ( m_wb1_err  [0] ),
    .wb1m0_rty_i ( m_wb1_rty  [0] ),
    .wb1m0_dat_o ( m_wb1_dat_w[0] ),
    .wb1m0_we_o  ( m_wb1_we   [0] ),
    .wb1m0_sel_o ( m_wb1_sel  [0] ),
    .wb1m0_adr_o ( m_wb1_adr  [0] ),
    .wb1m0_cyc_o ( m_wb1_cyc  [0] ),
    .wb1m0_stb_o ( m_wb1_stb  [0] ),
    // wishbone slave port(s)
    // wb1s0
    .wb1s0_dat_o ( s_wb1_dat_r[0] ),
    .wb1s0_ack_o ( s_wb1_ack  [0] ),
    .wb1s0_err_o ( s_wb1_err  [0] ),
    .wb1s0_rty_o ( s_wb1_rty  [0] ),
    .wb1s0_dat_i ( s_wb1_dat_w[0] ),
    .wb1s0_we_i  ( s_wb1_we   [0] ),
    .wb1s0_sel_i ( s_wb1_sel  [0] ),
    .wb1s0_adr_i ( s_wb1_adr  [0] ),
    .wb1s0_cyc_i ( s_wb1_cyc  [0] ),
    .wb1s0_stb_i ( s_wb1_stb  [0] ),
    // wb1s1
    .wb1s1_dat_o ( s_wb1_dat_r[1] ),
    .wb1s1_ack_o ( s_wb1_ack  [1] ),
    .wb1s1_dat_i ( s_wb1_dat_w[1] ),
    .wb1s1_we_i  ( s_wb1_we   [1] ),
    .wb1s1_sel_i ( s_wb1_sel  [1] ),
    .wb1s1_adr_i ( s_wb1_adr  [1] ),
    .wb1s1_cti_i ( s_wb1_cti  [1] ),
    .wb1s1_bte_i ( s_wb1_bte  [1] ),
    .wb1s1_cyc_i ( s_wb1_cyc  [1] ),
    .wb1s1_stb_i ( s_wb1_stb  [1] ),
    // wb1s2
    .wb1s2_dat_o ( s_wb1_dat_r[2] ),
    .wb1s2_ack_o ( s_wb1_ack  [2] ),
    .wb1s2_dat_i ( s_wb1_dat_w[2] ),
    .wb1s2_we_i  ( s_wb1_we   [2] ),
    .wb1s2_sel_i ( s_wb1_sel  [2] ),
    .wb1s2_adr_i ( s_wb1_adr  [2] ),
    .wb1s2_cti_i ( s_wb1_cti  [2] ),
    .wb1s2_bte_i ( s_wb1_bte  [2] ),
    .wb1s2_cyc_i ( s_wb1_cyc  [2] ),
    .wb1s2_stb_i ( s_wb1_stb  [2] ),
    // wb1s3
    .wb1s3_dat_o ( s_wb1_dat_r[3] ),
    .wb1s3_ack_o ( s_wb1_ack  [3] ),
    .wb1s3_dat_i ( s_wb1_dat_w[3] ),
    .wb1s3_we_i  ( s_wb1_we   [3] ),
    .wb1s3_sel_i ( s_wb1_sel  [3] ),
    .wb1s3_adr_i ( s_wb1_adr  [3] ),
    .wb1s3_cyc_i ( s_wb1_cyc  [3] ),
    .wb1s3_stb_i ( s_wb1_stb  [3] ),
    // clock and reset
    .clk   ( wb_clk ),
    .reset ( wb_rst )
);



// -------------------------------------------------------------
// Instantiate Wishbone 2 Arbiter
// -------------------------------------------------------------
intercon2 u_wb2_arb (
    // wishbone master port(s)
    // wb2m0
    .wb2m0_dat_i ( m_wb2_dat_r[0] ),
    .wb2m0_ack_i ( m_wb2_ack  [0] ),
    .wb2m0_dat_o ( m_wb2_dat_w[0] ),
    .wb2m0_we_o  ( m_wb2_we   [0] ),
    .wb2m0_sel_o ( m_wb2_sel  [0] ),
    .wb2m0_adr_o ( m_wb2_adr  [0] ),
    .wb2m0_cyc_o ( m_wb2_cyc  [0] ),
    .wb2m0_stb_o ( m_wb2_stb  [0] ),
    // wb2m1
    .wb2m1_dat_i ( m_wb2_dat_r[1] ),
    .wb2m1_ack_i ( m_wb2_ack  [1] ),
    .wb2m1_err_i ( m_wb2_err  [1] ),
    .wb2m1_rty_i ( m_wb2_rty  [1] ),
    .wb2m1_dat_o ( m_wb2_dat_w[1] ),
    .wb2m1_we_o  ( m_wb2_we   [1] ),
    .wb2m1_sel_o ( m_wb2_sel  [1] ),
    .wb2m1_adr_o ( m_wb2_adr  [1] ),
    .wb2m1_cyc_o ( m_wb2_cyc  [1] ),
    .wb2m1_stb_o ( m_wb2_stb  [1] ),
    // wishbone slave port(s)
    // wb2s0
    .wb2s0_dat_o ( s_wb2_dat_r[0] ),
    .wb2s0_ack_o ( s_wb2_ack  [0] ),
    .wb2s0_dat_i ( s_wb2_dat_w[0] ),
    .wb2s0_we_i  ( s_wb2_we   [0] ),
    .wb2s0_sel_i ( s_wb2_sel  [0] ),
    .wb2s0_adr_i ( s_wb2_adr  [0] ),
    .wb2s0_cyc_i ( s_wb2_cyc  [0] ),
    .wb2s0_stb_i ( s_wb2_stb  [0] ),
    // wb2s1
    .wb2s1_dat_o ( s_wb2_dat_r[1] ),
    .wb2s1_ack_o ( s_wb2_ack  [1] ),
    .wb2s1_dat_i ( s_wb2_dat_w[1] ),
    .wb2s1_we_i  ( s_wb2_we   [1] ),
    .wb2s1_sel_i ( s_wb2_sel  [1] ),
    .wb2s1_adr_i ( s_wb2_adr  [1] ),
    .wb2s1_cyc_i ( s_wb2_cyc  [1] ),
    .wb2s1_stb_i ( s_wb2_stb  [1] ),
    // wb2s2
    .wb2s2_dat_o ( s_wb2_dat_r[2] ),
    .wb2s2_ack_o ( s_wb2_ack  [2] ),
    .wb2s2_err_o ( s_wb2_err  [2] ),
    .wb2s2_rty_o ( s_wb2_rty  [2] ),
    .wb2s2_dat_i ( s_wb2_dat_w[2] ),
    .wb2s2_we_i  ( s_wb2_we   [2] ),
    .wb2s2_sel_i ( s_wb2_sel  [2] ),
    .wb2s2_adr_i ( s_wb2_adr  [2] ),
    .wb2s2_cyc_i ( s_wb2_cyc  [2] ),
    .wb2s2_stb_i ( s_wb2_stb  [2] ),
    // clock and reset
    .clk   ( wb_clk ),
    .reset ( wb_rst )
);


endmodule

