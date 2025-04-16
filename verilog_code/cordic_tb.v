// cordic_tb.v
// Author: Luke Griffin 21334528, Taha Al-Salihi 21302227, Reema Ibrahim 2447644, Aaron Smith 21335168
// Date: 15-04-2025
//
// Testbench for the CORDIC module. This testbench checks sine and cosine values for
// angles from -90 to +90 degrees in 15-degree steps

`timescale 1ns / 1ps

module tb_CORDIC;
    
    //Inputs
    reg signed [1:-16] angle; // Input angle in Q2.16
    reg init = 0;
    reg clk = 0;

    // Outputs 
    wire signed [1:-16] cos_out, sin_out;
    wire done;

    // Instantiate
    CORDIC uut (
        .cosine(cos_out),
        .sine(sin_out),
        .done(done),
        .target_angle(angle),
        .init(init),
        .clk(clk)
    );

    // clock signal
    always #5 clk = ~clk;

    // convert radians to Q2.16 format
    function signed [1:-16] rad_to_fixed;
        input real radians;
        begin
            rad_to_fixed = $rtoi(radians * 65536.0);
        end
    endfunction

    // Variables for expected and actual outputs
    real angle_deg, angle_rad;
    real expected_cos, expected_sin;
    real actual_cos, actual_sin;
    real error_cos, error_sin;

    integer i;

    initial begin
        $display("Starting CORDIC 15 degrees step testbench...");
        $dumpfile("cordic_loop_tb.vcd");    // For waveform viewing
        $dumpvars(0, tb_CORDIC);            // Dump everything under tb_CORDIC

        // Loop from -90 to 90 degrees in 15-degree steps
        for (i = -90; i <= 90; i = i + 15) begin
            angle_deg = i;
            angle_rad = angle_deg * 3.14159265358979 / 180.0;
            angle <= rad_to_fixed(angle_rad); // Convert to fixed-point

            $display("\\n==== Test Angle: %0d degrees (%.4f rad) ====", i, angle_rad);

            // Trigger CORDIC computation
            @(negedge clk); init <= 1;
            @(negedge clk); init <= 0;

            // Wait until the output is ready
            wait (done == 1);
            @(negedge clk);

            // Convert outputs back to real numbers
            actual_cos = cos_out / 65536.0;
            actual_sin = sin_out / 65536.0;
            expected_cos = $cos(angle_rad);
            expected_sin = $sin(angle_rad);
            error_cos = expected_cos - actual_cos;
            error_sin = expected_sin - actual_sin;

            // Display the results
            $display("   COS = %f (CORDIC), expected = %f, error = %f", actual_cos, expected_cos, error_cos);
            $display("   SIN = %f (CORDIC), expected = %f, error = %f", actual_sin, expected_sin, error_sin);
        end

        $display("\\nTestbench complete.");
        $finish;
    end

endmodule
