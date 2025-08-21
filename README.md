# AMBA-APB-System-Design

This repository contains the design and implementation of an AMBA Advanced Peripheral Bus (APB) system in Verilog HDL. The project covers the complete design cycle: protocol study, RTL implementation, functional verification, and synthesis. It aims to provide a practical demonstration of how the APB protocol can be used to connect low-power peripherals in a modular SoC environment.

The system consists of an APB master, decoder, RAM slave, and timer slave, all integrated through a top-level wrapper module. The master generates the necessary APB signals, the decoder handles address mapping and slave selection, the RAM slave provides parameterized memory storage, and the timer slave implements a programmable one-shot down-counter with reload and interrupt support. Together, these modules form a functional APB-based subsystem that is compliant with the ARM AMBA APB protocol.

Verification of the design was carried out using QuestaSim. The RAM was tested for read and write operations, while the timer was validated for reload, countdown, and interrupt generation. The system was also verified under wait state conditions using the PREADY signal. After simulation, the RTL was successfully elaborated and synthesized to confirm structural correctness and compliance with the protocol.

The design is written in a parameterized style to ensure reusability and scalability, making it possible to expand the system or adapt it to different word sizes and memory depths. This approach reflects real-world SoC design practices where flexibility and modularity are essential.

For documentation, the repository includes a full technical report explaining the APB protocol, the architecture of the project, detailed design decisions, and verification results. Simulation waveforms and synthesis outputs are also included for reference.
