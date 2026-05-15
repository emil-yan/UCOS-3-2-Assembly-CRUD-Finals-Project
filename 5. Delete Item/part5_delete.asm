; ============================================================================
;  PART 5 of 8 : DELETE ITEM
;  Group: Lugo, Villanueva
;
;  Purpose: Pre-populates the inventory with 3 sample items, then prompts the
;           user for an item ID to delete. If found, the record is removed
;           by shifting all later records back one slot in the array, and
;           the item counter is decremented. If not found, an error is shown.
;           Type ID = 0 to stop.
;
;  Build:  nasm -f elf part5_delete.asm -o part5_delete.o
;          ld -m elf_i386 part5_delete.o -o part5_delete
;          ./part5_delete
;
;  Test stdin:
;          102
;          999
;          0
; ============================================================================

%define SYS_EXIT  1
%define SYS_READ  3
%define SYS_WRITE 4
%define STDIN     0
%define STDOUT    1

%define REC_ID    0
%define REC_QTY   4
%define REC_PRICE 8
%define REC_NAME  16
%define REC_SIZE  48
%define NAME_LEN  32
%define MAX_ITEMS 100

; ----------------------------------------------------------------------------
section .data
; ----------------------------------------------------------------------------
banner:     db 10, "=== PART 5: DELETE ITEM DEMO ===", 10
            db "Pre-loaded with 3 items. Delete one by ID.", 10
            db "Enter ID = 0 to stop.", 10
banner_len  equ $ - banner

p_id:       db 10, "Enter ID of item to DELETE (0 to stop): "
p_id_len    equ $ - p_id
p_newq:     db "(unused in delete)", 10
p_newq_len  equ $ - p_newq
p_newp:     db "(unused in delete)", 10
p_newp_len  equ $ - p_newp

m_ok:       db "[OK]  Item deleted.", 10
m_ok_len    equ $ - m_ok
m_nf:       db "[ERR] Item not found.", 10
m_nf_len    equ $ - m_nf
m_dump:     db 10, "--- Inventory state (id  qty  price_cents  name) ---", 10
m_dump_len  equ $ - m_dump
m_bye:      db "--- end ---", 10
m_bye_len   equ $ - m_bye

nl:         db 10
sp_ch:      db " "

; Pre-populated names (we copy these into inventory at startup)
name1:      db "Pencil", 0
name2:      db "Notebook", 0
name3:      db "Eraser", 0

; ----------------------------------------------------------------------------
section .bss
; ----------------------------------------------------------------------------
inventory:  resb REC_SIZE * MAX_ITEMS
item_count: resd 1
input_buf:  resb 128
acc_buf:    resb 16
eof_flag:   resb 1

; ----------------------------------------------------------------------------
section .text
global _start
; ----------------------------------------------------------------------------

print_buf:
    push eax
    push ebx
    mov  eax, SYS_WRITE
    mov  ebx, STDOUT
    int  0x80
    pop  ebx
    pop  eax
    ret

print_nl:
    push ecx
    push edx
    mov  ecx, nl
    mov  edx, 1
    call print_buf
    pop  edx
    pop  ecx
    ret

print_sp:
    push ecx
    push edx
    mov  ecx, sp_ch
    mov  edx, 1
    call print_buf
    pop  edx
    pop  ecx
    ret

print_cstr:
    push esi
    push edx
    push ecx
    mov  esi, ecx
    xor  edx, edx
.l:
    cmp  byte [esi+edx], 0
    je   .w
    inc  edx
    jmp  .l
.w:
    mov  ecx, esi
    call print_buf
    pop  ecx
    pop  edx
    pop  esi
    ret

read_line:
    push ebx
    push ecx
    push edx
    push esi
    xor  esi, esi
.next:
    cmp  esi, 127
    jge  .done
    mov  eax, SYS_READ
    mov  ebx, STDIN
    lea  ecx, [input_buf + esi]
    mov  edx, 1
    int  0x80
    test eax, eax
    js   .eof
    jz   .eof
    cmp  byte [input_buf + esi], 10
    je   .gotnl
    inc  esi
    jmp  .next
.gotnl:
    mov  byte [input_buf + esi], 0
    jmp  .done
.eof:
    mov  byte [input_buf + esi], 0
    mov  byte [eof_flag], 1
.done:
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    ret

atoi_buf:
    push ebx
    push esi
    push ecx
    xor  eax, eax
    mov  esi, input_buf
.d:
    movzx ecx, byte [esi]
    cmp  ecx, '0'
    jl   .x
    cmp  ecx, '9'
    jg   .x
    sub  ecx, '0'
    imul eax, eax, 10
    add  eax, ecx
    inc  esi
    jmp  .d
.x:
    pop  ecx
    pop  esi
    pop  ebx
    ret

parse_price_buf:
    push ebx
    push esi
    push ecx
    mov  esi, input_buf
    xor  eax, eax
    xor  ebx, ebx
.whole:
    movzx ecx, byte [esi]
    cmp  ecx, '0'
    jl   .chk
    cmp  ecx, '9'
    jg   .chk
    sub  ecx, '0'
    imul eax, eax, 10
    add  eax, ecx
    inc  esi
    jmp  .whole
.chk:
    cmp  ecx, '.'
    jne  .comb
    inc  esi
    movzx ecx, byte [esi]
    cmp  ecx, '0'
    jl   .comb
    cmp  ecx, '9'
    jg   .comb
    sub  ecx, '0'
    mov  ebx, ecx
    inc  esi
    movzx ecx, byte [esi]
    cmp  ecx, '0'
    jl   .single
    cmp  ecx, '9'
    jg   .single
    sub  ecx, '0'
    imul ebx, ebx, 10
    add  ebx, ecx
    jmp  .comb
.single:
    imul ebx, ebx, 10
.comb:
    imul eax, eax, 100
    add  eax, ebx
    pop  ecx
    pop  esi
    pop  ebx
    ret

print_int:
    push eax
    push ebx
    push ecx
    push edx
    push edi
    mov  edi, acc_buf
    xor  ecx, ecx
    test eax, eax
    jne  .gen
    mov  byte [edi], '0'
    mov  ecx, 1
    jmp  .out
.gen:
    mov  ebx, 10
.div:
    test eax, eax
    je   .pop
    xor  edx, edx
    div  ebx
    add  dl, '0'
    push edx
    inc  ecx
    jmp  .div
.pop:
    mov  ebx, ecx
.po:
    test ebx, ebx
    je   .out
    pop  edx
    mov  [edi], dl
    inc  edi
    dec  ebx
    jmp  .po
.out:
    mov  edx, ecx
    mov  ecx, acc_buf
    call print_buf
    pop  edi
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    ret

copy_name:
    push esi
    push edi
    push ecx
    push eax
    mov  ecx, NAME_LEN - 1
.l:
    test ecx, ecx
    je   .nul
    mov  al, [esi]
    test al, al
    je   .nul
    mov  [edi], al
    inc  esi
    inc  edi
    dec  ecx
    jmp  .l
.nul:
    mov  byte [edi], 0
    pop  eax
    pop  ecx
    pop  edi
    pop  esi
    ret

rec_addr:
    push ecx
    mov  ecx, REC_SIZE
    imul eax, ecx
    add  eax, inventory
    pop  ecx
    ret

find_item_by_id:
    push ebx
    push ecx
    push edx
    push esi
    mov  edx, eax
    mov  ecx, [item_count]
    xor  ebx, ebx
    mov  esi, inventory
.l:
    cmp  ebx, ecx
    jge  .nf
    cmp  edx, [esi + REC_ID]
    je   .fnd
    add  esi, REC_SIZE
    inc  ebx
    jmp  .l
.fnd:
    mov  eax, ebx
    jmp  .d
.nf:
    mov  eax, -1
.d:
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    ret

; ============================================================================
;  Sample data setup -- pre-populate 3 items
; ============================================================================
setup_sample_data:
    push edi
    push esi
    ; record 0: ID=101, qty=50, price=125 (=$1.25), name="Pencil"
    mov  eax, 0
    call rec_addr
    mov  edi, eax
    mov  dword [edi + REC_ID], 101
    mov  dword [edi + REC_QTY], 50
    mov  dword [edi + REC_PRICE], 125
    mov  esi, name1
    push edi
    add  edi, REC_NAME
    call copy_name
    pop  edi
    ; record 1: ID=102, qty=5, price=1500 (=$15.00), name="Notebook"
    mov  eax, 1
    call rec_addr
    mov  edi, eax
    mov  dword [edi + REC_ID], 102
    mov  dword [edi + REC_QTY], 5
    mov  dword [edi + REC_PRICE], 1500
    mov  esi, name2
    push edi
    add  edi, REC_NAME
    call copy_name
    pop  edi
    ; record 2: ID=103, qty=200, price=50 (=$0.50), name="Eraser"
    mov  eax, 2
    call rec_addr
    mov  edi, eax
    mov  dword [edi + REC_ID], 103
    mov  dword [edi + REC_QTY], 200
    mov  dword [edi + REC_PRICE], 50
    mov  esi, name3
    push edi
    add  edi, REC_NAME
    call copy_name
    pop  edi
    mov  dword [item_count], 3
    pop  esi
    pop  edi
    ret

; ============================================================================
;  DELETE ITEM logic
;
;  Algorithm: find the record's index. Then shift all records after it
;  back by one REC_SIZE (48) bytes, overwriting the deleted one. Finally
;  decrement [item_count].
; ============================================================================
handle_update:                      ; (keeping the same label name for reuse)
    push ebx
    push esi
    push edi
    ; prompt ID
    mov  ecx, p_id
    mov  edx, p_id_len
    call print_buf
    call read_line
    call atoi_buf
    test eax, eax
    je   .stop                       ; 0 = stop
    ; find by id
    call find_item_by_id
    cmp  eax, -1
    jne  .got
    mov  ecx, m_nf
    mov  edx, m_nf_len
    call print_buf
    jmp  .cont
.got:
    mov  ebx, eax                    ; ebx = index to delete
    ; --- shift records [index+1 .. count-1] back by 1 slot ---
    mov  eax, ebx
    call rec_addr
    mov  edi, eax                    ; dst = record being deleted
    mov  esi, edi
    add  esi, REC_SIZE               ; src = next record
    mov  ecx, [item_count]
    sub  ecx, ebx
    dec  ecx                         ; ecx = number of records to shift
    test ecx, ecx
    jle  .dec                        ; nothing to shift (deleting last)
    imul ecx, ecx, REC_SIZE          ; ecx = bytes to copy
.copy:
    test ecx, ecx
    je   .dec
    mov  al, [esi]
    mov  [edi], al
    inc  esi
    inc  edi
    dec  ecx
    jmp  .copy
.dec:
    dec  dword [item_count]
    mov  ecx, m_ok
    mov  edx, m_ok_len
    call print_buf
.cont:
    mov  eax, 1
    jmp  .out
.stop:
    xor  eax, eax
.out:
    pop  edi
    pop  esi
    pop  ebx
    ret

dump_inventory:
    push ebx
    push esi
    mov  ecx, m_dump
    mov  edx, m_dump_len
    call print_buf
    xor  ebx, ebx
    mov  esi, inventory
.l:
    cmp  ebx, [item_count]
    jge  .d
    mov  eax, [esi + REC_ID]
    call print_int
    call print_sp
    mov  eax, [esi + REC_QTY]
    call print_int
    call print_sp
    mov  eax, [esi + REC_PRICE]
    call print_int
    call print_sp
    push ecx
    mov  ecx, esi
    add  ecx, REC_NAME
    call print_cstr
    pop  ecx
    call print_nl
    add  esi, REC_SIZE
    inc  ebx
    jmp  .l
.d:
    mov  ecx, m_bye
    mov  edx, m_bye_len
    call print_buf
    pop  esi
    pop  ebx
    ret

_start:
    call setup_sample_data
    mov  ecx, banner
    mov  edx, banner_len
    call print_buf
    call dump_inventory              ; show initial state
.loop:
    call handle_update
    test eax, eax
    jne  .loop
    call dump_inventory              ; show final state
    mov  eax, SYS_EXIT
    xor  ebx, ebx
    int  0x80
