module block_ram 
#(
    parameter ADDR_WIDTH = 14,
    parameter DATA_WIDTH = 16,
    parameter SEL_WIDTH = 2
)
(
    input                   wb_clk_i,
    input                   wb_rst_i,
    input                   wb_cyc_i,
    input                   wb_stb_i,
    input  [SEL_WIDTH-1:0]  wb_sel_i,
    input  [31:0]           wb_adr_i,
    input                   wb_we_i,
    input  [DATA_WIDTH-1:0] wb_dat_i,
    output [DATA_WIDTH-1:0] wb_dat_o,
    output                  wb_ack_o
);

    localparam DATA_DEPTH = 1 << ADDR_WIDTH;

    wire [ADDR_WIDTH-1:0]   address;
    reg  [7:0]              read_data [SEL_WIDTH-1:0];
    wire [7:0]              write_data [SEL_WIDTH-1:0];
    wire                    clock;

    assign clock = wb_clk_i;

    genvar i;
    generate for (i=0;i<SEL_WIDTH;i=i+1)
        begin: instantiate
            reg  [7:0] ram_i [DATA_DEPTH-1:0];
	    assign write_data[i] = wb_dat_i[8*i+7:8*i];
            assign masked_read_data[8*i+7:8*i] = byte_enable[i] ?
                                                 read_data[i] :
                                                 write_data[i];
            always @( posedge clock )
            begin
                read_data[i] <= ram_i[address];
                if (byte_enable[i])
                    ram_i[address] <= write_data[i];
            end
        end
    endgenerate

    reg                     start_read_r = 'd0;

    wire                    start_write;
    wire                    start_read;
    wire [DATA_WIDTH-1:0]   byte_enable;
    wire [SEL_WIDTH-1:0]    mask_address;


    assign start_write = wb_stb_i &&  wb_we_i && !(|start_read_r);
    assign start_read  = wb_stb_i && !wb_we_i && !start_read_r;

    always @( posedge clock )
    begin
        start_read_r <= start_read;
    end

    assign byte_enable = wb_sel_i;
    wire   [DATA_WIDTH-1:0] masked_read_data;


    assign wb_dat_o    = masked_read_data;
    assign address     = wb_adr_i[ADDR_WIDTH+SEL_WIDTH-2:SEL_WIDTH-1];

    assign wb_ack_o    = wb_stb_i && ( start_write || start_read_r );

endmodule
