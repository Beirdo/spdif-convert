#include "register_map.h"

typedef struct {
    uint32_t    baud;
    uint16_t    divisor;
} baud_entry_t;

static const baud_entry_t baud_table[] = {
    {    300, 768 },
    {    600, 384 },
    {   1200, 192 },
    {   2400,  96 },
    {   4800,  48 },
    {   9600,  24 },
    {  19200,  12 },
    {  38400,   6 },
    {  57600,   4 },
    { 115200,   2 }
};
static const uint8_t baud_entry_count = NELEMS(baud_table);

uint16_t uart_calc_divisor(uint32_t baud)
{
    int i;
    uint32_t divisor;

    if (baud > 115200)
        return 0;

    for (i = 0; i < baud_entry_count; i++)
    {
        if (baud_table[i].baud == baud)
            return baud_table[i].divisor;
    }

    divisor = (UART_CLK >> 4) / baud;
    return (uint16_t)(divisor & 0x0000FFFF);
}


/* 
 * vim:ts=4:sw=4:ai:et:si:sts=4
 */
