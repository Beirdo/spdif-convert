#ifndef _uart_h
#define _uart_h

/* IER - Interrupt Enable Register */
#define UART_IER_MSIE   BIT(3)  /* Modem Status Interrupt Enable */
#define UART_IER_LSIE   BIT(2)  /* Line Status Interrupt Enable */
#define UART_IER_THRIE  BIT(1)  /* Transmit Hold Register Empty Int. Enable */
#define UART_IER_RDAIE  BIT(0)  /* Receive Data Available Int. Enable */

/* IIR - Interrupt Identification Register */
#define UART_IIR_PEND   BIT(0)  /* Interrupt pending (active = 0) */
#define UART_IIR_MASK   0x0E    /* Mask of interrupt priority */
#define UART_IIR_MS     0x00    /* Modem Status Interrupt        (pri 4) */
#define UART_IIR_THRE   0x02    /* Transmit Hold Reg. Empty Int. (pri 3) */
#define UART_IIR_RDA    0x04    /* Receive Data Available Int.   (pri 2) */
#define UART_IIR_LS     0x06    /* Line Status Interrupt         (pri 1) */
#define UART_IIR_TO     0x0C    /* Recieve Timeout               (pri 2) */

/* FCR - FIFO Control Register */
#define UART_FCR_ENABLE     BIT(0)  /* Enable FIFOs - ignored, always enabled */
#define UART_FCR_CLR_RX     BIT(1)  /* Clear the Rx FIFO */
#define UART_FCR_CLR_TX     BIT(2)  /* Clear the Tx FIFO */
#define UART_FCR_RX_HW_MASK 0xC0    /* Rx FIFO HighWater Interrupt Level */
#define UART_FCR_RC_HW_1    0x00    /* Rx HighWater = 1 byte */
#define UART_FCR_RC_HW_4    0x40    /* Rx HighWater = 4 bytes */
#define UART_FCR_RC_HW_8    0x80    /* Rx HighWater = 8 bytes */
#define UART_FCR_RC_HW_14   0xC0    /* Rx HighWater = 14 bytes */

/* LCR - Line Control Register */
#define UART_LCR_BIT_MASK   0x03    /* Mask for number of data bits */
#define UART_LCR_BIT_5      0x00    /* 5-bit data */
#define UART_LCR_BIT_6      0x01    /* 6-bit data */
#define UART_LCR_BIT_7      0x02    /* 7-bit data */
#define UART_LCR_BIT_8      0x03    /* 8-bit data */
#define UART_LCR_STOP_BIT   BIT(2)  /* 0 = 1 stop bit, 1 = 1.5 (5bit), else 2 */
#define UART_LCR_PAR_EN     BIT(3)  /* 0 = no parity, 1 = parity */
#define UART_LCR_PAR_EVEN   BIT(4)  /* 0 = odd parity, 1 = even (if enabled) */
#define UART_LCR_PAR_STICK  BIT(5)  /* 0 = disabled, 1 = stick parity */
#define UART_LCR_BREAK      BIT(6)  /* 1 = force BREAK condition */
#define UART_LCR_DIVISOR    BIT(7)  /* 1 = enable access to Divisor latches */

/* MCR - Modem Control Register */
#define UART_MCR_DTR        BIT(0)  /* Assert DTR (active low signal) */
#define UART_MCR_RTS        BIT(1)  /* Assert RTS (active low signal) */
#define UART_MCR_OUT1       BIT(2)  /* in loopback, assert RI */
#define UART_MCR_OUT2       BIT(3)  /* in loopback, assert DCD */
#define UART_MCR_LOOPBACK   BIT(4)  /* 1 = loopback mode, 0 = normal */

/* LSR - Line Status Register */
#define UART_LSR_DR         BIT(0)  /* Rx Data Ready */
#define UART_LSR_OE         BIT(1)  /* Rx Overrun Error */
#define UART_LSR_RPE        BIT(2)  /* Parity Error in top of Rx FIFO */
#define UART_LSR_FE         BIT(3)  /* Framing Error */
#define UART_LSR_BI         BIT(4)  /* Break Indicator */
#define UART_LSR_TFE        BIT(5)  /* Tx FIFO Empty */
#define UART_LSR_TE         BIT(6)  /* Tx Empty */
#define UART_LSR_PE         BIT(7)  /* Parity error in Rx FIFO */

/* MSR - Modem Status Register */
#define UART_MSR_DCTS       BIT(0)  /* Change in CTS signal */
#define UART_MSR_DDSR       BIT(1)  /* Change in DSR signal */
#define UART_MSR_TERI       BIT(2)  /* Trailing edge of RI (active low sig) */
#define UART_MSR_DDCD       BIT(3)  /* Change in DCD signal */
#define UART_MSR_CTS        BIT(4)  /* CTS is asserted (active low) */
#define UART_MSR_DSR        BIT(5)  /* DSR is asserted (active low) */
#define UART_MSR_RI         BIT(6)  /* RI is asserted (active low) */
#define UART_MSR_DCD        BIT(7)  /* DCD is asserted (active low) */

#endif

/* 
 * vim:ts=4:sw=4:ai:et:si:sts=4
 */
