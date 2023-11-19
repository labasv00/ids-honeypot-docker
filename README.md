# Detección de intrusiones
Práctica 2 para la asignatura de Sistemas Confiables


## Estructura del proyecto

El proyecto está dividido en cuatro directorios y un fichero docker-compose.

En el docker-compose encontraremos toda la información básica para levantar tanto los contenedores como las redes, sin ninguna configuración especial.

En cada uno de los directorios encontraremos la imagen de docker de cada uno de los dispositivos de la red (a excepción de la intranet, que se usa la misma imagen usa para dos dispositivos). Estos directorios contienen el script de entrada, el Dockerfile, ficheros de configuración o scripts que se han utilizado para realizar pruebas.

Podemos ver que hay cinco imágenes en total:
* `dmz`: La zona desmilitarizada. Contiene una honeypot solo expuesta a la red externa.
* `extranet`: los dispositivos externos a la red. No ve el servicio real de SSH de la DMZ, solo la honeypot.
* `fw`: el encaminador que actúa de cortafuegos. Cuenta con un detector de intrusiones (IDS) instalado.
* `intranet`: los dispositivos de la red interna. No juegan un papel relevante en esta práctica.

## Ejecución

Para iniciar los contenedores y ejecutarlos simplemente se deben ejecutar los siguientes comandos:
```bash
# Para levantar los contenedores
docker-compose up --build

# Entramos por SSH al firewall
docker-compose exec fw bash
```

## Imágenes

### DMZ
La zona desmilitarizada cuenta con lo siguiente:

* `Cowrie`: Una honeypot de SSH. Es un servicio trampa/señuelo que imita el comportamiento de SSH. Cowrie se trata de una honeypot de interacción alta, ya que permite una interacción rica con binarios y sistema de ficheros, simulación de usuarios, entre otros.
* `scripts`: contiene scripts de prueba. Hay algunos interesantes como *start_cowrie* o *install_cowrie*.
* `hosts`: un fichero que se añade al final de `/etc/hosts` para la resolución de nombres de la red, igual que en la anterior práctica.

Para instalar e iniciar Cowrie, contamos con un par de scripts. El de instalación corre a cargo de la descarga y configuración del programa. Una vez instalado, el programa arranca a través de *supervisor*.  Durante la instalación podemos ver algunos ajustes como la adición de un usuario a **userdb.txt**, o el cambio del hostname con sed. El script también prepara el entorno virtual de Python que sugieren las instrucciones de instalación oficiales.

En el script de arranque simplemente se cambia al directorio de Cowrie, se inicia el entorno virtual de Python y se arranca Cowrie. Esta instrucción se realiza a través de *supervisor*.

> Cabe destacar que la honeypot solo está expuesta a la extranet a través de una sencilla regla de iptables (redirigir el tráfico del puerto 22 al 2222 para ext). La red interna y el cortafuegos pordrán acceder al servicio de SSH real sin problema.

### Firewall

El firewall es el otro protagonista de esta práctica.

* `Snort`: Un sistema de detección de intrusiones
* `scripts`: contiene scripts de prueba. Hay algunos interesantes como *install_snort*.
* `hosts`: un fichero que se añade al final de `/etc/hosts` para la resolución de nombres de la red, igual que en la anterior práctica.
* `config`: contiene los ficheros de reglas de snort.

En el cortafuegos hemos instalado **Snort**, un sistema de detección/prevención de instrusiones (IDS/IPS) de código abierto. Nosotros lo configuraremos como IDS solamente. Este programa funciona a través de reglas que nosotros configuramos. Para hacer nuestra tarea más sencilla, Snort ofrece una serie de reglas de comunidad que añadiremos a modo de detección básica.

Por otro lado, en la carpeta `config` veremos dos ficheros `.rules`. 
* `dos.rules`: contiene las reglas para detectar una denegación de servicio (DOS) por **SYN** y **FIN** flood. Como aclaración, en el enunciado de la práctica se llama *SYN-flood* al ataque, pero el comando sugiere lanzar paquetes de FIN, así que lo bauticé *FIN-flood* y los separé en dos reglas.

    > Estas están configuradas para detectar inundiaciones de 1000 paquetes por segundo. Estos parámetros son ajustables.

* `all.rules`: es el fichero que importa finalmente Snort. Incluye las reglas de la comunidad y las de DOS propias. 
* Las **reglas de la comunidad** se descargan durante el proceso de instalación de Snort.

### Extranet

Cuenta con un puñado de scripts para realizar las pruebas y `hping` para la denegación de servicio.

### Intranet

Nada especialmente relevante.