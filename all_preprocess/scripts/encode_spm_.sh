#!/bin/bash
source $1 ## just to get the config set. We won't need all the vars obviously


SPM=../fairseq/scripts/spm_encode.py
SPM_MODEL=/projects/sema4648/mb_fairseq/finetune-mbart-en-de/mbart.cc25/sentence.bpe.model

if [ $DO_PRETRAIN == true ] && [ $DO_TRAIN == false ]; then
DATA=/scratch/alpine/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/pretraining_processing/cleaned
DATA_BPE=/scratch/alpine/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/pretraining_processing/encoded
else
DATA=/scratch/alpine/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/processing/cleaned
DATA_BPE=/scratch/alpine/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/processing/encoded
fi


SRC=$SRC_MBART_CODE
TGT=$TGT_MBART_CODE

tr=train
val=valid

rm -rfv $DATA_BPE
mkdir $DATA_BPE

for dir in $DATA/*/; do
    x=$(basename $dir)
    mkdir -p $DATA_BPE/$x
    rm -rf $DATA_BPE/$x/*
    for f in $tr $val; do
        python ${SPM} --model=$SPM_MODEL < $dir$f.${SRC} > $DATA_BPE/$x/$f.${SRC} 
        python ${SPM} --model=$SPM_MODEL < $dir$f.${TGT} > $DATA_BPE/$x/$f.${TGT} 
    done
done

# python ${SPM} --model=$SPM_MODEL < ${DATA}/train.${SRC} > ${DATA_BPE}/train.${SRC} 
# python ${SPM} --model=$SPM_MODEL < ${DATA}/train.${TGT} > ${DATA_BPE}/train.${TGT}
# python ${SPM} --model=$SPM_MODEL < ${DATA}/valid.${SRC} > ${DATA_BPE}/valid.${SRC} 
# python ${SPM} --model=$SPM_MODEL < ${DATA}/valid.${TGT} > ${DATA_BPE}/valid.${TGT}







# python ${SPM} --model=$SPM_MODEL < ${DATA}/test.${SRC} > ${DATA_BPE}/test.${SRC} 
# python ${SPM} --model=$SPM_MODEL < ${DATA}/test.${TGT} > ${DATA_BPE}/test.${TGT}

# python ${SPM} --model=$SPM_MODEL < ${DATA}/test_bible.${SRC} > ${DATA_BPE}/test_bible.${SRC} 
# python ${SPM} --model=$SPM_MODEL < ${DATA}/test_bible.${TGT} > ${DATA_BPE}/test_bible.${TGT}