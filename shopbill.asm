; ════════════════════════════════════════════════════════════════
; FILE      : billing.asm
; PROJECT   : Shop Billing System
; SUBJECT   : System Programming (CSLB 154)
; LANGUAGE USED    : NASM – x86 32-bit Assembly Language
; PURPOSE   : Demonstrates core arithmetic operations used in
;             shop billing: item amount, subtotal, GST, grand total etc.
; ════════════════════════════════════════════════════════════════

; ──────────────────────────────────────────────────────────────
; DATA SEGMENT – stores all variables used in billing
; ──────────────────────────────────────────────────────────────
section .data

    ; ── Input values (set before calling functions) ──────────
    price       dd  50          ; Item price in rupees (example: 50)
    quantity    dd  3           ; Number of units (example: 3)

    ; ── Rates and constants ───────────────────────────────────
    gst_rate    dd  18          ; GST rate = 18%
    divisor     dd  100         ; For percentage: divide by 100

    ; ── Result variables (computed by functions) ─────────────
    item_amount dd  0           ; price × quantity
    subtotal    dd  0           ; sum of all item amounts
    gst_amount  dd  0           ; GST on subtotal
    grand_total dd  0           ; subtotal + gst_amount

    ; ── Newline character for print ───────────────────────────
    newline     db  10


; ──────────────────────────────────────────────────────────────
; BSS SEGMENT – uninitialised buffer for number to string output
; ──────────────────────────────────────────────────────────────
section .bss
    buffer      resb 12         ; 12-byte buffer for integer output


; ──────────────────────────────────────────────────────────────
; CODE SEGMENT
; ──────────────────────────────────────────────────────────────
section .text
    global _start               ; entry point for linker


; ════════════════════════════════════════════════════════════════
; FUNCTION: calc_item_amount
; PURPOSE : Compute the amount for a single item
;           item_amount = price × quantity
; INPUT   : [price] and [quantity] are set in .data
; OUTPUT  : [item_amount] is updated; EAX holds result
; REGISTERS USED: EAX (multiplicand/result), EBX (multiplier)
; ════════════════════════════════════════════════════════════════
calc_item_amount:
    mov  eax, [price]           ; Step 1: load price into EAX
    mov  ebx, [quantity]        ; Step 2: load quantity into EBX
    imul eax, ebx               ; Step 3: EAX = price × quantity
                                ;         IMUL = signed integer multiply
    mov  [item_amount], eax     ; Step 4: store result back to memory
    ret                         ; return (result also in EAX)


; ════════════════════════════════════════════════════════════════
; FUNCTION: add_to_subtotal
; PURPOSE : Accumulate item amounts into a running subtotal
;           subtotal = subtotal + item_amount
; INPUT   : [subtotal] = current running total
;           [item_amount] = latest item amount
; OUTPUT  : [subtotal] is updated
; REGISTERS USED: EAX (holds item_amount), EBX (holds subtotal)
; ════════════════════════════════════════════════════════════════
add_to_subtotal:
    mov  eax, [item_amount]     ; Step 1: load current item amount
    add  eax, [subtotal]        ; Step 2: EAX = item_amount + subtotal
                                ;         ADD performs integer addition
    mov  [subtotal], eax        ; Step 3: write new subtotal to memory
    ret


; ════════════════════════════════════════════════════════════════
; FUNCTION: calc_gst
; PURPOSE : Calculate GST amount on the subtotal
;           gst_amount = (subtotal × gst_rate) / 100
;           Example: subtotal=150, rate=18 → (150×18)/100 = 27
; INPUT   : [subtotal], [gst_rate], [divisor]
; OUTPUT  : [gst_amount] is set
; REGISTERS USED:
;   EAX  – dividend (subtotal × rate), then quotient after DIV
;   EBX  – holds gst_rate for multiplication
;   EDX  – high 32 bits of dividend (must be zero before DIV)
; ════════════════════════════════════════════════════════════════
calc_gst:
    mov  eax, [subtotal]        ; Step 1: load subtotal into EAX
    mov  ebx, [gst_rate]        ; Step 2: load GST rate (18) into EBX
    imul eax, ebx               ; Step 3: EAX = subtotal × 18
    xor  edx, edx               ; Step 4: clear EDX (for 64-bit division)
                                ;         XOR reg,reg zeroes the register
    div  dword [divisor]        ; Step 5: EDX:EAX / 100
                                ;         EAX = quotient (gst_amount)
                                ;         EDX = remainder (ignored)
    mov  [gst_amount], eax      ; Step 6: store GST amount
    ret


; ════════════════════════════════════════════════════════════════
; FUNCTION: calc_grand_total
; PURPOSE : Add GST to subtotal to get final bill amount
;           grand_total = subtotal + gst_amount
; INPUT   : [subtotal], [gst_amount]
; OUTPUT  : [grand_total] is set
; REGISTERS USED: EAX
; ════════════════════════════════════════════════════════════════
calc_grand_total:
    mov  eax, [subtotal]        ; Step 1: load subtotal
    add  eax, [gst_amount]      ; Step 2: EAX = subtotal + gst_amount
    mov  [grand_total], eax     ; Step 3: store grand total
    ret


; ════════════════════════════════════════════════════════════════
; FUNCTION: int_to_string
; PURPOSE : Convert integer in EAX to ASCII string in buffer[]
;           Uses repeated DIV 10 to extract digits, then reverses
; INPUT   : EAX = integer to convert
; OUTPUT  : buffer[] contains ASCII digits, ECX = length
; REGISTERS USED: EAX, EBX, ECX, EDX, ESI
; ════════════════════════════════════════════════════════════════
int_to_string:
    mov  esi, buffer + 11       ; point ESI to end of buffer
    mov  byte [esi], 10         ; write newline at end
    dec  esi                    ; move pointer left
    mov  ebx, 10                ; divisor for base-10 extraction
    xor  ecx, ecx               ; ECX = character count
.loop:
    xor  edx, edx               ; clear EDX before division
    div  ebx                    ; EAX = EAX / 10, EDX = remainder (digit)
    add  dl, '0'                ; convert digit to ASCII ('0'=48)
    mov  [esi], dl              ; store ASCII digit
    dec  esi                    ; move pointer left
    inc  ecx                    ; increment digit count
    test eax, eax               ; check if EAX is zero
    jnz  .loop                  ; if not zero, loop
    inc  esi                    ; adjust pointer to first digit
    ret


; ════════════════════════════════════════════════════════════════
; PROGRAM ENTRY POINT: _start
; Calls all billing functions in order, prints grand total
; ════════════════════════════════════════════════════════════════
_start:
    ; 1: Calculate item amount (price × qty) ──────────
    call calc_item_amount       ; [item_amount] = 50 × 3 = 150

    ; 2: Add item amount to subtotal ──────────────────
    call add_to_subtotal        ; [subtotal] = 0 + 150 = 150

    ; 3: Calculate GST on subtotal ────────────────────
    call calc_gst               ; [gst_amount] = (150×18)/100 = 27

    ; 4: Calculate grand total ────────────────────────
    call calc_grand_total       ; [grand_total] = 150 + 27 = 177

    ; 5: Print grand total to stdout ──────────────────
    mov  eax, [grand_total]     ; load result (177)
    call int_to_string          ; convert to ASCII string

    ; 6: sys_write (syscall 4) ────────────────────────
    mov  eax, 4                 ; syscall number: write
    mov  ebx, 1                 ; file descriptor: stdout
    mov  edx, ecx              ; number of bytes = digit count + 1
    inc  edx                    ; include newline
    int  0x80                   ; call kernel

    ; 7: sys_exit (syscall 1) ─────────────────────────
    mov  eax, 1                 ; syscall number: exit
    xor  ebx, ebx               ; exit code 0 (success)
    int  0x80                   ; call kernel

; END OF FILE
