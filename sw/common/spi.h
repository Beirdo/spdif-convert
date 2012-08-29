#ifndef _spi_h
#define _spi_h

/* CTRL - Control Register */
#define SPI_CTRL_CHAR_LEN_MASK  0x0000007F  /* Bits per transfer 0 = 128bit */
#define SPI_CTRL_GO_BSY         BIT(8)      /* Start transfer / busy */
#define SPI_CTRL_RX_NEG         BIT(9)      /* Latch RX on falling edge */
#define SPI_CTRL_TX_NEG         BIT(10)     /* Change TX on falling edge */
#define SPI_CTRL_LSB            BIT(11)     /* 1 = Data LSB first, 0 = MSB */
#define SPI_CTRL_IE             BIT(12)     /* Interrupt Enable */
#define SPI_CTRL_ASS            BIT(13)     /* Auto-control SS signals */

#endif

/* 
 * vim:ts=4:sw=4:ai:et:si:sts=4
 */
