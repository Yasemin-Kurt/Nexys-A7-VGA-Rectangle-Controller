# Nexys A7 (Artix-7) VGA Rectangle Controller in SystemVerilog

This repository contains a **SystemVerilog** hardware design implementing a **640×480 @ 60 Hz VGA controller** on the **Digilent Nexys A7 (Artix-7 DDR4)** FPGA development board. The controller renders a solid rectangular region on a VGA monitor whose RGB color is dynamically configured in real time using 12 onboard slide switches.

---

## ⚙️ Architecture & Design Principles

* **Target Hardware:** Digilent Nexys A7 (Artix-7 FPGA)
* **VGA Timing Standard:** 640×480 resolution @ 60 Hz refresh rate (25 MHz pixel clock derived from the 100 MHz onboard oscillator).
* **Dual-Counter Coordinate Addressing:**
  * **Horizontal Counter (`h_count`):** Tracks horizontal pixel positions across active video, front porch, sync pulse, and back porch intervals.
  * **Vertical Counter (`v_count`):** Increments by one upon each complete horizontal line scan.
  * **Zero-Origin Mapping:** Both counters are aligned such that `(h_count == 0, v_count == 0)` directly addresses the top-left pixel of the active display area, eliminating the need for separate coordinate offset counters.
* **12-Bit RGB Color Control:** Reads color data directly from 12 onboard switches (`SW[11:0]`):
  * `SW[11:8]` → 4-bit Red (`VGA_R[3:0]`)
  * `SW[7:4]` → 4-bit Green (`VGA_G[3:0]`)
  * `SW[3:0]` → 4-bit Blue (`VGA_B[3:0]`)
* **Blanking & Boundary Logic:** Outputs valid RGB levels only within the defined rectangular boundary inside the active display region; forces RGB outputs to `0` during horizontal/vertical blanking intervals.

---

## 📂 Repository Structure

```text
Nexys-A7-VGA-Rectangle-Controller/
├── rtl/            # SystemVerilog source modules (.sv)
├── constraints/    # Nexys A7 pin assignment constraints (.xdc)
└── README.md
