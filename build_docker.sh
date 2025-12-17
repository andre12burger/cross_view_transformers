#!/bin/bash

# Script para construir a imagem Docker com TODAS as dependências
# Execute este script apenas UMA VEZ ou quando precisar atualizar as dependências

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "=============================================="
echo "   Construindo imagem Docker CVT + RTX 5090"
echo "=============================================="
echo ""
echo "Isso vai:"
echo "  1. Criar imagem base com PyTorch 2.8.0 + CUDA 12.9"
echo "  2. Instalar dependências do sistema"
echo "  3. Instalar TODAS as dependências Python"
echo ""
echo "⏱️  Tempo estimado: 5-10 minutos"
echo "📦 Tamanho final: ~15GB"
echo ""
read -p "Continuar? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

echo ""
echo "🔨 Construindo imagem cvt-rtx5090:latest..."
echo ""

docker build -t cvt-rtx5090:latest .

echo ""
echo "✅ Imagem construída com sucesso!"
echo ""
echo "Agora você pode treinar com: ./train_docker.sh"
echo ""
