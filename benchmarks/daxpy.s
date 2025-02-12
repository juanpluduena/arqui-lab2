	.data
	N:       .dword 4096	// Number of elements in the vectors
	Alpha:   .dword 2      // scalar value
	
	.bss 
	X: .zero  32768        // vector X(4096)*8
	Y: .zero  32768        // Vector Y(4096)*8
        Z: .zero  32768        // Vector Y(4096)*8

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

	ldr     x0, N
    	ldr     x10, Alpha // saque el = porque no andaba
    	ldr     x2, =X
    	ldr     x3, =Y
	ldr     x4, =Z

//---------------------- CODE HERE ------------------------------------

	lsl 	X20, X0, #3			// X20 = N*8
	mov 	X5, #0 				// X5 = i = 0
	SCVTF 	D10, X10 			// Convert signed 64-bit integer in X10 to double-precision scalar in D4

loop:

	add 	X6, X2, X5
	ldur 	D11, [X6, #0]     	// X11 = X[i]
	
	add 	X6, X3, X5
	ldur 	D12, [X6, #0]     	// X12 = Y[i]

	fmul 	D13, D11, D10     	// X13 = X[i] * Alpha
	fadd 	D14, D13, D12     	// X10 = X[i] * Alpha + Y[i]

	add 	X6, X4, X5
	stur 	D14, [X6, #0]     	// Z[i] = X10

	add 	X5, X5, 8         	// i + 8

	cmp 	X5, X20            	// i = (N*8) ? goto loop 
	bne 	loop         

//---------------------- END CODE -------------------------------------

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
