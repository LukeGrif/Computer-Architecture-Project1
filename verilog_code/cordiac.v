// cordic_tb.v
// Author: Luke Griffin 21334528, Taha Al-Salihi 21302227, Reema Ibrahim 2447644, Aaron Smith 21335168
// Date: 15-04-2025

module CORDIC(
    output reg signed [1:-16] cosine,
    output reg signed [1:-16] sine,
    output reg done,
    input signed [1:-16] target_angle,
    input init,
    input clk
);

    parameter integer N = 16;

    // atan(2^-i) in radians, scaled to Q2.16
    reg signed [1:-16] atan_table [0:N];
    initial begin
        atan_table[0]  = 32'sd51472;  // atan(2^-0) ≈ 0.7854 rad
        atan_table[1]  = 32'sd30385;  // atan(2^-1) ≈ 0.4636
        atan_table[2]  = 32'sd16055;
        atan_table[3]  = 32'sd8149;
        atan_table[4]  = 32'sd4090;
        atan_table[5]  = 32'sd2045;
        atan_table[6]  = 32'sd1023;
        atan_table[7]  = 32'sd512;
        atan_table[8]  = 32'sd256;
        atan_table[9]  = 32'sd128;
        atan_table[10] = 32'sd64;
        atan_table[11] = 32'sd32;
        atan_table[12] = 32'sd16;
        atan_table[13] = 32'sd8;
        atan_table[14] = 32'sd4;
        atan_table[15] = 32'sd2;
        atan_table[16] = 32'sd1;
    end

    reg signed [1:-16] x, y, z;
    reg signed [1:-16] x_next, y_next, z_next;
    reg [4:0] i;
    reg busy;

    always @(posedge clk) begin
        if (init) begin
            x <= 32'sd39797; // 1/A(n) ≈ 0.60725 * 65536
            y <= 0;
            z <= target_angle;
            i <= 0;
            busy <= 1;
            done <= 0;
        end else if (busy) begin
            if (i <= N) begin
                if (z >= 0) begin
                    x_next = x - (y >>> i);
                    y_next = y + (x >>> i);
                    z_next = z - atan_table[i];
                end else begin
                    x_next = x + (y >>> i);
                    y_next = y - (x >>> i);
                    z_next = z + atan_table[i];
                end
                x <= x_next;
                y <= y_next;
                z <= z_next;
                i <= i + 1;
            end else begin
                cosine <= x;
                sine <= y;
                done <= 1;
                busy <= 0;
            end
        end
    end

endmodule

