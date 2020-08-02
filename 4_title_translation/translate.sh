#!/bin/bash

python XLM/translate.py \
        --dump_path ./dumped \
        --exp_name translate \
        --batch_size 32 \
        --model_path ./dumped/train/l0iz2ga499/best-valid_zh-en_mt_bleu.pth \
        --output_path ./data/translated.en.1 \
        --src_lang zh \
        --tgt_lang en < ./data/test.bpe.zh