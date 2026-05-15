section .data
p_uid:          db "Enter ID of item to UPDATE: "
p_uid_len       equ $ - p_uid
p_newqty:       db "Enter new quantity: "
p_newqty_len    equ $ - p_newqty
p_newprice:     db "Enter new price: "
p_newprice_len  equ $ - p_newprice
m_updated:      db 10, "[OK]  Item updated.", 10
m_updated_len   equ $ - m_updated
m_empty:        db 10, "[ERR] Inventory is empty.", 10
m_empty_len     equ $ - m_empty
m_notfound:     db 10, "[ERR] Item not found.", 10
m_notfound_len  equ $ - m_notfound

section .text

handle_update:
    push ebx
    push edi
    cmp  dword [item_count], 0
    jne  .ne
    mov  ecx, m_empty
    mov  edx, m_empty_len
    call print_buf
    jmp  .ret
.ne:
    mov  ecx, p_uid
    mov  edx, p_uid_len
    call print_buf
    call read_line
    call atoi_buf
    call find_item_by_id
    cmp  eax, -1
    jne  .got
    mov  ecx, m_notfound
    mov  edx, m_notfound_len
    call print_buf
    jmp  .ret
.got:
    mov  ebx, eax                ; ebx = index
    push ebx
    call print_one_item          ; show the item being edited (Part 7)
    pop  ebx
    ; -- prompt new quantity --
    mov  ecx, p_newqty
    mov  edx, p_newqty_len
    call print_buf
    call read_line
    call atoi_buf
    push eax                     ; save new qty
    mov  eax, ebx
    call rec_addr
    mov  edi, eax                ; edi = record addr
    pop  eax
    mov  [edi + REC_QTY], eax
    ; -- prompt new price --
    mov  ecx, p_newprice
    mov  edx, p_newprice_len
    call print_buf
    call read_line
    call parse_price_buf
    mov  [edi + REC_PRICE], eax
    mov  ecx, m_updated
    mov  edx, m_updated_len
    call print_buf
.ret:
    pop  edi
    pop  ebx
    ret