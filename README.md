# Índice

1. [Introducción](#introducción)
2. [Linux](#linux)
   - [Configuración Inicial](#configuración-inicial)
   - [Instalación Limpia](#purgar-todo-lo-que-tengas-de-docker-para-hacer-una-instalación-limpia)
   - [Instalación de Docker desde el Repositorio APT](#instalación-de-docker-para-linux-usando-el-repositorio-apt)
   - [Instalación de Docker Compose](#instalación-de-docker-compose)
   - [Diferencias entre Dockerfile y Docker Compose](#diferencias-entre-dockerfile-y-docker-compose)
   - [Creación de un Entorno de Desarrollo con Docker](#creando-nuestro-entorno-de-desarrollo-en-contenedores-de-docker)
   - [Volúmenes persistentes](#volúmenes-persistentes)
3. [Windows](#windows)
   - [Instalación en Windows](#instalación-en-windows)
   - [Configuración de Docker Desktop](#configuración-de-docker-desktop)
   - [Clonación de Repositorios con Git](#clonación-de-repositorios-con-git)
4. [Adjuntar contenedor a Visual Studio](#adjuntar-contenedor-a-visual-studio)

---

# Introducción

Este repositorio tiene como objetivo documentar el proceso de configuración de un entorno de programación utilizando Docker y contenedores. La creación de un entorno de desarrollo aislado y reproducible es esencial para garantizar la estabilidad y portabilidad del código entre diferentes sistemas, eliminando problemas relacionados con dependencias, configuraciones y versiones específicas de software. Docker permite empaquetar todo el entorno, desde el sistema operativo hasta las bibliotecas y herramientas de desarrollo, en un contenedor que se puede ejecutar en cualquier máquina que tenga Docker instalado.

---

# Linux

Este tutorial ha sido verificado para las versiones de Ubuntu de la 20 a la 24.

## Instalación de Git y configuración Inicial

En primer lugar, para poder utilizar Git deberemos instalar la herramienta. Podemos hacerlo desde la terminal con el siguiente comando:

```bash
sudo apt install git
```

En segundo lugar configuramos las credenciales de Git:

```bash
git config --global user.name "usuario"
git config --global user.email "usuario@mail.com"
```

Para poder realizar una instalación exitosa de docker y todas sus herramientas está bien seguir el tutorial oficial que puedes encontrar en el siguiente enlace: [Docker for Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

De todas maneras aquí desglosamos exactamente paso a paso como se deber hacer.

## Purgar todo lo que tengas de docker para hacer una instalación limpia

```bash
 for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

Me ha pasado de intentar instalar Docker y que haya habido algún problema por el camino. Con este comando purgas todo lo relativo a la herramienta para poder empezar de cero.


#  Instalación de Docker para Linux usando el repositorio APT

En primer lugar se añade la GPG key oficial de Docker:

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```
### Añadir el repositorio a las APT sources:
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

### Instalar los paquetes de Docker

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Verificar que la instalación ha funcionado correctamente

```bash
 sudo docker run hello-world
```

Desde este momento debería funcionar sin problemas. Ahora instalaremos Docker Compose para orquestar contenedores. Será la herramienta con la que crearemos las imágenes y las levantaremos.

# Instalación de Docker Compose

De nuevo, el sitio oficial de docker ofrece información relativa a la instalación: [Overview of installing Docker Compose](https://docs.docker.com/compose/install/)

Dentro de este enlace nos vamos a dirigir directamente a la instalación única: [Install Compose standalone](https://docs.docker.com/compose/install/standalone/)

Con el siguiente comando descargamos e instalamos docker compose de una:

```bash
curl -SL https://github.com/docker/compose/releases/download/v2.29.6/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
```

Comprobamos la versión.

```bash
docker compose version
```
Importante a tener en cuenta, hay dos versiones de docker compose. 

Versión 1: docker-compose

Versión 2: docker compose

La última versión de esta herramienta no lleva guión. Esto es importante porque si usas la V2 como la que se ha instalado en esta guía, no te reconocerá los comandos si usas la versión con guión. Confusing, I know.

Para poder correr comandos de docker en la terminal sin tener que usar sudo ni ser super usuario hay que hacer lo siguiente:

```bash
sudo usermod -aG docker $USER
groups
```

Primero añadimos nuestro usuario a superusuarios y después comprobamos que se ha añadido correctamente.

Por último reiniciamos el pc para que se efectuen los cambios.

# Diferencias entre Dockerfile y Docker Compose

La principal diferencia entre un Dockerfile y Docker Compose radica en su propósito y en cómo se utilizan dentro del ecosistema de Docker.

1. Dockerfile:

Propósito: Es un archivo de texto que contiene las instrucciones para construir una imagen de Docker. Es el plano de cómo debe ser construida la imagen que luego se utilizará para crear contenedores.

Uso: Se utiliza para definir qué software, dependencias, configuración, y archivos se deben incluir en una imagen de Docker. Incluye comandos como FROM (para definir la imagen base), RUN (para ejecutar comandos durante la construcción de la imagen), y COPY (para copiar archivos desde tu máquina al contenedor).

Ejemplo:
```bash
FROM python:3.9
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```

Resultado: Genera una imagen que puede ser utilizada para crear contenedores con el comando docker run.

2. Docker Compose:

Propósito: Es una herramienta para definir y ejecutar aplicaciones multicontenedor. Permite orquestar la ejecución de múltiples contenedores que conforman una aplicación más compleja.

Uso: Se utiliza para configurar y correr múltiples servicios (contenedores) que pueden interactuar entre sí, como bases de datos, servidores web, aplicaciones backend, etc. El archivo docker-compose.yml permite definir qué contenedores correrán, cómo se conectarán entre ellos y cómo se manejarán volúmenes, redes, y variables de entorno.

Ejemplo:
```bash
version: '3'
services:
  web:
    build: .
    ports:
      - "5000:5000"
  redis:
    image: "redis:alpine"
```
Resultado: Crea y corre varios contenedores simultáneamente con el comando docker-compose up.

Diferencias clave:

Dockerfile: Se utiliza para construir una imagen de un solo servicio o aplicación.

Docker Compose: Se utiliza para orquestar múltiples contenedores que dependen entre sí y manejarlos de forma coordinada.

Ambos pueden usarse juntos: el Dockerfile para crear imágenes personalizadas y Docker Compose para correr esas imágenes junto con otros contenedores.


# Creando nuestro entorno de desarrollo en contenedores de Docker

Se ha creado la siguiente imagen de docker que tiene python 3.12

Usa la imagen base oficial de Python 3.12

```bash
# Usa la imagen base oficial de Python 3.12-slim-bookworm
FROM python:3.12-slim-bookworm

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /usr/src/app

# Actualiza los paquetes e instala Git y las dependencias necesarias para cv2
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 && \
    apt-get remove -y build-essential && apt-get autoremove -y && apt-get clean



# Instala las bibliotecas de Python que necesitas
RUN pip install --no-cache-dir \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    scikit-learn \
    scipy \
    opencv-python \
#    h5py \
#    tensorflow-gpu \
#    tensorflow \
#    torch \
#   torchvision \
#   keras \
    notebook \
    tqdm \
#    tensorboard \
    pillow


# Establece un comando por defecto para iniciar la shell de Python
CMD ["bash"]
```

¿Por qué se ha generado el directorio de trabajo en /usr/src/app?

La ruta /usr/src/app dentro del contenedor es una convención común utilizada en muchos contenedores Docker, especialmente cuando se trata de entornos de desarrollo y aplicaciones. Sin embargo, puedes usar cualquier otra ruta dentro del contenedor si prefieres algo más específico. Aquí te explico en más detalle por qué se utiliza y qué alternativas tienes.

1. Convención en contenedores de desarrollo:

Uso común: En muchos contenedores Docker oficiales (por ejemplo, para Python, Node.js, etc.), la carpeta de trabajo predeterminada es /usr/src/app. Esto es más una convención para mantener los entornos de contenedores organizados y consistentes. Siguiendo esta convención, cualquier código o aplicación que desarrolles dentro del contenedor estará ubicado en un lugar conocido y estándar.

Documentación y ejemplos: Muchas guías y documentación de Docker utilizan /usr/src/app como la ruta por defecto para almacenar código en contenedores de desarrollo, por lo que facilita seguir ejemplos y colaborar con otros desarrolladores.

2. Separación del sistema de archivos:

Estructura clara: Al usar una carpeta dentro de /usr/src/, mantienes el sistema de archivos del contenedor bien organizado y separado de otros directorios del sistema. Esto asegura que tu código esté en un lugar dedicado a la aplicación y no mezclado con archivos del sistema operativo del contenedor (por ejemplo, archivos de configuración del sistema en /etc o archivos binarios en /bin).

3. Seguridad y control:

Mejora en la administración de permisos: Al usar /usr/src/app (o un directorio en /usr/src/), tienes mayor control sobre los permisos y accesos. Los archivos en /home o rutas de sistema pueden tener permisos y configuraciones que compliquen la administración dentro del contenedor.

No sobreescribes partes críticas del sistema: Mantenerte en /usr/src/app reduce el riesgo de sobreescribir directorios importantes del contenedor si decides hacer bind mounts en rutas más sensibles (como /etc o /var).

4. Persistencia de datos en un contenedor:

Al montar /home/j/Documentos/Desarrollo en /usr/src/app, todos los cambios que realices en tu contenedor dentro de /usr/src/app se reflejarán directamente en tu directorio local /home/j/Documentos/Desarrollo. De este modo, tienes un enlace claro entre lo que ocurre en el contenedor y tu máquina local. Esta separación también hace que tu directorio local esté claramente organizado, ya que puedes tener distintos proyectos o aplicaciones en diferentes carpetas de tu sistema local.

Alternativas

Aunque /usr/src/app es una convención común, no estás obligado a usarla. Aquí te doy algunas alternativas:

/app:

Puedes usar /app como una ruta más corta. A veces se prefiere simplemente para ahorrar escritura o simplificar la estructura.

```bash
volumes:
   - /home/j/Documentos/Desarrollo:/app

/home/appuser/app:
```

Si quieres simular un entorno más parecido a lo que harías en tu máquina local, podrías crear un usuario dentro del contenedor (por ejemplo, appuser) y colocar el código en /home/appuser/app. Esto también proporciona un enfoque de permisos de usuario más seguro.

```bash
volumes:
   - /home/j/Documentos/Desarrollo:/home/appuser/app
```

Directorio personalizado:
Si prefieres una estructura totalmente personalizada, puedes utilizar cualquier otra ruta dentro del contenedor, por ejemplo:

```bash
volumes:
   - /home/j/Documentos/Desarrollo:/mnt/development
```

¿Qué debes considerar?

Al final, la decisión sobre qué ruta usar depende de:

Organización: Mantener el contenedor organizado y consistente con convenciones comunes.

Permisos: Algunas rutas en el contenedor podrían tener configuraciones de permisos que podrían afectar tu capacidad para leer/escribir archivos.

Facilidad de uso: Usar una ruta corta como /app o una personalizada puede hacer que sea más rápido acceder a los archivos.

Conclusión

Recomiendo /usr/src/app porque es una buena práctica ampliamente adoptada en la comunidad de Docker, pero no es obligatorio. Puedes cambiar esa ruta a algo que te sea más cómodo o que se ajuste mejor a tu estructura de trabajo, siempre que mantengas los permisos y la lógica de tu proyecto en mente.

# Creación el docker-compose.yml

Una vez tenemos el Dockerfile diseñado vamos a proceder a crear el docker-compose.yml.

```bash
version: '3'

services:
  DevEnvironment:
    build: .
    image: dev-environment
    container_name: python_dev_env
    volumes:
      - /home/j/Desarrollo/:/usr/src/app
    stdin_open: true  # Para habilitar la entrada interactiva (útil para shells)
    tty: true          # Asignar un terminal (útil para shells)
```

A continuación se realiza el buildeo de la imagen y después se levanta el contendedor:

```bash
docker compose build
docker compose up -d
```

Desde este momento tenemos el contenedor levantado y podemos abrirlo desde VSCode y trabajar en él. Desde este punto ya tenemos el entorno de desarrollo.


# Volúmenes persistentes


¿Cómo guardamos todo lo que hacemos en el contenedor? Ya que cada vez que se reinicia el contenedor o se para, este pierde todo lo que se haya generado en él a menos que usemos volúmenes persistentes.

¿Qué son los volúmenes en Docker?

Los volúmenes en Docker son una forma de persistir datos generados o utilizados por los contenedores. Cuando el contenedor se detiene o se elimina, los datos dentro del contenedor normalmente desaparecen. Sin embargo, los volúmenes permiten que estos datos persistan fuera del ciclo de vida del contenedor. En tu caso, los volúmenes están pensados para que cualquier cambio hecho en el directorio dentro del contenedor (por ejemplo, donde se guarda tu archivo de Python) sea reflejado en tu sistema de archivos local y viceversa.

Tipos de Volúmenes

Volúmenes anónimos: Docker los crea automáticamente sin necesidad de especificar un nombre o ruta. Se eliminan cuando el contenedor se elimina.

Volúmenes nombrados: Volúmenes gestionados por Docker pero que persisten incluso después de eliminar el contenedor, y pueden ser reutilizados por diferentes contenedores.

Montajes de carpetas (bind mounts): Permiten vincular un directorio o archivo del host (tu máquina) con un directorio dentro del contenedor. Esto es lo que estás intentando hacer al enlazar /home/j/Documentos/Desarrollo con el directorio de trabajo dentro del contenedor.

Tu caso: Volumen persistente (bind mount)

En tu archivo docker-compose.yml, especificaste un volumen con un bind mount:

```bash
volumes:
  - /home/j/Documentos/Desarrollo:/usr/src/app
```
Esto debería vincular tu carpeta local /home/j/Documentos/Desarrollo con el directorio /usr/src/app dentro del contenedor. En otras palabras:

Si creas un archivo dentro del contenedor en /usr/src/app, debería aparecer en /home/j/Documentos/Desarrollo de tu máquina.

Si agregas algo a /home/j/Documentos/Desarrollo en tu máquina, debería aparecer en /usr/src/app dentro del contenedor.


# Guia para instalar Docker en Linux, concretamente en Windows

Necesitaremos tener instalado git para poder clonar repositorios y utilizar la terminal de bash.

[Git Download site](https://git-scm.com/downloads/win)

Para que funciones Docker en nuestro equipo con Windows necesitaremos instalar el ejecutable que podemos conseguir en la página oficial. Lo más sencillo sin duda alguna es instalar Docker Desktop que viene con Docker Engine y Docker Compose preinstalado.

[Docker Desktop exe](https://docs.docker.com/desktop/install/windows-install/)

Con estos dos programas instalados ya podemos funcionar sin problemas usando la terminal de Git. Para todo lo demás es igual.

# Adjuntar contenedor a Visual Studio

Para ello necesitaremos tener instalada la extensión de Docker en Visual Studio. Una vez tenemos la imagen buildead y corriendo podemos ir a la pestaña de esta extensión, darle a click derecho sobre el contenedor que está corriendo y adjuntar a Visual Studio. De esta manera podremos tener una sesión de vscode dentro del contenedor para poder trabajar.