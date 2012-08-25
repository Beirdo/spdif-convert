Memory Map
----------


Bus Slave	Description		Base	ADDR Mask	Count
-------------------------------------------------------------------------------
WB0s0		DMEM (1k x 32)		0000	0FFF		4096
WB0s1		LCD  (128 x 8)          1000	007F		128
WB0s2		UART (8 x 32)		1100	001F		32
WB0s3		SPI (8 x 32)		1200	001F		32
WB0s4		PIC (8 x 8)		1300	0003		4
WB0s5		GPIO (2 x 8)		1400	0001		2
WB0s6		DMA (3 x 32)		1500	000F		12
WB0s7		SPDIF RX (1k x 32)	2000	0FFF		4096
WB0s8		SPDIF TX (1k x 32)	3000	0FFF		4096

WB1s0		IMEM (16k x 16)		0000	7FFF		32768
WB2s1		BMEM (4k x 16)		8000	1FFF		8192
internal	AE18 SFRs		F000	00FF		256


DMA Mapping
-----------

Entity		Size		Addr Mask	Device Ptr
-------------------------------------------------------------
SPDIF RX	512 x 64	1FF		0b00
SPDIF TX	512 x 64	1FF		0b01
IMEM		 4k x 64	FFF		0b10
DMEM		 2k x 64	7FF		0b11

