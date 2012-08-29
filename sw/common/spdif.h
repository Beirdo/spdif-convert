#ifndef _spdif_h
#define _spdif_h

/* RX Config */
#define SPDIF_RX_CONFIG_RX_EN   BIT(0)  /* 1 = Rx Enabled */
#define SPDIF_RX_CONFIG_SAMPLE  BIT(1)  /* 1 = data in sample buffer */
#define SPDIF_RX_CONFIG_RINTEN  BIT(2)  /* 1 = Rx Interrupt Enabled */
#define SPDIF_RX_CONFIG_CHAS    BIT(3)  /* 0 = Chan B, 1 = Chan A */
#define SPDIF_RX_CONFIG_VALID   BIT(4)  /* 1 = sample data only on valid */
#define SPDIF_RX_CONFIG_VALEN   BIT(16) /* 1 = validity bit -> sample[28] */
#define SPDIF_RX_CONFIG_USEREN  BIT(17) /* 1 = user data bit -> sample[29] */
#define SPDIF_RX_CONFIG_STATEN  BIT(18) /* 1 = chan stat bit -> sample[30] */
#define SPDIF_RX_CONFIG_PAREN   BIT(19) /* 1 = parity bit -> sample[31] */
#define SPDIF_RX_CONFIG_MODE_MASK   0x00F00000  /* 23:20 */
#define SPDIF_RX_CONFIG_16_BIT      0x00000000  /* 16-bit sample data */
#define SPDIF_RX_CONFIG_17_BIT      0x00100000  /* 17-bit sample data */
#define SPDIF_RX_CONFIG_18_BIT      0x00200000  /* 18-bit sample data */
#define SPDIF_RX_CONFIG_19_BIT      0x00300000  /* 19-bit sample data */
#define SPDIF_RX_CONFIG_20_BIT      0x00400000  /* 20-bit sample data */
#define SPDIF_RX_CONFIG_21_BIT      0x00500000  /* 21-bit sample data */
#define SPDIF_RX_CONFIG_22_BIT      0x00600000  /* 22-bit sample data */
#define SPDIF_RX_CONFIG_23_BIT      0x00700000  /* 23-bit sample data */
#define SPDIF_RX_CONFIG_24_BIT      0x00800000  /* 24-bit sample data */
#define SPDIF_RX_CONFIG_BLKEN   BIT(24) /* 1 = 1st sample/block -> sample[27] */

/* RX Status */
#define SPDIF_RX_STATUS_LOCK    BIT(0)  /* 1 = locked to SPDIF clock */
#define SPDIF_RX_STATUS_PRO     BIT(1)  /* 1 = professional, 0 = consumer */
#define SPDIF_RX_STATUS_AUDIO   BIT(2)  /* 1 = audio, 0 = data */
#define SPDIF_RX_STATUS_EMPH_MASK   0x00000038  /* Emphasis code */
#define SPDIF_RX_STATUS_COPY    BIT(6)  /* 1 = copy permitted (consumer only) */

/* RX Interrupts */
#define SPDIF_RX_INT_LOCK       BIT(0)  /* Receiver locked to signal */
#define SPDIF_RX_INT_LSBF       BIT(1)  /* Low Sample Buffer Full */
#define SPDIF_RX_INT_HSBF       BIT(2)  /* High Sample Buffer Full */
#define SPDIF_RX_INT_PARITYA    BIT(3)  /* Parity Error Channel A */
#define SPDIF_RX_INT_PARITYB    BIT(4)  /* Parity Error Channel B */
#define SPDIF_RX_INT_CAP(x)     BIT(((x) & 0x7) + 16) /* Capture Reg Changed */

/* Channel Status Capture - first bit captured in bit 0 */
#define SPDIF_RX_CAP_BITLEN_MASK    0x0000003F  /* 5:0 - bits to capture 0-32 */
#define SPDIF_RX_CAP_CHID           BIT(6)  /* 1 = Chan B, 0 = Chan A */
#define SPDIF_RX_CAP_CDATA          BIT(7)  /* 1 = Chan Stat, 0 = User Data */
#define SPDIF_RX_CAP_BITPOS_MASK    0x0000FF00  /* 15:8 - first bit pos 0-191 */

/* Rx Sample format */
#define SPDIF_RX_SAMPLE_DATL_MASK   0x0000FFFF  /* Bottom 16bits of data */
#define SPDIF_RX_SAMPLE_DATH_MASK   0x00FF0000  /* Top bits if >16bits data */
/* Optionally enabled bits */
#define SPDIF_RX_SAMPLE_BLKSTART    BIT(27) /* 1 = start of sample block */
#define SPDIF_RX_SAMPLE_VALID       BIT(28) /* Validity bit */
#define SPDIF_RX_SAMPLE_USRDAT      BIT(29) /* User Data Bit */
#define SPDIF_RX_SAMPLE_CHSTAT      BIT(30) /* Channel Status Bit */
#define SPDIF_RX_SAMPLE_PARITY      BIT(31) /* Parity Bit */

/* TX Config */
#define SPDIF_TX_CONFIG_TXEN    BIT(0)  /* Tx Enable */
#define SPDIF_TX_CONFIG_TXDATA  BIT(1)  /* 1 = data txed (valid = 0),
                                         * 0 = data not txed (valid = 1) */
#define SPDIF_TX_CONFIG_TINTEN  BIT(2)  /* Tx Interrupt Enabled */
#define SPDIF_TX_CONFIG_CHSTEN_MASK 0x00000030  /* 5:4 - Channel Stat Source */
/* Consumer only */
#define SPDIF_TX_CONFIG_CHST_REG    0x00000000  /* A&B <= TxChStat Reg */
/* Professional */
#define SPDIF_TX_CONFIG_CHST_BUF_L  0x00000010  /* A&B <= ChStat[7:0] */
#define SPDIF_TX_CONFIG_CHST_BUF_HL 0x00000020  /* A <= ChStat[7:0],
                                                 * B <= ChStat[15:8] */
#define SPDIF_TX_CONFIG_UDATEN_MASK 0x000000C0  /* 7:6 - User Data Source */
#define SPDIF_TX_CONFIG_UDAT_ZERO   0x00000000  /* A&B <= 0 */
#define SPDIF_TX_CONFIG_UDAT_BUF_L  0x00000040  /* A&B <= UserData[7:0] */
#define SPDIF_TX_CONFIG_UDAT_BUF_HL 0x00000080  /* A <= UserData[7:0],
                                                 * B <= UserData[15:8] */
#define SPDIF_TX_CONFIG_RATIO_MASK  0x0000FF00  /* 15:8 - Divider ratio
                                                 * TxClk = WBClk / (1+RATIO) */
#define SPDIF_TX_CONFIG_MODE_MASK   0x00F00000  /* 23:20 - Mode */
#define SPDIF_TX_CONFIG_16_BIT      0x00000000  /* 16-bit data */
#define SPDIF_TX_CONFIG_17_BIT      0x00100000  /* 17-bit data */
#define SPDIF_TX_CONFIG_18_BIT      0x00200000  /* 18-bit data */
#define SPDIF_TX_CONFIG_19_BIT      0x00300000  /* 19-bit data */
#define SPDIF_TX_CONFIG_20_BIT      0x00400000  /* 20-bit data */
#define SPDIF_TX_CONFIG_21_BIT      0x00500000  /* 21-bit data */
#define SPDIF_TX_CONFIG_22_BIT      0x00600000  /* 22-bit data */
#define SPDIF_TX_CONFIG_23_BIT      0x00700000  /* 23-bit data */
#define SPDIF_TX_CONFIG_24_BIT      0x00800000  /* 24-bit data */

/* Tx Channel Status Register - Consumer Mode Only */
#define SPDIF_TX_CH_ST_AUDIO        BIT(0)  /* 0 = Audio, 1 = Data */
#define SPDIF_TX_CH_ST_COPY         BIT(1)  /* 1 = copy permitted */
#define SPDIF_TX_CH_ST_PREEM        BIT(2)  /* 1 = 50/15uS Preemphasis */
#define SPDIF_TX_CH_ST_GSTAT        BIT(3)  /* 1 = Original or Commercial */
/* Category code set to 00 */
#define SPDIF_TX_CH_ST_FREQ_MASK    0x000000C0  /* 7:6 - Sample Freq */
#define SPDIF_TX_CH_ST_44100        0x00000000  /* 44.1kHz */
#define SPDIF_TX_CH_ST_48000        0x00000040  /* 48 kHz */
#define SPDIF_TX_CH_ST_32000        0x00000080  /* 32 kHz */
#define SPDIF_TX_CH_ST_CONVERT      0x000000C0  /* Sample Rate Converter */

/* Tx Interrupts */
#define SPDIF_TX_INT_LSBE           BIT(1)  /* Low Sample Buffer Empty */
#define SPDIF_TX_INT_HSBE           BIT(2)  /* High Sample Buffer Empty */
#define SPDIF_TX_INT_LCSBE          BIT(3)  /* Low Chan Stat/UserData Empty */
#define SPDIF_TX_INT_HCSBE          BIT(4)  /* High Chan Stat/UserData Empty */

/* TX User Data Buffer */
#define SPDIF_TX_USERDAT_CHAUD_MASK 0x000000FF  /* Channel A Data */
#define SPDIF_TX_USERDAT_CHBUD_MASK 0x0000FF00  /* Channel B Data */

/* Tx Channel Status Buffer */
#define SPDIF_TX_CHSTAT_CHACS_MASK  0x000000FF  /* Channel A Channel Status */
#define SPDIF_TX_CHSTAT_CHBCS_MASK  0x000000FF  /* Channel B Channel Status */

/* Tx Sample format */
#define SPDIF_TX_SAMPLE_DATL_MASK   0x0000FFFF  /* Bottom 16bits of data */
#define SPDIF_TX_SAMPLE_DATH_MASK   0x00FF0000  /* Top bits if >16bits data */

#endif

/* 
 * vim:ts=4:sw=4:ai:et:si:sts=4
 */
