section .data
    header db 10, "=== INVENTORY LIST ===", 10
    total_msg db 10, "Total Items: "
    nl db 10

    id_lbl db "ID: "
    name_lbl db " Name: "
    qty_lbl db " Qty: "
    price_lbl db " Price: "

    name1 db "Apple",0
    name2 db "Banana",0

section .bss
    item_count resd 1
    inventory resb 3200
    buf resb 16

section .text
    global _start

_start:

    mov dword [item_count], 2

    ; ITEM 1
    mov esi, inventory
    mov dword [esi], 1
    mov dword [esi+24], 10
    mov dword [esi+28], 25

    lea edi, [esi+4]
    mov esi, name1
.c1:
    lodsb
    stosb
    test al, al
    jnz .c1

    ; ITEM 2
    mov esi, inventory
    add esi, 32
    mov dword [esi], 2
    mov dword [esi+24], 5
    mov dword [esi+28], 15

    lea edi, [esi+4]
    mov esi, name2
.c2:
    lodsb
    stosb
    test al, al
    jnz .c2

    call display

    mov eax, 1
    xor ebx, ebx
    int 80h

display:

    mov eax, 4
    mov ebx, 1
    mov ecx, header
    mov edx, 24
    int 80h

    mov esi, inventory
    mov ebp, [item_count]

.loop:
    test ebp, ebp
    jz .done

    ; ID
    mov eax, 4
    mov ebx, 1
    mov ecx, id_lbl
    mov edx, 4
    int 80h

    mov ecx, [esi]
    call print_num

    ; NAME
    mov eax, 4
    mov ebx, 1
    mov ecx, name_lbl
    mov edx, 7
    int 80h

    lea ecx, [esi+4]
    call print_str

    ; QTY
    mov eax, 4
    mov ebx, 1
    mov ecx, qty_lbl
    mov edx, 6
    int 80h

    mov ecx, [esi+24]
    call print_num

    ; PRICE
    mov eax, 4
    mov ebx, 1
    mov ecx, price_lbl
    mov edx, 8
    int 80h

    mov ecx, [esi+28]
    call print_num

    ; newline
    mov eax, 4
    mov ebx, 1
    mov ecx, nl
    mov edx, 1
    int 80h

    add esi, 32
    dec ebp
    jmp .loop

.done:
    mov eax, 4
    mov ebx, 1
    mov ecx, total_msg
    mov edx, 14
    int 80h

    mov ecx, [item_count]
    call print_num

    ret

print_num:
    push eax
    push ebx
    push edx
    push esi

    mov eax, ecx
    mov ebx, 10
    mov esi, buf + 15
    mov byte [esi], 0
    dec esi

    cmp eax, 0
    jne .conv
    mov byte [esi], '0'
    jmp .out

.conv:
.loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [esi], dl
    dec esi
    test eax, eax
    jnz .loop

    inc esi

.out:
    mov ecx, esi
    mov edx, buf + 15
    sub edx, esi

    mov eax, 4
    mov ebx, 1
    int 80h

    pop esi
    pop edx
    pop ebx
    pop eax
    ret

print_str:
    push eax
    push ebx
    push edx

    mov edx, 0
.len:
    cmp byte [ecx+edx], 0
    je .out
    inc edx
    jmp .len

.out:
    mov eax, 4
    mov ebx, 1
    int 80h

    pop edx
    pop ebx
    pop eax
    ret