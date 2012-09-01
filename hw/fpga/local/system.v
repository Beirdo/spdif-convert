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
    output  [3:0]               lcd_sf_d,
    output                      lcd_e,
    output                      lcd_rs,
    output                      lcd_rw,

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

    inout  [7:0]                gpio
);


wire            sys_clk;    // System clock
wire            sys_rst;    // Active low reset, synchronous to sys_clk
wire            uart_clk;   // UART Clock (at 3686636Hz for easy divisors)
                            // Aimed for 3686400Hz, but this is 0.2% off.
wire            int_rst;    // internally triggered reset (ibase change)
wire [7:0]      instr_base; // Top 8 bits of the instruction bus to use

// ======================================
// Wishbone Buses
// ======================================

wire            wb_clk;
wire            wb_rst;

localparam WB0_MASTERS = 1;
localparam WB0_SLAVES  = 9;
localparam WB0_DWIDTH  = 32;
localparam WB0_SWIDTH  = 4;
localparam WB0_AWIDTH  = 16;

localparam WB1_MASTERS = 1;
localparam WB1_SLAVES  = 2;
localparam WB1_DWIDTH  = 16;
localparam WB1_SWIDTH  = 2;
localparam WB1_AWIDTH  = 16;

localparam DMA_DEVICES = 4;
localparam DMA_AWIDTH  = 12;
localparam DMA_DWIDTH  = 64;

// Wishbone 0 Master Buses
wire      [WB0_AWIDTH-1:0]  m_wb0_adr      [WB0_MASTERS-1:0];
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
wire      [WB0_AWIDTH-1:0]  s_wb0_adr      [WB0_SLAVES-1:0];
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
wire      [WB1_AWIDTH-1:0]  m_wb1_adr      [WB0_MASTERS-1:0];
wire      [WB1_SWIDTH-1:0]  m_wb1_sel      [WB0_MASTERS-1:0];
wire      [WB1_MASTERS-1:0] m_wb1_we                        ;
wire      [WB1_DWIDTH-1:0]  m_wb1_dat_w    [WB0_MASTERS-1:0];
wire      [WB1_DWIDTH-1:0]  m_wb1_dat_r    [WB0_MASTERS-1:0];
wire      [WB1_MASTERS-1:0] m_wb1_cyc                       ;
wire      [WB1_MASTERS-1:0] m_wb1_stb                       ;
wire      [WB1_MASTERS-1:0] m_wb1_ack                       ;
wire      [WB1_MASTERS-1:0] m_wb1_err                       ;
wire      [WB1_MASTERS-1:0] m_wb1_rty                       ;
wire      [1:0]             m_wb1_bte      [WB0_MASTERS-1:0];
wire      [2:0]             m_wb1_cti      [WB0_MASTERS-1:0];

// Wishbone 1 Slave Buses
wire      [WB1_AWIDTH-1:0]  s_wb1_adr      [WB0_SLAVES-1:0];
wire      [WB1_SWIDTH-1:0]  s_wb1_sel      [WB0_SLAVES-1:0];
wire      [WB1_SLAVES-1:0]  s_wb1_we                       ;
wire      [WB1_DWIDTH-1:0]  s_wb1_dat_w    [WB0_SLAVES-1:0];
wire      [WB1_DWIDTH-1:0]  s_wb1_dat_r    [WB0_SLAVES-1:0];
wire      [WB1_SLAVES-1:0]  s_wb1_cyc                      ;
wire      [WB1_SLAVES-1:0]  s_wb1_stb                      ;
wire      [WB1_SLAVES-1:0]  s_wb1_ack                      ;
wire      [WB1_SLAVES-1:0]  s_wb1_err                      ;
wire      [WB1_SLAVES-1:0]  s_wb1_rty                      ;
wire      [1:0]             s_wb1_bte      [WB0_SLAVES-1:0];
wire      [2:0]             s_wb1_cti      [WB0_SLAVES-1:0];

wire      [DMA_DEVICES-1:0] dma_en;
wire      [DMA_DEVICES-1:0] dma_we;
wire      [DMA_AWIDTH-1:0]  dma_adr        [DMA_DEVICES-1:0];
wire      [DMA_DWIDTH-1:0]  dma_dat_w      [DMA_DEVICES-1:0];
wire      [DMA_DWIDTH-1:0]  dma_dat_r      [DMA_DEVICES-1:0];


// ======================================
// Interrupts
// ======================================
wire      [1:0]             ae_irq;
wire      [1:0]             ae_irqe;

wire      [ 7:0]            irq_in;

// In IRQ0
wire                        uart0_int;
wire                        spi_int;
wire                        spdif_rx_int;
wire                        spdif_tx_int;
wire                        dma_int;
wire                        wb0m0_exc_be;
wire                        wb0m0_exc_wdt;


assign ae_irqe   = 2'd3;      // Assuming active high interrupt enables

// IRQ0
assign irq_in[0] = uart0_int;
assign irq_in[1] = spi_int;
assign irq_in[2] = spdif_rx_int;
assign irq_in[3] = spdif_tx_int;
assign irq_in[4] = dma_int;
assign irq_in[5] = wb0m0_exc_be;
assign irq_in[6] = wb0m0_exc_wdt;
assign irq_in[7] = 1'b0;

// ======================================
// Clocks and Resets Module
// ======================================
wire rst_in;
assign rst_in = brd_rst | int_rst;

clocks_resets u_clocks_resets (
    .i_brd_rst          ( rst_in            ),
    .i_brd_clk_n        ( brd_clk_n         ),  
    .i_brd_clk_p        ( brd_clk_p         ),  
    .o_sys_rst          ( sys_rst           ),
    .o_sys_clk          ( sys_clk           ),
    .o_uart_clk         ( uart_clk          )
);
                

// -------------------------------------------------------------
// Instantiate AE18 Processor Core
// -------------------------------------------------------------

wire                  wb0m0_acc_sel;
wire [WB0_AWIDTH-1:0] wb0m0_acc_adr;
wire [ 7:0]           wb0m0_acc_dat;
wire [ 7:0]           wb0m0_acc_dat_r;
wire [ 7:0]           wb0m0_acc_dat_w;
wire                  wb0m0_acc_we_i;
wire                  wb0m0_acc_we_o;
wire                  wb0m0_acc_ack_i;
wire                  wb0m0_acc_ack_o;

wire [WB0_SWIDTH-1:0] wb0m0_mem_sel;
wire [WB0_AWIDTH-1:0] wb0m0_mem_adr;
wire [WB0_DWIDTH-1:0] wb0m0_mem_dat;
wire [WB0_DWIDTH-1:0] wb0m0_mem_dat_r;
wire [WB0_DWIDTH-1:0] wb0m0_mem_dat_w;
wire                  wb0m0_mem_we;
wire                  wb0m0_mem_ack;

wire                  wb0s_is_8bit;

assign m_wb1_adr[0][15] = instr_base[0]; // set the top bit from the base reg
                                         // 0 = imem, 1 = bmem

assign wb0s_is_8bit = s_wb0_stb[0] | s_wb0_stb[1] | s_wb0_stb[2] |
                      s_wb0_stb[4] | s_wb0_stb[5];

ae18_core #(
    .ISIZ ( 16 ),
    .DSIZ ( 16 )
)
u_ae18 (
    .wb_clk_o ( wb_clk ),
    .wb_rst_o ( wb_rst ),

    // Instruction bus
    .iwb_adr_o ( m_wb1_adr  [0][14:0] ),
    .iwb_dat_i ( m_wb1_dat_r[0] ),
    .iwb_dat_o ( m_wb1_dat_w[0] ),
    .iwb_stb_o ( m_wb1_stb  [0] ),
    .iwb_we_o  ( m_wb1_we   [0] ),
    .iwb_ack_i ( m_wb1_ack  [0] ),
    .iwb_sel_o ( m_wb1_sel  [0] ),

    // Data Bus
    .dwb_adr_o     ( wb0m0_acc_adr    ),
    .dwb_dat_o     ( wb0m0_acc_dat_w  ),
    .dwb_stb_o     ( m_wb0_stb[0]     ),
    .dwb_we_o      ( wb0m0_acc_we_i   ),
    .dwb_dat_i     ( wb0m0_acc_dat_r  ),
    .dwb_ack_i     ( wb0m0_acc_ack_o  ),

    // I/O
    .int_i  ( ae_irq ),
    .inte_i ( ae_irqe ),
    .clk_i  ( sys_clk ),
    .rst_i  ( sys_rst )
);

assign m_wb0_cyc[0] = m_wb0_stb[0];
assign m_wb1_cyc[0] = m_wb1_stb[0];


//
// Memory sizer for AE18 on WB0
//
memory_sizer_dual_path u_wb0m0_sizer (
    .clk_i           ( wb_clk ),
    .reset_i         ( wb_rst ),
    .memory_has_be_i ( 1'b0   ),  // At least the SPI has no BE bits

    .access_width_i ( 3'b001 ),   // AE18 data bus is 8-bit
    .access_big_endian_i ( 1'b0 ),

    .sel_i          ( wb0m0_acc_sel ),
    .adr_i          ( wb0m0_acc_adr ),
    .we_i           ( wb0m0_acc_we_o ),
    .dat_io         ( wb0m0_acc_dat ),
    .access_ack_o   ( wb0m0_acc_ack_i ),

    .memory_width_i ( 3'b100 ),   // All slaves are 32-bit

    .memory_be_o    ( wb0m0_mem_sel ),
    .memory_adr_o   ( wb0m0_mem_adr ),
    .memory_we_o    ( wb0m0_mem_we ),
    .memory_dat_io  ( wb0m0_mem_dat ),
    .memory_ack_i   ( wb0m0_mem_ack ),

    .exception_be_o ( wb0m0_exc_be ),
    .exception_watchdog_o ( wb0m0_exc_wdt )
);

assign wb0m0_acc_we_o  = ~wb0s_is_8bit & wb0m0_acc_we_i;
assign wb0m0_acc_sel   = ~wb0s_is_8bit & m_wb0_stb[0];
assign wb0m0_acc_dat_r = ~wb0m0_acc_we_i ?
                         (wb0s_is_8bit   ? m_wb0_dat_r[0]  : wb0m0_acc_dat) :
                         8'bZ;
assign wb0m0_acc_dat   =  wb0m0_acc_we_o ? wb0m0_acc_dat_w : 8'bZ;
assign wb0m0_acc_ack_o =  wb0s_is_8bit   ? m_wb0_ack[0] : wb0m0_acc_ack_i;

assign wb0m0_mem_dat   = ~wb0m0_mem_we   ? wb0m0_mem_dat_r : 32'bZ;
assign wb0m0_mem_dat_w =  wb0m0_mem_we   ? wb0m0_mem_dat   : 32'bZ;
assign wb0m0_mem_dat_r = ~wb0s_is_8bit   ? m_wb0_dat_r[0]  : 32'bZ;
assign wb0m0_mem_ack   = ~wb0s_is_8bit   & m_wb0_ack[0];

assign m_wb0_dat_w[0]  =  wb0s_is_8bit   ? wb0m0_acc_dat_w : wb0m0_mem_dat_w;
assign m_wb0_adr[0]    =  wb0s_is_8bit   ? wb0m0_acc_adr   : wb0m0_mem_adr;
assign m_wb0_sel[0]    =  wb0s_is_8bit   ? m_wb0_stb[0]    : wb0m0_mem_sel;
assign m_wb0_we[0]     =  wb0s_is_8bit   ? wb0m0_acc_we_i  : wb0m0_mem_we;

// -------------------------------------------------------------
// Instantiate 4kx8 Data Memory
// -------------------------------------------------------------

wire       dmem_inuse;
wire       dmem_write;
wire       dmem_ena;
wire       dmem_wea;

bufmem_4096x8 u_dmem (
    .clka     ( wb_clk         ),
    .rsta     ( wb_rst         ),
    .ena      ( dmem_ena       ),
    .wea      ( dmem_wea       ),
    .addra    ( s_wb0_adr  [0] ),
    .dina     ( s_wb0_dat_w[0] ),
    .douta    ( s_wb0_dat_r[0] ),
    .clkb     ( wb_clk         ),
    .rstb     ( wb_rst         ),
    .enb      ( dma_en   [3]   ),
    .web      ( dma_we   [3]   ),
    .addrb    ( dma_adr  [3]   ),
    .dinb     ( dma_dat_w[3]   ),
    .doutb    ( dma_dat_r[3]   )
);

assign dmem_inuse   = s_wb0_cyc[0] &  s_wb0_stb[0];
assign dmem_ena     = dmem_inuse   & ~s_wb0_we[0];
assign dmem_write   = dmem_inuse   &  s_wb0_we[0];
assign dmem_wea     = dmem_write   &  s_wb0_sel[0];

assign s_wb0_ack[0] = dmem_inuse;


// -------------------------------------------------------------
// Instantiate LCD Interface
// -------------------------------------------------------------
wb_lcd u_wb_lcd (
    //
    // I/O Ports
    //
    .wb_clk_i ( wb_clk ),
    .wb_rst_i ( wb_rst ),

    //
    // WB slave interface
    //
    .wb_dat_i ( s_wb0_dat_w[1] ),
    .wb_dat_o ( s_wb0_dat_r[1] ),
    .wb_adr_i ( s_wb0_adr  [1] ),
    .wb_sel_i ( s_wb0_sel  [1] ),
    .wb_we_i  ( s_wb0_we   [1] ),
    .wb_cyc_i ( s_wb0_cyc  [1] ),
    .wb_stb_i ( s_wb0_stb  [1] ),
    .wb_ack_o ( s_wb0_ack  [1] ),
    .wb_err_o ( s_wb0_err  [1] ),
    
    //
    // LCD interface
    //
    .SF_D   ( lcd_sf_d ),
    .LCD_E  ( lcd_e ),
    .LCD_RS ( lcd_rs ),
    .LCD_RW ( lcd_rw )
);
    
// -------------------------------------------------------------
// Instantiate UART
// -------------------------------------------------------------
uart_top u_uart (
    .wb_clk_i               ( wb_clk         ),
    .wb_rst_i               ( wb_rst         ),
    .uart_clk_i             ( uart_clk       ),

    .int_o                  ( uart0_int      ),
    
    .cts_pad_i              ( i_uart0_cts    ),
    .stx_pad_o              ( o_uart0_tx     ),
    .rts_pad_o              ( o_uart0_rts    ),
    .srx_pad_i              ( i_uart0_rx     ),
    .dtr_pad_o              ( o_uart0_dtr    ),
    .dsr_pad_i              ( i_uart0_dsr    ),
    .ri_pad_i               ( i_uart0_ri     ),
    .dcd_pad_i              ( i_uart0_dcd    ),
    
    .wb_adr_i               ( s_wb0_adr  [2] ),
    .wb_sel_i               ( s_wb0_sel  [2] ),
    .wb_we_i                ( s_wb0_we   [2] ),
    .wb_dat_o               ( s_wb0_dat_r[2] ),
    .wb_dat_i               ( s_wb0_dat_w[2] ),
    .wb_cyc_i               ( s_wb0_cyc  [2] ),
    .wb_stb_i               ( s_wb0_stb  [2] ),
    .wb_ack_o               ( s_wb0_ack  [2] )
);

// -------------------------------------------------------------
// Instantiate SPI Controller Module
// -------------------------------------------------------------
spi_top u_spi
(
    // Wishbone signals
    .wb_clk_i ( wb_clk ),
    .wb_rst_i ( wb_rst ),
    .wb_adr_i ( s_wb0_adr  [3] ),
    .wb_dat_i ( s_wb0_dat_w[3] ),
    .wb_dat_o ( s_wb0_dat_r[3] ),
    .wb_sel_i ( s_wb0_sel  [3] ),
    .wb_we_i  ( s_wb0_we   [3] ),
    .wb_stb_i ( s_wb0_stb  [3] ),
    .wb_cyc_i ( s_wb0_cyc  [3] ),
    .wb_ack_o ( s_wb0_ack  [3] ),
    .wb_err_o ( s_wb0_err  [3] ),
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
simple_pic #(
    .SOURCE_COUNT ( 8 ),
    .REG_WIDTH ( 8 )
)
u_simple_pic (
    .clk_i ( wb_clk ),
    .rst_i ( wb_rst ),
    .cyc_i ( s_wb0_cyc  [4] ),
    .stb_i ( s_wb0_stb  [4] ),
    .adr_i ( s_wb0_adr  [4] ),
    .we_i  ( s_wb0_we   [4] ),
    .dat_i ( s_wb0_dat_w[4] ),
    .dat_o ( s_wb0_dat_r[4] ),
    .ack_o ( s_wb0_ack  [4] ),
    .int_o ( ae_irq ),
    .irq   ( irq_in ) 
);


// -------------------------------------------------------------
// Instantiate GPIO controller
// -------------------------------------------------------------

simple_gpio u_gpio(
    .clk_i   ( wb_clk ),
    .rst_i   ( wb_rst ),
    .cyc_i   ( s_wb0_cyc  [5] ),
    .stb_i   ( s_wb0_stb  [5] ),
    .adr_i   ( s_wb0_adr  [5] ),
    .we_i    ( s_wb0_we   [5] ),
    .dat_i   ( s_wb0_dat_w[5] ),
    .dat_o   ( s_wb0_dat_r[5] ),
    .ack_o   ( s_wb0_ack  [5] ),
    .gpio    ( gpio ),
    .ibase   ( instr_base ),
    .rst_o   ( int_rst )
);


// -------------------------------------------------------------
// Instantiate DMA Controller
// -------------------------------------------------------------
dma_controller #(
    .DMA_DWIDTH ( DMA_DWIDTH ),
    .DMA_AWIDTH ( DMA_AWIDTH )
)
u_dma (
    .clk_i ( wb_clk ),
    .rst_i ( wb_rst ),

    // Wishbone Bus
    .wb_dat_o ( s_wb0_dat_r[6] ),
    .wb_dat_i ( s_wb0_dat_w[6] ),
    .wb_ack_o ( s_wb0_ack  [6] ),
    .wb_we_i  ( s_wb0_we   [6] ),
    .wb_sel_i ( s_wb0_sel  [6] ),
    .wb_adr_i ( s_wb0_adr  [6] ),
    .wb_cyc_i ( s_wb0_cyc  [6] ),
    .wb_stb_i ( s_wb0_stb  [6] ),

    // DMA Bus to Device 0 - SPDIF Rx
    .dma0_en_o  ( dma_en   [0] ),
    .dma0_we_o  ( dma_we   [0] ),
    .dma0_adr_o ( dma_adr  [0] ),
    .dma0_dat_o ( dma_dat_w[0] ),
    .dma0_dat_i ( dma_dat_r[0] ),

    // DMA Bus to Device 1 - SPDIF Tx
    .dma1_en_o  ( dma_en   [1] ),
    .dma1_we_o  ( dma_we   [1] ),
    .dma1_adr_o ( dma_adr  [1] ),
    .dma1_dat_o ( dma_dat_w[1] ),
    .dma1_dat_i ( dma_dat_r[1] ),

    // DMA Bus to Device 2 - Instruction Memory
    .dma2_en_o  ( dma_en   [2] ),
    .dma2_we_o  ( dma_we   [2] ),
    .dma2_adr_o ( dma_adr  [2] ),
    .dma2_dat_o ( dma_dat_w[2] ),
    .dma2_dat_i ( dma_dat_r[2] ),

    // DMA Bus to Device 3 - Main Memory
    .dma3_en_o  ( dma_en   [3] ),
    .dma3_we_o  ( dma_we   [3] ),
    .dma3_adr_o ( dma_adr  [3] ),
    .dma3_dat_o ( dma_dat_w[3] ),
    .dma3_dat_i ( dma_dat_r[3] ),
 
    .dma_irq ( dma_int )
);

// -------------------------------------------------------------
// Instantiate SPDIF Reciever 
// -------------------------------------------------------------
rx_spdif #(
    .data_width ( WB0_DWIDTH ),
    .addr_width ( 10 ),  // gives 2kB of buffer
    .ch_st_capture ( 8 ),
    .wishbone_freq ( 40 )  // Assume a 40MHz wb_clk for now
)
u_spdif_rx (
    .wb_clk_i ( wb_clk ),
    .wb_rst_i ( wb_rst ),
    .wb_sel_i ( s_wb0_sel  [7] ),
    .wb_stb_i ( s_wb0_stb  [7] ),
    .wb_we_i  ( s_wb0_we   [7] ),
    .wb_cyc_i ( s_wb0_cyc  [7] ),
    .wb_bte_i ( s_wb0_bte  [7] ),
    .wb_cti_i ( s_wb0_cti  [7] ),
    .wb_adr_i ( s_wb0_adr  [7] ),
    .wb_dat_i ( s_wb0_dat_w[7] ),
    .wb_ack_o ( s_wb0_ack  [7] ),
    .wb_dat_o ( s_wb0_dat_r[7] ),
    // Interrupt line
    .rx_int_o ( spdif_rx_int ),
    // SPDIF input signal
    .spdif_rx_i ( spdif_rx ),
    // DMA Bus
    .dma_clk_i ( wb_clk ),
    .dma_en_i  ( dma_en   [0] ),
    .dma_we_i  ( dma_we   [0] ),
    .dma_adr_i ( dma_adr  [0] ),
    .dma_dat_i ( dma_dat_w[0] ),
    .dma_dat_o ( dma_dat_r[0] )
);


// -------------------------------------------------------------
// Instantiate SPDIF Transmitter 
// -------------------------------------------------------------
tx_spdif #(
    .data_width ( WB0_DWIDTH ),
    .addr_width ( 10 ),  // gives 2kB of buffer
    .user_data_buf ( 1 ),
    .ch_stat_buf ( 1 )
)
u_spdif_tx (
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
    .tx_int_o ( spdif_tx_int ),
    // SPDIF input signal
    .spdif_tx_o ( spdif_tx ),
    // DMA Bus
    .dma_clk_i ( wb_clk ),
    .dma_en_i  ( dma_en   [1] ),
    .dma_we_i  ( dma_we   [1] ),
    .dma_adr_i ( dma_adr  [1] ),
    .dma_dat_i ( dma_dat_w[1] ),
    .dma_dat_o ( dma_dat_r[1] )
);

// -------------------------------------------------------------
// Instantiate 16kx16 Instruction Memory
// -------------------------------------------------------------

wire       imem_inuse;
wire       imem_write;
wire       imem_ena;
wire       imem_wea;

bufmem_16384x16 
u_imem (
    .clka  ( wb_clk         ),
    .rsta  ( wb_rst         ),
    .ena   ( imem_ena       ),
    .wea   ( imem_wea       ),
    .addra ( s_wb1_adr  [0] ),
    .dina  ( s_wb1_dat_w[0] ),
    .douta ( s_wb1_dat_r[0] ),
    .clkb  ( wb_clk         ),
    .rstb  ( wb_rst         ),
    .enb   ( dma_en     [2] ),
    .web   ( dma_we     [2] ),
    .addrb ( dma_adr    [2] ),
    .dinb  ( dma_dat_w  [2] ),
    .doutb ( dma_dat_r  [2] )
);

assign imem_inuse  = s_wb1_cyc[0] & s_wb1_stb[0];
assign imem_ena    = imem_inuse   & ~s_wb1_we[0];
assign imem_write  = imem_inuse   &  s_wb1_we[0];
assign imem_wea    = imem_write   & |s_wb1_sel[0];

assign s_wb1_ack[0] = imem_inuse;

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
    .wb_cyc_i ( s_wb1_cyc  [1] ),
    .wb_stb_i ( s_wb1_stb  [1] ),
    .wb_sel_i ( s_wb1_sel  [1] ),
    .wb_adr_i ( s_wb1_adr  [1] ),
    .wb_we_i  ( s_wb1_we   [1] ),
    .wb_dat_i ( s_wb1_dat_w[1] ),
    .wb_dat_o ( s_wb1_dat_r[1] ),
    .wb_ack_o ( s_wb1_ack  [1] )
);


// -------------------------------------------------------------
// Instantiate Wishbone 0 Arbiter
// -------------------------------------------------------------
intercon0 u_wb0_arb (
    // wishbone master port(s)
    // wb0m0
    .wb0m0_dat_i ( m_wb0_dat_r[0] ),
    .wb0m0_ack_i ( m_wb0_ack  [0] ),
    .wb0m0_dat_o ( m_wb0_dat_w[0] ),
    .wb0m0_we_o  ( m_wb0_we   [0] ),
    .wb0m0_sel_o ( m_wb0_sel  [0] ),
    .wb0m0_adr_o ( m_wb0_adr  [0] ),
    .wb0m0_cyc_o ( m_wb0_cyc  [0] ),
    .wb0m0_stb_o ( m_wb0_stb  [0] ),
    // wishbone slave port(s)
    // wb0s0
    .wb0s0_dat_o ( s_wb0_dat_r[0] ),
    .wb0s0_ack_o ( s_wb0_ack  [0] ),
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
    .wb0s3_err_o ( s_wb0_err  [3] ),
    .wb0s3_dat_i ( s_wb0_dat_w[3] ),
    .wb0s3_we_i  ( s_wb0_we   [3] ),
    .wb0s3_sel_i ( s_wb0_sel  [3] ),
    .wb0s3_adr_i ( s_wb0_adr  [3] ),
    .wb0s3_cyc_i ( s_wb0_cyc  [3] ),
    .wb0s3_stb_i ( s_wb0_stb  [3] ),
    // wb0s4
    .wb0s4_dat_o ( s_wb0_dat_r[4] ),
    .wb0s4_ack_o ( s_wb0_ack  [4] ),
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
    .wb0s7_cti_i ( s_wb0_cti  [7] ),
    .wb0s7_bte_i ( s_wb0_bte  [7] ),
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
    .wb1s1_cyc_i ( s_wb1_cyc  [1] ),
    .wb1s1_stb_i ( s_wb1_stb  [1] ),
    // clock and reset
    .clk   ( wb_clk ),
    .reset ( wb_rst )
);


endmodule

// vim:ts=4:sw=4:ai:et:si:sts=4
