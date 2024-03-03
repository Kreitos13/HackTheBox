# LITTER
<img src="ANEXOS/Litter/2024-03-03  03-42-05.png">

Khalid acaba de iniciar sesión en un host que él y su equipo usan como anfitrión de pruebas para muchos propósitos diferentes, está fuera de su red corporativa, pero tiene acceso a muchos recursos en la red. El anfitrión se utiliza como vertedero para muchas personas en la empresa, pero es muy útil, por lo que nadie ha planteado ningún problema. Poco sabe Khalid; la máquina ha sido comprometida y la información de la compañía que no debería haber estado allí ahora ha sido robada - depende de usted para averiguar lo que ha sucedido y qué datos se han tomado.
- `litter.zip` 
- `hacktheblue`

# Reconocimiento
- *.pcap* -> Packet Capture es un protocolo de captura de paquetes utilizado en redes informáticas, contiene datos de red capturados como tráfico de red, paquetes enviados y recibidos, información de protocolos...
- `file suspicious_traffic.pcap`
<img src="ANEXOS/Litter/2024-03-02  16-31-51.png">
- `strings suspicious_traffic.pcap > strings.txt`

# Task 1
#### At a glance, what protocol seems to be suspect in this attack?
##### Solución: DNS

- `tshark -r suspicious_traffic.pcap -qz io,phs`
<img src="ANEXOS/Litter/2024-03-02  17-03-17 1.png">
- Abrir el archivo con Wireshark: File -> open -> archivo
<img src="ANEXOS/Litter/2024-03-02  17-09-08.png">

# Task 2
#### There seems to be a lot of traffic between our host and another, what is the IP address of the suspect host?
##### Solución: 192.168.157.145

Utilizamos varios filtros para analizar las diferentes IPs:
- `dhcp && ip.addr == 192.168.157.145`
- `dns.id == 0x20f8`
- `ip.src != 192.168.0.1 and ip.dst != 192.168.0.1`
- `ip.addr == 192.168.157.145`
La dirección `192.168.157.145` está intentando descargar desde la IP `192.168.157.254` por el protocolo DHCP diferentes archivos entre los que destacan:
- *CNAME (Canonical Name)*: se utiliza para crear alias de un nombre de dominio a otro nombre de dominio, esto permite que un dominio tenga multiples nombres que se resuelva a la misma dirección IP.
- *MX (Mail Exchange)*: se utiliza para especificar el servidor de correo electrónico responsable de recibir los correos electrónicos a un dominio especifico. Sirve para redirigir el correo al servidor correspondiente y define los servidores por orden de preferencia
- El robo de registros CNAME y MX puede ser utilizado por un atacante como parte de un amplio espectro de ataques, que van desde el phishing y la suplantación de identidad hasta ataques dirigidos a la infraestructura de correo electrónico. 
<img src="ANEXOS/Litter/2024-03-02  18-01-48.png">

# Task 3
#### What is the first command the attacker sends to the client?
##### Solución: whoami

- Para buscar los comandos que un atacante envía hay que ver toda la conversación de la sesión UDP que tuvo lugar entre los paquetes UDP, para esto se utiliza la función `Follow -> UDP Stream` para mostrar todos los paquetes.
<img src="ANEXOS/Litter/2024-03-02  23-31-02.png">
- Una vez echo esto hay que buscar el las cadenas hexadecimales y pasarlas a texto plano mediante el comando:
	- `echo -e "$(echo '<cadena en HEX>' | xxd -r -p)"`
<img src="ANEXOS/Litter/2024-03-02  23-30-26.png">
- Paquete: 
	- `13938	261.197094	192.168.157.144	192.168.157.145	DNS	208	Standard query 0x650c TXT 1eca012ec7305cb1f877686f616d690a6465736b746f702d756d6e636265.375c746573740d0a0d0a433a5c55736572735c746573745c446f776e6c6f.6164733e.microsofto365.com`

# Task 4
#### What is the version of the DNS tunneling tool the attacker is using?
##### Solución: 0.07

Para esta parte, hay que copiar todo el contenido del fichero Follow UDP Stream y añadirla a CyberChef para pasarlo de Hex a texto legible y guardar el fichero en nuestra máquina. Hay que tener en cuenta que el fichero se guarda en formato binario. 
<img src="ANEXOS/Litter/2024-03-03  00-59-45.png">
Una vez en nuestro sistema podemos listar las frases legibles con el comando:
- `strings followUDP.dat`
<img src="ANEXOS/Litter/2024-03-03  00-58-40.png">

# Task 5
#### The attackers attempts to rename the tool they accidentally left on the clients host. What do they name it to?
##### Solución: win-installer.exe

Para esta parte hay que buscar el comando `ren` que es el que se utiliza en Windows para renombrar archivos, ademas hay una secuencia en la que intenta cambiar o modificar un archivo.zip ya que aparecen fechas de modificación, ademas hay una cadena en la que aparece el texto win-install.exe después de un `ren` aunque la decodificación del archivo parece bastante corrupta y no se puede distinguir del todo.
- Hay que volver a seleccionar todo el output de `Follow UDP Stream` y pasarlo por CyberChef, guardarlo en un archivo.dat y utilizar el siguiente comando:
	- `strings allFollowUDPStream.dat | grep ren`
<img src="ANEXOS/Litter/2024-03-03  02-48-20.png">

# Task 6
#### The attacker attempts to enumerate the users cloud storage. How many files do they locate in their cloud storage directory?
##### Solución: 0

El almacenamiento en la nube de los usuarios se encuentra en el directorio OneDrive, pero al intentar entrar 2 veces en el directorio, el atacante no ha logrado listar ningún tipo de archivo. Se ha utilizado el comando:
- `strings allFollowUDPStream.dat | grep -i -A 3 -B 3 "onedrive"`
<img src="ANEXOS/Litter/2024-03-03  02-50-51.png">

# Task 7
#### What is the full location of the PII file that was stolen?
##### Solución: C:\\Users\\test\\Documents\\client data optimisation\\user details.csv

Si miramos al final de las conexiones encontraremos una serie de intentos de entrar al directorio *C:\Users\test\Documents\client data optimisation>* donde hay un archivo *user details.csv* que es un archivo que contiene detalles de datos tabulares para ser accedido fácilmente desde una hoja de calculo, en este caso contiene los detalles de los usuarios. Los archivos PII (Personal Identifiable Information) son archivos que contiene información para identificar de manera única a una persona.
<img src="ANEXOS/Litter/2024-03-03  02-56-28.png">
<img src="ANEXOS/Litter/2024-03-03  03-12-57.png">

# Task 8
#### Exactly how many customer PII records were stolen?
##### Solución: 721

Si Analizamos desde el momento en que el atacante entra en el directorio donde se encuentra el archivo PII, veremos que lista los datos de todos los usuarios comenzando por su número de identificación único que en este caso empieza en 0. En este caso 0 sería el primer usuario.
<img src="ANEXOS/Litter/2024-03-03  03-18-28.png">
Haciendo scroll y listando todos los usuarios vemos que el último es el identificador 720. Por lo tanto hay un total de 721 registros de datos de usuarios.
<img src="ANEXOS/Litter/2024-03-03  03-23-02.png">
