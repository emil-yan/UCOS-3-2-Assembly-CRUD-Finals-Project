# x86 Assembly CRUD Management System
### *UCOS-3-2 Assembly Language Finals Project*

A low-level Inventory Management System built using **x86 Assembly (NASM)**. This project demonstrates fundamental low-level programming concepts, including direct memory manipulation, system calls, and file I/O operations without high-level library abstractions.

---

## 📂 Project Structure

The repository is organized into modules representing each phase of the application lifecycle:

* **`1. System Initialization`** – Setup of data segments, constants, and file descriptors.
* **`2. Main Menu`** – The central UI loop and user input handling.
* **`3. Add Item`** – Implementation of the **Create** logic (writing to file/memory).
* **`4. Update Item`** – Pointer manipulation to modify existing records.
* **`5. Delete Item`** – Logic for record removal and memory shifting.
* **`6. Search Item`** – String comparison algorithms in Assembly.
* **`7. Display Inventory`** – Output formatting for terminal display.
* **`8. Generate Report & Exit`** – Final file synchronization and program termination.
* **`9. Compilation`** – Scripts and instructions for assembling and linking.

---

## 🛠️ Tech Stack & Requirements

* **Assembler:** NASM (Netwide Assembler)
* **Linker:** GNU LD
* **Architecture:** x86 (32-bit/64-bit compatibility)
* **Platform:** Linux / Unix-based systems

---

## 🚀 Key Features

* **Manual Memory Management:** Precise control over buffers and registers (EAX, EBX, ECX, EDX).
* **File Persistence:** Uses Linux System Calls (`int 0x80`) to save data permanently to disk.
* **Input Validation:** Low-level checks to ensure system stability during user interaction.
* **Efficient Search:** Implements linear search algorithms directly at the byte level.

---

## ⚙️ Compilation & Execution

To build the project, navigate to the **`9. Compilation`** folder or run the following commands from the root:

1. **Assemble the code:**
   ```bash
   nasm -f elf32 main.asm -o main.o
