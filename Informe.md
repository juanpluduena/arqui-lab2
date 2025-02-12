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

### Código optimizado vs no optimizado

En esta parte, vamos a comparar como un código optimizado puede tener un impacto significativo en el rendimiento de un microprocesador.  
Para lograr esto, se usó el metodo de loop unrolling con un factor de 8 que se puede ver en [daxpy_optimizado.s](/benchmarks/daxpy_optimizado.s).

Lo que se buscaba con esta optimización que se ejecutó en un procesador de `32kB` de memoria caché de datos y 2 vías, era conseguir resultados parecidos a los de `32kB` con 1 vía en el cuál se corrió un código no optimizado, por lo que los gráficos están basados en esa comparación.

Gŕafico comparativo:
![ej1e](/assets/ej1e.png "ej1e")

En el gráfico vemos un menor número de ciclos, lo que significa que se mejoro la eficiencia del procesamiento, reduciendo el tiempo total de ejecución. También vemos que los hits a la caché aumentaron con respecto al código no optimizado, esto significa que hay menos accesos a la memoria principal mejorando así el rendimiento. Por último vemos como la versión optimizada tiene más ciclos ociosos, esto debido a una mejor utilización de la caché, lo que reduce los tiempos de espera por accesos a memoria, permitiendo que el procesador pase más tiempo inactivo en lugar de estar ocupado esperando datos.

___

### In-order vs out-of-order

En esta parte vamos a comparar el rendimiento de un procesador **in-order**, que ejecuta las instrucciones en el mismo orden en que aparecen en el código, y un procesador **out-of-order**, que puede reordenarlas dinámicamente para optimizar el uso de sus unidades de ejecución y minimizar latencias.

Gráfico comparativo:
![ej1f](/assets/ej1f.png "ej1f")

En el gráfico se ve una clara diferencia en el número de ciclos, siendo muchísimo menor en el procesador out-of-order. Lo que resulta inesperado de este gráfico es la menor cantidad de hits a la caché por parte del procesador out-of-order, lo que se ve reflejado en la cantidad de ciclos ociosos, por lo que podemos concluir que el procesador out-of-order se pasa mucho tiempo activo accediendo a la memoria principal.

## Ejercicio 2

En el ejercicio 2 vamos a usar un programa que simula el flujo de calor en una placa de un material uniforme. Como en el ejercicio anterior, tenemos que escribir un programa no optimizado en código assembler, tal y como está en [simFisica.s](/benchmarks/simFisica.s).

Lo primero que vamos a evaluar es el rendimiento del procesador utilizando diferentes cachés asociativas de 1 vía, 2 vías, 4 vías y 8 vías. El gráfico obtenido luego de realizar las simulaciones es el siguiente:

![ej2c](/assets/ej2c.png "ej2c")

Como se puede ver en el gráfico, el rendimiento no cambia al variar las vías de la caché. Esto sucede porque los accesos a memoria en el código son secuenciales y predecibles, lo que permite que la caché los maneje de manera eficiente. Cada array (x y x_temp) ocupa 3 KB (3072 bytes), por lo que incluso juntos (6 KB) caben cómodamente en una caché de 32 KB. Entonces podemos concluir que aumentando las vías no podemos mejorar el rendimiento. Tal vez el rendimiento se vea afectado si decidimos cambiar el tamaño de las matrices.

---

### Predictor Local vs Predictor Torneos

El siguiente paso es comparar el rendimiento basado en el tipo de predictor. Para este gráfico usamos la métrica **Miss Rate** porque queremos evaluar la efectividad de los predictores de saltos. El **Miss Rate** nos indica qué porcentaje de predicciones de saltos fueron incorrectas respecto al total de decisiones de salto tomadas.  
Para estos tests, vamos a comparar el rendimiento entre un procesador _in-order con predictor local_, _in-order con predictor torneos_ y _out-of-order con predictor torneos_. Todos con caché de 32kB y 2 vías.

![ej2e](/assets/ej2e.png "ej2e")

El gráfico muestra que el predictor torneos tiene un mejor desempeño que el predictor local, reduciendo la tasa de fallos de predicción de saltos. Esto era esperable, ya que el predictor torneos combina un predictor local y uno global, eligiendo dinámicamente cuál usar en función del historial de aciertos.

Al utilizar un procesador out-of-order con el predictor torneos, la tasa de fallos sube ligeramente. Esto podría deberse a que el reordenamiento de instrucciones altera el patrón de ejecución de los saltos, afectando la precisión del predictor. Sin embargo, el impacto sigue siendo menor en comparación con el predictor local.
