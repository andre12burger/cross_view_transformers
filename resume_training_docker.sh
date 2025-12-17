#!/bin/bash

# Script para retomar treinamento a partir de um checkpoint usando Docker

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

# Parâmetro: UUID do experimento (obrigatório)
if [ -z "$1" ]; then
    echo "❌ Erro: UUID do experimento não especificado"
    echo ""
    echo "Uso: $0 <UUID_DO_EXPERIMENTO>"
    echo ""
    echo "Experimentos disponíveis:"
    ls -1 logs/cross_view_transformers_test/ 2>/dev/null || echo "  Nenhum experimento encontrado"
    echo ""
    exit 1
fi

EXPERIMENT_UUID="$1"
CHECKPOINT_DIR="logs/cross_view_transformers_test/${EXPERIMENT_UUID}/checkpoints"

# Verificar se o checkpoint existe
if [ ! -d "$CHECKPOINT_DIR" ]; then
    echo "❌ Diretório de checkpoint não encontrado: $CHECKPOINT_DIR"
    echo ""
    echo "Experimentos disponíveis:"
    ls -1 logs/cross_view_transformers_test/ 2>/dev/null || echo "  Nenhum experimento encontrado"
    echo ""
    exit 1
fi

# Listar checkpoints disponíveis
echo "=== Checkpoints encontrados ==="
ls -lh "$CHECKPOINT_DIR"
echo ""

echo "=== Retomando treinamento do experimento: $EXPERIMENT_UUID ==="
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
        echo "=== Retomando treinamento do checkpoint ===" && \
        python scripts/train.py \
            +experiment=cvt_nuscenes_vehicle \
            data.dataset_dir=/workspace/datasets/nuscenes \
            data.labels_dir=/workspace/datasets/cvt_labels_nuscenes \
            experiment.uuid=\"'"$EXPERIMENT_UUID"'\"
    '

echo ""
echo "=== Treinamento concluído ==="
