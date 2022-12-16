;------------------------------------------------------------------------------------------------------
; Design and Implementation of an AHB VGA peripheral and a GPIO peripheral
; 1) Input data from switches and output them to LEDs;
; 2) Display text string: "TEST" on VGA. 
; 3) Change the colour of the four corners of the image region.
;------------------------------------------------------------------------------------------------------


                PRESERVE8
                THUMB


; Vector Table Mapped to Address 0 at Reset
                AREA    RESET, DATA, READONLY   ; First 32 WORDS is VECTOR TABLE
                EXPORT  __Vectors

__Vectors       DCD     0x00003FFC
                DCD     Reset_Handler
                DCD     0              
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0

                ; External Interrupts
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0


                AREA    |.text|, CODE, READONLY

; Reset Handler
Reset_Handler   PROC
                GLOBAL  Reset_Handler
                ENTRY
 

AGAIN            

                
;Write "TEST" to the text console

		LDR 	R1, =0x50000000
		MOVS	R0, #'T'
		STR	R0, [R1]

		LDR 	R1, =0x50000000
		MOVS	R0, #'E'
		STR	R0, [R1]

		LDR 	R1, =0x50000000
		MOVS	R0, #'S'
		STR	R0, [R1]
				
		LDR 	R1, =0x50000000
		MOVS	R0, #'T'
		STR	R0, [R1]  

        LDR 	R1, =0x50000000
		MOVS	R0, #' '
		STR	R0, [R1]  


                ENDP

                ALIGN   4                       ; Align to a word boundary

                END                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
