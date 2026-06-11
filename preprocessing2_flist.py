import argparse
import os
import re
import wave
from random import shuffle, seed
from loguru import logger
from tqdm import tqdm
import utils

pattern = re.compile(r'^[\.a-zA-Z0-9_\/]+$')

def get_wav_duration(file_path):
    try:
        with wave.open(file_path, 'rb') as wav_file:
            n_frames  = wav_file.getnframes()
            framerate = wav_file.getframerate()
            return n_frames / float(framerate)
    except Exception as e:
        logger.error(f"Error reading {file_path}")
        raise e

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--train_list", type=str, default="./filelists/train.txt")
    parser.add_argument("--val_list",   type=str, default="./filelists/val.txt")
    parser.add_argument("--test_list",  type=str, default="./filelists/test.txt")
    parser.add_argument("--source_dir", type=str, default="./dataset")
    parser.add_argument("--train_ratio", type=float, default=0.8)
    parser.add_argument("--val_ratio",   type=float, default=0.1)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()

    seed(args.seed)

    train, val, test = [], [], []
    spk_dict = {}
    spk_id   = 0

    for speaker in tqdm(sorted(os.listdir(args.source_dir))):
        speaker_dir = os.path.join(args.source_dir, speaker)
        if not os.path.isdir(speaker_dir):
            continue

        spk_dict[speaker] = spk_id
        spk_id += 1

        wavs = []
        for file_name in os.listdir(speaker_dir):
            if not file_name.endswith(".wav"):
                continue
            if file_name.startswith("."):
                continue
            file_path = os.path.join(args.source_dir, speaker, file_name)
            if get_wav_duration(file_path) < 0.3:
                logger.info(f"Skip too short: {file_path}")
                continue
            wavs.append(file_path)

        shuffle(wavs)
        n = len(wavs)

        n_train = max(1, int(n * args.train_ratio))
        n_val   = max(1, int(n * args.val_ratio))
        n_test  = max(0, n - n_train - n_val)

        train += wavs[:n_train]
        val   += wavs[n_train:n_train + n_val]
        test  += wavs[n_train + n_val:]

        logger.info(f"  {speaker}: {n} files → train={n_train}, val={n_val}, test={n_test}")

    shuffle(train)
    shuffle(val)
    shuffle(test)

    os.makedirs("filelists", exist_ok=True)

    logger.info(f"Writing {args.train_list} ({len(train)} files)")
    with open(args.train_list, "w") as f:
        for fname in tqdm(train):
            f.write(fname + "\n")

    logger.info(f"Writing {args.val_list} ({len(val)} files)")
    with open(args.val_list, "w") as f:
        for fname in tqdm(val):
            f.write(fname + "\n")

    logger.info(f"Writing {args.test_list} ({len(test)} files)")
    with open(args.test_list, "w") as f:
        for fname in tqdm(test):
            f.write(fname + "\n")

    logger.info(f"\nTotal: {len(train)} train | {len(val)} val | {len(test)} test")
    logger.info(f"Singers: {spk_id}")

    d_config_template = utils.load_config("configs_template/diffusion_template.yaml")
    d_config_template["model"]["n_spk"] = spk_id
    d_config_template["spk"] = spk_dict

    logger.info("Writing configs/diffusion.yaml")
    utils.save_config("configs/diffusion.yaml", d_config_template)