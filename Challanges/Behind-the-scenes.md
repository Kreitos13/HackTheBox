- https://medium.com/@polygonben/behind-the-scenes-htb-reverse-engineering-b1c0c13d9ab3
- https://www.youtube.com/watch?v=O9vNPp2k6Jo

# COMANDOS
---------------
- *file* behidthescenes
	- https://serverfault.com/questions/730922/how-can-i-get-information-about-a-binary-file-that-wont-execute
	- ELF 64-bit LSB![[2024-02-14  12-32-25.png]]
- *strings* behidthescenes
	- ./challenge `<password>`
	- strncmp -> comprueba la contraseña con la flag
	- strlen -> comprueba la longitud de la contraseña
	- ![[2024-02-14  12-37-43.png]]
- *strace* ./behindthescenes
	- Intenta llamar funciones![[2024-02-14  12-40-05.png]]
	- ![[2024-02-14  12-43-25.png]]
- *ltrace* ./behindthescenes password
	- https://stackoverflow.com/questions/18410344/program-received-signal-sigill-illegal-instruction
	- ud2a y ud2  
	- ![[2024-02-14  12-40-54.png]]
- *hexeditor* behindthescenes
	- ![[2024-02-14  12-55-20.png]]
	- ![[2024-02-14  13-01-13.png]]
- *xxd* behindthescenes
	- ![[2024-02-14  13-35-46.png]]
- `HTB{Itz_0nLy_UD2}`
# Info
-----------
Se trata de un desafió en el que se requiere hacer ingeniería inversa a un programa que requiere una contraseña para poder funcionar. Si hacemos un `file` al programa, vemos que se trata de una arquitectura 
- *ELF 64-bit LSB*: describe un archivo ejecutable de 64 bits en formato ELF con orden de bytes LSB. Esto significa que el archivo está diseñado para ser ejecutado en sistemas operativos de 64 bits con arquitectura x86 o compatible. 
	- *ELF* - Executable and Linkable Format 
	- *LSV* - Least Significant Byte
Procedemos con el comando `strings` que nos muestra que que esta utilizando la bibilioteca *libc.so.6* que es una biblioteca estándar en *C*. Tambien hay nombres de funciones de la biblioteca, como *puts, printf, strlen, memset*. Se utiliza *strlen* para comparar la longitud de una cadena y *strncmp* para comparar cadenas. *GLIBC_X* son etiquetas de versión. Lo destacable que podemos sacar de aquí es que está intentando leer una cadena y procesarla para compararla con otra. 

A continuación con el comando `strace` muestra las llamadas al sistema realizadas por el programa *behindthescenes* durante su ejecución, incluyendo la carga de bibliotecas compartidas y la asignación de memoria. El programa se ejecuta correctamente y procesa una acceso al sistema pero no lo lleva a cabo por que el archivo no existe, luego abre diferentes bibliotecas necesarias.

Si ejecutamos el programa directamente nos muestra un output que indica que debe ser ejecutado con una contraseña `./challenge <password>`. Por lo tanto las funciones anteriores están intentando comparar la contraseña introducida con la que está guardada en el sistema. Por lo tanto utilizamos el comando `ltrace` para rastrear las llamadas a la funciones de las bibliotecas. El programa se interrumpe 3 veces con *SIGILL* lo que indica que encontró una instrucción no válida en la ejecución del programa.
 
Con búsquedas exhaustivas me lleva a la conclusión de que es un problema de la instrucción *UD2* que se utiliza para indicar un error o una situación inesperada en el código, y su presencia en el output de depuración sugiere que se ha alcanzado un estado no válido en la ejecución del programa. Por eso el programa se interrumpe y no llega a ejecutarse por completo.

Haciendo una depuración con `hexeditor` para ver la resolución del código binario o directamente con `xxd` podemos ver que donde se esta ejecutando el programa con la contraseña, hay una cadena que compara la contraseña con la que se introduce para acceder a la función. Y cuando se introduce la contraseña correcta imprime por consola un resultado. En este caso la contraseña es **Itz_0nLy_UD2** que si la introducimos con el programa de esta manera `./behindthescenes Itz_0nLy_UD2` nos saca la flag que necesitamos introducir en *Hack The Box*.

---------
##### 🚩 HTB{Itz_0nLy_UD2}