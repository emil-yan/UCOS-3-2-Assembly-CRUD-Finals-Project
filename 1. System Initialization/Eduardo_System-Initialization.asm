%define SYS_EXIT   1
%define SYS_READ   3
%define SYS_WRITE  4
%define SYS_OPEN   5
%define SYS_CLOSE  6
%define STDIN  0
%define STDOUT 1
%define O_RDONLY 0
%define O_WRONLY 1
%define O_CREAT  64
%define O_TRUNC  512
%define MODE_644 420

; ---- Item record layout: 48 bytes ----
%define REC_ID    0       ; offset 0:  4-byte ID
%define REC_QTY   4       ; offset 4:  4-byte quantity
%define REC_PRICE 8       ; offset 8:  4-byte price in cents
%define REC_PAD   12      ; offset 12: 4-byte padding
%define REC_NAME  16      ; offset 16: 32-byte name (NUL-terminated)
%define REC_SIZE  48
%define NAME_LEN  32
%define MAX_ITEMS 100
%define LOW_STOCK 10      ; threshold for "low stock"

section .data
welcome:    db 10, "==========================================", 10
            db "  INVENTORY CONTROL SYSTEM  (Assembly)    ", 10
            db "  Group: Eduardo & Eser          ", 10
            db "==========================================", 10
welcome_len equ $ - welcome

datfile:    db "inventory.dat", 0    ; persistent storage filename

section .bss
inventory:  resb REC_SIZE * MAX_ITEMS  ; the array of items
item_count: resd 1                     ; current number of items
input_buf:  resb 128                   ; line input buffer
acc_buf:    resb 32                    ; ASCII conversion scratch
eof_flag:   resb 1                     ; set when stdin reaches EOF

section .text
global _start

; ----------------------------------------------------------------------------
;  Entry point: load saved inventory, print welcome, jump to main menu loop
;  (the main loop itself is in Part 2)
; ----------------------------------------------------------------------------
_start:
    call load_from_file          ; load inventory.dat if present
    mov  ecx, welcome
    mov  edx, welcome_len
    call print_buf
    jmp  main_loop               ; defined in Part 2

; ----------------------------------------------------------------------------
;  load_from_file : reads inventory.dat (4-byte count + N*48-byte records)
;                   silently starts fresh if the file does not exist
; ----------------------------------------------------------------------------
load_from_file:
    push ebx
    mov  eax, SYS_OPEN
    mov  ebx, datfile
    mov  ecx, O_RDONLY
    mov  edx, 0
    int  0x80
    test eax, eax
    js   .none                   ; no file -> fresh start
    mov  ebx, eax                ; ebx = fd
    mov  eax, SYS_READ
    mov  ecx, item_count
    mov  edx, 4
    int  0x80
    cmp  eax, 4
    jne  .close
    mov  eax, [item_count]
    test eax, eax
    js   .reset
    cmp  eax, MAX_ITEMS
    jg   .reset
    mov  edx, REC_SIZE
    imul edx, eax
    test edx, edx
    jle  .close
    mov  eax, SYS_READ
    mov  ecx, inventory
    int  0x80
    jmp  .close
.reset:
    mov  dword [item_count], 0
.close:
    mov  eax, SYS_CLOSE
    int  0x80
    pop  ebx
    ret
.none:
    mov  dword [item_count], 0
    pop  ebx
    ret