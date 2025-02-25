module cordic #(parameter ITERATIONS = 16) (
    input wire clk,
    input wire init,
    input wire signed [31:0] theta,  // 2.16 Fixed-point format
    output reg signed [31:0] cos_out,
    output reg signed [31:0] sin_out
);

    // Internal registers
    reg signed [31:0] x, y, z;
    reg [4:0] iter; // Iteration counter
    reg signed [31:0] atan_table [0:ITERATIONS-1]; // Precomputed arctan table

    // **Synchronous initialization of atan_table**
    initial begin
        atan_table[0] = 32'd25735;  // atan(2^0)  * 2^16
        atan_table[1] = 32'd15192;  // atan(2^-1) * 2^16
        atan_table[2] = 32'd8027;   // atan(2^-2) * 2^16
        atan_table[3] = 32'd4074;   // atan(2^-3) * 2^16
        atan_table[4] = 32'd2045;   // atan(2^-4) * 2^16
        atan_table[5] = 32'd1024;   // atan(2^-5) * 2^16
        atan_table[6] = 32'd512;    // atan(2^-6) * 2^16
        atan_table[7] = 32'd256;    // atan(2^-7) * 2^16
        atan_table[8] = 32'd128;    // atan(2^-8) * 2^16
        atan_table[9] = 32'd64;     // atan(2^-9) * 2^16
        atan_table[10] = 32'd32;    // atan(2^-10) * 2^16
        atan_table[11] = 32'd16;    // atan(2^-11) * 2^16
        atan_table[12] = 32'd8;     // atan(2^-12) * 2^16
        atan_table[13] = 32'd4;     // atan(2^-13) * 2^16
        atan_table[14] = 32'd2;     // atan(2^-14) * 2^16
        atan_table[15] = 32'd1;     // atan(2^-15) * 2^16
    end

    // Synchronous logic (driven by clock)
    always @(posedge clk) begin
        if (init) begin
            // Initialize values for first iteration
            x <= 32'd39797; // Precomputed K value in 2.16 format (0.607252 * 2^16)
            y <= 0;
            z <= theta;
            iter <= 0;
        end else if (iter < ITERATIONS) begin
            // Perform CORDIC iteration
            if (z >= 0) begin
                x <= x - (y >>> iter);
                y <= y + (x >>> iter);
                z <= z - atan_table[iter];
            end else begin
                x <= x + (y >>> iter);
                y <= y - (x >>> iter);
                z <= z + atan_table[iter];
            end
            iter <= iter + 1;
        end else begin
            // Store results when done
            cos_out <= x;
            sin_out <= y;
        end
    end
endmodule
