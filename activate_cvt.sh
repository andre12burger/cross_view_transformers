#!/bin/bash
# Ativar ambiente CVT
# Uso: source activate_cvt.sh

export CVT_ROOT="/home/bevlog-1/Documents/bevlog/cross/cross_view_transformers"
cd "$CVT_ROOT"

# Ativar conda
eval "$(conda shell.bash hook)"
conda activate cvt39

# Configurar PYTHONPATH
export PYTHONPATH="$CVT_ROOT:$PYTHONPATH"

echo "✅ Ambiente CVT ativado!"
echo "   Diretório: $CVT_ROOT"
echo "   Python: $(which python)"
echo "   Ambiente: $CONDA_DEFAULT_ENV"
