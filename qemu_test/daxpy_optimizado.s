.data
	N:       .dword 16	// Number of elements in the vectors
	Alpha:   .dword 2   // scalar value
	
.bss 
	X: .zero 128 // vector X(4096)*8
	Y: .zero 128 // Vector Y(4096)*8
  	Z: .zero 128 // Vector Y(4096)*8
	
.text

	// START: 	habilitamos punto flotante en GDB
	MRS 	X9, CPACR_EL1 
	MOVZ 	X10, 0x0030, lsl #16
	ORR 	X9, X9, X10
	MSR 	CPACR_EL1, X9 		
	// END: 	habilitamos punto flotante en GDB

	ldr     X0, N
	ldr     X10, Alpha		
	ldr     X2, =X
	ldr     X3, =Y
	ldr     X4, =Z

// ------------------------- INIT START ------------------------------
	
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

// ------------------------- CODE START ------------------------------

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

// ------------------------- CODE END --------------------------------

infloop: B infloop