#!/bin/bash


MODEL_TYPE=pretrained_liu_polish_medical
TGT_LANG=pl_XX
IS_LECA=false
DICTIONARY_PATH_PRE=/projects/sema4648/mb_fairseq/mbart-bible/dictionaries/Polish/pl-en-med-merged.txt
DICTIONARY_PATH=/projects/sema4648/mb_fairseq/mbart-bible/dictionaries/Polish/pl-en-med-merged.txt
LEMMAS_PATH=/projects/sema4648/mb_fairseq/mbart-bible/dictionaries/Polish/all_lemmas_Polish_dictionary.txt
MAX_EPOCH=60
MIN_EPOCH=20
EARLY_STOPPING=true
PATIENCE=10
WARMUP_UPDATES=2000
TOTAL_NUM_UPDATES=100000 ## the only bad thing is that for every size of training dataset, I have to check the number of steps of each epoch so that this wouldn't pass the max number of epochs
DOMAIN=medical
TARGET_LANG_NAME=Polish
IS_FOLDED=true
LOSS=label_smoothed_cross_entropy
SEED=42
LEARNING_RATE=3e-5
MAX_TOKENS=1024

MASK=0.35
TOKENS_PER_SAMPLE=384
POISSON_L=3.5
POST_MBART_NOISE_FUNCTION=liu

######## FIXED ONES ########

SRC_LANG=en_XX #Source Language code
MBART_MODEL=/projects/sema4648/mb_fairseq/finetune-mbart-en-de/mbart.cc25/model.pt
LANGS=ar_AR,cs_CZ,de_DE,en_XX,es_XX,et_EE,fi_FI,fr_XX,gu_IN,hi_IN,it_IT,ja_XX,kk_KZ,ko_KR,lt_LT,lv_LV,my_MM,ne_NP,nl_XX,ro_RO,ru_RU,si_LK,tr_TR,vi_VN,zh_CN ## fixed
SCHEDULER=polynomial_decay
ARCHITECTURE=mbart_large
BPE_TYPE=sentencepiece
SPM_MODEL=/projects/sema4648/mb_fairseq/finetune-mbart-en-de/mbart.cc25/sentence.bpe.model
TOKENIZER_TYPE=moses
OPTIMIZER=adam
FAIRSEQ_PATH=/projects/sema4648/mb_fairseq/mbart-bible/fairseq
TASK=denoising ## pretraining uses denoising. but this is for training only.




######## DERIVED ########


DATA_INIT=/rc_scratch/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/pretraining_processing/processed ## preprocessed data folder. With or without folders for different epochs

 
if [ "$IS_FOLDED" == true ]; then
    DATA=""

    for dir in $DATA_INIT/*/; do
    x=$(basename $dir)
    DATA+=$DATA_INIT/$x:
    done 
    DATA=${DATA::-1}

else
    DATA=$DATA_INIT
fi


if [ "$IS_LECA" == true ]; then
    CONSNMT="--consnmt"
    USEPTR="--use-ptrnet"
    CONS_METHOD="--const-method dictionary"
else
    CONSNMT=""
    USEPTR=""
    CONS_METHOD=""
fi

if [ "$EARLY_STOPPING" == false ]; then
    PATIENCE=-1
fi


if [ "$USE_BLEU" == true ]; then
   EVAL_BLEU="--eval-bleu"
   BLEU_DETOK="--eval-bleu-detok sp"
   BLEU_REMOVE="--eval-bleu-remove-bpe"
   BLEU_CHECKPOINT="--best-checkpoint-metric bleu" 
   BLEU_MAXIMIZE="--maximize-best-checkpoint-metric"
else
   EVAL_BLEU=""
   BLEU_DETOK=""
   BLEU_REMOVE=""
   BLEU_CHECKPOINT="" 
   BLEU_MAXIMIZE=""
fi 



CHECKPOINTS_DIR=/rc_scratch/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/pretrained_models/$MODEL_TYPE
mkdir -p $CHECKPOINTS_DIR

LOG_DIR=/projects/sema4648/mb_fairseq/mbart-bible/logs/$DOMAIN/$TARGET_LANG_NAME/pretrained/$MODEL_TYPE
rm -rfv $LOG_DIR
mkdir -p $LOG_DIR




