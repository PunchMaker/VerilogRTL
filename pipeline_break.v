module pipeline_break #(
// parameter declaration
    parameter   VALID_MODE  = 1     ,
    parameter   READY_MODE  = 1     ,
    parameter   DATA_WIDTH  = 128
    )(
// interface declaration
    input                               clk             ,
    input                               rst_n           ,

    input                               i_valid         ,
    output                              i_ready         ,
    input       [DATA_WIDTH-1:0]        i_data          ,

    output                              o_valid         ,
    input                               o_ready         ,
    output      [DATA_WIDTH-1:0]        o_data
    );

// localparam declaration

// *** internal signal declaration ***
wire                            mid_valid       ;
wire                            mid_ready       ;
wire    [DATA_WIDTH-1:0]        mid_data        ;

// logic description here
// ========================================== FUNCTION DESCRIPTIONS ==========================================
// 1) Support valid & ready ctrl signal delay break with mode optional as below
//      PARAMETER VALID_MODE ========== 0: valid bypass mode
//                                      1: valid delay mode
//      PARAMETER READY_MODE ========== 0: ready bypass mode
//                                      1: ready delay mode
// 2) Support bitwidth of delay data with PARAMETER "DATA_WIDTH" for user design
//
// ========================================== IO CONNECTING DISPLAY ==========================================
//                                           ____________________
//          -----------> i_valid ---------> |                    | ---------> o_valid ----------->
//                                          |                    |
//          <----------- i_ready <--------- |   pipeline_break   | <--------- o_ready <-----------
//                                          |                    |
//          -----------> i_data ----------> |                    | ---------> o_data ------------>
//                                          |____________________|
//
// ==========================================================================================================
//generate block
generate
// ************************ ready break ************************
if (READY_MODE == 0) begin : READY_BYPASS_MODE

    assign mid_valid = i_valid  ;
    assign i_ready   = mid_ready;
    assign mid_data  = i_data   ;

end
else begin : READY_DELAY_MODE

    reg                     i_valid_tmp ;
    reg                     i_ready_tmp ;
    reg [DATA_WIDTH-1:0]    i_data_tmp  ;

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            i_valid_tmp <= 1'b0;
        end
        else if (i_valid == 1'b1 && mid_ready == 1'b0 && i_valid_tmp == 1'b0) begin
            i_valid_tmp <= 1'b1;
        end
        else if (mid_ready == 1'b1) begin
            i_valid_tmp <= 1'b0;
        end
        else;
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            i_ready_tmp <= 1'b0;
        end
        else begin
            i_ready_tmp <= mid_ready;
        end
    end

    always @(posedge clk ) begin
        if (i_valid == 1'b1 && mid_ready == 1'b0 && i_valid_tmp == 1'b0) begin
            i_data_tmp <= i_data;
        end
        else;
    end

    assign mid_valid =  i_valid_tmp | i_valid       ;
    assign i_ready   = ~i_valid_tmp | i_ready_tmp   ;

    assign mid_data  = i_valid_tmp == 1'b1 ? i_data_tmp : i_data;

end
// ************************ valid break ************************
if (VALID_MODE == 0) begin : VALID_BYPASS_MODE

    assign o_valid   = mid_valid;
    assign mid_ready = o_ready  ;
    assign o_data    = mid_data ;

end
else begin : VALID_DELAY_MODE

    reg                     o_valid_tmp ;
    reg [DATA_WIDTH-1:0]    o_data_tmp  ;

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            o_valid_tmp <= 1'b0;
        end
        else if (mid_valid == 1'b1) begin
            o_valid_tmp <= 1'b1;
        end
        else if (o_ready == 1'b1) begin
            o_valid_tmp <= 1'b0;
        end
        else;
    end

    always @(posedge clk ) begin
        if (mid_valid == 1'b1 && mid_ready == 1'b1) begin
            o_data_tmp <= mid_data;
        end
        else;
    end

    assign o_valid   =  o_valid_tmp             ;
    assign mid_ready = ~o_valid_tmp | o_ready   ;

    assign o_data    = o_data_tmp;

end
endgenerate

//inst submodule here


endmodule
