.data
	N:       .dword 4096	// Number of elements in the vectors
	Alpha:   .dword 2   	// scalar value
	
.bss 
	X: .zero 32768 // vector X(4096)*8
	Y: .zero 32768 // Vector Y(4096)*8
  	Z: .zero 32768 // Vector Y(4096)*8
	
	.arch 	armv8-a
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB6:
	.cfi_startproc
	stp		X29, X30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	mov		X29, sp
	mov		X1, 0
	mov		X0, 0
	bl		m5_dump_stats

	ldr     X0, N
	ldr     X10, Alpha 	// saque el = porque no andaba
	ldr     X2, =X
	ldr     X3, =Y
	ldr     X4, =Z

//---------------------- CODE HERE ------------------------------------
	lsl 	X20, X0, #3			// X20 = N*8
	mov 	X5, #0 				// X5 = i = 0
	SCVTF 	D29, X10 			// Convert signed 64-bit integer in X10 to double-precision scalar in D4
loop:

	add 	X6, X2, X5
	add 	X7, X3, X5
	add 	X8, X4, X5
    
	ldur 	D1,  [X6, #0]
	ldur 	D2,  [X6, #8]
	ldur 	D3,  [X6, #16]
	ldur 	D4,  [X6, #24]
	ldur 	D5,  [X6, #32]
	ldur 	D6,  [X6, #40]
	ldur 	D7,  [X6, #48]
	ldur 	D8,  [X6, #56]
	
	ldur 	D12, [X7, #0]
	ldur 	D13, [X7, #8]
	ldur 	D14, [X7, #16]
	ldur 	D15, [X7, #24]
	ldur 	D16, [X7, #32]
	ldur 	D17, [X7, #40]
	ldur 	D18, [X7, #48]
	ldur 	D19, [X7, #56]
	
	fmul 	D1, D1, D29     	// X13 = X[i] * Alpha
	fadd 	D1, D1, D12     	// X10 = X[i] * Alpha + Y[i]
	
	fmul 	D2, D2, D29     	// X13 = X[i] * Alpha
	fadd 	D2, D2, D13     	// X10 = X[i] * Alpha + Y[i]
	
	fmul 	D3, D3, D29     	// X13 = X[i] * Alpha
	fadd 	D3, D3, D14     	// X10 = X[i] * Alpha + Y[i]
	
	fmul 	D4, D4, D29     	// X13 = X[i] * Alpha
	fadd 	D4, D4, D15     	// X10 = X[i] * Alpha + Y[i]
	
	fmul 	D5, D5, D29     	// X13 = X[i] * Alpha
	fadd 	D5, D5, D16     	// X10 = X[i] * Alpha + Y[i]
	
	fmul 	D6, D6, D29     	// X13 = X[i] * Alpha
	fadd 	D6, D6, D17     	// X10 = X[i] * Alpha + Y[i]
	
	fmul 	D7, D7, D29     	// X13 = X[i] * Alpha
	fadd 	D7, D7, D18     	// X10 = X[i] * Alpha + Y[i]
	
	fmul 	D8, D8, D29     	// X13 = X[i] * Alpha
	fadd 	D8, D8, D19     	// X10 = X[i] * Alpha + Y[i]
	
	
	stur 	D1, [X8, #0]
	stur 	D2, [X8, #8]
	stur 	D3, [X8, #16]
	stur 	D4, [X8, #24]
	stur 	D5, [X8, #32]
	stur 	D6, [X8, #40]
	stur 	D7, [X8, #48]
	stur 	D8, [X8, #56]
	
	add 	X5, X5, #64         	// i + 8

	cmp 	X5, X20            	// i = (N*8) ? goto loop 
    bne 	loop     

//---------------------- END CODE -------------------------------------

	mov 	X0, 0
	mov 	X1, 0
	bl		m5_dump_stats
	mov		w0, 0
	ldp		X29, X30, [sp], 16
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE6:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0"
	.section	.note.GNU-stack,"",@progbits