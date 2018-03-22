	AREA	lib, CODE, READWRITE	
	EXPORT lab3
	EXPORT pin_connect_block_setup_for_uart0
	EXPORT uart_init

;U0LSR EQU 0x14			; UART0 Line Status Register
U0LSR EQU 0xE000C014			; UART0 Line Status Register
U0THR EQU 0xE000C000
stringaddress DCD 0x00000000	

		; You'll want to define more constants to make your code easier 
		; to read and debug
	   
		; Memory allocated for user-entered strings

prompt = "Enter a number between -9999 to 9999. Press a to find average:  ",0          
          ALIGN
		; Additional strings may be defined here
input_numbers = "Enter a number or a for average ",0
	      ALIGN
answer = "The average is:",0 
	      ALIGN	



lab3
	  STMFD SP!,{lr}	; Store register lr on stack
          LDR r4, =prompt 
	  BL output_string ;; output the prompt on string
	  MOV r0, #0xA	;Line Feed \n	
	  BL output_character	; 
	  MOV r0, #0xD ; Carriage Return \r
	  BL output_character	;  Got to new line after LF & CR
          LDR r4,=input_numbers
	  BL output_string ;; output the prompt on string
	  MOV r0, #0xA	;Line Feed \n	
	  BL output_character	; 
	  MOV r0, #0xD ; Carriage Return \r
	  BL output_character	;  Got to new line after LF & CR
          MOV r6,#0 ; set up a counter to keep track of how many numbers are inputted 
          MOV r5,#0; initialize it to 0 to add the inputed numbers in add_input  
start  
           LDR r4,=stringaddress ; Base adress where user enters the value
	   B read_string ; read the string
	   MOV r0, #0xA	;Line Feed \n	
	   BL output_character	; 
	   MOV r0, #0xD ; Carriage Return \r
	   BL output_character	;  Got to new line after LF & CR
	   
saves      MOV r2,r3 ;load the converted into r2
	   ADD r6,r6,#1; increment the counter.This will be our divisor 	 
   	   BL add_input ;to add the numbers thats been converted
           MOV r1,r5; added number will be dividend	 

answer1 
           MOV r0, #0xA	;Line Feed \n	
	   BL output_character	; 
	   MOV r0, #0xD ; Carriage Return \r
	   BL output_character	;  Got to new line after LF & CR
           LDR r4,=answer
           BL output_string	 
           MOV r0, #0xA	;Line Feed \n	
	   BL output_character	; 
	   MOV r0, #0xD ; Carriage Return \r
	   BL output_character	;  Got to new line after LF & CR
   	   MOV r0,r6; divisor intiialized in r0
	   BL div_and_mod ; divide to take the average
           MOV r0,r1 ; answer to saved in r0
           BL int_to_string ; convert the answer back to string 
	   LDR r1,[r4] ; load the string to r1
	   LDRB r0,[r1]; 
	   BL read_string
	   B lab3 ; go to main program again	  
	  ;qoutient will be saved in r1
	  ;BL int_to_string ; change the final result to string to display
morenumbers
          MOV r0, #0xA	;Line Feed \n	
	  BL output_character	; 
	  MOV r0, #0xD ; Carriage Return \r
	  BL output_character	  ;  Got to new line after LF & CR     
          LDR r4,=input_numbers
	  BL output_string ;; output the prompt on string
	  MOV r0, #0xA	;Line Feed \n	
	  BL output_character	; 
	  MOV r0, #0xD ; Carriage Return \r
	  BL output_character	  ;  Got to new line after LF & CR     
	  LDR r4,=stringaddress ; Base address where user enters the value
	  BL read_string
	  ;B start ; loop back to start to input more numbers
	  LDMFD SP!,{lr}
	  BX lr
	
	
	
read_string
      STMFD SP!,{r0-r4,lr}
       BL read_character ;first character is read
       CMP r0,#0x61. ; if its ‘a’ skip and take the average
       BEQ answer1	;take average
loop2 BL read_character 
      CMP r0, #0x0D ; Comparing with CR in ascii
	  BEQ done   ; if user hit enter go to done
      STRB r0,[r4] ; store it into r4
      ADD r4,r4,#1 ; increment to the next byte of address
      B loop2 	 ; loop back     
      
done  
       BL string_to_int ; converts the string into int
	   BL saves.  ; saves the converted int to r2 and increment the r3 counter 
	   MOV r0, #0xA	;Line Feed \n	
	   BL output_character	; 
	   MOV r0, #0xD ; Carriage Return \r
	   BL output_character	;  Got to new line after LF & CR      
           B morenumbers ;  if user wants to enter more numbers then branch back   	   
       
           LDMFD sp!,{r0-r4,lr}
	   BX lr
	  
output_string
	  STMFD SP!,{r0-r4,lr}
	 
	 
loop3 LDRB r0, [r4] ; Load the contents to r0
	  CMP r0,#0x00  ; check if its null
      BEQ done1
	 BL output_character 
	  ADD r4,r4,#1. ; increment by one to go the next char
	  B loop3	  ;if its not null move to next char
done1

      LDMFD SP!,{r0-r4,lr}
	  BX lr	
	
read_character
     STMFD SP!,{r0,lr}	; Store register lr on stack
     LDR r1, =U0LSR   ; load the base address of U0LSR

loop0 LDRB r0,[r1]   ;load the byte into r0
      AND r0,r0,#1 ; logical and to check 1 in RDR  
      CMP r0,#0   ; if its 1 read it else keep looping back
      BEQ loop0   ; loop back
      LDR r1, =U0THR ; for UOTHR AND U0RBR
      LDRB r0,[r1]  ; read it into UOTHR 
      B output_character 
      LDMFD sp!, {r0,lr}
      BX lr

	 
output_character
      STMFD SP!,{r0-r2,lr}	; Store register lr on stack
      LDR r1, =U0LSR. ; load the base address of U0LSR

loop1  
      LDRB r2,[r1] ; Load the byte into r2
	  AND r2,r2,#32 ; Logical And it to check if THRE is 1 
	  CMP r2,#0; if its 1 store otherwise keep looping back
	  BEQ loop1
	  LDR r1, =U0THR ; load the adress of UOTHR 
	  STRB r0,[r1] ; store it into r0
	   LDMFD sp!, {r0-r2,lr}
	  BX lr
	  
;;int to be stored in r0 

string_to_int
          
          STMFD SP!,{r0-r9,lr}	; 
		  MOV r1,#0 ; Setting the counter
		  MOV r2,#0 ; Setting flags for negative number     
	      MOV r3,#0 ; answers to be placed in
		  LDRB r5,[r4],#1 ;loading the byte of string to r5
          CMP r5,#0x2D ;  checking if the first char is '-' or negative
    	  BNE tracknumofchar ; if number is positive skip 
          ADD r1,#-1 ; Since the first char is '-'decrement the counter
          MOV r2,#1 ; Flag =1; 
		 
tracknumofchar 
          ADD r1,r1,#1 ; increment the counter
		  LDRB r5,[r4],#1 ;Load next character
		  CMP r5,#0 ; Check whether it hits a null char
		  BNE tracknumofchar ; loop back and it counts the num of char in string
         ;;ascii '0' = 48, '1'=49 ......'9' = 57
         ;  Ascii - 48 * the digit   
         ; if '3999' 
          ;0009  Ascii(9) - 48 * 1 = (57-48)*1         
         ;0090  Ascii(9) - 48 *10
          ;0900  ''   "     "   *100
         ;3000   "   3 - 48 *1000
         ;Add everything up  
           LDR r4,=stringaddress ; load the stringadress
		   CMP r2,#0   ; check the negative flag
		   BEQ ifpositive ; if its 0 go to positive
		   ADD r4,r4,#1 ; otherwsie increment the stringaddress
         
          
ifpositive LDRB r5,[r4],#1 ;load the byte into r5
           ADD r5,r5,#-48   ; Ascii(r5) - 48 = numerical value
		   CMP r1,#4   ; is the string 4 character?
		   BNE threechars  ; if not go to 3 characters.
		   ADD r1,r1,#-1   ; if yes decrement the counter
		   MOV r9,#1000   ; intialize it to 1000
		   MUL r5,r9,r5   ; multiply by 1000 
		   ADD r3,r3,r5    ; answer is stored in r3
           B ifpositive

threechars CMP r1,#3   ; is string 3 characters?
		   BNE twochars    ; if not got to two characters
		   ADD r1,r1,#-1   ; if yes decrement the counter
		   MOV r9,#100   ; initialize to 100
		   MUL r5,r9,r5   ; multiply by 100
		   ADD r3,r3,r5  ; place the answer in r3
                   B ifpositive	 

twochars   CMP r1,#2 ; is the string 2 characters?
		   BNE char ; if not go to adding
		   ADD r1,r1,#-1 ; if yes decrement the counter
		   MOV r9,#10 ; Initialize to 10
		   MUL r5,r9,r5 ; Multiply by 10
		   ADD r3,r3,r5 ; add it and place the answer in r3
                   B ifpositive	
char               ADD r3,r3,r5; add the result 
                   CMP r2,#0    ; check if its negative
	           BEQ donestringtoint  ; if its take two’s complement 
	           MVN r3,r3
		   ADD r3,r3,#1
donestringtoint 
           LDMFD sp!, {r0-r9,lr}
	       BX lr


int_to_string
	STMFD SP!,{lr} 
	MOV r7, #0x00 ; 
	STRB r7, [r4] ; Store the null character in r7 
	SUB r4, r4, #1 ;Decrement the address by 1 
	CMP r0, #0 ;Check if the dividend is negative
	BGE loop5; Skip to loop5 if not negative
	MOV r7, #1 ;If its negative set flag
loop5
	MOV r0, #10 ; Initialize r0 to 10 for dividing
	BL div_and_mod ; Branch to div_and_mod to take the result
	ADD r0, r0, #48 ; Change the remainder to ascii value
	STRB r0, [r4] ; Store it in r0
	CMP r1, #0 ; Check the quotient stored in r1 
	BEQ loop6 ; If 0 skip to loop6
	SUB r4, r4, #1 ;Decrement to store another ascii value
	B loop5
loop6
	CMP r7, #0 ;Check it to see the negative flag
	BEQ done3 ;if 0 then skip t0 done3
	SUB r4, r4, #1; if its negative we need to decrement to store '-�'infront of the number
	MOV r7, #0x2D ; initialize r7 to '-'
	STRB r7, [r4] ; Store the byte into the address of r4
done3
	LDMFD sp!, {lr} 
	BX lr



add_input    
           
    		  STMFD SP!,{r0-r12,lr}
                  MOV r3,r2; saving the first number in r3
	          ADD r5,r5,r3 ; adding the numbers
		  B morenumbers ; To input more numbers and add here later
		  LDMFD sp!, {r0-r9,lr}
                  BX lr

;;divisor is initialized in register r0 in div_and_mod

div_and_mod
                STMFD SP!, {r2-r12,lr}
                MOV r5,#0  ; setting r5 to 0 to keep track whether the dividend is pos or neg
                CMP r1,#0 ; comparing dividend with 0
 	            BLT complement ;if its less than 0 go to complement
initialize	    MOV r3,#15; set counter to 15
	            MOV r2,#0; set quotient to 0
	            MOV r0,r0,LSL#15 ; shift 15 places to left
	            MOV r4,r1; set remainder to dividend
		        B routine0
complement      MVN r1,r1 ; take one's complement
                ADD r1,r1,#1 ; add one for two's complement
               MOV r5,#1 ; r5 set to 1 since the dividend was negative				
			    B initialize ; branch to initialize

routine0        SUB r4,r4,r0; subtract divisor from remainder
                CMP r4,#0; compare remainder with 0
	            BLT routine; if its less than 0 go to routine
	            MOV r2,r2,LSL#1 ; shift quotient one place to left
	            ADD r2,r2,#1 ; add one for LSB =1
	            MOV r0,r0,LSR#1; shift divisor 1 places to right
	            B comparison  ; Branch to comparison
	 
routine         ADD r4,r4,r0; Add remainder with divisor
               MOV r2,r2,LSL#1; Shift quotient one place to left
		        MOV r0,r0,LSR#1 ; shift divisor one place to right
		        B comparison;  Branch to comparison
	
comparison      CMP r3,#0 ; compare counter to 0
              BGT decrement; if its greater decrement
	        B check; Branch to check if its less or equal
decrement      SUB r3,r3,#1; counter=counter-1
               B routine0; Branch to routine0
check              MOV r0,r4; Initialize the remainder to r0
              CMP r5,#0; Compare r5
			   BGT finalcomplement; if r5 is 1 then need to negate again
			   B finish; if its positive just branch to finish
			   
finalcomplement   MVN r2,r2 ; one's complement
                  ADD r2,r2,#1; add one for two's complement
                  B finish; done
               
finish		      MOV r1,r2; initialize quotient to r1
		         LDMFD SP!,{r2-r12,lr}
		         BX lr;
		   
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
