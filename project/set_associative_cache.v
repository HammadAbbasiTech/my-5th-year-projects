module set_associative_cache (
    input clk,
    input [7:0] address,
    output reg hit
);

reg valid [0:1][0:1];
reg [6:0] tag [0:1][0:1];

wire set;
wire [6:0] addr_tag;
integer i;

assign set = address[0];
assign addr_tag = address[7:1];

always @(posedge clk) begin
    hit = 0;

    for (i = 0; i < 2; i = i + 1) begin
        if (valid[set][i] && tag[set][i] == addr_tag)
            hit = 1;
    end

    if (!hit) begin
        valid[set][0] <= 1;
        tag[set][0] <= addr_tag;
    end
end

endmodule
