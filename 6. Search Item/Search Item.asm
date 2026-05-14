section .data
    prompt_search db "Search (Enter ID): ", 0
    msg_header    db 10, "--- Item Details ---", 10, 0
    msg_id        db "ID: ", 0
    msg_qty       db "Qty: ", 0
    msg_not_found db 10, "Error: Item not found!", 10, 0
    newline       db 10, 0

    MAX_ITEMS     equ 10
    RECORD_SIZE   equ 64  ; [ID(4) | Name(32) | Qty(4) | Price(24)]

section .bss
    inventory     resb RECORD_SIZE * MAX_ITEMS
    item_count    resd 1
    input_buffer  resb 16
    search_id     resd 1

section .text
    global _start

_start:
    ; --- MOCK DATA INSERTION (For Testing) ---
    mov esi, inventory
    mov dword [esi], 101       ; ID: 101
    mov dword [esi + 36], 50   ; Qty: 50 (Offset 36 = ID + Name)
    inc dword [item_count]

    ; --- PART 2: USER INTERFACE (I/O) ---
    mov edx, prompt_search
    call print_string

    ; Read user input
    mov eax, 3          ; sys_read
    mov ebx, 0          ; stdin
    mov ecx, input_buffer
    mov edx, 16
    int 0x80

    ; Convert input string to integer
    call ascii_to_int
    mov [search_id], eax

    ; --- PART 1: CORE ENGINE (Traversal) ---
    call search_engine
    
    ; Exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

; ---------------------------------------------------------
; CORE ENGINE: SEARCH LOOP
; ---------------------------------------------------------
search_engine:
    mov ecx, [item_count]
    mov esi, inventory
    mov eax, [search_id]

    test ecx, ecx
    jz .fail

.search_loop:
    cmp [esi], eax          ; Compare current ID with target
    je .success             ; Match found!
    
    add esi, RECORD_SIZE    ; Move pointer to next record
    loop .search_loop

.fail:
    mov edx, msg_not_found
    call print_string
    ret

.success:
    call display_item_details
    ret

; ---------------------------------------------------------
; UI: DISPLAY FORMATTING
; ---------------------------------------------------------
display_item_details:
    pusha
    mov ebp, esi            ; Save record pointer in EBP
    
    mov edx, msg_header
    call print_string

    ; Display ID Label and Value
    mov edx, msg_id
    call print_string
    ; (Note: In a full app, you'd call an Integer-to-ASCII function here)
    
    ; Display Name (Starting at ESI + 4)
    lea edx, [ebp + 4]
    call print_string
    mov edx, newline
    call print_string

    popa
    ret

; ---------------------------------------------------------
; UTILITIES: ATOI & PRINT
; ---------------------------------------------------------
ascii_to_int:
    xor eax, eax
    mov esi, input_buffer
.next_digit:
    movzx ecx, byte [esi]
    cmp cl, 10              ; End on newline
    je .done
    sub cl, '0'
    jl .done
    imul eax, 10
    add eax, ecx
    inc esi
    jmp .next_digit
.done:
    ret

print_string:
    pusha
    mov ebx, edx
    xor al, al
    mov edi, edx
    mov ecx, -1
    repne scasb
    not ecx
    dec ecx
    mov edx, ecx
    mov ecx, ebx
    mov ebx, 1
    mov eax, 4
    int 0x80
    popa
    ret