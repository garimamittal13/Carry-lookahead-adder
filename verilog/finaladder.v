module carry_lookahead_adder_4bit (
    input [3:0] A, B,
    input Cin,
    output [3:0] Sum,
    output Cout
);
    wire [3:0] P, G;
    wire [4:0] C;

    xor p0(P[0], A[0], B[0]);
    xor p1(P[1], A[1], B[1]);
    xor p2(P[2], A[2], B[2]);
    xor p3(P[3], A[3], B[3]);

    and g0(G[0], A[0], B[0]);
    and g1(G[1], A[1], B[1]);
    and g2(G[2], A[2], B[2]);
    and g3(G[3], A[3], B[3]);

    assign C[0] = Cin;

    wire P0C0, P1G0, P1P0C0, P2G1, P2P1G0, P2P1P0C0, P3G2, P3P2G1, P3P2P1G0, P3P2P1P0C0;

    and and1(P0C0, P[0], C[0]);
    or c1(C[1], G[0], P0C0);

    and and2(P1G0, P[1], G[0]);
    and and3(P1P0C0, P[1], P[0], C[0]);
    or c2(C[2], G[1], P1G0, P1P0C0);

    and and4(P2G1, P[2], G[1]);
    and and5(P2P1G0, P[2], P[1], G[0]);
    and and6(P2P1P0C0, P[2], P[1], P[0], C[0]);
    or c3(C[3], G[2], P2G1, P2P1G0, P2P1P0C0);

    and and7(P3G2, P[3], G[2]);
    and and8(P3P2G1, P[3], P[2], G[1]);
    and and9(P3P2P1G0, P[3], P[2], P[1], G[0]);
    and and10(P3P2P1P0C0, P[3], P[2], P[1], P[0], C[0]);
    or c4(C[4], G[3], P3G2, P3P2G1, P3P2P1G0, P3P2P1P0C0);

    xor s0(Sum[0], P[0], C[0]);
    xor s1(Sum[1], P[1], C[1]);
    xor s2(Sum[2], P[2], C[2]);
    xor s3(Sum[3], P[3], C[3]);
    assign Cout = C[4];

endmodule

module tb_carry_lookahead_adder_4bit;
    reg [3:0] A, B;
    reg Cin;
    wire [3:0] Sum;
    wire Cout;

    carry_lookahead_adder_4bit uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    initial begin
        $dumpfile("adder.vcd");
        $dumpvars(0, tb_carry_lookahead_adder_4bit);
        A = 4'b0000; B = 4'b0000; Cin = 1'b0;
        #10;
        A = 4'b0101; B = 4'b0011; Cin = 1'b0;
        #10;
        A = 4'b1111; B = 4'b0001; Cin = 1'b1;
        #10;
        A = 4'b1010; B = 4'b0101; Cin = 1'b0;
        #10;
        A = 4'b1111; B = 4'b1111; Cin = 1'b1;
        #10;
        $finish;
    end

    initial begin
        $monitor("Time = %0d, A = %b, B = %b, Cin = %b, Sum = %b, Cout = %b", $time, A, B, Cin, Sum, Cout);
    end
endmodule