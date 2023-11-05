; *******************************************************************
; *** This software is copyright 2004 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

; R7 - Line pointer
; R8 - Executing line
; R9 - Destination var

#include    ../include/ops.inc
#include    ../include/bios.inc

#ifdef MCHIP
#define    ANYROM
#define    CODE   07800h
o_inmsg:   equ    f_inmsg
o_input:   equ    f_input
o_type:    equ    f_type
o_readkey: equ    f_read
xopenw:    equ    07006h
xopenr:    equ    07009h
xread:     equ    0700ch
xwrite:    equ    0700fh
xclosew:   equ    07012h
xcloser:   equ    07015h
#endif

#ifdef PICOROM
#define    ANYROM
#define    CODE   08800h
o_inmsg:   equ    f_inmsg
o_input:   equ    f_input
o_type:    equ    f_type
o_readkey: equ    f_read
xopenw:    equ     08006h
xopenr:    equ     08009h
xread:     equ     0800ch
xwrite:    equ     0800fh
xclosew:   equ     08012h
xcloser:   equ     08015h
#endif

#ifdef DLOAD
#define    CODE   02000h
o_inmsg:   equ    f_inmsg
o_input:   equ    f_input
o_type:    equ    f_type
o_readkey: equ    f_read
xopenw:    equ    08006h
xopenr:    equ    08009h
xread:     equ    0800ch
xwrite:    equ    0800fh
xclosew:   equ    08012h
xcloser:   equ    08015h
#endif

#ifdef ELFOS
#define    CODE   02000h
#include   kernel.inc
           org     8000h
           lbr     0ff00h
           db      'vtl2',0
           dw      9000h
           dw      endrom+7000h
           dw      2000h
           dw      endrom-2000h
           dw      2000h
           db      0
#endif
 
#ifdef ELFOS
           org     CODE
           br      start
#include   date.inc
#include   build.inc
           db      'Written by Michael H. Riley',0
#endif

#ifdef DLOAD
           org     CODE-4
           dw      CODE
           dw      endrom-CODE
           mov     r2,stack
           mov     r6,start
           lbr     f_initcall
#endif

#ifdef ANYROM
           org     CODE
           mov     r2,stack
           mov     r6,start
           lbr     f_initcall
#endif

trim:      lda     r8                  ; get next byte
           smi     ' '                 ; check for spaces
           bz      trim                ; skip past any spaces
           dec     r8                  ; move back to non-space
return:    rtn                         ; and return

; ****************************
; ***** Copy memory      *****
; ***** RF = source      *****
; ***** RD = destination *****
; ***** RC = count       *****
; ****************************
copy:      glo     rc           ; see if done
           bnz     copy1        ; jump if not
           ghi     rc
           bnz     copy1
           rtn                  ; return to caller
copy1:     lda     rf           ; get byte from source
           str     rd           ; store into destination
           inc     rd
           dec     rc           ; decrement count
           br      copy         ; and keep copying

; *******************************
; ***** Copy memory inverse *****
; ***** RF = source         *****
; ***** RD = destination    *****
; ***** RC = count          *****
; *******************************
copydn:    glo     rc           ; RF += RC - 1
           str     r2
           glo     rf
           add
           plo     rf
           ghi     rc
           str     r2
           ghi     rf
           adc
           phi     rf
           dec     rf
           glo     rc           ; RD += RC - 1
           str     r2
           glo     rd
           add
           plo     rd
           ghi     rc
           str     r2
           ghi     rd
           adc
           phi     rd
           dec     rd
copydnl:   glo     rc           ; see if done
           bnz     copydn1      ; jump if not
           ghi     rc
           bnz     copydn1
           rtn                  ; otherwise return
copydn1:   ldn     rf           ; get byte from source
           str     rd           ; store into destination
           dec     rf           ; update pointers
           dec     rd
           dec     rc           ; decrement count
           br      copydnl      ; loop until done

; ************************************************
; ***** Find length, including terminating 0 *****
; ***** RF = string to check                 *****
; ***** Returns: RC = length                 *****
; ************************************************
len:       mov     rc,0         ; set initial count
lenlp:     inc     rc           ; increment count
           lda     rf           ; get byte from string
           bnz     lenlp        ; Loop until end found
           rtn                  ; then return to caller

start:
#ifdef ANYROM
           sep     scall             ; clear the screen
           dw      f_inmsg
           db      01bh,'[2J',0      ; ANSI erase display
#endif
           call    o_inmsg             ; display header
           db      'Rc/VTL2 V1.0.2',10,13,0

#ifdef ELFOS
new:       mov     rc,HIMEM            ; set end of memory pointer
           lda     rc
           phi     rf
           lda     rc
           plo     rf
#endif
#ifdef DLOAD
new:       mov     rf,07dffh           ; set end of memory pointer
#endif
#ifdef MCHIP
new:       mov     rf,0fdffh           ; set end of memory pointer
#endif
#ifdef PICOROM
new:       mov     rf,07dffh           ; set end of memory pointer
#endif

           ldi     '*'                 ; need * variable
           call    store

           mov     rf,program          ; end of program text
           ldi     0                   ; mark program as empty
           str     rf
           ldi     '&'                 ; need & variable
           call    store

           mov     rf,0
           ldi     '#'                 ; need # var
           call    store

           ldi     '!'                 ; set ! variable
           call    store

; ******************************
; ***** Start of main loop *****
; ******************************
main:      mov     r2,stack            ; reset stack pointer
           call    o_inmsg             ; display prompt
           db      '>',0
           mov     rf,buffer
           call    o_input             ; get input from user
           call    crlf                ; display cr/lf
           mov     r8,buffer
           ldn     r8
           smi     '<'                 ; check for load <
           lbz     load
           smi     2                   ; check for save >
           lbz     save
           ldn     r8                  ; check for number
           smi     '0'
           lbnf    doexec              ; jump if beflow numbers
           smi     10                  ; check high of numbers
           lbdf    doexec              ; jump if above numbers
           call    atoi                ; convert line number
           mov     rf,rd               ; move line number
           glo     rd                  ; check for zero
           str     r2
           ghi     rd
           or
           lbz     list                ; list program if zero
           lda     r8                  ; get next byte
           lbnz    insline             ; insert line if not terminator
           call    delline             ; otherwise delete line
           lbr     main                ; and back to main loop
doexec:    mov     r7,r8
           dec     r7
           dec     r7
           dec     r7
           call    exec                ; execute line
           call    crlf                ; display cr/lf
           lbr     main                ; and back to main loop

run:       call    findline            ; find next line to execute
run2:      mov     r2,stack            ; reset stack pointer
           call    fn_lfsr             ; set ' variable
           mov     rc,variables+12
           ghi     rf
           str     rc
           inc     rc
           glo     rf
           str     rc

           lda     r7
           lbz     main                ; back to main if end of program reached
           lda     r7                  ; get line number
           phi     rf
           lda     r7
           plo     rf
           mov     r8,r7               ; point to line text
           dec     r7                  ; restore r7
           dec     r7
           dec     r7
           mov     rc,variables+4      ; need to write current executing line
           ghi     rf
           str     rc
           inc     rc
           glo     rf
           str     rc
           call    exec                ; and execute it
           ldn     r7                  ; add line size to line address
           str     r2
           glo     r7
           add
           plo     r7
           ghi     r7
           adci    0
           phi     r7
           lbr     run2                ; execute next line

exec:      call    trim                ; trim leading spaces
           lda     r8                  ; get what shoudl be a variable
           plo     r9                  ; put in r9.0
exec_1:    lda     r8                  ; get next byte
           lbz     main
           smi     '='                 ; must be equals
           lbnz    exec_1              ; do not execute line if not
           ldn     r8                  ; get next byte
           smi     34                  ; check for quote
           lbnz    exec2               ; jump if not
           glo     r9                  ; get destination
           smi     '?'                 ; must be ?
           lbnz    return              ; jumpt if not
           inc     r8                  ; move past quote
print:     lda     r8                  ; get next byte
           plo     re                  ; keep a copy
           smi     34                  ; look for ending quote
           lbnz    print1              ; jump if not
           lda     r8                  ; get final byte
           smi     ';'                 ; check for semicolon
           lbz     return              ; jump if so
           call    crlf                ; otherwise output cr/lf
           rtn                         ; and return
print1:    glo     re                  ; recover character
           call    o_type              ; display it
           lbr     print               ; back to print loop
exec2:     call    eval                ; evaluate expression
           mov     r8,r7
           inc     r8
           inc     r8 
           inc     r8
           call    trim
           inc     r8
           glo     r9                  ; get destination variable
           
           lbr     store               ; store value

; **************************************
; ***** Process expression         *****
; ***** R8 - pointer to expression *****
; ***** Returns: RF - result       *****
; **************************************
eval:      ldi     0                   ; push end onto stack
           stxd                        ; place on stack
eval_n:    ldn     r8                  ; get byte from expression
           smi     '('                 ; check for open parens
           lbz     eval_o              ; jump if so
           ldn     r8                  ; get byte from expression
           lbz     eval_z              ; jump if end of expression
           smi     '0'                 ; check against numerals
           lbnf    eval_v              ; jump if it is a variable
           smi     10
           lbdf    eval_v              ; jump if it is a variable
           call    atoi                ; convert number
           lbr     eval_n1             ; process number
eval_v:    lda     r8                  ; get variable
           call    fetch               ; retrieve it
           mov     rd,rf               ; move result
eval_n1:   irx                         ; get operation
           ldx
           smi     '('                 ; need to know if open parens
           lbz     eval_n1a            ; ignore open
           adi     '('
           lbnz    eval_2              ; jump if not end
eval_n1a:  dec     r2                  ; keep zero on stack
eval_p:    glo     rd                  ; push new number onto stack
           stxd
           ghi     rd
           stxd
eval_o:    lda     r8                  ; get operation
           lbz     eval_z              ; jump if end found
           smi     ')'                 ; check for close parens
           lbz     eval_cp
           adi     ')'                 ; recover character
           smi     125                 ; check for close brace
           lbz     eval_cp
           adi     125
           stxd                        ; otherwise push operation on stack
           lbr     eval_n              ; and then get next number
eval_cp:   irx                         ; recover number from stack
           ldxa
           phi     rd
           ldxa
           plo     rd
           ldx
           lbz     eval_z2
           ldx
           smi     '('                 ; must be open parens
           lbnz    eval_z              ; jump if not
           lbr     eval_n1             ; now process as normal number
eval_2:    smi     '&'                 ; check for &
           lbz     and
           smi     4                   ; check for *
           lbz     mul
           smi     1                   ; check for +
           lbz     add
           smi     2                   ; check for -
           lbz     sub
           smi     2                   ; check for /
           lbz     div
           smi     13                  ; check for <
           lbz     lt
           smi     1                   ; check for =
           lbz     eq
           smi     1                   ; check for >
           lbz     gt
           smi     32                  ; check for ^
           lbz     xor
           smi     30                  ; check for |
           lbz     or

eval_z:    irx                         ; recover final result
           ldxa
           phi     rf
           ldxa
           plo     rf
           rtn                         ; and return to caller
eval_z2:   mov     rf,rd               ; move number to rf
           rtn                         ; and return

and:       mov     ra,doand            ; AND
           lbr     doop
or:        mov     ra,door             ; OR
           lbr     doop
xor:       mov     ra,doxor            ; XOR
           lbr     doop
add:       mov     ra,doadd            ; ADC
doop:      adi     0                   ; clear carry flag
           irx                         ; recover first argument
           ldxa
           phi     rc
           ldx
           str     r2                  ; prepare for op
           glo     rd                  ; against rd
           sep     ra
           plo     rc
           ghi     rc
           str     r2
           ghi     rd
           sep     ra
           phi     rc
eval_pc:   glo     rc
           stxd
           ghi     rc
           stxd
           lbr     eval_o
      
doand:     and
           sep     r3
           and
           sep     r3
door:      or
           sep     r3
           or
           sep     r3
doxor:     xor
           sep     r3
           xor
           sep     r3
doadd:     adc
           sep     r3
           adc
           sep     r3

sub:       mov     rf,subr             ; perform subtraction
           sep     rf
           lbr     eval_pc             ; save result


mul:       irx                         ; recover first arg
           ldxa 
           phi     rc
           ldx
           plo     rc
           call    mul16               ; perform multiply
           lbr     eval_pc             ; and then save result

div:       irx                         ; recover first arg
           ldxa 
           phi     rc
           ldx
           plo     rc
           call    div16               ; perform multiply
           mov     rf,rd               ; move remainder
           ldi     '%'                 ; % variable
           call    store     
           lbr     eval_pc             ; and then save result

eq:        mov     rf,subr             ; perform subtraction
           sep     rf
           glo     rc                  ; was result 0
           str     r2
           ghi     rc
           or
           lbnz    logic_0             ; jump if unequal
logic_1:   mov     rc,1
           lbr     eval_pc
logic_0:   mov     rc,0
           lbr     eval_pc

gt:        mov     rf,subr             ; perform subtraction
           sep     rf
           glo     rc                  ; was result 0
           str     r2
           ghi     rc
           or
           lbz     logic_0             ; jump if equal
           lbnf  logic_0
           lbr   logic_1

lt:        mov     rf,subr             ; perform subtraction
           sep     rf
           glo     rc                  ; was result 0
           str     r2
           ghi     rc
           or
           lbz     logic_0             ; jump if unequal
           lbdf  logic_0
           lbr   logic_1

subr:      irx                         ; recover first argument
           ldxa
           phi     rc
           ldx
           plo     rc
           glo     rd                  ; rc -= rd
           str     r2
           glo     rc
           sm
           plo     rc
           ghi     rd
           str     r2
           ghi     rc
           smb
           phi     rc
           sep     r3                  ; return to caller


; *********************************************
; *** Function to multiply 2 16 bit numbers ***
; *** RC *= RD                              ***
; *********************************************
mul16:     ldi     0                   ; zero out total
           phi     rf
           plo     rf
mulloop:   glo     rd                  ; get low of multiplier
           lbnz    mulcont             ; continue multiplying if nonzero
           ghi     rd                  ; check hi byte as well
           lbnz    mulcont
           mov     rc,rf               ; transfer answer
           rtn                         ; return to caller
mulcont:   ghi     rd                  ; shift multiplier
           shr
           phi     rd
           glo     rd
           shrc
           plo     rd
           lbnf    mulcont2            ; loop if no addition needed
           glo     rc                  ; add RC to RF
           str     r2
           glo     rf
           add
           plo     rf
           ghi     rc
           str     r2
           ghi     rf
           adc
           phi     rf
mulcont2:  glo     rc                  ; shift first number
           shl
           plo     rc
           ghi     rc
           shlc
           phi     rc
           lbr     mulloop             ; loop until done

; *********************************************
; *** Function to divide 2 16 bit numbers   ***
; *** RC /= RD                              ***
; *** RD = remainder                        ***
; *********************************************
div16:     glo     rd                  ; check for divide by zero
           lbnz    div16_1
           ghi     rd
           lbnz    div16_1
           mov     rc,0                ; return 0 as div/0
           rtn                         ; and return to caller
div16_1:   push    r9                  ; save consumed registers
           push    r8
           ldi     0                   ; clear answer
           phi     rf
           plo     rf
           phi     r8                  ; set additive
           plo     r8
           inc     r8
d16lp1:    ghi     rd                  ; get high byte from rd
           ani     128                 ; check high bit
           lbnz    divst               ; jump if set
           glo     rd                  ; lo byte of divisor
           shl                         ; multiply by 2
           plo     rd                  ; and put back
           ghi     rd                  ; get high byte of divisor
           shlc                        ; continue multiply by 2
           phi     rd                  ; and put back
           glo     r8                  ; multiply additive by 2
           shl
           plo     r8
           ghi     r8
           shlc
           phi     r8
           lbr     d16lp1              ; loop until high bit set in divisor
divst:     glo     rd                  ; get low of divisor
           lbnz    divgo               ; jump if still nonzero
           ghi     rd                  ; check hi byte too
           lbnz    divgo
divret:    mov     rd,rc               ; move remainder to rd
           mov     rc,rf               ; move answer to rc
           pop     r8                  ; recover consumed registers
           pop     r9
           rtn                         ; jump if done
divgo:     mov     r9,rc               ; copy dividend
           glo     rd                  ; get lo of divisor
           str     r2                  ; store for subtract
           glo     rc                  ; get low byte of dividend
           sm                          ; subtract
           plo     rc                  ; put back into r6
           ghi     rd                  ; get hi of divisor
           str     r2                  ; store for subtract
           ghi     rc                  ; get hi of dividend
           smb                         ; subtract
           phi     rc                  ; and put back
           lbdf    divyes              ; branch if no borrow happened
           mov     rc,r9               ; recover copy
           lbr     divno               ; jump to next iteration
divyes:    glo     r8                  ; get lo of additive
           str     r2                  ; store for add
           glo     rf                  ; get lo of answer
           add                         ; and add
           plo     rf                  ; put back
           ghi     r8                  ; get hi of additive
           str     r2                  ; store for add
           ghi     rf                  ; get hi byte of answer
           adc                         ; and continue addition
           phi     rf                  ; put back
divno:     ghi     rd                  ; get hi of divisor
           shr                         ; divide by 2
           phi     rd                  ; put back
           glo     rd                  ; get lo of divisor
           shrc                        ; continue divide by 2
           plo     rd
           ghi     r8                  ; get hi of divisor
           shr                         ; divide by 2
           phi     r8                  ; put back
           glo     r8                  ; get lo of divisor
           shrc                        ; continue divide by 2
           plo     r8
           lbdf    divret
           lbr     divst               ; next iteration

; ****************************************
; ***** Convert ASCII to integer     *****
; ***** R8 - Pointer to ASCII number *****
; ***** Returns: RD - 16-bit integer *****
; ****************************************
atoi:      ldi     0                   ; clear total
           plo     rc
           phi     rc
atoi_0_1:  ldn     r8                  ; get next character
           smi     '0'                 ; convert to binary
           lbnf    atoi_0_2            ; jump if below numbers
           smi     10                  ; check for above numbers
           lbdf    atoi_0_2            ; jump if above numbers
           mov     rd,10
           call    mul16
           lda     r8
           smi     '0'
           str     r2
           glo     rc
           add
           plo     rc
           ghi     rc
           adci    0
           phi     rc
           lbr     atoi_0_1
atoi_0_2:  mov     rd,rc
           rtn                         ; and return to caller

; **************************************
; ***** Convert RF to bcd in M[RD] *****
; **************************************
tobcd:     push    rd           ; save address
           ldi     5            ; 5 bytes to clear
           plo     re
tobcdlp1:  ldi     0
           str     rd           ; store into answer
           inc     rd
           dec     re           ; decrement count
           glo     re           ; get count
           lbnz    tobcdlp1     ; loop until done
           pop     rd           ; recover address
           ldi     16           ; 16 bits to process
           plo     r9
tobcdlp2:  ldi     5            ; need to process 5 cells
           plo     re           ; put into count
           push    rd           ; save address
tobcdlp3:  ldn     rd           ; get byte
           smi     5            ; need to see if 5 or greater
           lbnf    tobcdlp3a    ; jump if not
           adi     8            ; add 3 to original number
           str     rd           ; and put it back
tobcdlp3a: inc     rd           ; point to next cell
           dec     re           ; decrement cell count
           glo     re           ; retrieve count
           lbnz    tobcdlp3     ; loop back if not done
           glo     rf           ; start by shifting number to convert
           shl
           plo     rf
           ghi     rf
           shlc
           phi     rf
           shlc                 ; now shift result to bit 3
           shl
           shl
           shl
           str     rd
           pop     rd           ; recover address
           push    rd           ; save address again
           ldi     5            ; 5 cells to process
           plo     re
tobcdlp4:  lda     rd           ; get current cell
           str     r2           ; save it
           ldn     rd           ; get next cell
           shr                  ; shift bit 3 into df
           shr
           shr
           shr
           ldn     r2           ; recover value for current cell
           shlc                 ; shift with new bit
           ani     0fh          ; keep only bottom 4 bits
           dec     rd           ; point back
           str     rd           ; store value
           inc     rd           ; and move to next cell
           dec     re           ; decrement count
           glo     re           ; see if done
           lbnz    tobcdlp4     ; jump if not
           pop     rd           ; recover address
           dec     r9           ; decrement bit count
           glo     r9           ; see if done
           lbnz    tobcdlp2     ; loop until done
           rtn                  ; return to caller
; ***************************************************
; ***** Output 16-bit integer                   *****
; ***** RF - 16-bit integer                     *****
; ***************************************************
itoa:      push    r9           ; save consumed registers
           push    r8
           push    r7
           glo     r2           ; make room on stack for buffer
           smi     6
           plo     r2
           ghi     r2
           smbi    0
           phi     r2
           mov     rd,r2        ; RD is output buffer
           inc     rd
itoa1:     call    tobcd        ; convert to bcd
           mov     rd,r2
           inc     rd
           ldi     5
           plo     r8
           ldi     4            ; max 4 leading zeros
           phi     r8
itoalp1:   lda     rd
           lbz     itoaz        ; check leading zeros
           str     r2           ; save for a moment
           ldi     0            ; signal no more leading zeros
           phi     r8
           ldn     r2           ; recover character
itoa2:     adi     030h
           call    o_type       ; display it
itoa3:     dec     r8
           glo     r8
           lbnz    itoalp1
           glo     r2           ; pop work buffer off stack
           adi     6
           plo     r2
           ghi     r2
           adci    0
           phi     r2
           pop     r7
           pop     r8           ; recover consumed registers
           pop     r9
           ldi     0            ; terminate string
           str     rb
           rtn                  ; return to caller
itoaz:     ghi     r8           ; see if leading have been used up
           lbz     itoa2        ; jump if so
           smi     1            ; decrement count
           phi     r8
           lbr     itoa3        ; and loop for next character

; ****************************************
; ***** Program management functions *****
; ****************************************

save:      inc     r8           ; move past symbol
           call    trim         ; then past any spaces
           mov     rf,r8        ; prepare for open
#ifdef ELFOS
           mov     rd,fildes
           mov     r7,3         ; create/truncate
           call    o_open       ; open the file
           lbdf    dskerr
#endif
#ifdef DLOAD
           call    xopenw
#endif
#ifdef ANYROM
           call    xopenw
#endif
           ldi     '&'          ; need last program address
           call    fetch
           glo     rf           ; subtract program start
           smi     program.0
           plo     rc
           ghi     rf
           smbi    program.1
           phi     rc
           inc     rc
           mov     rf,program   ; point to program space
#ifdef ELFOS
           mov     rd,fildes
           call    o_write      ; write to disk
           call    o_close      ; close file
#endif
#ifdef DLOAD
           call    xwrite
           call    xclosew
#endif
#ifdef ANYROM
           call    xwrite
           call    xclosew
#endif
           lbr     main         ; and back to main

load:      inc     r8           ; move past symbol
           call    trim         ; then past any spaces
           mov     rf,r8        ; prepare for open
#ifdef ELFOS
           mov     rd,fildes
           mov     r7,0         ; create/truncate
           call    o_open       ; open the file
           lbdf    dskerr
#endif
#ifdef DLOAD
           call    xopenr
#endif
#ifdef ANYROM
           call    xopenr
#endif
           mov     rc,32767     ; read as many bytes as possible
           mov     rf,program   ; point to program space
#ifdef ELFOS
           mov     rd,fildes
           call    o_read       ; read from disk
           call    o_close      ; close file
#endif
#ifdef DLOAD
           call    xread
           call    xcloser
#endif
#ifdef ANYROM
           call    xread
           call    xcloser
#endif
           mov     rf,program   ; need to find end of program
loadlp:    ldn     rf           ; get next byte
           lbz     loaddn       ; jump if end found
           str     r2           ; add to address
           glo     rf
           add
           plo     rf
           ghi     rf
           adci    0
           phi     rf
           lbr     loadlp       ; and keep looking
loaddn:    ldi     '&'          ; need to set & variable
           call    store
           lbr     main         ; and back to main
    

dskerr:    call    o_inmsg      ; display error
           db      'Could not open file',10,13,0
           lbr     main         ; then back to main

; *********************************
; ***** Find line             *****
; ***** RF = Line number      *****
; ***** Returns:              *****
; *****     R7 = Line address *****
; *********************************
findline:  mov     r7,program   ; point to program space
findln1:   ldn     r7           ; read size
           lbz     return       ; return if end of program space found
           inc     r7           ; move to line number
           lda     r7           ; retrieve line number
           phi     rc
           ldn     r7
           plo     rc
           dec     r7           ; move back to size byte
           dec     r7
           glo     rc           ; subtract line number from requested
           str     r2
           glo     rf
           sm
           plo     re
           ghi     rc
           str     r2
           ghi     rf
           smb
           shl                  ; check sign of result
           lbdf    return       ; if negative, then line was found
           shrc                 ; shift it back
           str     r2           ; zero check
           glo     re
           or
           lbz     return       ; if zero then line was found
           ldn     r7           ; get size byte
           str     r2           ; and add to r7
           glo     r7
           add
           plo     r7
           ghi     r7
           adci    0
           phi     r7
           lbr     findln1      ; and keep looking

; ****************************
; ***** Delete line      *****
; ***** RF = line number *****
; ****************************
delline:   call    findline     ; find the line
           lda     r7           ; get size byte
           lbz     return       ; jump if end of program hit
           lda     r7           ; msb of line number
           stxd
           ldn     r7           ; lsb of line number
           str     r2           ; store for comparison
           dec     r7           ; move back to size byte
           dec     r7
           glo     rf           ; compare line number
           sm
           irx
           lbnz    return       ; return if numbers are not a match
           ghi     rf
           sm
           lbnz    return       ; return if msb was not a match
           ldi     '&'          ; need current end of program
           call    fetch
           mov     rc,rf        ; move it to rc
           ldn     r7           ; get size
           str     r2           ; store for add
           glo     r7           ; get current address
           plo     rd           ; need in rd
           add                  ; add line size
           plo     rf           ; and put into rf
           ghi     r7           ; high byte as well
           phi     rd
           adci    0
           phi     rf
           glo     rf           ; rc -= rf
           str     r2
           glo     rc
           sm
           plo     rc
           ghi     rf
           str     r2
           ghi     rc
           smb
           phi     rc           ; rc now has number of byte
           inc     rc           ; +1
           call    copy         ; move program down
           mov     rf,rd        ; need to write new value to &
           dec     rf           ; -1
           ldi     '&'
           call    store
           rtn                  ; return to caller

; *************************************
; ***** Insert line               *****
; ***** R8 - pointer to line text *****
; ***** RF - line number          *****
; *************************************
insline:   push    rf
           call    delline      ; delete existing line if it exists
           pop     rf
           call    findline     ; Find where to insert line
           ldn     r7           ; check for end of program space
           lbz     addline      ; jump if need to add to end
           push    rf           ; save line number
           mov     rf,r8        ; need length of line
           call    len
           inc     rc           ; add size byte and line number bytes
           inc     rc
           inc     rc
           glo     rc           ; save this for later
           stxd
           glo     rc           ; RD = R7 + RC
           str     r2
           glo     r7
           add
           plo     rd
           ghi     rc
           str     r2
           ghi     r7
           adc
           phi     rd           ; RD now has destination address
           push    rd           ; save destination address
           ldi     '&'          ; need current end of program
           call    fetch
           glo     r7           ; RC = RF - R7
           str     r2
           glo     rf
           sm
           plo     rc
           ghi     r7
           str     r2
           ghi     rf
           smb
           phi     rc
           inc     rc           ; rc now has number of bytes to copy
           pop     rd           ; recover destination
           mov     rf,r7        ; r7 is the source
           call    copydn       ; make room for new line
           irx                  ; recover line size
           ldxa
           plo     rc           ; keep a copy
           str     r7           ; and write it to size byte
           inc     r7
           ldxa                 ; recover line number
           str     r7           ; and write to program space
           inc     r7
           ldx
           str     r7
           inc     r7
inslp:     lda     r8           ; get byte from input
           str     r7           ; write to program memory
           inc     r7
           lbnz    inslp        ; copy until terminator copied
           ldi     '&'          ; need end of program space
           call    fetch
           glo     rc           ; add size of new line
           str     r2
           glo     rf
           add
           plo     rf
           ghi     rf
           adci    0
           phi     rf
           ldi     '&'          ; write back to & variable
           call    store
           lbr     main         ; all done
addline:   mov     rc,4         ; minimum of 4 bytes for the line
           mov     rd,r7        ; save position
           inc     r7           ; move to line number
           ghi     rf           ; write line number
           str     r7
           inc     r7
           glo     rf
           str     r7
           inc     r7
addlinelp: lda     r8           ; get byte from source
           str     r7           ; write to program space
           inc     r7
           lbz     addlinedn    ; jump if terminator written
           inc     rc           ; otherwise increment count
           lbr     addlinelp    ; and keep copying
addlinedn: ldi     0            ; write new end of program marker
           str     r7
           glo     rc           ; get size of line
           str     rd           ; and write into size byte
           mov     rf,r7        ; move new end of program to rf
           ldi     '&'          ; need to set & variable
           call    store
           lbr     main         ; then back to main loop
    
; ************************
; ***** List program *****
; ************************
list:      mov     r7,program   ; point to program space
listlp:    lda     r7           ; get byte from program text
           lbz     main         ; back to main if done
           lda     r7           ; retrieve line number
           phi     rf
           lda     r7
           plo     rf
           call    itoa         ; output it
           ldi     ' '          ; output a space
           call    o_type
listlp1:   lda     r7           ; get next byte from program
           lbz     list_1       ; jump if end of line
           call    o_type       ; otherwise display it
           lbr     listlp1      ; keep displaying line
list_1:    call    crlf         ; display cr/lf
           lbr     listlp       ; and keep listing program until done

; *********************************************
; ***** Get 16-bit unsigned random number *****
; ***** RF - random number                *****
; *********************************************
fn_lfsr:   ldi     16                  ; need to perform 16 shifts
           plo     rc
           push    r7                  ; save r7
lfsr_lp:   ldi     high lfsr           ; point to lfsr
           phi     r7
           ldi     low lfsr
           plo     r7
           inc     r7                  ; point to lsb
           inc     r7
           inc     r7
           ldn     r7                  ; retrieve it
           plo     re                  ; put into re  ( have bit 0)
           shr                         ; shift bit 1 into first position
           str     r2                  ; xor with previous value
           glo     re
           xor
           plo     re                  ; keep copy
           ldn     r2                  ; get value
           shr                         ; shift bit 2 into first position
           str     r2                  ; and combine
           glo     re
           xor
           plo     re
           ldn     r2                  ; now shift to bit 4
           shr
           shr
           str     r2                  ; and combine
           glo     re
           xor
           plo     re
           ldn     r2                  ; now shift to bit 6
           shr
           shr
           str     r2                  ; and combine
           glo     re
           xor
           plo     re
          dec     r7                  ; point to lfsr msb
           dec     r7
           dec     r7
           ldn     r7                  ; retrieve it
           shl                         ; shift high bit to low
           shlc
           str     r2                  ; combine with previous value
           glo     re
           xor
           xri     1                   ; combine with a final 1
           shr                         ; shift new bit into DF
           ldn     r7                  ; now shift the register
           shrc
           str     r7
           inc     r7                  ; now byte 1
           ldn     r7                  ; now shift the register
           shrc
           str     r7
           inc     r7                  ; now byte 2
           ldn     r7                  ; now shift the register
           shrc
           str     r7
           inc     r7                  ; now byte 3
           ldn     r7                  ; now shift the register
           shrc
           str     r7
           dec     rc                  ; decrement count
           glo     rc                  ; see if done
           lbnz    lfsr_lp             ; jump if not
           ldi     high lfsr           ; point to lfsr
           phi     r7
           ldi     low lfsr
           plo     r7
           lda     r7                  ; retrieve 16 bits from register
           plo     rf
           ldn     r7
           phi     rf
           pop     r7                  ; recover r7
           rtn                         ; and return


; ***********************************
; ***** Store value to variable *****
; *****  D = Variable           *****
; ***** RF = Value              *****
; ***********************************
store:     plo     re                  ; save variable
           smi     '#'                 ; check for #
           lbz     store_n             ; jump if so
           smi     1                   ; check for $
           lbz     store_d             ; jump if so
           smi     2                   ; check for &
           lbz     store_a             ; jump if so
           smi     1                   ; check for '
           lbz     store_r             ; jump if so
           smi     3                   ; check for *
           lbz     store_s             ; jump if so
           smi     16                  ; check for :
           lbz     store_y             ; jump if so
           smi     5                   ; check for ?
           lbz     store_q             ; jump if so
           smi     60                  ; check for open brace
           lbz     store_y2
store2:    glo     re
           smi     '!'
           shl                         ; variables are two bytes
           adi     variables.0         ; add in variable table
           plo     rd
           ldi     variables.1         ; high byte
           adci    0
           phi     rd
           ghi     rf                  ; store value
           str     rd
           inc     rd
           glo     rf
           str     rd
           rtn                         ; return to caller
store_a:   glo     rf                  ; check for zero
           lbnz    store2              ; jump if not
           ghi     rf
           lbnz    store2
           lbr     new                 ; otherwise new
store_q:   call    itoa                ; display number
           lbr     return              ; and return
store_d:   glo     rf                  ; get character
           call    o_type              ; and output it
           lbr     return              ; and then return
store_s:   glo     rf                  ; check for zero
           lbnz    store2              ; jump if not
           ghi     rf
           lbnz    store2
#ifdef ELFOS
           lbr     o_wrmboot           ; otherwise return to the OS
#endif
#ifdef DLOAD
           lbr     08003h
#endif
#ifdef MCHIP
           lbr     07003h
#endif
#ifdef PICOROM
           lbr     08003h
#endif

store_n:   glo     rf                  ; check for zero
           lbnz    store_n1            ; jump if not
           ghi     rf
           lbnz    store_n1
           rtn                         ; otherwise do nothing
store_y:   glo     rf                  ; save value
           stxd
           ghi     rf
           stxd
           call    arrayadr            ; get address of array cell
           irx                         ; retrieve value
           ldxa
           str     rf                  ; and store into array destination
           inc     rf
           ldx
           str     rf
           rtn                         ; and return to caller
store_y2:  glo     rf                  ; save value
           stxd
           call    eval                ; get address
           irx                         ; recover value
           ldx
           str     rf                  ; and store it
           rtn
store_n1:  mov     rd,variables+4      ; need to retrieve current line pointer
           lda     rd
           phi     rc
           ldn     rd
           plo     rc
           inc     rc                  ; +1 
           mov     ra,variables        ; write it to !
           ghi     rc
           str     ra
           inc     ra
           glo     rc
           str     ra
           glo     rf                  ; write new value to #
           str     rd
           dec     rd
           ghi     rf
           str     rd
           lbr     run                 ; run from specified line
store_r:   mov     rd,lfsr             ; point to lfsr
           ghi     rf                  ; write to register
           str     rd
           inc     rd
           glo     rf
           str     rd
           inc     rd
           ghi     rf
           xri     0ffh
           str     rd
           inc     rd
           glo     rf
           xri     0ffh
           str     rd
           rtn

; ***********************************
; ***** Store value to variable *****
; *****  D = Variable           *****
; ***** Returns:                *****
; *****          RF = Value     *****
; ***********************************
fetch:     plo     re
           smi     ':'                 ; check for array reference
           lbz     fetch_a             ; jump if so
           glo     re
           smi     123                 ; check for open brace
           lbz     fetch_b
           glo     re
           smi     '$'                 ; check for single char input
           lbz     fetch_d
           glo     re
           smi     '?'                 ; check for line input
           lbz     fetch_q
           glo     re                  ; recover value
           smi     '!'
           shl                         ; variables are two bytes
           adi     variables.0         ; add in variable table
           plo     rd
           ldi     variables.1         ; high byte
           adci    0
           phi     rd
           lda     rd
           phi     rf
           lda     rd
           plo     rf
           rtn                         ; return to caller
fetch_a:   call    arrayadr            ; get address of array element
           lda     rf                  ; retrieve value from array
           plo     re
           ldn     rf
           plo     rf
           glo     re
           phi     rf
           rtn                         ; and return
fetch_b:   call    eval                ; evaluate expression to get address
           lda     rf                  ; retrieve value
           plo     rf
           ldi     0
           phi     rf
           rtn
fetch_d:   call    o_readkey           ; read character
           plo     rf                  ; place into rd
           ldi     0
           phi     rf
           rtn                         ; and return
fetch_q:   mov     rf,buffer2          ; point to buffer
           call    o_input             ; get input
           call    crlf
           push    r8                  ; save eval pointer
           mov     r8,buffer2          ; point to buffer
           call    eval                ; and evaluate it
           pop     r8                  ; recover pointer
           rtn                         ; return to caller

; *****************************************
; ***** Get address of array element  *****
; ***** R8 - pointer to array expr    *****
; ***** Returns: RF - Address of data *****
; *****************************************
arrayadr:  call    eval                ; evaluate array expression
           glo     rf                  ; array entires are 2 bytes
           shl
           plo     rf
           ghi     rf
           shlc
           phi     rf
           mov     rd,variables+11     ; point to & lsb
           ldn     rd                  ; add to eval result
           str     r2
           glo     rf
           add
           plo     rf
           dec     rd
           ldn     rd
           str     r2
           ghi     rf
           adc
           phi     rf
           rtn                         ; return to caller

crlf:      call    o_inmsg
           db      10,13,0
           rtn

#ifdef ELFOS
fildes:    db      0,0,0,0
           dw      dta
           db      0,0
           db      0
           db      0,0,0,0
           dw      0,0
           db      0,0,0,0
#endif

endrom:    equ     $

#ifdef MCHIP
           org     08100h
#endif

#ifdef PICOROM
           org     00100h
#endif

buffer:    ds      130
buffer2:   ds      130
dta:       ds      512
lfsr:      ds      4
           ds      1024
stack:     ds      1
variables: ds      192
program:   ds      1
