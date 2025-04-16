// cordic.v
// Author: Luke Griffin 21334528, Taha Al-Salihi 21302227, Reema Ibrahim 2447644, Aaron Smith 21335168
// Date: 15-04-2025
//
// This module implements a fixed-point CORDIC algorithm to calculate sine and cosine values


module CORDIC(
    output reg signed [1:-16] cosine,   // computed cosine in Q2.16 format
    output reg signed [1:-16] sine,     // computed sine in Q2.16 format
    output reg done,                    // high when computation is complete
    input signed [1:-16] target_angle,  // desired rotation angle in Q2.16
    input init,                         // signal to start computation
    input clk                           // clock signal
);

    parameter integer N = 16;  // Number of iterations, determines precision

    // Precomputed arctangent values scaled to Q2.16 format
    reg signed [1:-16] atan_table [0:N];
    initial begin
        atan_table[0]  = 32'sd51472;  // atan(2^-0) ≈ 0.7854
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

    // Internal working variables for each iteration
    reg signed [1:-16] x, y, z;             // Current coordinates and angle
    reg signed [1:-16] x_next, y_next, z_next; // Updated values for next step
    reg [4:0] i;                            // Iteration counter (can count to 16)
    reg busy;                               // Indicates active calculation

    // Core CORDIC rotation algorithm
    always @(posedge clk) begin
        if (init) begin
            // Initialization step
            x <= 32'sd39797; // x starts as 1 / gain ≈ 0.60725 (scaled)
            y <= 0;
            z <= target_angle;  // Set target angle
            i <= 0;
            busy <= 1;
            done <= 0;
        end else if (busy) begin
            if (i <= N) begin
                // Perform one iteration of CORDIC
                if (z >= 0) begin
                    x_next = x - (y >>> i);
                    y_next = y + (x >>> i);
                    z_next = z - atan_table[i];
                end else begin
                    x_next = x + (y >>> i);
                    y_next = y - (x >>> i);
                    z_next = z + atan_table[i];
                end

                // Update registers for next iteration
                x <= x_next;
                y <= y_next;
                z <= z_next;
                i <= i + 1;
            end else begin
                // Done with all iterations
                cosine <= x;
                sine <= y;
                done <= 1;
                busy <= 0;
            end
        end
    end

endmodule
