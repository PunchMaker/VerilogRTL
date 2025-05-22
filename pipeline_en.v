module pipeline_en #(
// parameter declaration
    parameter   O_STAGE     = 2
    )(
// interface declaration
    input                               clk             ,
    input                               rst_n           ,

    input                               i_valid         ,
    output                              i_ready         ,

    output                              o_valid         ,
    input                               o_ready         ,
    output      [O_STAGE-1:0]           ppen
    );

// localparam declaration

// *** internal signal declaration ***
reg     [O_STAGE-1:0]       mid_valid   ;
wire    [O_STAGE-1:0]       mid_ready   ;

// logic description here
// ========================================== IO CONNECTING DISPLAY ==========================================
//                                   _______________________________
//                                  |                               |
//  ----------> i_valid ----------> |                               | ------------> o_valid ---------->
//                                  |         pipeline_en           |
//  <---------- i_ready <---------- |                               | <------------ o_ready <----------
//                                  |_______________________________|
//                                       |                     |
//                                       |                     |
//                                       v                     v
//                                     ppen[0]     ...    ppen[O_STAGE-1]
//
// ==========================================================================================================
//generate block
always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        mid_valid[0] <= 1'b0;
    end
    else if (i_valid == 1'b1) begin
        mid_valid[0] <= 1'b1;
    end
    else if (mid_ready[0] == 1'b1) begin
        mid_valid[0] <= 1'b0;
    end
    else;
end

assign i_ready = ~mid_valid[0] | mid_ready[0];
assign ppen[0] = i_valid & i_ready;

generate
if (O_STAGE > 1) begin : MULTI_PPEN

    genvar i;
    for (i = 0; i < O_STAGE-1; i = i + 1) begin : MULTI_PPEN_GEN

        always @(posedge clk or negedge rst_n) begin
            if (rst_n == 1'b0) begin
                mid_valid[i+1] <= 1'b0;
            end
            else if (mid_valid[i] == 1'b1) begin
                mid_valid[i+1] <= 1'b1;
            end
            else if (mid_ready[i+1] == 1'b1) begin
                mid_valid[i+1] <= 1'b0;
            end
            else;
        end

        assign mid_ready[i] = ~mid_valid[i+1] | mid_ready[i+1];
        assign ppen[i+1] = mid_valid[i] & mid_ready[i];

    end
end
endgenerate

assign o_valid = mid_valid[O_STAGE-1];
assign mid_ready[O_STAGE-1] = o_ready;

//inst submodule here


endmodule
