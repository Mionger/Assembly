_DATA	SEGMENT
MSG_DONE_01		DB	0DH,0AH,"DONE	01	File opened successfully.",'$'
MSG_DONE_02		DB	0DH,0AH,"DONE	02	File created successfully.",'$'
MSG_DONE_03		DB	0DH,0AH,"DONE	03	File closed successfully.",'$'
MSG_DONE_04		DB	0DH,0AH,"DONE	04	File size got successfully.",'$'
MSG_DONE_05		DB	0DH,0AH,"DONE	05	File content got successfully.",'$'
MSG_DONE_06		DB	0DH,0AH,"DONE	06	Student number calculated successfully.",'$'
MSG_DONE_07		DB	0DH,0AH,"DONE	07	Random number got successfully.",'$'

MSG_ERROR_01	DB	0DH,0AH,"ERROR	01	File opening failed!",'$'
MSG_ERROR_02	DB	0DH,0AH,"ERROR	02	File creating failed!",'$'
MSG_ERROR_03	DB	0DH,0AH,"ERROR	03	File closing failed!",'$'

MSG_1			DB	0DH,0AH,"The random number is: ",'$'
MSG_2			DB	0DH,0AH,"The number of the lucky student is: ",'$'

FILE_NAME_IN	DB	"STU.TXT",0
FILE_HANDLE		DW	?

FILE_HI			DW	?
FILE_LO			DW	?

STUD_NUM		DB	?
RAND_NUM		DB	?

STR_BUFFER_SIZE	DW	?
STR_BUFFER		DW	?
_DATA	ENDS

_CODE	SEGMENT
ASSUME	CS:_CODE,	DS:_DATA
MAIN_START:
		MOV		AX,_DATA
		MOV		DS,AX

;INPUT FILE OPEN:
		LEA		DX,FILE_NAME_IN
		MOV		AL,0
		CALL	FILE_OPEN
		CMP		AX,1
		JE		FILE_OPEN_ERROR
FILE_OPEN_DONE:
		MOV		FILE_HANDLE,BX
		LEA		DX,MSG_DONE_01
		MOV		AH,09H
		INT		21H
		JMP		FILE_OPEN_OVER
FILE_OPEN_ERROR:
		LEA		DX,MSG_ERROR_01
		MOV		AH,09H
		INT		21H
FILE_OPEN_OVER:

;GET SIZE OF THE FILE
		MOV		BX,FILE_HANDLE
		CALL	GET_FILE_SIZE
		CMP		AX,0
		JE		GET_FILE_SIZE_DONE
		JMP		GET_FILE_SIZE_OVER
GET_FILE_SIZE_DONE:
		LEA		DX,MSG_DONE_04
		MOV		AH,09H
		INT		21H
GET_FILE_SIZE_OVER:

;GET CONTENT OF FILE
		MOV		BX,FILE_HANDLE
		CALL	GET_FILE_CONTENT
		CMP		AX,0
		JE		GET_FILE_CONTENT_DONE
		JMP		GET_FILE_CONTENT_OVER
GET_FILE_CONTENT_DONE:
		LEA		DX,MSG_DONE_05
		MOV		AH,09H
		INT		21H
GET_FILE_CONTENT_OVER:

;CALCULATE THE NUMBER OF STUDENT
		CALL	STUD_NUM_CAL
		CMP		AX,0
		JE		CALCULATE_NUMBER_OF_STUDENT_DONE
		JMP		CALCULATE_NUMBER_OF_STUDENT_OVER
CALCULATE_NUMBER_OF_STUDENT_DONE:
		LEA		DX,MSG_DONE_06
		MOV		AH,09H
		INT		21H
CALCULATE_NUMBER_OF_STUDENT_OVER:

;GENEARTE RANDOM
		CALL	RAND
		CMP		AX,0
		JE		GENEARTE_RANDOM_DONE
		JMP		GENEARTE_RANDOM_OVER
GENEARTE_RANDOM_DONE:
		LEA		DX,MSG_DONE_07
		MOV		AH,09H
		INT		21H
GENEARTE_RANDOM_OVER:

;PRINT THE RANDOM NUMBER:
		LEA		DX,MSG_1
		MOV		AH,09H
		INT		21H

		MOV		AL,RAND_NUM
		MOV		AH,0

		MOV		BX,10
		MOV		CX,0
PUSH_IN:
		MOV		DX,0
		DIV		BX

		PUSH	DX
		INC		CX

		CMP		AX,0
		JZ		POP_OUT

		JMP		PUSH_IN
POP_OUT:
		POP		DX
		ADD		DL,30H
		MOV		AH,02H
		INT		21H

		LOOP	POP_OUT

;PRINT THE LUCKY STUDENT`S NUMBER:
		LEA		DX,MSG_2
		MOV		AH,09H
		INT		21H

		MOV		DL,9
		MOV		AL,RAND_NUM
		MUL		DL
		SUB		AX,9
		MOV		BX,AX

		MOV		SI,0
LOOP_:
		MOV		DL,BYTE	PTR	STR_BUFFER[BX][SI]
		MOV		AH,02H
		INT		21H
		INC		SI
		CMP		SI,7
		JB		LOOP_

;CLOSE THE OPEN INPUT FILE
		MOV		BX,FILE_HANDLE
		CALL	FILE_CLOSE
		CMP		AX,1
		JE		IN_FILE_CLOSE_ERROR
IN_FILE_CLOSE_DONE:
		LEA		DX,MSG_DONE_03
		MOV		AH,09H
		INT		21H
		JMP		IN_FILE_CLOSE_OVER
IN_FILE_CLOSE_ERROR:
		LEA		DX,MSG_ERROR_03
		MOV		AH,09H
		INT		21H
IN_FILE_CLOSE_OVER:

MAIN_OVER:
		MOV		AX,4C00H
		INT		21H

;-----------------------------------------------------------
;sub-programe of file open
;功能：文件打开
;入口参数：
;			DS:DX=文件名（以0为结尾的字符串）
;			AL=打开方式（0-只读 1-只写 2-读写）
;出口参数：成功：
;		  	CF=0
;			AX=文件句柄
;		  失败：
;			CF=1
;			AX=系统错误码
;封装后出口参数：
;		  	BX=文件句柄（如果成功）
;			AX=错误码
;错误码：
;			AX=0	DONE	01	File opened successfully.
;			AX=1	ERROR	01	File opening failed!
;-----------------------------------------------------------
FILE_OPEN		PROC
		MOV		AH,3DH
		INT		21H

		JNC		FILE_OPEN_PROC_DONE
FILE_OPEN_PROC_ERROR:
		MOV		AX,1
		JMP		FILE_OPEN_PROC_OVER
FILE_OPEN_PROC_DONE:
		MOV		BX,AX
		MOV		AX,0
FILE_OPEN_PROC_OVER:
		RET
FILE_OPEN		ENDP

;-----------------------------------------------------------
;sub-program of file create
;功能：文件创建
;入口参数：
;			DS:DX=文件名（以0为结尾的字符串）
;			CX=文件属性（0-普通 1-只读 2-隐藏 4-系统）
;出口参数：成功：
;			CF=0
;			AX=文件句柄
;		  失败：
;			CF=1
;			AX=系统错误码
;封装后出口参数：
;		  	BX=文件句柄（如果成功）
;			AX=错误码
;错误码：
;			AX=0	DONE	02	File created successfully.
;			AX=1	ERROR	02	File creating failed!
;-----------------------------------------------------------
FILE_CREATE		PROC
		MOV	AH,3CH
		INT	21H

		JNC		FILE_CREATE_PROC_DONE
FILE_CREATE_PROC_ERROR:
		MOV		AX,1
		JMP		FILE_CREATE_PROC_OVER
FILE_CREATE_PROC_DONE:
		MOV		BX,AX
		MOV		AX,0
FILE_CREATE_PROC_OVER:
		RET
FILE_CREATE		ENDP

;-----------------------------------------------------------
;sub-program of file close
;功能：文件关闭
;入口参数：
;			BX=文件句柄
;出口参数：成功：
;			CF=0
;		  失败：
;			CF=1
;			AX=系统错误码
;封装后出口参数：
;			AX=错误码
;错误码：
;			AX=0	DONE	03	File closed successfully.
;			AX=1	ERROR	03	File closing failed!
;-----------------------------------------------------------
FILE_CLOSE		PROC
		MOV	AH,3EH
		INT	21H

		JNC		FILE_CLOSE_PROC_DONE
FILE_CLOSE_PROC_ERROR:
		MOV		AX,1
		JMP		FILE_CLOSE_PROC_OVER
FILE_CLOSE_PROC_DONE:
		MOV		AX,0
FILE_CLOSE_PROC_OVER:
		RET
FILE_CLOSE		ENDP

;-----------------------------------------------------------
;sub-program of get the size of the file
;功能：获取文件大小，并申请相应大小的动态内存
;入口参数：
;			BX=文件句柄
;封装后出口参数：
;			AX=错误码
;			STR_BUFFER_SIZE=文件大小
;错误码：
;			AX=0	DONE	04	File size got successfully.
;-----------------------------------------------------------
GET_FILE_SIZE		PROC
			MOV		AH,42H
			MOV		AL,0
			MOV		CX,0
			MOV		DX,0
			INT		21H
			MOV		FILE_HI,DX
			MOV		FILE_LO,AX

			MOV		AH,42H
			MOV		AL,2
			MOV		CX,0
			MOV		DX,0
			INT		21H
			
			SUB		DX,FILE_HI
			MOV		FILE_HI,DX

			SUB		AX,FILE_LO
			MOV		FILE_LO,AX

			MOV		STR_BUFFER_SIZE,AX

			PUSH	BX
			MOV		AH,48H
			MOV		BX,STR_BUFFER_SIZE
			INT		21H
			MOV		STR_BUFFER,AX

			MOV		AX,0

			POP		BX
			RET
GET_FILE_SIZE		ENDP

;-----------------------------------------------------------
;sub-program of get the content of the file
;功能：读取文件内容
;入口参数：
;			BX=文件句柄
;出口参数：成功：
;			CF=0
;		  失败：
;			CF=1
;			AX=系统错误码
;封装后出口参数：
;			AX=错误码
;			BUFFER_SIZE=文件内容地址
;错误码：
;			AX=0	DONE	05	File content got successfully.
;-----------------------------------------------------------
GET_FILE_CONTENT	PROC
			MOV		AH,42H
			MOV		CX,0
			MOV		DX,0
			MOV		AL,0
			INT		21H

			MOV		AH,3FH
			LEA		DX,STR_BUFFER
			MOV		CX,STR_BUFFER_SIZE
			INT		21H

			MOV		AX,0
			RET
GET_FILE_CONTENT	ENDP

;-----------------------------------------------------------
;sub-program of calculate the number of student
;功能：计算参与抽奖学生人数
;入口参数：
;			STR_BUFFER_SIZE=文件大小
;封装后出口参数：
;			STUD_NUM=总人数
;			AX=错误码
;错误码：
;			AX=0	DONE	06	Student number calculated successfully.
;-----------------------------------------------------------
STUD_NUM_CAL		PROC
			PUSH	AX
			PUSH	BX
			PUSH	CX
			PUSH	DX

			MOV		DX,0
			MOV		AX,STR_BUFFER_SIZE
			MOV		BL,9
			ADD		AX,2

			DIV		BL
			MOV		STUD_NUM,AL

			POP		DX
			POP		CX
			POP		BX
			POP		AX

			MOV		AX,0
			RET
STUD_NUM_CAL		ENDP

;-----------------------------------------------------------
;sub-program of generate a random number
;功能：利用系统时钟生成随机数
;入口参数：
;			STUD_NUM=总人数
;封装后出口参数：
;			RAND_NUM=随机数
;			AX=错误码
;错误码：
;			AX=0	DONE	07	Random number got successfully.
;-----------------------------------------------------------
RAND				PROC
			PUSH	CX
			PUSH	DX
			PUSH	BX
			PUSH	AX

			STI
			MOV		AH,0
			INT		1AH
			MOV		AX,DX
			AND		AH,3
			MOV		DL,STUD_NUM
			DIV		DL
			MOV		BL,AH
			INC		BL

			MOV		RAND_NUM,BL

			POP		AX
			POP		BX
			POP		DX
			POP		CX

			MOV		AX,0
			RET
RAND				ENDP

_CODE	ENDS
		END		MAIN_START
