; ============================================================
; INVENTORY MANAGEMENT SYSTEM
; NASM Assembly Language (x86 Linux)
; ============================================================

section .data

; -------------------------------
; TITLE
; -------------------------------

title db 10,"==========================================",10
      db "       INVENTORY MANAGEMENT SYSTEM",10
      db "==========================================",10

titleLen equ $ - title

; -------------------------------
; MENU
; -------------------------------

menu db 10
     db "[1] Add Item",10
     db "[2] Update Item",10
     db "[3] Delete Item",10
     db "[4] Search Item",10
     db "[5] Display Inventory",10
     db "[6] Generate Report",10
     db "[7] Exit",10,10
     db "Enter your choice: "

menuLen equ $ - menu

; -------------------------------
; MESSAGES
; -------------------------------

addMsg db 10,"[ADD ITEM SELECTED]",10
addLen equ $ - addMsg

updateMsg db 10,"[UPDATE ITEM SELECTED]",10
updateLen equ $ - updateMsg

deleteMsg db 10,"[DELETE ITEM SELECTED]",10
deleteLen equ $ - deleteMsg

searchMsg db 10,"[SEARCH ITEM SELECTED]",10
searchLen equ $ - searchMsg

displayMsg db 10,"[DISPLAY INVENTORY SELECTED]",10
displayLen equ $ - displayMsg

reportMsg db 10,"[GENERATE REPORT SELECTED]",10
reportLen equ $ - reportMsg

invalidMsg db 10,"[INVALID CHOICE! TRY AGAIN]",10
invalidLen equ $ - invalidMsg

exitMsg db 10,"Exiting Program...",10
exitLen equ $ - exitMsg

newline db 10
newlineLen equ $ - newline

section .bss

choice resb 2

section .text
global _start

; ============================================================
; PROGRAM START
; ============================================================

_start:

main_menu:

    ; -------------------------------
    ; DISPLAY TITLE
    ; -------------------------------

    mov eax, 4
    mov ebx, 1
    mov ecx, title
    mov edx, titleLen
    int 0x80

    ; -------------------------------
    ; DISPLAY MENU
    ; -------------------------------

    mov eax, 4
    mov ebx, 1
    mov ecx, menu
    mov edx, menuLen
    int 0x80

    ; -------------------------------
    ; READ USER INPUT
    ; -------------------------------

    mov eax, 3
    mov ebx, 0
    mov ecx, choice
    mov edx, 2
    int 0x80

    ; -------------------------------
    ; CHECK USER CHOICE
    ; -------------------------------

    mov al, [choice]

    cmp al, '1'
    je add_item

    cmp al, '2'
    je update_item

    cmp al, '3'
    je delete_item

    cmp al, '4'
    je search_item

    cmp al, '5'
    je display_inventory

    cmp al, '6'
    je generate_report

    cmp al, '7'
    je exit_program

    jmp invalid_choice


; ============================================================
; ADD ITEM
; ============================================================

add_item:

    mov eax, 4
    mov ebx, 1
    mov ecx, addMsg
    mov edx, addLen
    int 0x80

    jmp pause


; ============================================================
; UPDATE ITEM
; ============================================================

update_item:

    mov eax, 4
    mov ebx, 1
    mov ecx, updateMsg
    mov edx, updateLen
    int 0x80

    jmp pause


; ============================================================
; DELETE ITEM
; ============================================================

delete_item:

    mov eax, 4
    mov ebx, 1
    mov ecx, deleteMsg
    mov edx, deleteLen
    int 0x80

    jmp pause


; ============================================================
; SEARCH ITEM
; ============================================================

search_item:

    mov eax, 4
    mov ebx, 1
    mov ecx, searchMsg
    mov edx, searchLen
    int 0x80

    jmp pause


; ============================================================
; DISPLAY INVENTORY
; ============================================================

display_inventory:

    mov eax, 4
    mov ebx, 1
    mov ecx, displayMsg
    mov edx, displayLen
    int 0x80

    jmp pause


; ============================================================
; GENERATE REPORT
; ============================================================

generate_report:

    mov eax, 4
    mov ebx, 1
    mov ecx, reportMsg
    mov edx, reportLen
    int 0x80

    jmp pause


; ============================================================
; INVALID CHOICE
; ============================================================

invalid_choice:

    mov eax, 4
    mov ebx, 1
    mov ecx, invalidMsg
    mov edx, invalidLen
    int 0x80

    jmp pause


; ============================================================
; PAUSE BEFORE RETURNING TO MENU
; ============================================================

pause:

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, newlineLen
    int 0x80

    jmp main_menu


; ============================================================
; EXIT PROGRAM
; ============================================================

exit_program:

    mov eax, 4
    mov ebx, 1
    mov ecx, exitMsg
    mov edx, exitLen
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80