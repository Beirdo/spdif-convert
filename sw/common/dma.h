#ifndef _dma_h
#define _dma_h

#define DMA_ADDR_MASK   0x00000FFF      /* Note: 64-bit word addresses */
#define DMA_ADDR_COUNT  (DMA_ADDR_MASK + 1)
#define DMA_ADDR_SHIFT  3               /* Byte addr >> 3 = 64-bit word addr */

/* READ */
#define DMA_DEV(x)      (((x) << 30) & 0xC0000000)
#define DMA_ADDR(x)     (((x) >> DMA_ADDR_SHIFT) & DMA_ADDR_MASK)

#define DMA_COUNT_VAL(x) (((x) > (DMA_ADDR_COUNT << DMA_ADDR_SHIFT)) ? \
                         DMA_ADDR_COUNT : ((x) >> DMA_ADDR_SHIFT))
#define DMA_START       BIT(31)

#endif

/* 
 * vim:ts=4:sw=4:ai:et:si:sts=4
 */
