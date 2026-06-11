#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log() { echo "[$(date '+%H:%M:%S')] === $1 ==="; }
log "Working dir: $SCRIPT_DIR"
log "Setup environment + pretrained checkpoints"
bash "${SCRIPT_DIR}/1_setup.sh"
log "Download & reorganize data"
bash "${SCRIPT_DIR}/2_download_data.sh"
log "Preprocessing"
bash "${SCRIPT_DIR}/3_preprocess.sh"
log "Train Teacher model"
bash "${SCRIPT_DIR}/4_train_teacher.sh"
log "Train CoMo model"
bash "${SCRIPT_DIR}/5_train_como.sh"
log "DONE"