section .data
    ; --- Strings for Report and Exit ---
    report_header   db "--- INVENTORY REPORT ---", 10, 0
    report_hdr_len  equ $ - report_header

    low_stock_msg   db " - [WARNING: LOW STOCK]", 10, 0
    low_stock_len   equ $ - low_stock_msg

    total_val_msg   db "Total Inventory Value: $", 0
    total_val_len   equ $ - total_val_msg

    exit_msg        db 10, "Data saved. Exiting Inventory System. Goodbye!", 10, 0
    exit_msg_len    equ $ - exit_msg

    filename        db "inventory_data.dat", 0
    newline         db 10, 0

    ; --- Constants ---
    LOW_STOCK_THRESHOLD equ 5    ; Items with <= 5 quantity trigger an alert
    ITEM_SIZE           equ 24   ; 16 (name) + 4 (qty) + 4 (price)

section .bss
    fd resq 1                    ; Reserve 8 bytes for the file descriptor

section .text
    global generate_report_and_exit
    
    ; Assuming these exist elsewhere in your project
    extern inventory_array       ; The base address of your item array
    extern item_count            ; Variable holding the current number of items
    extern print_int             ; Your routine to print an integer to stdout

generate_report_and_exit:
    ; ---------------------------------------------------------
    ; 1. PRINT SUMMARY REPORT HEADER
    ; ---------------------------------------------------------
    mov rax, 1                   ; sys_write
    mov rdi, 1                   ; stdout
    mov rsi, report_header
    mov rdx, report_hdr_len
    syscall

    ; Initialize accumulators and pointers
    xor r12, r12                 ; r12 = Total Inventory Value (starts at 0)
    xor r13, r13                 ; r13 = Loop counter (starts at 0)
    mov r14, inventory_array     ; r14 = Pointer to the current item in the array

.report_loop:
    ; Check if we have processed all items
    cmp r13, [item_count]
    jge .report_done

    ; ---------------------------------------------------------
    ; 2. CALCULATE TOTAL STOCK VALUE (Quantity * Price)
    ; ---------------------------------------------------------
    mov eax, dword [r14 + 16]    ; Load Quantity (offset 16)
    mov ebx, dword [r14 + 20]    ; Load Price (offset 20)
    imul eax, ebx                ; eax = Quantity * Price
    add r12d, eax                ; Accumulate into total value (r12)

    ; ---------------------------------------------------------
    ; 3. IDENTIFY LOW-STOCK ITEMS (Threshold Check)
    ; ---------------------------------------------------------
    mov eax, dword [r14 + 16]    ; Reload Quantity
    cmp eax, LOW_STOCK_THRESHOLD
    jg .next_item                ; If qty > threshold, skip the warning print

    ; Print the Item Name
    mov rax, 1
    mov rdi, 1
    mov rsi, r14                 ; Name is at the very start of the struct (offset 0)
    mov rdx, 16                  ; Print max 16 characters
    syscall

    ; Print "Low Stock" Warning suffix
    mov rax, 1
    mov rdi, 1
    mov rsi, low_stock_msg
    mov rdx, low_stock_len
    syscall

.next_item:
    add r14, ITEM_SIZE           ; Move pointer to the next item struct
    inc r13                      ; Increment loop counter
    jmp .report_loop

.report_done:
    ; Print "Total Inventory Value: $"
    mov rax, 1
    mov rdi, 1
    mov rsi, total_val_msg
    mov rdx, total_val_len
    syscall

    ; Print the calculated integer value
    mov rdi, r12                 ; Pass total value as argument
    call print_int               ; Call your external integer printing function

    ; Print a newline for formatting
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; ---------------------------------------------------------
    ; 4. SAVE DATA (File Handling)
    ; ---------------------------------------------------------
    ; Open File
    mov rax, 2                   ; sys_open
    mov rdi, filename            ; "inventory_data.dat"
    mov rsi, 577                 ; Flags: O_WRONLY (1) | O_CREAT (64) | O_TRUNC (512)
    mov rdx, 0644o               ; Permissions: rw-r--r--
    syscall
    mov [fd], rax                ; Store the returned file descriptor

    ; Validate file opening (if rax < 0, jump to skip writing)
    test rax, rax
    js .skip_write

    ; Write Array to File
    mov rax, 1                   ; sys_write
    mov rdi, [fd]                ; File descriptor
    mov rsi, inventory_array     ; Buffer to write
    mov rax, [item_count]        
    mov rcx, ITEM_SIZE           
    mul rcx                      ; Calculate Total Bytes = item_count * ITEM_SIZE
    mov rdx, rax                 ; Move total bytes into rdx for syscall
    
    mov rax, 1                   ; Reset sys_write syscall number (overwritten by mul)
    syscall

    ; Close File
    mov rax, 3                   ; sys_close
    mov rdi, [fd]
    syscall

.skip_write:
    ; ---------------------------------------------------------
    ; 5 & 6. DISPLAY EXIT MESSAGE AND TERMINATE
    ; ---------------------------------------------------------
    mov rax, 1                   ; sys_write
    mov rdi, 1                   ; stdout
    mov rsi, exit_msg
    mov rdx, exit_msg_len
    syscall

    mov rax, 60                  ; sys_exit
    xor rdi, rdi                 ; Return code 0 (Success)
    syscall