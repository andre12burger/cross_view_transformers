# Dockerfile para Cross-View Transformers com suporte RTX 5090
FROM pytorch/pytorch:2.8.0-cuda12.9-cudnn9-devel

# Configurar variáveis de ambiente
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    vim \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Downgrade pip para suportar pytorch-lightning 1.6.2
RUN pip install pip==24.0

# Instalar TODAS as dependências Python na imagem (para não reinstalar toda vez)
RUN pip install --no-cache-dir \
    hydra-core==1.3.2 \
    omegaconf \
    pytorch-lightning==2.0.0 \
    torchmetrics \
    einops \
    fvcore \
    efficientnet-pytorch \
    nuscenes-devkit \
    wandb \
    albumentations \
    opencv-python-headless \
    scikit-image \
    matplotlib \
    Pillow \
    pyquaternion \
    tqdm \
    imgaug

# Pré-baixar pesos do EfficientNet-B4 para evitar download durante treinamento
RUN python -c "import torch; \
    from efficientnet_pytorch import EfficientNet; \
    model = EfficientNet.from_pretrained('efficientnet-b4'); \
    print('EfficientNet-B4 weights downloaded successfully')"

# Criar diretório de trabalho
WORKDIR /workspace

# Comando padrão
CMD ["/bin/bash"]
