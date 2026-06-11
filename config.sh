REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONDA_ENV_NAME="comosvc"

TEACHER_CONFIG="${REPO_DIR}/configs/diffusion.yaml"
COMO_CONFIG="${REPO_DIR}/configs/diffusion.yaml"
CHUNK_FORMAT="rar"

DATA_CHUNK_IDS=(
    "17u0IBwdwZnJU6X0Nh_zEd6a7oz2EnyIZ", #chunk1
    "1Zjair5o_bP_K6TKV9sTOfvzHabB-Gsbt", #chunk2
    "1BlPioErdIGdjnXTXy0PTn_gX7pkajVOs", #chunk3
    "10rDUESLQ5QXSW32MbqlXfEOyb1z6kO1R", #chunk4
    "1xBBc_Cz4weihvb5O_Q5V4xryUZD3f4Fu", #chunk5
    "1kztz57Vrrldj_9HaUnuLyws0pt-lwIpr" #chunk6
)
NUM_CPU_PROCESSES=8
GPU_ID=0
