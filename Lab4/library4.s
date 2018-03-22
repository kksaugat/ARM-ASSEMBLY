	AREA   LIBRARY, CODE, READWRITE	
	EXTERN lab4
	EXPORT pin_connect_block_setup_for_uart0
	EXPORT uart_init
    EXPORT read_character
	EXPORT output_character
	EXPORT read_string
	EXPORT output_string
	EXPORT string_to_int 
	EXPORT illuminate_RGB_LED
    EXPORT seven_segment
	EXPORT reverse_bits	
U0LSR EQU 0x14			; UART0 Line Status Register

U0THR EQU 0xE000C000
IO0CLR  EQU  0xE002800C  
stringaddress DCD 0x00000000
digits_SET        
        DCD 0x00003780  ; 0
        DCD 0x00003000  ; 1 
        DCD 0x00009580  ; 2
        DCD 0x00008780  ; 3
        DCD 0x0000A300;   4
		DCD 0x0000A680  ; 5
	    DCD 0x0000B680  ; 6
        DCD 0x00000380  ; 7
        DCD 0x0000B780  ; 8
        DCD 0x0000A780  ; 9
        DCD 0x0000B380  ; A
        DCD 0x0000B600  ; b
        DCD 0x00003480  ; C
        DCD 0x00009700  ; d
        DCD 0x0000B480  ; E
        DCD 0x0000B080  ; F   
            
                 ALIGN
					 


read_string
		STMFD sp!,{r0,r4, lr}	  	
LOOP1   BL read_character				
		BL output_character				
		CMP r0, #0x0D
		BEQ END
		STRB r0, [r4]
        ADD r4,r4,#1		
		B LOOP1	
END		MOV r0, #0x00
		STRB r0, [r4]		
		MOV r0, #0x0A
		BL	output_character

		LDMFD sp!,{r0,r4,lr}
		BX lr				

output_string

		STMFD sp!,{r0, lr}
output_loop	LDRB r0,[r4]
        ADD r4,r4,#1
		CMP r0, #0x00			
		BEQ STOP				
		BL output_character				
		B output_loop
STOP	LDMFD sp!, {r0, lr}
		BX lr


read_character 
		
		STMFD sp!,{r6-r7,lr}
		LDR r6, =U0THR
        LDR r9,=U0LSR
read_loop	LDRB r7, [r6, r9]
		AND r7, r7, #0x1
		CMP r7, #0
		BEQ read_loop
		LDRB r0, [r6]
		LDMFD sp!,{r6-r7,lr}
		BX lr

		
output_character

		STMFD sp!,{r7-r8,lr}
		LDR r8, =U0THR
        LDR r9,=U0LSR
LOOP2	LDRB r7, [r8, r9]
		AND r7, r7, #0x20
		CMP r7, #0
		BEQ LOOP2
		STRB r0, [r8]
		LDMFD sp!, {r7-r8,lr}
		BX lr



string_to_int 					 
	STMFD sp!, { lr}
	MOV r3, #0			; intiialize r3 to 0		 
	MOV r5, #10					  ; intialize r5 to multiply later
	MOV r1, #0					  ; intialize r1 to 0
	
stoi
	LDRB r2, [r4, r3]			 ; load the string of r4 to r2 with 0 offset at first
	CMP r2, #45			  
	BEQ load_next					 
	CMP r2, #0  ; if its 0 then were done 
	BEQ done_changing					 
	SUB r2, r2, #48 ; otherwsise subtract from 48 to get the value
	MUL r1, r5, r1				 ; multiplt r1 by 10 to add it later
	ADD r1, r1, r2				 ; add the multiplied value with the r2 value after subtracting
load_next
	ADD r3, r3, #1				 ; increment the counter
	B stoi    ; branch back
		
done_changing
	LDMFD sp!, { lr}
	BX lr 
	




 
uart_init
		STMFD 	sp!, {lr,r0-r7}
		LDR 	r0, =0xE000C00C ;Load the address to r0
		MOV     r1, #131 ; initialize r1 to 131 			
		STRB 	r1, [r0] ; store 131 from r1 to memory address of r2				
		LDR 	r2,	=0xE000C000   ;load the address to r2
		MOV		r3,	#120  ; initialze r2 to 120
		STRB	r3, [r2]   ;store 120 from r3 to memory address of r3			 
		LDR		r4,	=0xE000C004   ; load the address to r4
		MOV		r5,	#0x00   ; intiialize 0 to r5
		STRB	r5,	[r4] ; store 0 from r5 to memory address of r4				
		LDR		r6,	=0xE000C00C  ;load the address to r6
		MOV		r7, #0x03 ; initialze r7 to 3
		STRB	r7,	[r6]  ;store the value of r7 to memory address of r6 				
		
		LDMFD 	sp!, {lr,r0-r7}
		BX 		lr   
		      
illuminate_RGB_LED
    STMFD   SP!, {lr, r0-r4} 
    CMP r0,#0x72   ; pressed 'r' for red?
    BNE green_on    ; if not branch tp green
	MOV r0,#0x20000 ;1 on pin 17
	B turn_rgb
green_on 
    CMP r0,#0x67 ; pressed 'g' for blue?
	BNE blue_on
	MOV r0,#0x200000 ; 1 0n pin 21
	B turn_rgb  ; turn on the color
	
blue_on
    CMP r0,#0x62  ; pressed 'b' for blue?
	BNE purple_on
	MOV r0,#0x40000 ;;  1 on pin 18
	B turn_rgb
	
purple_on
    CMP r0,#0x70  ;; pressed 'p' for purple?
    BNE yellow_on
    MOV r0,#0x60000 ;pin 17 and 18 =1 purple
    B turn_rgb

yellow_on
    CMP r0,#0x79  ;; pressed 'y' for yellow?
	BNE white_on    
	MOV r0,#0x220000
	B turn_rgb
	
white_on
    CMP r0,#0x77  ;; pressed 'w' for white?
	BNE lab4    ; go back to lab4
	MOV r0,#0x260000  ;pin 17 , 18 ,21 =1== white
	B turn_rgb   ; turn on the color
			  
turn_rgb   ;clearing port to turn on 
 
 LDR r2,=IO0CLR      ;load the base adress
 LDR r1,[r2]
 ORR r1,r1,r0    ; 1 to turn on 
 STR r1,[r2]
 B  lab4
 LDMFD   SP!, {lr, r0-r4}
 BX lr		

reverse_bits


; moving 0th bit to third and third to 0 and 1 to 2 ,2 to 1 and so on
  STMFD SP!, {r0-r3,lr}
  MOV r1,#0   
  MOV r2,#0
  MOV r3,#0
  AND r1,r0,#0x8 ;  
  LSR r1,r1,#3  ; Move it to 0th place
  AND r2,r2,#0x4  ; 2nd bit
  LSR r2,r2,#1 ; 2nd bit to 1st place
  AND r3,r0,#0x2 ; 1st bit
  LSL r3,r3,#1 ; 1st to 2nd
  AND r0,r0,#1 ; 0th bit
  LSL r0,r0,#3 ; 0th to 3rd
  ADD r0,r0,r1  
  ADD r0,r0,r2
  ADD r0,r0,r3 ; add everything up to get the reversed value
  LDMFD SP, {r0-r3,lr}
  BX LR





seven_segment
 STMFD SP!,{lr,r1,r2,r3}
 LDR r1,=0xE0028000    ; base adress
 LDR r3,=digits_SET   ; load the digits 
 MOV r0,r0,LSL#2    
 LDR r2,[r3,r0]
 STR r2,[r1,#4]
 B lab4
 LDMFD SP!, {lr,r1,r2,r3}
 BX lr
			  

pin_connect_block_setup_for_uart0
	STMFD sp!, {r0, r1, lr}
	LDR r0, =0xE002C000  ; PINSEL0
	LDR r1, [r0]
	ORR r1, r1, #5
	BIC r1, r1, #0xA
	STR r1, [r0]
	LDMFD sp!, {r0, r1, lr}
	BX lr



	END
