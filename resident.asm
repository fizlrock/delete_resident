;/* vim: set filetype=nasm: */
org 100h


section .code

jmp Load

handler_segment dw 0
handler_bias dw 0
flag: dw 5555h

NewHandler:
		push ax
		push dx
		mov ah, 02h
		mov dl, '.'
		int 21h
		pop dx
		pop ax
		
		jmp Unload

		iret

Unload:
		; Изменение
		; DS:DX - вектор прерывания - адрес программы обработки прерывания
		mov ax, 251Ch
		mov ds, [cs:handler_segment]
		mov dx, [cs:handler_bias] 
		int 21h

		mov es,cs:2CH
		mov ah,49H
		int 21H

		push cs
		pop es
		mov ah,49H
		int 21H

		iret




Load:

		; Сохранение
		; Выход:
		; ES:BX - адрес обработчика прерывания
		mov ax, 351Ch
		int 21h
		mov [handler_bias], bx
		mov [handler_segment], es
		mov ax, es:[bx-2]
		cmp ax, 5555h
		jne first_load

		mov ah, 09h
		mov dx, fail
		int 21h
		ret


		
first_load:
		mov ah, 09h
		mov dx, success
		int 21h
		; Изменение
		; DS:DX - вектор прерывания - адрес программы обработки прерывания
		mov ax, 251Ch
		mov dx, NewHandler
		int 21h
		mov dx, Load
		int 27h

success db 'Resident module installed!',10,13,'$'
fail db 'Resident already loaded!',10,13,'$'
