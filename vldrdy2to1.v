module vldrdy2to1 #(
// parameter declaration
    )(
// interface declaration
    input                               i_valid_1       ,
    output                              i_ready_1       ,
    input                               i_valid_2       ,
    output                              i_ready_2       ,

    output                              o_valid         ,
    input                               o_ready
    );

// localparam declaration

// *** internal signal declaration ***

// logic description here

//generate block
assign i_ready_1 = o_ready & i_valid_2;
assign i_ready_2 = o_ready & i_valid_1;

assign o_valid = i_valid_1 & i_valid_2;

//inst submodule here

endmodule
