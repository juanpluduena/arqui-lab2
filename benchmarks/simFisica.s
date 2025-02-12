.data
	N:       .dword 5	
	t_amb:   .dword 0   
	n_iter:  .dword 5    
	fc_temp: .dword 50
	fc_x:    .dword 2
	fc_y:    .dword 2
	
.bss 
	x: .zero  3072        
	x_temp: .zero  3072     

.text
	// START: 	habilitamos punto flotante en GDB
	MRS 	X9, CPACR_EL1 
	MOVZ 	X10, 0x0030, lsl #16
	ORR 	X9, X9, X10
	MSR 	CPACR_EL1, X9 		
	// END: 	habilitamos punto flotante en GDB

	.arch armv8-a
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB6:
	.cfi_startproc
	stp	x29, x30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	mov	x29, sp
	mov	x1, 0
	mov	x0, 0
	bl	m5_dump_stats

	// Calculo fc
	ldr     x0, N
	ldr     x1, fc_y
	mul x30, x1, x0
	ldr     x1, fc_x
	add x30, x30, x1
	// Termina Calculo fc

	ldr     x27, fc_temp
	ldr     x1, =x 
	ldr     x2, =x_temp
	ldr     x3, n_iter
	ldr     x4, t_amb
	SCVTF   D4, x4
	mul 	x18, x0, x0

	ldr     x0, N
    ldr     x1, =x 
    ldr     x2, =x_temp
    ldr     x3, n_iter
	ldr     x4, t_amb
	SCVTF   D4, x4
	mul 	x18, x0, x0

//---------------------- VARIABLES HERE ------------------------------------

N .req x0
t_amb .req D4 
x_temp .req x2 
x .req x1 
k .req x10
i .req x11
j .req x12
n_iter .req x3
iN .req x15
iNplusj .req x16
temp_calc .req x17
ftemp_calc .req D17
// 	x17 = ( i*N + j-1 )or( i*N + j+1 )or( (i+1)*N + j )or( (i-1)*N + j )
NN .req x18
xi .req x19
// x[i] = x + i
temp_ij .req x20
// i+1 or i-1 or j+1 or j-1 
ifStatus .req x21
// guardamos si se tomo el if o no para mantener la estructura lo mas parecido a c
fc .req x30
// temperatura de fuente de calor
SCVTF D27, x27
fc_temp .req D27
// x30 = fc_x*N+fc_y
sum .req D29

//---------------------- CODE HERE ------------------------------------

mov i , #0
mov xi , x
forInit:
	cmp i , NN	
	b.ge endInit

	stur t_amb , [xi]

	add xi, xi , 8
	add i, i , #1
	b forInit
endInit:

// Temperatura de fuente de calor
mov temp_calc, fc
lsl temp_calc, temp_calc, 3
add temp_calc, temp_calc, x
stur fc_temp, [temp_calc]

mov k , #0
fstLoop:

	cmp k , n_iter
	bge notFstLoop

	mov i , #0
	scdLoop:

		cmp i , N
		bge notScdLoop

		mov j , #0
		trdLoop:

			cmp j , N
			bge notTrdLoop

			mul iN , i , N
			add iNplusj , iN , j
			cmp iNplusj , fc
			beq inFC
				fmov sum, XZR

				//first if

				mov ifStatus , #0
				add temp_ij, i , #1 // (i+1)
				cmp temp_ij , N
				bge fstIfElse
					mov ifStatus , #1
					mul temp_calc , temp_ij, N // (i+1)*N
					add temp_calc , temp_calc, j // (i+1)*N + j
					lsl temp_calc , temp_calc, 3
					add temp_calc , temp_calc, x // x[(i+1)*N + j]
					ldur ftemp_calc , [temp_calc] // [x[(i+1)*N + j]]
					fadd sum , sum , ftemp_calc
				fstIfElse:
				cbnz ifStatus , endfirstIf
					fadd sum , sum , t_amb
				endfirstIf:

				//second if

				mov ifStatus , #0
				sub temp_ij, i , #1 // (i-1)
				cmp temp_ij , xzr
				blt sndIfElse
					mov ifStatus , #1
					mul temp_calc , temp_ij, N // (i-1)*N
					add temp_calc , temp_calc, j // (i-1)*N + j
					lsl temp_calc , temp_calc, 3
					add temp_calc , temp_calc, x // x[(i-1)*N + j]
					ldur ftemp_calc , [temp_calc] // [x[(i-1)*N + j]]
					fadd sum , sum , ftemp_calc
				sndIfElse:
				cbnz ifStatus , endSecondIf
					fadd sum , sum , t_amb
				endSecondIf:

				//third if

				mov ifStatus , #0
				add temp_ij, j , #1 // (j+1)
				cmp temp_ij , N
				bge trdIfElse
					mov ifStatus , #1
					mul temp_calc , i , N // (i)*N
					add temp_calc , temp_calc , temp_ij // i*N + (j+1)
					lsl temp_calc , temp_calc, 3
					add temp_calc , temp_calc , x // x[i*N + (j+1)]
					ldur ftemp_calc , [temp_calc] // [x[i*N + (j+1)]]
					fadd sum , sum , ftemp_calc
				trdIfElse:
				cbnz ifStatus , endThirdIf
					fadd sum , sum , t_amb
				endThirdIf:

				//four if

				mov ifStatus , #0
				sub temp_ij, j , #1 // (j-1)
				cmp temp_ij , xzr
				blt fthIfElse
					mov ifStatus , #1
					mul temp_calc , i , N // (i)*N
					add temp_calc , temp_calc , temp_ij // i*N + (j-1)
					lsl temp_calc , temp_calc, 3
					add temp_calc , temp_calc , x // x[i*N + (j-1)]
					ldur ftemp_calc , [temp_calc ]// [x[i*N - (j-1)]]
					fadd sum , sum , ftemp_calc
				fthIfElse:
				cbnz ifStatus , endFourthIf
					fadd sum , sum , t_amb
				endFourthIf:

				
				mul temp_calc , i , N 	// (i*N)
				add temp_calc , temp_calc , j  // (i*N + j)
				lsl temp_calc , temp_calc , 3 // (i*N + j)*8
				add temp_calc , temp_calc , x_temp // x_temp(i*N + j)
				fmov D28, 4.0
				fdiv sum , sum , D28 // sum/4
				stur sum , [temp_calc]

			inFC:  

			add j , j , #1
			b trdLoop
			notTrdLoop:
		add i , i , #1
		b scdLoop
		notScdLoop:

	mov i , #0
	mov xi , x
	saveFor:
		cmp i , NN	
		b.ge endSaveFor

		cmp i , fc
		beq notSave

		lsl temp_calc , i , 3	// i*8
		add temp_calc , temp_calc, x_temp // x_temp[i] 
		ldur ftemp_calc , [temp_calc] // [[x_temp[i]]]

		stur ftemp_calc, [xi]

		notSave:

		add i , i, #1
		add xi , xi, #8
		b saveFor
	endSaveFor:

add k , k , #1
b fstLoop
notFstLoop:

//---------------------- END CODE -------------------------------------

.unreq N
.unreq t_amb 
.unreq x_temp 
.unreq x 
.unreq k 
.unreq i 
.unreq j 
.unreq n_iter 
.unreq iN 
.unreq iNplusj 
.unreq temp_calc 
.unreq fc 
.unreq sum 


//---------------------- END VARIABLES ------------------------------------

	mov 	x0, 0
	mov 	x1, 0
	bl	m5_dump_stats
	mov	w0, 0
	ldp	x29, x30, [sp], 16
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE6:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
