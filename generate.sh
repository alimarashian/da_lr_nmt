#!/bin/bash
# DATA=/rc_scratch/sema4648/project_data/bible_data/Polish/processing/processed/fold0/


TGT_LANG_NAME=Icelandic
DOMAIN_DATA=medical
SRC_LANG=en_XX
TGT_LANG=is_XX
MODEL_TYPE_PATH=just_bible_leca_icelandic_med
DOMAIN_MODEL=bible_data
has_leca=true
DICTIONARY_PATH=$PWD/dictionaries/Icelandic/is-en-med-merged.txt
LEMMAS_PATH=$PWD/dictionaries/Icelandic/all_lemmas_dictionary_med.txt


langs=ar_AR,cs_CZ,de_DE,en_XX,es_XX,et_EE,fi_FI,fr_XX,gu_IN,hi_IN,it_IT,ja_XX,kk_KZ,ko_KR,lt_LT,lv_LV,my_MM,ne_NP,nl_XX,ro_RO,ru_RU,si_LK,tr_TR,vi_VN,zh_CN
DATA=$PWDother_test_preprocessed/$TGT_LANG_NAME/$DOMAIN_DATA ## from another source
RESULTS_PATH=results/$TGT_LANG_NAME/$MODEL_TYPE_PATH
mkdir -p $RESULTS_PATH
MODEL_PATH=/scratch/alpine/sema4648/project_data/$DOMAIN_MODEL/$TGT_LANG_NAME/trained_models/$MODEL_TYPE_PATH/checkpoint_best.pt
TOKENIZER_TYPE=moses
BPE_TYPE=sentencepiece
SPM_MODEL=/projects/sema4648/mb_fairseq/finetune-mbart-en-de/mbart.cc25/sentence.bpe.model
SUBSET=test
LOWER_CASE=false




if [ $has_leca == true ]; then 
  CONSNMT=--consnmt 
  USE_PTR=--use-ptrnet
  CONS_METHOD="--const-method dictionary"
  DICTIONARY_PATH_LECA="--dictionary-path $DICTIONARY_PATH"
else
  CONSNMT="" 
  USE_PTR=""
  CONS_METHOD=""
  DICTIONARY_PATH_LECA="--dictionary-path $DICTIONARY_PATH" ## needs it now cause in init of the model some computation happens. 
fi



if [ "$LOWER_CASE" == false ]; then 
  CUDA_VISIBLE_DEVICES=0,1 python fairseq/fairseq_cli/generate.py $DATA --source-lang $SRC_LANG --target-lang $TGT_LANG \
  --path $MODEL_PATH \
  --results-path $RESULTS_PATH \
  --gen-subset $SUBSET \
  --bpe $BPE_TYPE --sentencepiece-model $SPM_MODEL \
  --task translation_from_pretrained_bart \
  --langs $langs \
  --scoring sacrebleu --remove-bpe sentencepiece \
  --batch-size 32 $CONSNMT $USE_PTR $CONS_METHOD $DICTIONARY_PATH_LECA \
  --beam 10
fi


if [ $LOWER_CASE == true ]; then
cat $RESULTS_PATH/generate-$SUBSET.txt | grep -P "^H" |sort -V |cut -f 3- | sed 's/\[ml_XX\]//g' | sed -e 's/\(.*\)/\L\1/' > $RESULTS_PATH/$SUBSET.hyp
cat $RESULTS_PATH/generate-$SUBSET.txt | grep -P "^T" |sort -V |cut -f 2- | sed 's/\[ml_XX\]//g' | sed -e 's/\(.*\)/\L\1/' > $RESULTS_PATH/$SUBSET.ref
else 
cat $RESULTS_PATH/generate-$SUBSET.txt | grep -P "^H" |sort -V |cut -f 3- | sed 's/\[ml_XX\]//g' > $RESULTS_PATH/$SUBSET.hyp
cat $RESULTS_PATH/generate-$SUBSET.txt | grep -P "^T" |sort -V |cut -f 2- | sed 's/\[ml_XX\]//g' > $RESULTS_PATH/$SUBSET.ref
fi


cat $RESULTS_PATH/$SUBSET.hyp | sacrebleu $RESULTS_PATH/$SUBSET.ref -m bleu chrf
 

