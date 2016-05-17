; Author:	Jaden Yuros
; Course / Project ID    Program 6 - Option A	           Date:	3/8/16
; Description:  Programming Assignment #6 Option A. 
;	1) Designing, implementing, and calling low-level I/O procedures
;	2) Implementing and using a macro

INCLUDE Irvine32.inc

INPUTS = 10		; number of inputs


mCommaSpace	MACRO
	push	eax
	mov		al, ','
	call	WriteChar
	mov		al, ' '
	call	WriteChar	
	pop		eax
ENDM

mDisplayString	MACRO	displayBuffer
	push	edx		; save the edx register
	mov		edx, displayBuffer
	call	WriteString
	pop		edx		; restore edx
ENDM

mGetString		MACRO	stringBuffer, stringMaxLength, stringLength
	push	ecx							; save registers
	push	edx				
	push	eax
	mov		edx, stringBuffer
	mov		ecx, stringMaxLength		; the max number of chars allowed
	call	ReadString
	mov		stringLength, eax			; stores the number of chars in the current string
	pop		eax							; restore registers
	pop		edx							
	pop		ecx	
ENDM

.data

;	**** STRING VARS ****
introText		BYTE	"Welcome to Programming Assignment 6 - Option A: Designing Low-Level I/O Procedures and Macros", 0
introName		BYTE	"Written by: Jaden Yuros", 0
instruct1		BYTE	"Please provide 10 unsigned decimal integers.", 0
instruct2		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
instruct3		BYTE	"After you have finished inputting the raw numbers", 0
instruct4		BYTE	"I will display a list of the integers, their sum, and their average value.", 0
promptText		BYTE	"Please enter an unsigned number: ", 0
promptTryAgain	BYTE	"Please try again: ", 0
resultText		BYTE	"You entered the following numbers: ", 0
sumText			BYTE	"The sum of these numbers is: ", 0
avgText			BYTE	"The average is: ", 0
errorInput		BYTE	"ERROR: You did not enter an unsigned number or your number was too big.", 0
goodbyeText		BYTE	"Thanks for playing! Come back soon!", 0

stringInput		BYTE	21 DUP(?)
stringCount		DWORD	?				; the number of chars in a string
stringClear		BYTE	21 DUP(0)		; string to clear out temp string for bad input
numArray		DWORD	10 DUP(?)	; array where 10 validated decimal numbers will be stored

sum				DWORD	?
avg				DWORD	?




;	



.code
main PROC

;****** introduction/instructions ******
	push	OFFSET introText	; +28
	push	OFFSET introName	; +24
	push	OFFSET instruct1	; +20
	push	OFFSET instruct2	; +16
	push	OFFSET instruct3	; +12
	push	OFFSET instruct4	; +8
	call	introduction

;****** prompt user for input and validate ******
	push	OFFSET stringClear		; +36
	push	OFFSET errorInput		; +32
	push	OFFSET numArray			; +28
	push	OFFSET promptText		; +24
	push	OFFSET promptTryAgain	; +20
	push	OFFSET stringInput		; +16
	push	SIZEOF stringInput		; +12
	push	OFFSET stringCount		; +8
	call	readVal


;****** calculate sum and average ******
	push	OFFSET numArray			; +16
	push	OFFSET sum				; +12	
	push	OFFSET avg				; +8
	call	calculations			

;****** display list of numbers *********
	push	OFFSET numArray			;	+12
	push	OFFSET resultText		;	+8
	call	printList

;****** display sum and avg ******
	call	CrLf
	call	CrLf
	mDisplayString	OFFSET sumText
	push	OFFSET sum				; +12
	call	WriteVal
	call	CrLf
	mDisplayString	OFFSET avgText
	push	OFFSET avg				; +8
	call	WriteVal
	call	CrLf

;****** GOODBYE *****	
	call	CrLf
	mDisplayString  OFFSET goodbyeText
	call	CrLf
	call	CrLf
	exit	; exit to operating system
main ENDP





; *************************************************************** 
; Procedure to Introduce Program and Programmer's Name.
; receives: address of introduction/instruction strings on system stack 
; returns: nothing 
; preconditions: none 
; registers changed: none
; ***************************************************************

introduction PROC
	push	ebp
	mov		ebp, esp
	mDisplayString	[ebp+28]	; introText
	call	CrLf
	mDisplayString	[ebp+24]	; introName
	call	CrLf
	call	CrLf
	mDisplayString	[ebp+20]	; instruct1
	call	CrLf
	call	CrLf
	mDisplayString	[ebp+16]	; instruct2
	call	CrLf
	mDisplayString	[ebp+12]	; instruct3
	call	CrLf
	mDisplayString	[ebp+8]		; instruct4
	call	CrLf
	call	CrLf
	pop		ebp
	ret		24
introduction ENDP


; *************************************************************** 
; Procedure to get the user's input. Also validates the input
; receives: address of a string for user input
;			address of the array to store the numbers
;			address of the variable for the number of chars in the input string
;			addresses of various instructional / error strings
; returns: none
; preconditions: none
; registers changed: none
; ***************************************************************

readVal PROC,
	stringLength:	PTR BYTE,		;	pointer to the LENGTHOF string input
	stringSize:		PTR BYTE,		;	pointer to the SIZEOF string input
	tempString:		PTR BYTE,		;	pointer to string input
	tryAgain:		PTR BYTE,		;	pointer to try again message
	directions:		PTR BYTE,		;	pointer to instructional text
	pArray:			PTR DWORD,		;	pointer to the array of numbers
	errorText:		PTR BYTE,		;	pointer to errorInput
	stringClr:		PTR BYTE		;	pointer to stringClear

	pushad		;	save registers




; set loop counter to get 10 strings, and set desination Array to EDI
	mov		ecx, INPUTS
	mov		edi, pArray			; the array to hold the numbers
L1:
	push	ecx					;	save outer loop counter
	mDisplayString	directions	;	display instructions
	
getString:

	mGetString		tempString, stringSize, stringLength	;	PARAMS:		( stringInput  |  SIZEOF stringInput  |  stringCount )
			
; set up the loop counter, move the string address into source
; and index registers, and clear the direction flag
	mov		ecx, stringLength	; number of chars that are in the string
	mov		esi, tempString		; the input string
	cld							; clear the direction flag

checkLength:
	cmp		ecx, 10					; if stringLength > 10 chars long, the number is too large to fit in a 32 bit register
	JA		invalidInput	

stringLoop:	
	
	; multiply exisiting number by 10 - (12 -> 120)
	mov		eax, [edi]			; move pArray[i] to EAX
	mov		ebx, 10d			
	mul		ebx					; temp * 10 = EAX
	mov		[edi], eax			; move EAX back to pArray[i]
	
	; load byte for validation
	xor		eax, eax			; clear EAX register
	lodsb						; loads byte from stringInput and puts into al, then increments esi to the next char
	sub		al, 48d				; convert ASCII to INT value
	cmp		al, 0				
	JB		invalidInput		; if AL < 0
	cmp		al, 9				
	JA		invalidInput		; if AL > 9
	add		[edi], al			; else input valid, add to value in EBX ( temp )
	loop	stringLoop			; get next char in string
	jmp		endReadVal

invalidInput:
	push	eax
	xor		eax, eax			
	mov		[edi], eax			; clear pArray[i]
	pop		eax

	mDisplayString  errorText
	call	CrLf
	mDisplayString	tryAgain	; promptTryAgain
	JMP		getString

endReadVal:
	pop		ecx		;	restore outer loop counter
	mov		eax,	[edi]
	add		edi, 4				; increment EDI so it goes to the next array element
	loop	L1

	popad
	ret
readVal ENDP

; *************************************************************** 
; Procedure to calculate the sum and average of the numbers
; receives: address of the array of numbers
;			address of the sum variable
;			address of the avg variable
; returns: sum and avg in values passed by reference
; preconditions: There are numbers in the array
; registers changed: none
; ***************************************************************

calculations	PROC,
	nAvg:	PTR DWORD,		;	+8
	nSum:	PTR DWORD,		;	+12
	nArray:	PTR DWORD		;	+16
	pushad

	mov		esi, nArray
	mov		ecx, INPUTS	
	mov		eax, 0		; set accumulator to 0
	
L1:
	add		eax, [esi]	; add current element to eax
	add		esi, 4		; increment to next element
	loop	L1
	
	mov		ebx, nSum	; move address of nSum to ebx
	mov		[ebx], eax	; store contents of EAX in sum global variable
	
	xor		edx, edx	; clear EDX for division		
	mov		ebx, INPUTS	; the number of strings entered initially by user
	cdq
	div		ebx			; quotient in EAX, remainder in EDX
	mov		ebx, nAvg
	mov		[ebx], eax	; store quotient in avg global variable
	popad
	ret
calculations	ENDP


; *************************************************************** 
; Procedure to convert a numeric value to string, then display it
; receives: address of a number
; returns: none
; preconditions: none
; registers changed: none
; ***************************************************************

writeVal	PROC,
	vNum:	PTR DWORD			; address of numerical input		;  +8
	LOCAL	vLen:DWORD			; stores the length of the number (100 = 3 length, 10 = 2 length)
	LOCAL	vStr[20] : BYTE		; address of a temp string variable
	pushad						; save registers


	; ****** get the number of digits in the number ******
			
	mov		vLen, 0				; initialize counter at 0
	mov		eax, [vNum]			; move address of number to eax
	mov		eax, [eax]			; move number to eax
	mov		ebx, 10d			; set our divisor
L1:
	xor		edx, edx			; clear edx register
	cmp		eax, 0
	JE		endCount			; if EAX = 0, don't increment length counter
	div		ebx					; Quotient = EAX, Remainder = EDX
	cdq
	mov		eax, eax
	inc		vLen				; increase the length counter
	jmp		L1

endCount:
	mov		ecx, vLen			
	cmp		ecx, 0				; if length was 0, the number was 0 and we just need to print that number
	JE		zeroCount
	lea		edi, vStr			; set the source for STOSB
	add		edi, vLen			; add the number of bytes we need to convert
				
			;	convert integer to string
	
	;	add 0 at the end of the string
	std
	push	ecx
	mov		al, 0
	stosb
	pop		ecx

	mov		eax, vNum			; move address of number to eax
	mov		eax, [eax]			; move number to eax
	mov		ebx, 10d			; set our divisor
	;std							; set direction flag
	
L2:
	xor		edx, edx		; clear edx
	mov		ebx, 10d		;
	cdq
	div		ebx				; Quotient = EAX, Remainder = EDX
	add		edx, 48d		; convert the remainder to ASCII char
	push	eax				; save EAX
	mov		eax, edx		; move new ASCII Char to EAX
	stosb					; store ASCII in outptString
	pop		eax				; restore EAX
	cmp		eax, 0			
	JE		printString		; if EAX = 0, we have looked at all digits in number
	JMP		L2				; else we have more digits to convert

zeroCount:
	push	ecx
	mov		ecx, 2
	xor		eax, eax		; clear eax so STOSB stores 0
	add		eax, 48d		; convert 0 to ASCII code
	push	eax
	mov		al, '0'
	call	WriteChar
	pop		eax
	pop		ecx

	JMP		endW

printString:
	lea		eax, vStr
	mDisplayString  eax
endW:
	popad					; restore registers
	ret		
writeVal	ENDP

; *************************************************************** 
; Procedure to print the values store in an array of numbers
;	uses the writeVal proc
; receives: address of an array
; returns: none
; preconditions: array has numbers in it
; registers changed: none
; ***************************************************************

printList	PROC,
	results:	PTR BYTE,
	arr:		PTR DWORD		;	address of first element in array	
	pushad

	call	CrLf
	mDisplayString results
	call	CrLf

	mov		ecx, INPUTS		; set the loop counter
	mov		esi, arr		
L1:
	push	esi
	call	WriteVal
	add		esi, 4
	cmp		ecx, 1
	JE		L1end
	mCommaSpace
	loop	L1

L1end:

	popad
	ret
printList	ENDP


END main