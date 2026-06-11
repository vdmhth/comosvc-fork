#!/bin/bash
# =============================================================================
# CoMoSVC — STEP 5: Train CoMo (Consistency Model)
# Phải chạy SAU khi teacher đã xong
# Có 2 cách chạy:
#   Direct: bash 5_train_como.sh
#   SLURM:  sbatch 5_train_como.sh
# =============================================================================
#
#SBATCH --job-name=comosvc_como
#SBATCH --partition=gpu
#SBATCH --gres=gpu:a100:1
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --time=72:00:00
#SBATCH --output=logs/slurm_como_%j.log
#SBATCH --error=logs/slurm_como_%j.err

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

CONDA_BASE=$(conda info --base)
source "${CONDA_BASE}/etc/profile.d/conda.sh"
conda activate "$CONDA_ENV_NAME"

log() { echo "[$(date '+%H:%M:%S')] $1"; }

cd "$REPO_DIR"
log "REPO_DIR: $REPO_DIR"

TEACHER_CKPT=$(ls -v "${REPO_DIR}/logs/teacher/"model_*.pt 2>/dev/null | tail -1)
if [ -z "$TEACHER_CKPT" ]; then
    log "ERROR: cannot find teacher ckpt"
    exit 1
fi

log "=== Training CoMo Model ==="
log "Teacher checkpoint: $TEACHER_CKPT"
python train.py -t -c "$COMO_CONFIG" -p "$TEACHER_CKPT"
log "=== CoMo training complete! ==="
log "Checkpoint: ${REPO_DIR}/logs/como/"