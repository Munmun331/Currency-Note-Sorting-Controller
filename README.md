🚀 Currency Note Sorting Controller (RTL to GDSII)
📌 Overview

This project implements an FSM-based controller for an automated currency note sorting machine, designed using Verilog and taken through a complete ASIC design flow from RTL to GDSII.

⚙️ Features

Mealy FSM-based control logic for fast response

Sorting of ₹10–₹500 notes into dedicated bins

Counterfeit detection with alarm signal

Maintenance mode for manual control and debugging

Real-time counters and total amount calculation

🏗️ Design Flow

RTL Design (Verilog)

Functional Simulation (Cadence SimVision)

Synthesis (Cadence Genus)

Physical Design (Innovus)

Static Timing Analysis (Tempus)

GDSII Generation

📊 Results

✔️ Successful FSM verification (waveforms)

✔️ No timing violations after STA

✔️ Area, Power, and Timing analyzed

🖼️ Key Outputs

(Add your screenshots here)

🛠️ Tools Used

Verilog HDL

Cadence Genus

Cadence Innovus

Cadence SimVision

Cadence Tempus

📚 Learnings

FSM & datapath design

ASIC design flow (RTL → GDSII)

Timing closure and optimization
