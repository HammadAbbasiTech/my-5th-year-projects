module fully_associative_cache (
    input clk,
    input [7:0] address,
    output reg hit
);

reg valid [0:3];
reg [7:0] tag [0:3];
integer i;

always @(posedge clk) begin
    hit = 0;

    for (i = 0; i < 4; i = i + 1) begin
        if (valid[i] && tag[i] == address)
            hit = 1;
    end

    if (!hit) begin
        valid[0] <= 1;
        tag[0] <= address;
    end
end

endmodule