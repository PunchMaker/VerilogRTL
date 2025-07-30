module ram_rd_refresh #(
// parameter declaration
    parameter   RAM_PIPE_STAGE          = 2             ,
    parameter   ADDR_WIDTH              = 4             ,
    parameter   DATA_WIDTH              = 8
    )(
// interface declaration
    input                               clk             ,
    input                               rst_n           ,

    input   logic                       ram_wr          ,
    input   logic   [ADDR_WIDTH-1:0]    ram_waddr       ,
    input   logic   [DATA_WIDTH-1:0]    ram_wmask       ,
    input   logic   [DATA_WIDTH-1:0]    ram_wdata       ,
    input   logic                       ram_rd          ,
    input   logic   [ADDR_WIDTH-1:0]    ram_raddr       ,
    input   logic   [DATA_WIDTH-1:0]    ram_rdata       ,
    output  logic   [DATA_WIDTH-1:0]    ram_rdata_proc
    );

// localparam declaration

// *** internal signal declaration ***
logic                                   ram_rd_dly          [RAM_PIPE_STAGE-1:0]    ;
logic   [ADDR_WIDTH-1:0]                ram_raddr_dly       [RAM_PIPE_STAGE-1:0]    ;
logic   [DATA_WIDTH-1:0]                ram_wdata_dly       [RAM_PIPE_STAGE-1:0]    ;
logic   [DATA_WIDTH-1:0]                ram_wmask_dly       [RAM_PIPE_STAGE-1:0]    ;

logic   [RAM_PIPE_STAGE:0]              conflict_flag       [RAM_PIPE_STAGE  :0]    ;
logic                                   conflict_bitmap     [RAM_PIPE_STAGE  :0]    ;
logic   [DATA_WIDTH-1:0]                ram_wdata_sel       [RAM_PIPE_STAGE  :0]    ;
logic   [DATA_WIDTH-1:0]                ram_wdata_merge     [RAM_PIPE_STAGE  :0]    ;
logic   [DATA_WIDTH-1:0]                ram_wmask_sel       [RAM_PIPE_STAGE  :0]    ;
logic   [DATA_WIDTH-1:0]                ram_wmask_merge     [RAM_PIPE_STAGE  :0]    ;

// logic description here

//generate block
assign conflict_flag[0][RAM_PIPE_STAGE] = ram_rd & ram_wr & (ram_waddr[ADDR_WIDTH-1:0] == ram_raddr[ADDR_WIDTH-1:0]);

generate
genvar i;
genvar j;
genvar k;
for (i = 0; i < RAM_PIPE_STAGE; i = i + 1) begin

    assign conflict_flag[0][i] = ram_rd_dly[RAM_PIPE_STAGE-1-i] & ram_wr & (ram_waddr[ADDR_WIDTH-1:0] == ram_raddr_dly[RAM_PIPE_STAGE-1-i][ADDR_WIDTH-1:0]);

    always @(posedge clk)
    begin
        conflict_flag[i+1] <= conflict_flag[i];
    end

end
for (j = 0; j <= RAM_PIPE_STAGE; j = j + 1) begin

    assign conflict_bitmap[j] = (j == 0) ? conflict_flag[j][j] : ~conflict_bitmap[j-1] & conflict_flag[j][j];

    if (j == 0) begin
        assign ram_wdata_sel[j] = (conflict_bitmap[j] == 1'b1) ? ram_wdata : {(DATA_WIDTH){1'b0}};
        assign ram_wmask_sel[j] = (conflict_bitmap[j] == 1'b1) ? ram_wmask : {(DATA_WIDTH){1'b0}};
    end
    else begin
        assign ram_wdata_sel[j] = (conflict_bitmap[j] == 1'b1) ? ram_wdata_dly[j-1] : {(DATA_WIDTH){1'b0}};
        assign ram_wmask_sel[j] = (conflict_bitmap[j] == 1'b1) ? ram_wmask_dly[j-1] : {(DATA_WIDTH){1'b0}};
    end

    assign ram_wdata_merge[j] = (j == 0) ? ram_wdata_sel[j] : ram_wdata_merge[j-1] | ram_wdata_sel[j];
    assign ram_wmask_merge[j] = (j == 0) ? ram_wmask_sel[j] : ram_wmask_merge[j-1] | ram_wmask_sel[j];

end
for (k = 0; k < DATA_WIDTH; k = k + 1) begin

    assign ram_rdata_proc[k] = ((|conflict_bitmap[RAM_PIPE_STAGE:0]) == 1'b1) && (ram_wmask_merge[RAM_PIPE_STAGE][k] == 1'b1) ? ram_wdata_merge[RAM_PIPE_STAGE][k] : ram_rdata[k];

end
endgenerate

always @(posedge clk)
begin
    ram_rd_dly[RAM_PIPE_STAGE-1:0]    <= {ram_rd_dly[RAM_PIPE_STAGE-2:0], ram_rd};
    ram_raddr_dly[RAM_PIPE_STAGE-1:0] <= {ram_raddr_dly[RAM_PIPE_STAGE-2:0], ram_raddr};
    ram_wmask_dly[RAM_PIPE_STAGE-1:0] <= {ram_wmask_dly[RAM_PIPE_STAGE-2:0], ram_wmask};
    ram_wdata_dly[RAM_PIPE_STAGE-1:0] <= {ram_wdata_dly[RAM_PIPE_STAGE-2:0], ram_wdata};
end

//inst submodule here


endmodule
