`timescale 1ns / 1ps

module cordic_tb();
    reg clk;
    reg init;
    reg signed [31:0] theta;
    wire signed [31:0] cos_out, sin_out;

    // Instantiate the CORDIC DUT (Device Under Test)
    cordic dut (
        .clk(clk),
        .init(init),
        .theta(theta),
        .cos_out(cos_out),
        .sin_out(sin_out)
    );

    // Clock generation (10ns period, 100MHz)
    always #5 clk = ~clk;

    // Floating-point reference values (computed separately)
    real ref_cos, ref_sin;
    real computed_cos, computed_sin;
    real error_cos, error_sin;
    
    // Tolerance for checking (adjustable)
    real tolerance = 0.001; // Allowable error in fixed-point equivalent

    integer angle;
    integer pass_count = 0;
    integer fail_count = 0;

    initial begin
        // Initialize clock and signals
        clk = 0;
        init = 1;

        // Loop through angles from -90 to +90 degrees in steps of 10
        for (angle = -90; angle <= 90; angle = angle + 10) begin
            theta = (angle * 3.14159265358979323846 / 180.0) * (2**16); // Convert to 2.16 fixed-point
            
            #10 init = 0; // Start computation
            #300; // Wait for iterations to complete (assuming enough cycles)

            // Convert fixed-point CORDIC results back to floating-point
            computed_cos = cos_out / (2.0**16);
            computed_sin = sin_out / (2.0**16);

            // Compute reference values using Verilog's math functions
            ref_cos = $cos(angle * 3.14159265358979323846 / 180.0);
            ref_sin = $sin(angle * 3.14159265358979323846 / 180.0);

            // Compute absolute error
            error_cos = computed_cos - ref_cos;
            error_sin = computed_sin - ref_sin;

            // Check if the computed values are within tolerance
            if ((error_cos < tolerance && error_cos > -tolerance) && 
                (error_sin < tolerance && error_sin > -tolerance)) begin
                $display("PASS: Angle %d° -> CORDIC cos=%.6f, sin=%.6f (Expected cos=%.6f, sin=%.6f)", 
                          angle, computed_cos, computed_sin, ref_cos, ref_sin);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: Angle %d° -> CORDIC cos=%.6f, sin=%.6f (Expected cos=%.6f, sin=%.6f) | ERROR: cos=%.6f, sin=%.6f",
                          angle, computed_cos, computed_sin, ref_cos, ref_sin, error_cos, error_sin);
                fail_count = fail_count + 1;
            end

            // Reset for next test case
            init = 1;
            #20;
        end

        // Final Test Summary
        $display("Test Completed: %d Passed, %d Failed.", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("Some tests failed. Check errors above.");

        $stop; // End simulation
    end
endmodule
