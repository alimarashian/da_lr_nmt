#!/bin/bash


MODEL_TYPE=psuedo_plain
TGT_LANG=pl_XX
IS_LECA=false
DICTIONARY_PATH=/projects/sema4648/mb_fairseq/data/news/Polish/dictionary/extracted_glossary_from_english_new.txt ## only if using the leca based systems that use dictionaries for suggestions
LEMMAS_PATH=/path/to/lemmas
MAX_EPOCH=300
MIN_EPOCH=100
EARLY_STOPPING=true
PATIENCE=50
WARMUP_UPDATES=2000
TOTAL_NUM_UPDATES=98000 ### total-num-update is more than the steps for 100 epochs, but need to change it everytime (the first epoch had 305 iter so i went with this estimate for 100). Will have to check first and change it manually everytime :((
DOMAIN=news
TARGET_LANG_NAME=Polish
IS_FOLDED=true
LOSS=label_smoothed_cross_entropy
SEED=42
LEARNING_RATE=3e-5
MAX_TOKENS=1024
USE_BLEU=false



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
TASK=translation_from_pretrained_bart ## pretraining uses denoising. but this is for training only.




######## DERIVED ########


DATA_INIT=/rc_scratch/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/processing/processed/ ## preprocessed data folder. With or without folders for different epochs


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

CHECKPOINTS_DIR=/rc_scratch/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/trained_models/$MODEL_TYPE
mkdir -p $CHECKPOINTS_DIR

LOG_DIR=/projects/sema4648/mb_fairseq/mbart-bible/logs/$DOMAIN/$TARGET_LANG_NAME/$MODEL_TYPE
rm -rfv $LOG_DIR
mkdir -p $LOG_DIR




