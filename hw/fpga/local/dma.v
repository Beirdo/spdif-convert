module dma_controller
(
    input              clk_i,
    input              rst_i,

    // Wishbone Bus
    output [31:0]      wb_dat_o,
    input  [31:0]      wb_dat_i,
    output             wb_ack_o,
    input              wb_we_i,
    input  [3:0]       wb_sel_i,
    input  [15:0]      wb_adr_i,
    input              wb_cyc_i,
    input              wb_stb_i,

    // DMA Bus to Device 0 - SPDIF Rx
    output             dma0_en_o,
    output             dma0_we_o,
    output [6:0]       dma0_adr_o,
    output [127:0]     dma0_dat_o,
    input  [127:0]     dma0_dat_i,

    // DMA Bus to Device 1 - SPDIF Tx
    output             dma1_en_o,
    output             dma1_we_o,
    output [6:0]       dma1_adr_o,
    output [127:0]     dma1_dat_o,
    input  [127:0]     dma1_dat_i,

    // DMA Bus to Device 2 - I2S Tx
    output             dma2_en_o,
    output             dma2_we_o,
    output [6:0]       dma2_adr_o,
    output [127:0]     dma2_dat_o,
    input  [127:0]     dma2_dat_i,

    // DMA Bus to Device 3 - Main Memory
    output             dma3_en_o,
    output             dma3_we_o,
    output [6:0]       dma3_adr_o,
    output [127:0]     dma3_dat_o,
    input  [127:0]     dma3_dat_i,
 
    output             dma_irq
);

    reg [ 31:0] control_reg;
    // Address 11 - | Start | 000 | RD_DEV | WR_DEV |
    //              |   7   | 6:4 | 3:2    | 1:0    |
    // Address 10 - | Count |
    //              | 7:0   |
    // Address 01 - | 0 | RD_ADDR |
    //              | 7 | 6:0     |
    // Address 00 - | 0 | WR_ADDR |
    //              | 7 | 6:0     |

    reg [  7:0] count_reg;
    reg [  1:0] rd_dev_reg;
    reg [  6:0] rd_adr_reg;
    reg [  1:0] wr_dev_reg;
    reg [  6:0] wr_adr_reg;

    reg         start;
    reg         running;
    reg         wasrunning;
    reg         done;
    reg [127:0] dma_dat_reg;

    always @(posedge clk_i)
    begin
        if (~rst_i)
            control_reg <= 32'd0;
        else if (wb_stb_i & wb_we_i) begin
            if (wb_sel_i[3]) begin
                control_reg[31:24] <= wb_dat_i[31:24];
            end
            if (wb_sel_i[2]) begin
                control_reg[23:16] <= wb_dat_i[23:16];
            end
            if (wb_sel_i[1]) begin
                control_reg[15:8]  <= wb_dat_i[15:8];
            end
            if (wb_sel_i[0]) begin
                control_reg[7:0]   <= wb_dat_i[7:0];
            end
        else if (start)
            control_reg[31] <= 0;
        end
    end

    assign wb_dat_o = control_reg;
    assign wb_ack_o = wb_stb_i;

    always @(negedge clk_i)
    begin
        if (~rst_i)
            start <= 1'b0;
        else
            start <= control_reg[31];
    end;

    always @(negedge clk_i)
    begin
        if (~rst_i)
            rd_dev_reg <= 2'd0;
        else if (control_reg[31])
            rd_dev_reg <= control_reg[27:26];
    end;

    always @(negedge clk_i)
    begin
        if (~rst_i)
            wr_dev_reg <= 2'd0;
        else if (control_reg[31])
            wr_dev_reg <= control_reg[25:24];
    end;

    always @(negedge clk_i)
    begin
        if (~rst_i)
            count_reg <= 8'd0;
        else if (control_reg[31])
            count_reg <= control_reg[23:16];
        else if (running)
            count_reg <= count_reg - 1;
    end;

    always @(negedge clk_i)
    begin
        if (~rst_i)
            rd_adr_reg <= 7'd0;
        else if (control_reg[31])
            rd_adr_reg <= control_reg[14:8];
        else if (running)
            rd_adr_reg <= rd_adr_reg + 1;
    end;

    always @(negedge clk_i)
    begin
        if (~rst_i)
            wr_adr_reg <= 7'd0;
        else if (control_reg[31])
            wr_adr_reg <= control_reg[7:0];
        else if (running)
            wr_adr_reg <= wr_adr_reg + 1;
    end;

    always @(posedge clk_i)
    begin
        if (~rst_i)
            running <= 1'd0;
        else if (start)
            running <= start;
        else if (running)
            running <= |count_reg;
    end;

    always @(posedge clk_i)
    begin
        if (~rst_i)
            wasrunning <= 1'd0;
        else
            wasrunning <= running;
    end;

    always @(posedge clk_i)
    begin
        if (~rst_i)
            done <= 1'd0;
        else 
            done <= (~running & wasrunning);
    end;

    wire [127:0] dma_dat_r;

    always @(posedge clk_i)
    begin
        if (~rst_i)
            dma_dat_reg <= 128'd0;
        else if (start | running)
            dma_dat_reg <= dma_dat_r;
    end;

    assign dma_irq = done;

    assign dma0_dat_o = dma_dat_reg;
    assign dma1_dat_o = dma_dat_reg;
    assign dma2_dat_o = dma_dat_reg;
    assign dma3_dat_o = dma_dat_reg;

    assign dma_dat_r = rd_dev_reg == 2'b00 ? dma0_dat_i :
                       rd_dev_reg == 2'b01 ? dma1_dat_i :
                       rd_dev_reg == 2'b10 ? dma2_dat_i :
                       rd_dev_reg == 2'b11 ? dma3_dat_i : 128'd0;

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
