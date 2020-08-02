#!/bin/bash
DATA_PATH=$PWD/data/processed/umt
PRETRAINED_MODEL_PATH=$PWD/dumped/pretrain/iqzchx65lr/best-valid_mlm_ppl.pth

python XLM/train.py \
        --exp_name train \
        --dump_path ./dumped/ \
        --reload_model "$PRETRAINED_MODEL_PATH,$PRETRAINED_MODEL_PATH" \
        --data_path $DATA_PATH \
        --lgs 'zh-en' \
        --ae_steps 'zh,en' \
        --bt_steps 'zh-en-zh,en-zh-en' \
        --word_shuffle 3 \
        --word_dropout 0.1 \
        --word_blank 0.1 \
        --lambda_ae '0:1,100000:0.1,300000:0' \
        --encoder_only false \
        --emb_dim 512 \
        --n_layers 6 \
        --n_heads 8 \
        --dropout 0.1 \
        --attention_dropout 0.1 \
        --gelu_activation true \
        --tokens_per_batch 1250 \
        --batch_size 24 \
        --bptt 256 \
        --optimizer adam_inverse_sqrt,beta1=0.9,beta2=0.98,lr=0.0001 \
        --epoch_size 200000 \
        --eval_bleu true \
        --stopping_criterion 'valid_zh-en_mt_bleu,10' \
        --validation_metrics 'valid_zh-en_mt_bleu'