#include <stdio.h>
#include <stdint.h>
#include <math.h>

#define FIXED_POINT_SHIFT 16
#define FIXED_SCALE (1 << FIXED_POINT_SHIFT)
#define K_FIXED 39797  // Approximation of 0.607252 * 2^16

// Precomputed arctangent values in 2.16 fixed-point (scaled by 2^16)
const int16_t atan_lut[] = {
    25735, 15192, 8027, 4074, 2045, 1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1
};

void cordic(int16_t theta, int16_t *cos_out, int16_t *sin_out, int iterations) {
    int32_t x = K_FIXED;
    int32_t y = 0;
    int32_t z = theta;

    for (int i = 0; i < iterations; i++) {
        int32_t x_new, y_new;
        int16_t shift = atan_lut[i];

        if (z >= 0) {
            x_new = x - (y >> i);
            y_new = y + (x >> i);
            z -= shift;
        } else {
            x_new = x + (y >> i);
            y_new = y - (x >> i);
            z += shift;
        }

        x = x_new;
        y = y_new;
    }

    *cos_out = (int16_t)x;
    *sin_out = (int16_t)y;
}

void test_cordic() {
    printf("Angle (deg) | CORDIC Cos (2.16) | CORDIC Sin (2.16) | Float Cos | Float Sin | Error Bits\n");
    for (int angle = -90; angle <= 90; angle += 10) {
        int16_t theta = (int16_t)((angle * M_PI / 180.0) * FIXED_SCALE);
        int16_t cos_val, sin_val;

        cordic(theta, &cos_val, &sin_val, 16);

        double cos_fp = cos(angle * M_PI / 180.0);
        double sin_fp = sin(angle * M_PI / 180.0);

        double cos_err = fabs((double)cos_val / FIXED_SCALE - cos_fp);
        double sin_err = fabs((double)sin_val / FIXED_SCALE - sin_fp);

        int cos_accuracy = -log2(cos_err);
        int sin_accuracy = -log2(sin_err);

        printf("%4d        | %10d        | %10d        | %8.5f  | %8.5f  | %3d bits, %3d bits\n",
               angle, cos_val, sin_val, cos_fp, sin_fp, cos_accuracy, sin_accuracy);
    }
}

int main() {
    test_cordic();
    return 0;
}
