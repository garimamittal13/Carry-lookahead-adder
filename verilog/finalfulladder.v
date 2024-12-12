module dff (
    input wire clk,
    input wire d,
    output reg q
);
    always @(posedge clk) begin
        q <= d;
    end
endmodule

module carry_lookahead_adder_4bit (
    input wire clk,
    input [3:0] A, B,
    input Cin,
    output [3:0] Sum,
    output Cout
);
    wire [3:0] A_dff, B_dff, Sum_dff;
    wire Cin_dff, Cout_dff;
    wire [3:0] P, G;
    wire [4:0] C;

    // DFFs for inputs
    dff dff_A0 (.clk(clk), .d(A[0]), .q(A_dff[0]));
    dff dff_A1 (.clk(clk), .d(A[1]), .q(A_dff[1]));
    dff dff_A2 (.clk(clk), .d(A[2]), .q(A_dff[2]));
    dff dff_A3 (.clk(clk), .d(A[3]), .q(A_dff[3]));

    dff dff_B0 (.clk(clk), .d(B[0]), .q(B_dff[0]));
    dff dff_B1 (.clk(clk), .d(B[1]), .q(B_dff[1]));
    dff dff_B2 (.clk(clk), .d(B[2]), .q(B_dff[2]));
    dff dff_B3 (.clk(clk), .d(B[3]), .q(B_dff[3]));

    dff dff_Cin (.clk(clk), .d(Cin), .q(Cin_dff));

    // Carry Lookahead Adder logic
    xor p0(P[0], A_dff[0], B_dff[0]);
    xor p1(P[1], A_dff[1], B_dff[1]);
    xor p2(P[2], A_dff[2], B_dff[2]);
    xor p3(P[3], A_dff[3], B_dff[3]);

    and g0(G[0], A_dff[0], B_dff[0]);
    and g1(G[1], A_dff[1], B_dff[1]);
    and g2(G[2], A_dff[2], B_dff[2]);
    and g3(G[3], A_dff[3], B_dff[3]);

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

    xor s0(Sum_dff[0], P[0], C[0]);
    xor s1(Sum_dff[1], P[1], C[1]);
    xor s2(Sum_dff[2], P[2], C[2]);
    xor s3(Sum_dff[3], P[3], C[3]);
    assign Cout_dff = C[4];

    // DFFs for outputs
    dff dff_Sum0 (.clk(clk), .d(Sum_dff[0]), .q(Sum[0]));
    dff dff_Sum1 (.clk(clk), .d(Sum_dff[1]), .q(Sum[1]));
    dff dff_Sum2 (.clk(clk), .d(Sum_dff[2]), .q(Sum[2]));
    dff dff_Sum3 (.clk(clk), .d(Sum_dff[3]), .q(Sum[3]));

    dff dff_Cout (.clk(clk), .d(Cout_dff), .q(Cout));

endmodule

module test_fulladder;
    reg clk;
    reg [3:0] A, B;
    reg Cin;
    wire [3:0] Sum;
    wire Cout;

    carry_lookahead_adder_4bit uut (
        .clk(clk),
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    initial begin
        $dumpfile("test_fulladder.vcd");
        $dumpvars(0, test_fulladder);

        // Initialize inputs
        clk = 0;
        A = 4'b0000;
        B = 4'b0000;
        Cin = 0;

        // Apply test vectors
        #10 A = 4'b0001; B = 4'b0001; Cin = 0;
        #10 A = 4'b0010; B = 4'b0010; Cin = 0;
        #10 A = 4'b0100; B = 4'b0100; Cin = 0;
        #10 A = 4'b1000; B = 4'b1000; Cin = 0;
        #10 A = 4'b1111; B = 4'b1111; Cin = 1;
        #10 A = 4'b1010; B = 4'b0101; Cin = 1;
        #10 A = 4'b0110; B = 4'b0011; Cin = 0;
        #10 A = 4'b1100; B = 4'b0011; Cin = 1;

        #10 $finish;
    end

    always #5 clk = ~clk;

    always @(posedge clk) begin
        $monitor("Time = %t | A = %b | B = %b | Cin = %b | Sum = %b | Cout = %b", $time, A, B, Cin, Sum, Cout);
    end
endmodule