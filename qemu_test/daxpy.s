.data
	N:       .dword 16	// Number of elements in the vectors
	Alpha:   .dword 2   // scalar value
	
.bss 
	X: .zero 32768 // vector X(4096)*8
	Y: .zero 32768 // Vector Y(4096)*8
  	Z: .zero 32768 // Vector Y(4096)*8
	

	
.text

	// START: 	habilitamos punto flotante en GDB
	MRS 	X9, CPACR_EL1 
	MOVZ 	X10, 0x0030, lsl #16
	ORR 	X9, X9, X10
	MSR 	CPACR_EL1, X9 		
	// END: 	habilitamos punto flotante en GDB

	// START: 	habilitamos punto flotante en GDB
	ldr     X0, N
	ldr     X10, Alpha		
	ldr     X2, =X
	ldr     X3, =Y
	ldr     X4, =Z

// ------------------------- INIT START ------------------------------
/* 
	fmov 	D6, 19.0 // Valores de inicializacion de X e Y
	fmov 	D8, 1.0
	mov 	x5, x2    // Inicializacion de los iteradores sobre X e Y
	mov 	x9, x3
	lsl 	x7, x0, 3  // Limite superior para el arreglo X
	add 	x7, x2, x7 // Se usa en la guarda de abajo 

initloop:	
	stur 	D6, [x5, #0] 
	stur 	D8, [x9, #0] 
	add 	x5, x5, #8
	add 	x9, x9, #8
	cmp 	x5, x7
	b.ne 	initloop
 */

// ------------------------- CODE START ------------------------------

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

// ------------------------- CODE END --------------------------------

infloop: B infloop
