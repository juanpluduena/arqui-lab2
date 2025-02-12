# Arquitectura de Computadoras - 2024
## Informe Lab2:  Análisis de microarquitecturas

El objetivo de este laboratorio es analizar cómo impactan en la performance de un microprocesador variaciones en
los tamaños y características de caché y predictores de saltos.

**Integrantes:**

 - Juan Pablo Ludueña Zakka


## Ejercicio 1

En el ejercicio 1 utilizamos el algoritmo `daxpy` para testear como nuestro procesador se comporta en diferentes configuraciones.  
El código consiste en una implementación nuestra realizada en código assembler y sin ningún tipo de optimización.  

Código en C:
```c
const int N;

double X[N], Y[N], Z[N], alpha;

for (int i = 0; i < N; ++i) {
    Z[i] = alpha * X[i] + Y[i];
}
```

Código assembler:
```assembly
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
```

En el primer caso, el microprocesador va a tener variaciones en el tamaño de su memoria caché de datos y también en la cantidad de asociaciones (vías).

El siguiente gráfico es el resultado de correr el algoritmo mencionado en las diferentes configuraciones:

![ej1d](/assets/ej1d.png "ej1d")

Lo que este gráfico demuestra es en las configuraciones de `8kB`, `16kB` y `32kB` con 1 vía, los hits son muy bajos, lo que significa un alto número de fallos de caché. El número de ciclos es relativamente alto, ya que los accesos a memoria principal son más frecuentes.  

Por otra parte, cuando aumentamos la asociatividad a 2 vías, los hits suben y los ciclos bajan, o sea que menos accesos a la memoria principal están ocurriendo, mejorando así el rendimiento.

Cuando llegamos a 4 y 8 vías, vemos que sus métricas son exactamente iguales, con hits altos pero ciclos muy elevados. Esto puede indicar que se está gastanto más tiempo manejando la caché.

Los datos con los valores exactos se encuentran en este [archivo](/ej1/ej1d.txt).

___