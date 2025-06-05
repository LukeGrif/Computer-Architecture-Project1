# Rotation-Mode CORDIC Processor

## 📘 Overview

This project implements a Rotation-Mode CORDIC processor to calculate trigonometric functions like sine and cosine using fixed-point arithmetic. The design includes:

- A Python-based simulation for algorithm verification  
- A Verilog hardware implementation  
- Error and accuracy analysis against standard math functions  

**Team Members:**
- Luke Griffin  
- Taha Al-Salihi  
- Reema Ibrahim  
- Aaron Smith

---

## 🧠 Background

CORDIC (COordinate Rotation DIgital Computer) is a shift-add algorithm for computing:

- Sine and Cosine  
- Hyperbolic and exponential functions  
- Vector rotation using angle accumulation  

It avoids multiplication and division, making it suitable for embedded hardware.

![image](https://github.com/user-attachments/assets/9f833443-592c-4d24-8517-75ccee653766)

**🖼️ Diagram of single rotation step (e.g., from Volder’s paper)**  

![image](https://github.com/user-attachments/assets/97ef44ab-1070-49fa-a2a9-671020b8c217)

**🖼️ Placeholder: Arithmetic unit block diagram**

---

## 🧱 System Architecture

The project includes two main components:

1. **Python Simulation**  
   - Uses 2.16 fixed-point representation  
   - Computes sine and cosine  
   - Compares results to Python's math library

2. **Verilog Hardware Design**  
   - FSM-based control flow  
   - Iterative rotation logic  
   - Fixed-point output for sine and cosine

---

## 🔣 Fixed-Point Arithmetic

- 2 bits for integer, 16 bits for fraction  
- Simulates how hardware calculates trigonometric values  
- Ensures consistent scaling and precision across systems

---

## 🔄 CORDIC Iterative Algorithm

The processor works by:
- Applying precomputed angle rotations  
- Rotating a vector using only additions, subtractions, and shifts  
- Accumulating angle corrections for convergence

---

## 🧪 Python Simulation Results

- Tested across input angles from -90° to +90°  
- Measured:
  - Sine and cosine values  
  - Absolute error  
  - Bit-level accuracy
 
  - 
![image](https://github.com/user-attachments/assets/8ef6a420-7d79-447a-8412-c5a85e716e11)

**🖼️ Graph of cosine error vs angle** 

![image](https://github.com/user-attachments/assets/89bbac4e-891e-498c-b1e9-74003d4b2499)

**🖼️ Graph of sine error vs angle**

---

## ⚙️ Verilog Hardware Implementation

- 17-cycle FSM for CORDIC rotation  
- Accepts angle input and computes fixed-point sine/cosine  
- Produces outputs and signals when computation is complete  

![image](https://github.com/user-attachments/assets/051cc696-0d48-4586-9c94-f4f52c75cb51)

**🖼️ Verilog waveform showing signal transitions**

---

## 📊 Final Results

- High accuracy (15–16 bits of precision)  
- Error values well within acceptable limits  
- Successfully validated hardware output against software simulation  

![image](https://github.com/user-attachments/assets/2c75865d-61a2-42ed-9f43-9a241f196112)

**🖼️ Table comparing printed output to expected values**  

---

## ✅ Conclusion

The project confirms that:
- CORDIC is a hardware-efficient algorithm for trigonometric calculations  
- Fixed-point representations provide high accuracy  
- Python simulation and Verilog implementation align closely  

---

## 🔭 Future Work

- Expand to include hyperbolic/trigonometric identities  
- Implement real-time dynamic scaling  
- Extend to pipeline or parallel versions

---

## 📎 References

- J. Volder, *The CORDIC Computing Technique*, 1959  
- Lecture notes and module resources on digital computation
