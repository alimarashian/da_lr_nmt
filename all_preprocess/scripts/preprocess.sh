#!/bin/bash
source $1 ## just to get the config set. We won't need all the vars obviously



if [ $DO_PRETRAIN == true ] && [ $DO_TRAIN == false ]; then
DATA=/scratch/alpine/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/pretraining_processing/encoded
DEST_DIR=/scratch/alpine/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/pretraining_processing/processed
else
DATA=/scratch/alpine/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/processing/encoded
DEST_DIR=/scratch/alpine/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/processing/processed
fi


SRC_LANG=$SRC_MBART_CODE #Source Language
TGT_LANG=$TGT_MBART_CODE #Target Language


TOKENIZER_TYPE=moses
BPE_TYPE=sentencepiece 
DICTIONARY=/projects/sema4648/mb_fairseq/finetune-mbart-en-de/mbart.cc25/dict.txt

# DEST_DIR=data_pretrain/preprocessed_data

rm -rfv $DEST_DIR
mkdir -p $DEST_DIR


for dir in $DATA/*/; do
    x=$(basename $dir)
    mkdir -p $DEST_DIR/$x
    rm -rf $DEST_DIR/$x/*
    echo $x
    CUDA_VISIBLE_DEVICES=0,1 python ../fairseq/fairseq_cli/preprocess.py \
    --source-lang $SRC_LANG \
    --target-lang $TGT_LANG \
    --trainpref "$DATA/$x/train"  \
    --validpref "$DATA/$x/valid" \
    --bpe $BPE_TYPE \
    --destdir $DEST_DIR/$x \
    --srcdict $DICTIONARY \
    --tgtdict $DICTIONARY \
    --workers 70\

done    


## 

# --target-lang $TGT_LANG \
#     --tgtdict $DICTIONARY \





# CUDA_VISIBLE_DEVICES=0,1 python fairseq/fairseq_cli/preprocess.py \
#     --source-lang $SRC_LANG --target-lang $TGT_LANG \
#     --testpref "$DATA/test" \
#     --bpe $BPE_TYPE \
#     --destdir $DEST_DIR \
#     --srcdict $DICTIONARY \
#     --tgtdict $DICTIONARY \
#     --workers 70
    