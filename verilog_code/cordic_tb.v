// cordic_tb.v
// Author: Luke Griffin 21334528, Taha Al-Salihi 21302227, Reema Ibrahim 2447644, Aaron Smith 21335168
// Date: 15-04-2025

`timescale 1ns / 1ps

module tb_CORDIC;

    reg signed [1:-16] angle;
    reg init = 0;
    reg clk = 0;
    wire signed [1:-16] cos_out, sin_out;
    wire done;

    CORDIC uut (
        .cosine(cos_out),
        .sine(sin_out),
        .done(done),
        .target_angle(angle),
        .init(init),
        .clk(clk)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Convert radians to Q2.16 fixed-point
    function signed [1:-16] rad_to_fixed;
        input real radians;
        begin
            rad_to_fixed = $rtoi(radians * 65536.0);
        end
    endfunction

    // Loop variables
    real angle_deg, angle_rad;
    real expected_cos, expected_sin;
    real actual_cos, actual_sin;
    real error_cos, error_sin;

    integer i;

    initial begin
        $display("Starting CORDIC 15 degrees step testbench...");
        $dumpfile("cordic_loop_tb.vcd");
        $dumpvars(0, tb_CORDIC);

        for (i = -90; i <= 90; i = i + 15) begin
            angle_deg = i;
            angle_rad = angle_deg * 3.14159265358979 / 180.0;
            angle <= rad_to_fixed(angle_rad);

            $display("\n==== Test Angle: %0d degrees (%.4f rad) ====", i, angle_rad);

            @(negedge clk); init <= 1;
            @(negedge clk); init <= 0;

            wait (done == 1);
            @(negedge clk);

            actual_cos = cos_out / 65536.0;
            actual_sin = sin_out / 65536.0;
            expected_cos = $cos(angle_rad);
            expected_sin = $sin(angle_rad);
            error_cos = expected_cos - actual_cos;
            error_sin = expected_sin - actual_sin;

            $display("   COS = %f (CORDIC), expected = %f, error = %f", actual_cos, expected_cos, error_cos);
            $display("   SIN = %f (CORDIC), expected = %f, error = %f", actual_sin, expected_sin, error_sin);
        end

        $display("\nTestbench complete.");
        $finish;
    end

endmodule
