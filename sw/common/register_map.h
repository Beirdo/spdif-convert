#ifndef _register_map_h
#define _register_map_h

typedef unsigned char uint8_t;
typedef          char  int8_t;
typedef unsigned int  uint16_t;
typedef          int   int16_t;
typedef unsigned long uint32_t;
typedef          long  int32_t;

#define BIT(x)  (1<<(x))
#define REG8(x) (*(volatile uint8_t *)(x))
#define REG32(x) (*(volatile uint32_t *)(x))

/* Wishbone 0 Slave 0 - 4k x 8 - Data RAM */
#define DMEM_BASE           0x0000

/* Wishbone 0 Slave 1 - 128 x 8 - LCD Controller */
/* Memory mapped 16x2 LCD */
#define LCD_BASE            0x1000
#define LCD_START_LINE_0    0x1000
#define LCD_END_LINE_0      0x100F
#define LCD_LINE_LINE_1     0x1040
#define LCD_END_LINE_1      0x104F

/* Wishbone 0 Slave 2 - 8 x 8 - UART 16550 Compatible */
#define UART_BASE           0x1100
#define UART_RXD            0x1100  /* RD only */
#define UART_TXD            0x1100  /* WR only */
#define UART_DIVLSB         0x1100  /* RD/WR when LCR[7] is set */
#define UART_DIVMSB         0x1101  /* RD/WR when LCR[7] is set */
#define UART_IER            0x1101
#define UART_IIR            0x1102  /* RD only */
#define UART_FCR            0x1102  /* WR only */
#define UART_LCR            0x1103
#define UART_MCR            0x1104  /* WR only */
#define UART_LSR            0x1105  /* RD only */
#define UART_MSR            0x1105  /* RD only */

#include "uart.h"

/* Wishbone 0 Slave 3 - 8 x 32 - SPI Controller */
#define SPI_BASE            0x1200
#define SPI_RX_0            0x1200  /* RD only */
#define SPI_RX_1            0x1204  /* RD only */
#define SPI_RX_2            0x1208  /* RD only */
#define SPI_RX_3            0x120C  /* RD only */
#define SPI_TX_0            0x1200  /* WR only */
#define SPI_TX_1            0x1204  /* WR only */
#define SPI_TX_2            0x1208  /* WR only */
#define SPI_TX_3            0x120C  /* WR only */
#define SPI_CTRL            0x1210
#define SPI_DIVIDER         0x1214
#define SPI_SS              0x1218

#include "spi.h"

/* Wishbone 0 Slave 4 - 4 x 8 - PIC Controller */
#define PIC_BASE            0x1300  /* values below are per bit */
#define PIC_EDGEN           0x1300  /* 1 : edge enabled, 0 : level */
#define PIC_POL             0x1301  /* 1 : active high/rising edge */
#define PIC_MASK            0x1302  /* 1 : interrupt *disabled* */
#define PIC_PENDING         0x1303  /* 1 : interrupt pending (write 1 clears) */

/* Wishbone 0 Slave 5 - 3 x 8 - GPIO Controller (and IBASE) */
#define GPIO_BASE           0x1400  /* values below are per bit */
#define GPIO_DIR            0x1400  /* 1 : output, 0 : input */
#define GPIO_LINE           0x1401  /* on RD : input values, on WR : outputs */
/* Note: any write to IBASE will reset the processor core */
#define IBASE               0x1402  /* MSB set = BMEM, clear = IMEM */
#define IBASE_IMEM          0x00    /* Use IMEM */
#define IBASE_BMEM          0x80    /* Use BMEM */

/* Wishbone 0 Slave 6 - 3 x 32 - DMA Controller */
#define DMA_BASE            0x1500
#define DMA_READ            0x1500  /* DMA Read  device / address */
#define DMA_WRITE           0x1504  /* DMA Write device / address */
#define DMA_COUNT           0x1508  /* DMA Count / enable */

#include "dma.h"

/* Wishbone 0 Slave 7 - 1k x 32 - SPDIF Rx */
#define SPDIF_RX_BASE           0x2000
#define SPDIF_RX_VERSION        0x2000  /* RD Only */
#define SPDIF_RX_CONFIG         0x2004
#define SPDIF_RX_STATUS         0x2008  /* RD Only */
#define SPDIF_RX_INT_MASK       0x200C
#define SPDIF_RX_INT_STATUS     0x2010  /* Write 1 to clear bit */
#define SPDIF_RX_CH_ST_BASE     0x2040
#define SPDIF_RX_CH_ST_CAP(x)   (SPDIF_RX_CH_ST_BASE + (((x) & 0x7) << 3))
#define SPDIF_RX_CH_ST_DATA(x)  (SPDIF_RX_CH_ST_BASE + (((x) & 0x7) << 3) + 4)
#define SPDIF_RX_LO_BUF_BASE    0x2800
#define SPDIF_RX_HI_BUF_BASE    0x2C00
#define SPDIF_RX_BUF_SIZE       0x0400

/* Wishbone 0 Slave 8 - 1k x 32 - SPDIF Tx */
#define SPDIF_TX_BASE                   0x3000
#define SPDIF_TX_VERSION                0x3000  /* RD Only */
#define SPDIF_TX_CONFIG                 0x3004
#define SPDIF_TX_CH_STATUS              0x3008
#define SPDIF_TX_INT_MASK               0x300C
#define SPDIF_TX_INT_STATUS             0x3010  /* Write 1 to clear bit */
#define SPDIF_TX_USER_DATA_LO_BUF_BASE  0x3080
#define SPDIF_TX_USER_DATA_HI_BUF_BASE  0x30B0
#define SPDIF_TX_USER_DATA_BUF_SIZE     0x0030
#define SPDIF_TX_CH_STAT_LO_BUF_BASE    0x3100
#define SPDIF_TX_CH_STAT_HI_BUF_BASE    0x3130
#define SPDIF_TX_CH_STAT_BUF_SIZE       0x0030
#define SPDIF_TX_LO_BUF_BASE            0x3800
#define SPDIF_TX_HI_BUF_BASE            0x3C00
#define SPDIF_TX_BUF_SIZE               0x0400

#include "spdif.h"


#endif

/* 
 * vim:ts=4:sw=4:ai:et:si:sts=4
 */
