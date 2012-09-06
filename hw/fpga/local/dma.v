module dma_controller
#(
    parameter DMA_DWIDTH = 64,
    parameter DMA_AWIDTH = 12
)
(
    input                   clk_i,
    input                   rst_i,  // Active high reset

    // Wishbone Bus
    output reg [31:0]       wb_dat_o,
    input  [31:0]           wb_dat_i,
    output                  wb_ack_o,
    input                   wb_we_i,
    input  [3:0]            wb_sel_i,
    input  [15:0]           wb_adr_i,
    input                   wb_cyc_i,
    input                   wb_stb_i,

    // DMA Bus to Device 0 - SPDIF Rx
    output                  dma0_en_o,
    output                  dma0_we_o,
    output [DMA_AWIDTH-1:0] dma0_adr_o,
    output [DMA_DWIDTH-1:0] dma0_dat_o,
    input  [DMA_DWIDTH-1:0] dma0_dat_i,

    // DMA Bus to Device 1 - SPDIF Tx
    output                  dma1_en_o,
    output                  dma1_we_o,
    output [DMA_AWIDTH-1:0] dma1_adr_o,
    output [DMA_DWIDTH-1:0] dma1_dat_o,
    input  [DMA_DWIDTH-1:0] dma1_dat_i,

    // DMA Bus to Device 2 - Instruction Memory
    output                  dma2_en_o,
    output                  dma2_we_o,
    output [DMA_AWIDTH-1:0] dma2_adr_o,
    output [DMA_DWIDTH-1:0] dma2_dat_o,
    input  [DMA_DWIDTH-1:0] dma2_dat_i,

    // DMA Bus to Device 3 - Main Memory
    output                  dma3_en_o,
    output                  dma3_we_o,
    output [DMA_AWIDTH-1:0] dma3_adr_o,
    output [DMA_DWIDTH-1:0] dma3_dat_o,
    input  [DMA_DWIDTH-1:0] dma3_dat_i,
 
    output                  dma_irq
);

    reg [ 31:0] control_reg [2:0];
    // Address 2 - | Start  | 0               | Count          |
    //             |  31    | 30:DMA_AWIDTH+1 | DMA_AWIDTH:0   |
    // Address 1 - | WR_DEV | 0               | WR_ADDR        |
    //             | 31:30  | 29:DMA_AWIDTH   | DMA_AWIDTH-1:0 |
    // Address 0 - | RD_DEV | 0               | RD_ADDR        |
    //             | 31:30  | 29:DMA_AWIDTH   | DMA_AWIDTH-1:0 |

    reg [DMA_AWIDTH:0] count_reg;

    reg [1:0] rd_dev_reg;
    reg [DMA_AWIDTH-1:0] rd_adr_reg;

    reg [1:0] wr_dev_reg;
    reg [DMA_AWIDTH-1:0] wr_adr_reg;

    reg         start;
    reg         running;
    reg         wasrunning;
    reg         done;
    reg [DMA_DWIDTH-1:0] dma_dat_reg;

    wire [1:0] reg_adr;
    assign reg_adr = wb_adr_i[3:2];

    integer reg_num;

    always @(reg_adr)
        reg_num = (reg_adr == 2'b11) ? 0 : reg_adr;

    wire [31:0] mask [2:0];
    assign mask[2][31]              = 1'b1;
    assign mask[2][30:DMA_AWIDTH+1] = {{29-DMA_AWIDTH}{1'b0}};
    assign mask[2][DMA_AWIDTH:0]   = {{DMA_AWIDTH+1}{1'b1}};

    assign mask[1][31:30]          = 2'b11;
    assign mask[1][29:DMA_AWIDTH]  = {{30-DMA_AWIDTH}{1'b0}};
    assign mask[1][DMA_AWIDTH-1:0] = {{DMA_AWIDTH}{1'b1}};

    assign mask[0][31:30]          = 2'b11;
    assign mask[0][29:DMA_AWIDTH]  = {{30-DMA_AWIDTH}{1'b0}};
    assign mask[0][DMA_AWIDTH-1:0] = {{DMA_AWIDTH}{1'b1}};

    wire [31:0] wr_data;

    assign wr_data = wb_dat_i & mask[reg_num];

    integer i;
    always @(posedge clk_i)
    begin
        if (rst_i) begin
            control_reg[0] <= 32'd0;
            control_reg[1] <= 32'd0;
            control_reg[2] <= 32'd0;
        end
        else begin
            if (wb_stb_i & wb_we_i) begin
                if (wb_sel_i[3])
                    control_reg[reg_num][31:24] <= wr_data[31:24];

                if (wb_sel_i[2])
                    control_reg[reg_num][23:16] <= wr_data[23:16];

                if (wb_sel_i[1])
                    control_reg[reg_num][15:8]  <= wr_data[15:8];

                if (wb_sel_i[0])
                    control_reg[reg_num][7:0]   <= wr_data[7:0];
            end
            else begin
                if (start) begin
                    control_reg[2][31] <= 0;
                end
            end
        end
    end

    always @(posedge clk_i)
    begin
        if (rst_i)
            wb_dat_o <= 32'b0;
        else
            wb_dat_o <= #1 control_reg[reg_num];
    end

    assign wb_ack_o = wb_stb_i;

    always @(posedge clk_i)
    begin
        if (rst_i)
            start <= 1'b0;
        else
            start <= control_reg[2][31];
    end

    always @(posedge clk_i)
    begin
        if (rst_i)
            rd_dev_reg <= 2'd0;
        else if (control_reg[2][31])
            rd_dev_reg <= control_reg[0][31:30];
    end

    always @(posedge clk_i)
    begin
        if (rst_i)
            wr_dev_reg <= 2'd0;
        else if (control_reg[2][31])
            wr_dev_reg <= control_reg[1][31:30];
    end

    always @(posedge clk_i)
    begin
        if (rst_i)
            count_reg <= {{DMA_AWIDTH+1}{1'b0}};
        else if (control_reg[2][31])
            count_reg <= control_reg[2][DMA_AWIDTH:0];
        else if (running)
            count_reg <= count_reg - 1;
    end

    always @(posedge clk_i)
    begin
        if (rst_i)
            rd_adr_reg <= {{DMA_AWIDTH}{1'b0}};
        else if (control_reg[2][31])
            rd_adr_reg <= control_reg[0][DMA_AWIDTH-1:0];
        else if (running)
            rd_adr_reg <= rd_adr_reg + 1;
    end

    always @(posedge clk_i)
    begin
        if (rst_i)
            wr_adr_reg <= {{DMA_AWIDTH}{1'b0}};
        else if (control_reg[2][31])
            wr_adr_reg <= control_reg[1][DMA_AWIDTH-1:0];
        else if (running)
            wr_adr_reg <= wr_adr_reg + 1;
    end

    always @(posedge clk_i)
    begin
        if (rst_i)
            running <= 1'd0;
        else if (start)
            running <= start;
        else if (running)
            running <= |count_reg;
    end

    always @(posedge clk_i)
    begin
        if (rst_i)
            wasrunning <= 1'd0;
        else
            wasrunning <= running;
    end

    always @(posedge clk_i)
    begin
        if (rst_i)
            done <= 1'd0;
        else 
            done <= (~running & wasrunning);
    end

    wire [DMA_DWIDTH-1:0] dma_dat_r;

    always @(posedge clk_i)
    begin
        if (rst_i)
            dma_dat_reg <= {{DMA_DWIDTH}{1'd0}};
        else if (start | running)
            dma_dat_reg <= dma_dat_r;
    end

    assign dma_irq = done;

    assign dma0_dat_o = dma_dat_reg;
    assign dma1_dat_o = dma_dat_reg;
    assign dma2_dat_o = dma_dat_reg;
    assign dma3_dat_o = dma_dat_reg;

    assign dma_dat_r = rd_dev_reg == 2'b00 ? dma0_dat_i :
                       rd_dev_reg == 2'b01 ? dma1_dat_i :
                       rd_dev_reg == 2'b10 ? dma2_dat_i :
                       rd_dev_reg == 2'b11 ? dma3_dat_i : {{DMA_DWIDTH}{1'd0}};

    assign dma0_en_o = rd_dev_reg == 2'b00 ? (start | running) : 1'b0;
    assign dma1_en_o = rd_dev_reg == 2'b01 ? (start | running) : 1'b0;
    assign dma2_en_o = rd_dev_reg == 2'b10 ? (start | running) : 1'b0;
    assign dma3_en_o = rd_dev_reg == 2'b11 ? (start | running) : 1'b0;

    assign dma0_we_o = wr_dev_reg == 2'b00 ? running : 1'b0;
    assign dma1_we_o = wr_dev_reg == 2'b01 ? running : 1'b0;
    assign dma2_we_o = wr_dev_reg == 2'b10 ? running : 1'b0;
    assign dma3_we_o = wr_dev_reg == 2'b11 ? running : 1'b0;

    assign dma0_adr_o = rd_dev_reg == 2'b00 ? rd_adr_reg : wr_adr_reg;
    assign dma1_adr_o = rd_dev_reg == 2'b01 ? rd_adr_reg : wr_adr_reg;
    assign dma2_adr_o = rd_dev_reg == 2'b10 ? rd_adr_reg : wr_adr_reg;
    assign dma3_adr_o = rd_dev_reg == 2'b11 ? rd_adr_reg : wr_adr_reg;

endmodule

// vim:ts=4:sw=4:ai:et:si:sts=4
