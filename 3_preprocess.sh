#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate "$CONDA_ENV_NAME"

log() { echo "[$(date '+%H:%M:%S')] $1"; }

cd "$REPO_DIR"
log "REPO_DIR: $REPO_DIR"

log " Resample to 24000Hz"
python preprocessing1_resample.py -n "$NUM_CPU_PROCESSES"

log " Split train/val/test (80/10/10 per singer) ==="
python preprocessing2_flist.py

# Verify n_spk
python3 -c "
import yaml
with open('configs/diffusion.yaml') as f:
    cfg = yaml.safe_load(f)
n_spk = cfg['model']['n_spk']
print(f' n_spk in config: {n_spk}')
assert n_spk == 57, f'Expected 57 singers, got {n_spk}!'
print(' Singer count verified.')
"

log "Extract features (ContentVec + pitch)"
python preprocessing3_feature.py -c "$TEACHER_CONFIG" -n "$NUM_CPU_PROCESSES"

log ""
log "=== Preprocessing complete! ==="
log "  filelists/train.txt"
log "  filelists/val.txt"
log "  filelists/test.txt"