INCLUDE Irvine32.inc

.data

NumElements = 12
FirstDimension = 3
SecondDimension = NumElements / FirstDimension
M1	SDWORD	NumElements DUP(?)
M2	SDWORD	NumElements DUP(?)
MP	SDWORD	FirstDimension * FirstDimension DUP(?)

outmsg1	byte "M1 = ", 13, 10, 0
outmsg2	byte "M2 = ", 13, 10, 0
outmsg3	byte "MP = ", 13, 10, 0
promptmsg1	byte "Enter element-", 0
promptmsg2	byte " of ", 0
promptmsg3	byte ": ", 0

.code
main proc
	
	mov ebx, 1			
input_loop:							; Loop to take input from user
	mov edx, offset promptmsg1
	call WriteString				; Print "Enter element-"
	mov eax, ebx
	call WriteDec					; Print element no.
	mov edx, offset promptmsg2
	call WriteString				; Print " of "
	mov eax, NumElements
	call WriteDec					; Print total number of elements
	mov edx, offset promptmsg3
	call WriteString				; Print ": "
	call ReadInt					; Read the element
	mov M1[ebx*4-4], eax			; Save it in M1
	inc ebx							; Increment the loop counter
	cmp ebx,  NumElements			; Repeat until all the NumElements have been prompted for
	jbe input_loop

	mov ecx, NumElements
	mov ebx,0
copy_loop:							; Loop to copy from M1 to M2 but in reverse
	mov eax, M1[ebx*4]				; Get an element from the start of M1
	mov M2[ecx*4-4], eax			; Put it at the end of M2
	inc ebx							; Move on to the nex element
	loop copy_loop

	mov edx, offset outmsg1
	call WriteString				; Print "M1 = "
	mov ebx, offset M1
	mov esi, FirstDimension
	mov edi, SecondDimension
	call PrintMatrix				; Print M1

	mov edx, offset outmsg2
	call WriteString				; Print "M2 = "
	mov ebx, offset M2
	mov esi, SecondDimension
	mov edi, FirstDimension
	call PrintMatrix				; Print M2

	mov ebx, offset MP
	mov ecx, 0						; i =0
multiply_loop_1:
	mov esi, 0						; j = 0
multiply_loop_2:
	mov edi, 0						; k = 0
	mov [ebx], edi
multiply_loop_3:
	push ebx
	mov eax, ecx
	mov ebx, SecondDimension
	mul ebx
	add eax, edi
	shl eax, 2
	mov ebx, offset M1
	add ebx, eax
	mov eax, [ebx]			
	push eax						; Save M1[i][k] in stack
	mov eax, edi
	mov ebx, FirstDimension
	mul ebx
	add eax, esi
	shl eax, 2
	mov ebx, offset M2
	add eax, ebx
	mov ebx, [eax]					; ebx has M2[k][j]
	pop eax
	mul ebx							; Find M1[i][k]*M2[k][j]
	pop ebx
	add [ebx], eax					; MP[i][j] += M1[i][k]*M2[k][j]
	inc edi							; k++
	cmp edi, SecondDimension
	jb multiply_loop_3
	add ebx, 4
	inc esi							; j++
	cmp esi, FirstDimension
	jb multiply_loop_2
	inc ecx							; i++
	cmp ecx, FirstDimension
	jb multiply_loop_1
	mov edx, offset outmsg3
	call WriteString				; Print "MP = "
	mov ebx, offset MP
	mov esi, FirstDimension
	mov edi, FirstDimension
	call PrintMatrix				; Print MP

	exit							; Exit
main endp

; Procedure to print a matrix
; Receives address of a matrix in EBX
; Receives FirstDimension in ESI
; Receives SecondDimension in EDI
PrintMatrix proc
	mov ecx, esi
PrintMatrix_eachrow:
	push ecx
	mov ecx, edi
PrintMatrix_eachcolumn:
	mov eax, [ebx]
	call WriteInt					; Print the matrix element
	mov al, 9
	call WriteChar					; Print a tab character
	add ebx, 4
	loop PrintMatrix_eachcolumn
	call Crlf
	pop ecx
	loop PrintMatrix_eachrow	
	ret
PrintMatrix endp

end main
