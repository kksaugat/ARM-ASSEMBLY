	AREA	library5, CODE, READWRITE	 
	EXPORT pin_connect_block_setup_for_uart0
	EXPORT uart_init
	EXPORT output_string
	EXPORT read_string
	EXPORT div_and_mod
	EXPORT multiplication
	EXPORT string_to_int
	EXPORT int_to_string
	EXPORT output_character
	EXPORT input_character
	EXPORT illuminate_RGB_LED
	EXPORT illuminate_LEDS
	EXPORT read_from_push_btns
	EXPORT display_digit_on_7_seg
	EXPORT pin_connect_block_setup_for_gpio
	

U0LSR     EQU 0x14			; UART0 Line Status Register
	ALIGN
digits_SET	
		DCD 0x00003780  ; 0
        DCD 0x00003000  ; 1
        DCD 0x00009580  ; 2 - a,b,d,e,g
        DCD 0x00008780  ; 3 - a,b,c,d,g
        DCD 0x0000A300  ; 4 - b,c,f,g
        DCD 0x0000A680  ; 5 - a,c,d,f,g
        DCD 0x0000B680  ; 6 - a,c,d,e,f,g
        DCD 0x00000380  ; 7 - a,b,c
        DCD 0x0000B780  ; 8 - all
        DCD 0x0000A380  ; 9 - a,b,c,f,g
        DCD 0x0000B380  ; A - a,b,c,e,f,g
        DCD 0x0000B600  ; B - c,d,e,f,g
        DCD 0x00003480  ; C - a,d,e,f
        DCD 0x00003780  ; D - b,c,d,e,g
        DCD 0x0000B480  ; E - a,d,e,f,g
        DCD 0x0000B080  ; F

	ALIGN
PIODATA EQU 0x8 ; Offset to parallel I/O data register
PINSEL0 EQU 0xE002C000
PINSEL1 EQU 0xE002C004

IO0DIR  EQU	0xE0028008
IO1DIR  EQU 0xE0028018
IO0SET  EQU 0xE0028004
IO0CLR  EQU 0xE002800C
IO1SET  EQU 0xE0028014
IO1CLR  EQU 0xE002801C
IO0PIN  EQU 0xE0028000
IO1PIN  EQU 0xE0028010

IO0CFG   EQU 0x26B784
IO1CFG   EQU 0xF0000

PINSEL0_GPIO_CFG EQU 0xFFFC000
PINSEL1_GPIO_CFG EQU 0xFFFF

pin_connect_block_setup_for_uart0
	STMFD sp!, {r0, r1, lr}
	LDR r0, =0xE002C000  ; PINSEL0
	LDR r1, [r0]
	ORR r1, r1, #5
	BIC r1, r1, #0xA
	STR r1, [r0]
	LDMFD sp!, {r0, r1, lr}
	BX lr


on_or_off
    
	STMFD SP!, {lr,r0}
    CMP r8, #0			         ; 0 for off ; 1 = 0n is it on?
	BNE turn_off   ; if not go to turn off
turn_on
    MOV r8, #1		 ; 1 = 0n		
   MOV r0, r7      
    BL done_display2		; go to display the digits	
    B exit

turn_off
	MOV r8, #0				; 0 to turn off
	BL clear_digits			; clear the digits

exit
    LDMFD SP!, {lr,r0}
	BX lr

done_display2
    STMFD SP!,{lr,r4,r2}
    MOV r8,#0
	LDR r4,=IO0CLR ; load the base address
	LDR r2,=0xB784
	STR r2,[r4]
	LDMFD  SP!, {lr,r4,r2} ; Restore regis
    BX LR
clear_digits
    STMFD SP!,{lr,r1,r2}
    MOV r8,#0
	LDR r1,=IO0CLR ; load the base address
	LDR r2,=0xB784
	STR r2,[r1]
	LDMFD  SP!, {lr,r1,r2} ; Restore regis
    BX LR










output_character
    STMFD SP!,{lr,r1,r2}    ; Storing the values of register lr,r1,r2 on the stack

    LDR r1, =0xE000C000 ; loading the base address

TRANSMIT_NOT_READY
    LDRB r2, [r1,#U0LSR] ; loading the LSB from the Line Status register after offseting it ;U0LSR
    AND r2, #32 ; checking if THRE == 1 with mask of #32
    CMP r2, #0 ; if it 0 that means no character was read. 
    BEQ TRANSMIT_NOT_READY ; go back to line 
    
    ; character can be output now.
    STRB r0, [r1,#0]  ; storing the LSB character in the base address from r0.
 
    LDMFD sp!, {lr,r1,r2}
    BX lr


; base address loaded in r0, character input(LSB) obtained in r0
input_character
    STMFD SP!,{lr,r4,r6}    ; Storing the values of registers lr,r4,r6 on memory.

    LDR r0, =0xE000C000 ; loading the base address in r0

WAIT_FOR_INPUT_DATA
    LDRB r1, [r0,#U0LSR] ; loading the LSB of the line status register after offseting base ;address
    AND r6, r1, #1 ; getting the LSB (LDR) in r6
    CMP r6, #0 ; comparing the obtained LSB with 0 to understand whether RDR is active
    BEQ WAIT_FOR_INPUT_DATA ; if r6 ==0 it means no data was input, so we need to ;wait 

    ; else the data has been read, so proceed.
    LDRB r0, [r0,#0] ; load LSB from the base register address.
 
    LDMFD sp!, {lr,r4,r6} ; load the registers lr,r4,r6 with values at the memory 
    BX lr ; return to function call.


 


; the base address of the string is in r4
read_string
    STMFD SP!,{lr,r0,r4}    ; Storing the values of registers lr,r0,r4 on memory.
    
READ_STRING_LOOP
    BL input_character ; get the character from the serial
    CMP r0, #0xD ; checking if it is a carriage return
    BEQ READING_COMPLETE
    STRB r0, [r4] ; storing the  read character in r0 from the base address of the string
    ADD r4, r4, #1 ; increment address of the string to get the next character
    BNE READ_STRING_LOOP ; if there are more characters in the string continue reading
READING_COMPLETE
    MOV r0, #0  ; get null character in r0
    STRB r0, [r4] ; null terminate the string
    
    ; reading is complete, return back
    LDMFD sp!, {lr,r0,r4}
    BX lr
    
	
; the base address of the string is passed in r4
output_string
    STMFD SP!,{lr,r0,r4} ; Storing the values of registers lr,r0,r4 on memory.
    
OUTPUT_STRING_LOOP
    LDRB r0, [r4] ; loading the LSB char from the base address of the string in r0 
    BL output_character ; output the character
    ADD r4, r4, #1 ; increment the base address of the string to get the next character
    CMP r0, #0 ; see if r0 i.e. the character loaded is null or not
    BNE OUTPUT_STRING_LOOP ; if not continue writing down the string in PuTTy
    
    ; else writing the string is done, return
    LDMFD sp!, {lr,r0,r4}
    BX lr
    

	
; it finds out the  the nth power of 10.  n should be passed in r0 and 10^n will obtained in r0
power_of_ten
    STMFD SP!, {lr,r1,r2} ; preserving the return address, r1, r2
    MOV r2, r0 ; copying value of n to r2
    MOV r0, #1 ; current power is set to 1 as (10^0 ==1 ). We need to multiplication by 10 in every ;loop
    MOV r1, #10 ; putting 10 in r1 for multiplicationing
    
POWER_OF_TEN_LOOP
    CMP r2, #0 ; see if we're done looping (r2=0 ie checking whether n = 0)
    BEQ POWER_OF_TEN_COMPLETE
    BL multiplication ; r0*10 wil be obtained in r0
    SUB r2, r2, #1 ; decrementing the value of  n
    B POWER_OF_TEN_LOOP
POWER_OF_TEN_COMPLETE

    LDMFD SP!, {lr,r1,r2} ; restoring the used registers
    BX lr ; return to the called function

; The address of a string  should be passed in r0, it's length will get stored in r1
size_of_string
    STMFD SP!,{lr,r0, r2} ; preserve return address, r0, r2
    MOV r1, #0 ; set initial size to 0
    
SIZE_OF_STRING_LOOP
    LDRB r2, [r0]      ; loading the LSB in r2 from base address of string
    ADD r0, r0, #1 ; incrementing the  string address to get next char
    ADD r1, r1, #1 ; incrementing the  size of the string for every character encountered
    CMP r2, #0     ; checking if the LSB is NULL
    BNE SIZE_OF_STRING_LOOP ; keep looping if we haven’t hit null
    
    SUB r1, r1, #1 ; the last increment done is null character.  So decreasing size by 1.
    LDMFD SP!, {lr,r0,r2} ; restore the registers
    BX lr


; The string address is passed into r0, a number in r1 
; the number will be converted to a string and stored at r0
int_to_string
    STR r1, [r0] ; store r1 as a word into address in r0.
    BX lr ; return 

; The address of the string to be converted is passed in r0
; the integer value of the string will be returned in r1
string_to_int
    STMFD SP!,{lr,r0,r2,r3,r4,r5,r6} ; saving the return addresses and the registers that we are using (r0, r2, r3, r4, r5, r6)
    
    MOV r6, #0 ; setting the  current result to 0
    BL size_of_string ; getting the size of the string
    MOV r4, r0 ; moving string address to r4 so that we can call functions using r0
    SUB r2, r1, #1 ; storing string size minus 1 in r2
    
    MOV r5, #0 ; setting r5 to zero to indicate that it is positive
    LDRB r3, [r4] ; load LSB from base address of string into r3
    CMP r3, #45 ; checking if it is '-', i.e the sign for negative
    BNE NUM_IS_POSITIVE
    ; else the number is negative
    MOV r5, #1 ; indication that num is neg, so we should negate at end
    SUB r2, r2, #1 ; subtracting 1 from size to account for the sign
    ADD r4, r4, #1 ; move to next character address
NUM_IS_POSITIVE
    
STRING_TO_INT_LOOP
    LDRB r1, [r4] ; loading the current character from the incremented address of string
    SUB r1, r1, #48 ; subtracting 48 to get digit as an actual number
    MOV r0, r2 ; moving r2 (r2 has the current power of 10 that will be needed) to r0
    BL power_of_ten ; getting the power of 10 in r0
    BL multiplication ; multiplicationing the current digit by the obtained power of 10
    ADD r6, r6, r0 ; adding the result to the total
    SUB r2, r2, #1 ; decrementing the power of 10
    ADD r4, r4, #1 ; incrementing the  address to go to the next character
    CMP r2, #0 ; r2 keeps track of the entire string so if it 0, string has ended.
    BGE STRING_TO_INT_LOOP ; if r2> 0, then keep running
    ; else r2 <0, so,
    MOV r1, r6 ; putting the result in r1
    CMP r5, #0 ; seeing if the number was negative or not
    BEQ STRING_WAS_POSITIVE
    MOV r5, #0 ; putting 0 in r5 to negate
    SUB r1, r5, r1 ; negating (r1 = 0-r1)
STRING_WAS_POSITIVE
    
    LDMFD sp!, {lr,r0,r2,r3,r4,r5,r6} ; restoring everything that we have used in the ;subroutine
    BX lr




	
uart_init
	STMFD SP!,{lr} ; store return address

	LDR r0, =0xE000C00C
	MOV r1, #131
	STR r1, [r0]
	
	LDR r0, =0xE000C000
	MOV r1, #120
	STR r1, [r0]
	
	LDR r0, =0xE000C004
	MOV r1, #0
	STR r1, [r0]
	
	LDR r0, =0xE000C00C
	MOV r1, #3
	STR r1, [r0]
	
	LDMFD SP!,{lr} ; restoring return address
	BX lr

multiplication
	STMFD sp!, {r2}
	MUL r2, r0, r1
	MOV r0, r2
	LDMFD sp!, {r2}
	BX lr
	
div_and_mod
    STMFD r13!, {r2-r12, r14}
            
    ; Your code for the signed division/mod routine goes here.  
    ; The dividend is passed in r0 and the divisor in r1.
    ; The quotient is returned in r0 and the remainder in r1.

    ; REGISTERS USED
     ;       r0 =   dividend
    ;            r1  =  divisor
    ;            r2  =  dividend sign flag
    ;            r3  =  divisor sign flag
    ;            r4  =  loop counter
    ;            r5  =  quotient
    ;                   r6  =  remainder
    ;            r7  =  zero 
    
    MOV r7, #0 ; storing 0 for convenience
    MOV r2, #0 ; initializing r2 to 0
    MOV r3, #0 ; initializing r3 to 0
    

    CMP r0, #0 ; checking if r0 is negative
    BLE DIVIDEND_IS_NEGATIVE
    B DIVIDEND_IS_NOT_NEGATIVE
DIVIDEND_IS_NEGATIVE
    MOV r2, #1 ; indication that r0 is negative
    SUB r0, r7, r0 ; making r0 positive
DIVIDEND_IS_NOT_NEGATIVE

    CMP r1, #0 ; checking if r1(divisor) is negative
    BLE DIVISOR_IS_NEGATIVE
    B DIVISOR_IS_NOT_NEGATIVE
DIVISOR_IS_NEGATIVE
    MOV r3, #1 ; indicating that r1 is negative
       SUB r1, r7, r1 ; making r1 positive
DIVISOR_IS_NOT_NEGATIVE

    MOV r6, r0 ; putting dividend into remainder to start the algorithm
    LSL r1, r1, #15 ; left shifting divisor 15 places
    MOV r4, #15 ; storing 15 as counter
    MOV r5, #0 ; initialize the quotient to 0

LOOP
    SUB r6, r6, r1 ; remainder = remainder - divisor
    CMP r6, #0 ; see if the remainder is positive
    BLT NEGATIVE_REMAINDER ; if negative, go directly to negative code
    
    ; else it is positive remainder
    LSL r5, r5, #1 ; logical left shift quotient 1
    ADD r5, r5, #1 ; setting the LSB to 1
    B END_OF_LOOP

NEGATIVE_REMAINDER ; negative remainder
    ADD r6, r6, r1 ; add divisor to remainder
    LSL r5, r5, #1 ;Left shifting quotient by 1
END_OF_LOOP
    
    LSR r1, r1, #1 ; right shifting divisor
    CMP r4, r7 ; checking if counter<=0
    SUB r4, r4, #1 ; decrement the counter
    BGT LOOP ; go back to looping if counter > 0
    ;END LOOP
    
    MOV r1, r6 ; putting remainder into r1
    MOV r0, r5 ; putting quotient into r0
    
    CMP r2, #0
    BEQ QUOTIENT_POSITIVE_1
    SUB r0, r7, r0 ; negating quotient if dividend was negative
QUOTIENT_POSITIVE_1
    CMP r3, #0
    BEQ QUOTIENT_POSITIVE_2
    SUB r0, r7, r0 ; negating quotient if divisor was negative
QUOTIENT_POSITIVE_2
    
    LDMFD r13!, {r2-r12, r14}
    BX lr      ; Return to the C program

    
	
; setting up PINSEL1 for GPIO use
; r2 is passed PINSEL0 ‘s address
; r1 is passed PINSEL0_GPIO_CFG ‘s address
pin_connect_block_setup_for_gpio
    STMFD sp!, {lr,r0,r1,r2}

    ; configure PINSEL 0
    LDR r2, =PINSEL0
    LDR r0, [r2]
    LDR r1, =PINSEL0_GPIO_CFG
    BIC r0, r0, r1
    STR r0, [r2] 


    ; configuring PINSEL 1
    LDR r2, =PINSEL1
    LDR r0, [r2]
    LDR r1, =PINSEL1_GPIO_CFG
    BIC r0, r0, r1
    STR r0, [r2]
    
    LDMFD sp!, {lr,r0,r1,r2}
    BX lr



; The digit is passed in r0
display_digit_on_7_seg
    STMFD SP!, {lr,r0,r1,r2,r3} ; preserving return address, r0-r3
    
    ; first we are turning off all pins
        LDR r3, =IO0CLR ; getting clear register address
    LDR r1, =0xFF80 ; bits 7-15 are 1's
    STR r1, [r3] ; turning off ie clearing all pins
	
	CMP r0, #0x20
	BEQ SEVSEGOFF
    
    ; Now we are turning on the segments we want
    LDR r3, =IO0SET ; getting the address of IO0SET register
    MOV r0, r0, LSL #2 ; multiplying digit by 4 to get the offset needed in digits_SET
    LDR r1, =digits_SET ; getting the base address of 7 segment values
    LDR r2, [r1,r0] ; getting the digit pattern for number
    STR r2, [r3] ; writing the pin pattern to the IO0SET register
SEVSEGOFF
	LDMFD sp!, {lr,r0,r1,r2,r3}
	BX lr
        





; returning the value read in r0
read_from_push_btns
    STMFD SP!, {lr,r1} ; preserving lr,r1

    LDR r1, =IO1PIN ; getting port 1 pin register address
    LDR r0, [r1] ; loading gpio values in the address at r1
    LSR r0, #20 ; shifting so that bit 20 becomes the lsb
    LDR r1, =0xFFFFFFFF ; storing all 1’s in r1
    EOR r0, r0, r1 ; XORing the value from push buttons to get the actual number
    AND r0, r0, #0xF ; clearing all but the first 4 bits
    BL reverse_lower_four_bits  ; reversing the lower four bits to adjust with the reversed ;pattern of the board

    LDMFD sp!, {lr,r1}
    BX lr


; bit masking of LEDs to light in r0
illuminate_LEDS
    STMFD SP!, {lr,r0,r1,r2} ; preserving lr,r0,r1,r2

    BL reverse_lower_four_bits ;  ; reversing the lower four bits to adjust with the reversed ;pattern of the board
 

    ; first turn all on
    LDR r1, =IO1SET
    LDR r2, =0xF0000 ; bits 16-19 are 1
    STR r2, [r1] ; turn on 16-19 bits
    
    ; now we turn off the ones specified
    LSL r0, #16 ; shifting bit 0 go to bit 16 (first LED)
    LDR r1, =IO1CLR ; getting clear register address
    STR r0, [r1] ; turning them off

    LDMFD sp!, {lr,r0,r1,r2}
    BX lr

; use the function by passing color in r0 
;color codes are red-1,green-2,blue-3,purple-4,yellow-5,white-6
illuminate_RGB_LED
    STMFD SP!, {lr,r1,r2} ; load the values of those registers in memory and preserve lr,r1,r2

    ;color codes for specific colors should be passed in r0
    ;red-1,green-2,blue-3,purple-4,yellow-5,white-6
    ;first turn all on
    LDR r1, =IO0SET
    LDR r2, =0x260000        ; we want to turn on bits 17,18,21 as set pin connect block to use are port 0: pin 17,18,21, so we are making a mask to do that 
    STR r2,[r1]                ;turns them all on

;RED COLOR 
    CMP r0,#1
    BNE green
    LDR r1, =IO0CLR        ; loading address of IO0CLR register
    LDR r2, =0x20000    ; turn on red led by clearing port 0, pin 17
    STR r2,[r1]        ;turns red led on as port 0, pin 17 has been cleared.

green
    ;GREEN COLOR
    CMP r0,#2
    BNE blue
    LDR r1, =IO0CLR        ; loading address of IO0CLR register
    LDR r2, =0x200000    ; turn on green LED by clearing port 0, pin 21. so we are taking a mask that has 1 in bit 21 and loading it in CLR register address so that it clears that place.
    STR r2,[r1]        ;turns green led on as port 0, pin 21 has been cleared.

blue
    ;BLUE COLOR
    CMP r0,#3
    BNE purple
    LDR r1, =IO0CLR        ; loading address of IO0CLR register
    LDR r2, =0x40000    ; turn on blue LED by clearing port 0, pin 18. so we are taking a mask that has 1 in bit 18 and loading it in CLR register address so that it clears that place.
    STR r2,[r1]        ;turns blue led on as port 0, pin 18 has been cleared.

purple
    ;PURPLE COLOR
    CMP r0,#4
    BNE yellow
    LDR r1, =IO0CLR        ; loading address of IO0CLR register
    LDR r2, =0x60000    ; turn on purple LED by clearing port 0, pin 17 and 18. so we are taking a mask that has 1 in bit 17 and 18 and loading it in CLR register address so that it clears that place.
    STR r2,[r1]            ; red and blue led is on, green is off. so we get purple led.

yellow
    ;YELLOW COLOR
    CMP r0,#5
    BNE white
    LDR r1, =IO0CLR        ; loading address of IO0CLR register
    MOV r2, #0x220000    ; turn on yellow LED by clearing port 0, pin 17 and 21. so we are taking a mask that has 1 in bit 17 and 21 and loading it in CLR register address so that it clears that place.
    STR r2,[r1]            ;red and green led is on, blue is off. so we get yellow LED when we load the mask at the clear register's address.

white
    ;WHITE COLOR
    CMP r0, #6
    BNE RGBTestComplete
    LDR r1, =IO0CLR        ; loading address of IO0CLR register
    LDR r2, =0x260000    ; turn on all three LEDS by clearing port 0, pin 17,18 and 21. so we are taking a mask that has 1 in bit 17,18 and 21 and loading it in CLR register address so that it clears that place.
    STR r2,[r1]            ; red, blue, green LED on. So we get a white LED when we load the mask at the clear register's address.
    
RGBTestComplete
    LDMFD sp!, {lr,r1,r2}
    BX lr
	
; this sub routine reverses the order of the lower 4 bits in r0
reverse_lower_four_bits
    STMFD sp!, {lr,r1,r2} ; preserve lr,r1,r2
    
    MOV r1, r0
    MOV r2, r0
    MOV r0, #0
    
    AND r1, r1, #1 ; isolating the  lsb
    LSL r1, #3 ; moving the lsb to msb
    ORR r0, r0, r1 ; setting the bit in r0
    
    MOV r1, r2 ; restoring the original value
    AND r1, #2 ; isolating the 2nd bit
    LSL r1, #1 ; moving it to the 3rd bit
    ORR r0, r0, r1 ; setting the bit in r0
    
    MOV r1, r2 ; restoring the original value
    AND r1, r1, #4 ; isolating the 3rd bit
    LSR r1, #1 ; moving it to the 2nd bit
    ORR r0, r0, r1 ; setting the bit in r0
    
    MOV r1, r2 ; restoring the original value
    AND r1, r1, #8 ; isolating the msb
    LSR r1, #3 ; moving the msb to lsb
    ORR r0, r0, r1 ; setting the bit in r0
    
    LDMFD sp!, {lr,r1,r2}
    BX lr

	END