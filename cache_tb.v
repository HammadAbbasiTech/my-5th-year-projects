module cache_tb;

reg clk;
reg [7:0] address;
wire hit;

direct_mapped_cache uut (
    .clk(clk),
    .address(address),
    .hit(hit)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    address = 8'h12; #10;
    address = 8'h34; #10;
    address = 8'h12; #10;
    address = 8'h56; #10;
    address = 8'h12; #10;
    $stop;
end

endmodule
