#!/bin/bash

# Script para entrar no container Docker interativamente

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Iniciando container Docker interativo..."

docker run -it --rm \
    --gpus all \
    --shm-size=16g \
    -v "$SCRIPT_DIR:/workspace" \
    -v "$SCRIPT_DIR/datasets:/workspace/datasets" \
    -v "$SCRIPT_DIR/logs:/workspace/logs" \
    -v "$SCRIPT_DIR/outputs:/workspace/outputs" \
    -w /workspace \
    -e WANDB_API_KEY="c7ff04049d5cd781e688f17ab60ada654f9323e3" \
    -e PYTHONPATH=/workspace \
    cvt-rtx5090:latest \
    /bin/bash
