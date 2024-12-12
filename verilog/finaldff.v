module dff (
    input wire clk,
    input wire d,
    output reg q
);
    always @(posedge clk) begin
        q <= d;
    end
endmodule

module dff_tb;
    reg clk;
    reg d;
    wire q;

    dff uut (
        .clk(clk),
        .d(d),
        .q(q)
    );

    initial begin
        $dumpfile("dff.vcd");
        $dumpvars(0, dff_tb);
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        d = 0;

        #10 d = 1;
        #15 d = 0;
        #10 d = 1;
        #10 d = 0;
        #10 d = 1;

        #10 $finish;
    end

    initial begin
        $monitor("At time %t, d = %b, q = %b", $time, d, q);
    end
endmodule