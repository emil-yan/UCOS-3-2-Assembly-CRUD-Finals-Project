section .data
    prompt_id    db "Enter Item ID (numeric): ", 0
    prompt_name  db "Enter Item Name: ", 0
    prompt_qty   db "Enter Quantity: ", 0
    prompt_price db "Enter Price: ", 0
    msg_exists   db "Error: ID already exists!", 10, 0
    msg_success  db "Item added successfully!", 10, 0
    msg_full     db "Error: Inventory full!", 10, 0

    MAX_ITEMS    equ 10
    RECORD_SIZE  equ 64

section .bss
    inventory    resb RECORD_SIZE * MAX_ITEMS
    item_count   resd 1
    temp_id      resd 1
    input_buffer resb 32

section .text
    global _start

_start:
    ; For demonstration, we call the add_item function
    call add_item
    
    ; Exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80

add_item:
    ; 1. Check Capacity
    mov eax, [item_count]
    cmp eax, MAX_ITEMS
    jge .inventory_full

    ; 2. Input ID
    ; (Simplified: Assuming input is converted to integer in EAX)
    ; For JDoodle, you'd use a read syscall and an ASCII-to-Integer (ATOI) function
    ; Let's assume the ID is now in EBX for validation
    
    ; 3. Validate Uniqueness (Loop through existing items)
    mov ecx, [item_count]
    mov esi, inventory
.check_unique:
    jecxz .id_is_unique
    cmp ebx, [esi]       ; Compare input ID with current record ID
    je .id_exists
    add esi, RECORD_SIZE
    loop .check_unique

.id_is_unique:
    ; 4. Calculate Offset for New Record
    ; Offset = item_count * RECORD_SIZE
    mov eax, [item_count]
    imul eax, RECORD_SIZE
    lea edi, [inventory + eax]

    ; 5. Store Data
    ; Store ID
    mov [edi], ebx       
    
    ; Store Name (using movsb or similar)
    ; Store Quantity
    ; Store Price
    
    ; 6. Increment Counter
    inc dword [item_count]
    
    ; Print Success Message
    ; ... (sys_write call)
    ret

.id_exists:
    ; Print msg_exists
    ret

.inventory_full:
    ; Print msg_full
    ret