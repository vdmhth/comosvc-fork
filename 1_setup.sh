#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

log() { echo "[$(date '+%H:%M:%S')] $1"; }

log "REPO_DIR resolved to: $REPO_DIR"

log "=== Setting up Conda environment: $CONDA_ENV_NAME ==="

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"

if conda env list | grep -q "^${CONDA_ENV_NAME} "; then
    log "Env '$CONDA_ENV_NAME' already exists, skipping."
else
    conda create -n "$CONDA_ENV_NAME" python=3.8 -y
    log "Env '$CONDA_ENV_NAME' created."
fi

conda activate "$CONDA_ENV_NAME"

log "=== Installing system dependencies ==="
if ! command -v unrar >/dev/null 2>&1; then
    log "Installing unrar..."
    sudo apt-get install -y unrar || sudo apt-get install -y unrar-free
    log "unrar installed."
else
    log "unrar already installed."
fi

log "=== Installing Python dependencies ==="
pip install -r "${REPO_DIR}/requirements.txt" -q
pip install gdown -q
# --- HiFi-GAN Vocoder ---
if [ ! -d "${REPO_DIR}/m4singer_hifigan" ]; then
    log "Downloading m4singer_hifigan..."
    gdown "10LD3sq_zmAibl379yTW5M-LXy2l_xk6h" -O /tmp/m4singer_hifigan.zip
    unzip -q /tmp/m4singer_hifigan.zip -d "$REPO_DIR"
    rm /tmp/m4singer_hifigan.zip
    log "m4singer_hifigan done."
else
    log "m4singer_hifigan already exists."
fi

# --- ContentVec ---
mkdir -p "${REPO_DIR}/Content"
CONTENTVEC_PATH="${REPO_DIR}/Content/checkpoint_best_legacy_500.pt"
if [ ! -f "$CONTENTVEC_PATH" ]; then
    log "Downloading ContentVec..."
    curl -L "https://ibm.box.com/shared/static/z1wgl1stco8ffooyatzdwsqn2psd9lrr" \
         -o "$CONTENTVEC_PATH" --retry 3 --retry-delay 5
    log "ContentVec done."
else
    log "ContentVec already exists."
fi

# --- Pitch Extractor ---
if [ ! -d "${REPO_DIR}/m4singer_pe" ]; then
    log "Downloading m4singer_pe..."
    gdown "19QtXNeqUjY3AjvVycEt3G83lXn2HwbaJ" -O /tmp/m4singer_pe.zip
    unzip -q /tmp/m4singer_pe.zip -d "$REPO_DIR"
    rm /tmp/m4singer_pe.zip
    log "m4singer_pe done."
else
    log "m4singer_pe already exists."
fi
log "=== Setup complete! ==="