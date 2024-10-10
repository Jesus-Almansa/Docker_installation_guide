# Usa la imagen base oficial de Python 3.12
FROM python:3.12-slim-bookworm

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /usr/src/app/workspace

# Actualiza los paquetes e instala Git y las dependencias necesarias para cv2
RUN apt-get update && apt-get install -y \
    curl \
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