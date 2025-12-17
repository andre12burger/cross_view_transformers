#!/bin/bash

# Script para treinar usando Docker (imagem já deve estar construída)
# Se a imagem não existir, execute primeiro: ./build_docker.sh

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Verificar se a imagem existe
if [[ "$(docker images -q cvt-rtx5090:latest 2> /dev/null)" == "" ]]; then
    echo "❌ Imagem cvt-rtx5090:latest não encontrada!"
    echo ""
    echo "Execute primeiro: ./build_docker.sh"
    echo ""
    exit 1
fi

echo "=== Iniciando treinamento CVT ==="
echo ""

docker run --rm \
    --gpus all \
    --shm-size=16g \
    -v "$SCRIPT_DIR:/workspace" \
    -v "$SCRIPT_DIR/datasets:/workspace/datasets" \
    -v "$SCRIPT_DIR/logs:/workspace/logs" \
    -v "$SCRIPT_DIR/outputs:/workspace/outputs" \
    -v "$SCRIPT_DIR/.cache:/root/.cache" \
    -v "/mnt/f16be684-4842-4b90-acc9-6565e6bd9d83/automni/dataset/nuscenes:/mnt/f16be684-4842-4b90-acc9-6565e6bd9d83/automni/dataset/nuscenes:ro" \
    -w /workspace \
    -e WANDB_API_KEY="c7ff04049d5cd781e688f17ab60ada654f9323e3" \
    -e PYTHONPATH=/workspace \
    cvt-rtx5090:latest \
    bash -c '
        echo "=== Instalando projeto (modo desenvolvimento) ===" && \
        pip install -e . && \
        echo "" && \
        echo "=== Verificando GPU ===" && \
        python -c "import torch; print(f\"PyTorch: {torch.__version__}\"); print(f\"CUDA: {torch.cuda.is_available()}\"); print(f\"GPU: {torch.cuda.get_device_name(0)}\"); print(f\"Compute: {torch.cuda.get_device_capability(0)}\")" && \
        echo "" && \
        echo "=== Iniciando treinamento ===" && \
        python scripts/train.py \
            +experiment=cvt_nuscenes_vehicle \
            data.dataset_dir=/workspace/datasets/nuscenes \
            data.labels_dir=/workspace/datasets/cvt_labels_nuscenes
    '

echo ""
echo "=== Treinamento concluído ==="
