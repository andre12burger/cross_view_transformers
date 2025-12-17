#!/bin/bash
# Script para treinar CVT com RTX 5090
# Força uso da GPU ignorando verificação de compatibilidade

cd /home/bevlog-1/Documents/bevlog/cross/cross_view_transformers

# Ativar ambiente
source ~/miniconda3/bin/activate cvt39

# Configurar variáveis de ambiente
export WANDB_API_KEY="c7ff04049d5cd781e688f17ab60ada654f9323e3"
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
export CUDA_LAUNCH_BLOCKING=0

# Treinar sem DDP (single GPU)
python scripts/train.py \
  +experiment=cvt_nuscenes_vehicle \
  data.dataset_dir=$PWD/datasets/nuscenes \
  data.labels_dir=$PWD/datasets/cvt_labels_nuscenes \
  +trainer.devices=1 \
  +trainer.accelerator=gpu \
  +trainer.strategy=null
