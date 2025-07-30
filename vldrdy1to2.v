module vldrdy1to2 #(
// parameter declaration
    )(
// interface declaration
    input                               i_valid         ,
    output                              i_ready         ,

    output                              o_valid_1       ,
    input                               o_ready_1       ,
    output                              o_valid_2       ,
    input                               o_ready_2
    );

// localparam declaration

// *** internal signal declaration ***

// logic description here

//generate block
assign o_valid_1 = i_valid & o_ready_2;
assign o_valid_2 = i_valid & o_ready_1;

assign i_ready = o_ready_1 & o_ready_2;

//inst submodule here

endmodule
