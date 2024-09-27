# Usa la imagen base oficial de Python 3.12
FROM python:3.12-slim

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /usr/src/app

# Actualiza los paquetes e instala Git y las dependencias necesarias para cv2
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0

# Instala las bibliotecas de Python que necesitas
RUN pip install --no-cache-dir numpy pandas matplotlib scikit-image opencv-python jupyter

# Establece un comando por defecto para iniciar la shell de Python
CMD ["bash"]