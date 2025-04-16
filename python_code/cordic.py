"""
cordic.py

CORDIC Algorithm Implementation in Python (Q2.16 Fixed-Point Arithmetic)
Author: Luke Griffin 21334528, Taha Al-Salihi 21302227, Reema Ibrahim 2447644, Aaron Smith 21335168
Date: 15-04-2025

This Python script implements a fixed-point version of the CORDIC (COordinate Rotation DIgital Computer) algorithm
for calculating sine and cosine values of angles using iterative shift-and-add operations.

"""

import math

# Define fixed-point parameters for Q2.16 format
FIXED_FRACTIONAL_BITS = 16
FIXED_ONE = 1 << FIXED_FRACTIONAL_BITS  # Represents 1.0 in fixed-point

def float_to_fixed(x):
    """
    Converts a floating-point number to fixed-point (Q2.16).
    """
    return int(round(x * FIXED_ONE))

def fixed_to_float(x):
    """
    Converts a fixed-point (Q2.16) number back to a floating-point number.
    """
    return float(x) / FIXED_ONE

def create_fixed_tan_table(n):
    """
    Creates a lookup table (as a list) for arctan(2^-i) in degrees,
    with each value converted to fixed-point Q2.16.
    
    Parameters:
        n (int): Number of table entries (for i = 0 to n, inclusive)
    
    Returns:
        list: A list of fixed-point angles in degrees.
    """
    table = []
    for i in range(n + 1):
        angle_rad = math.atan(2**(-i))
        angle_deg = math.degrees(angle_rad)
        table.append(float_to_fixed(angle_deg))
    return table

def find_An(n):
    """
    Computes the CORDIC gain factor A(n) as a floating-point number.
    
    The gain is the product:
        A(n) = sqrt(2) * sqrt(1 + 2^(-2)) * ... * sqrt(1 + 2^(-2*(n-1)))
    
    Parameters:
        n (int): Number of iterations.
    
    Returns:
        float: The CORDIC gain.
    """
    An = math.sqrt(2)
    for i in range(1, n):
        An *= math.sqrt(1 + 2**(-2 * i))
    return An

def cordic_fixed(angle, n):
    """
    Fixed-point implementation of the CORDIC algorithm in Q2.16 format.
    
    Parameters:
        angle (float): The target rotation angle in degrees.
        n (int): Number of iterations. (Typically, for fixed-point, using a count 
                 near the number of fractional bits, e.g. 16, is common.)
    
    Returns:
        tuple: (cos, sin) as floating-point numbers computed from fixed-point values.
    """
    # Precompute the scaling gain so that our initial vector equals (1/An, 0)
    gain = find_An(n)
    # Set initial vector x = 1.0/An, y = 0 in fixed-point representation.
    x = float_to_fixed(1.0 / gain)
    y = 0
    # Convert the desired rotation angle (in degrees) into fixed-point.
    z = float_to_fixed(angle)
    # Create a table of arctan(2^-i) values (in degrees) in fixed-point.
    tan_table = create_fixed_tan_table(n)
    
    # Iterate the CORDIC rotations.
    # In each iteration, the vector is rotated by an angle of arctan(2^-i)
    # The shift operations (>> i) effectively multiply by 2^-i.
    for i in range(n + 1):
        # Determine the rotation direction: if the remaining angle z is negative,
        # rotate in the negative direction.
        di = -1 if z < 0 else 1
        
        # Perform the fixed-point vector rotation.
        # Multiplication by 2^-i is performed by a right shift by i bits.
        new_x = x - di * (y >> i)
        new_y = y + di * (x >> i)
        x, y = new_x, new_y
        
        # Update the remaining angle z by subtracting the angle used in this iteration.
        z = z - di * tan_table[i]
    
    # Convert the final fixed-point cosine and sine values back to float.
    return fixed_to_float(x), fixed_to_float(y)

def main():
    N = 16

    print(f"      Angle |               CORDIC |             math.cos |               Error | Bits of Accuracy")
    print( "------------|----------------------|----------------------|---------------------|-----------------")

    for angle_deg in range(-90, 91, 10):
        cos_stdlib, _ = math.cos(math.radians(angle_deg)), math.sin(math.radians(angle_deg))
        cos_cordic, _ = cordic_fixed(angle_deg, N)

        error_cos = abs(cos_stdlib - cos_cordic)

        accuracy_cos_bits = FIXED_FRACTIONAL_BITS + 2 if error_cos == 0 else math.floor(-math.log2(error_cos))

        print(f"        {angle_deg:> 3} | {cos_cordic: 2.17f} | {cos_stdlib: 2.17f} | {error_cos:>2.17f} | {accuracy_cos_bits:>2}")

    print("\n")

    print(f"      Angle |               CORDIC |             math.sin |               Error | Bits of Accuracy")
    print( "------------|----------------------|----------------------|---------------------|-----------------")

    for angle_deg in range(-90, 91, 10):
        _, sin_stdlib = math.sin(math.radians(angle_deg)), math.sin(math.radians(angle_deg))
        _, sin_cordic = cordic_fixed(angle_deg, N)

        error_sin = abs(sin_stdlib - sin_cordic)

        accuracy_sin_bits = FIXED_FRACTIONAL_BITS + 2 if error_sin == 0 else math.floor(-math.log2(error_sin))

        print(f"        {angle_deg:> 3} | {sin_cordic: 2.17f} | {sin_stdlib: 2.17f} | {error_sin:>2.17f} | {accuracy_sin_bits:>2}")

if __name__ == '__main__':
    main()

