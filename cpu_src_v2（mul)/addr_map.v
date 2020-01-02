
module addr_map( 
    input   [31:0] addr_in,
    output  [31:0] addr_out,
    output  unmapped,
    output  uncache
);
    wire    useg;
    wire    kseg0;
    wire    kseg1;
    wire    ksseg;
    wire    kseg3;

    assign  useg = (addr_in[31] == 0);
    assign  kseg0 = (addr_in[31:29] == 3'b100);
    assign  kseg1 = (addr_in[31:29] == 3'b101);
    assign  ksseg = (addr_in[31:29] == 3'b110);
    assign  kseg3 = (addr_in[31:29] == 3'b111);
    assign  unmapped = kseg0 | kseg1;
    assign  uncache = kseg1;
    assign  addr_out = kseg0 ? {1'b0, addr_in[30:0]} :
                        kseg1 ? {3'b000, addr_in[28:0]} : addr_in;
endmodule
