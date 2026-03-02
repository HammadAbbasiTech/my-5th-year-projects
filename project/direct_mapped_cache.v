module direct_mapped_cache (
    input clk,
    input [7:0] address,
    output reg hit
);

reg valid [0:3];
reg [5:0] tag [0:3];

wire [1:0] index;
wire [5:0] addr_tag;

assign index = address[1:0];
assign addr_tag = address[7:2];

always @(posedge clk) begin
    if (valid[index] && tag[index] == addr_tag)
        hit <= 1;
    else begin
        hit <= 0;
        valid[index] <= 1;
        tag[index] <= addr_tag;
    end
end

endmodule