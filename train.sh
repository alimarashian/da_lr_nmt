#!/bin/bash

source $1



CUDA_VISIBLE_DEVICES=0,1 python $FAIRSEQ_PATH/train.py $DATA \
   --save-dir $CHECKPOINTS_DIR \
   --source-lang $SRC_LANG --target-lang $TGT_LANG \
   --bpe $BPE_TYPE --sentencepiece-model $SPM_MODEL \
   --max-tokens $MAX_TOKENS --patience $PATIENCE\
   --optimizer $OPTIMIZER --adam-eps 1e-06 --adam-betas '(0.9, 0.98)' \
   --lr-scheduler $SCHEDULER --lr $LEARNING_RATE  --warmup-updates $WARMUP_UPDATES\
   --max-epoch $MAX_EPOCH --min-epoch $MIN_EPOCH --total-num-update $TOTAL_NUM_UPDATES \
   --save-interval 5 --no-epoch-checkpoints \
   --dropout 0.3 --attention-dropout 0.1 --weight-decay 0.0 \
   --arch $ARCHITECTURE --layernorm-embedding \
   --encoder-normalize-before --decoder-normalize-before \
   --required-batch-size-multiple 1 \
   --share-decoder-input-output-embed \
   --criterion $LOSS --label-smoothing 0.2 \
   --encoder-learned-pos \
   $CONSNMT $USEPTR $CONS_METHOD --dictionary-path $DICTIONARY_PATH --lemmas-path $LEMMAS_PATH\
   --update-freq 2 \
   --log-format simple --log-interval 2 \
   --seed $SEED \
   --task $TASK \
   --langs $LANGS \
   --restore-file $MBART_MODEL $LOAD_FROM_PRETRAINED \
   --reset-optimizer --reset-meters --reset-dataloader --reset-lr-scheduler \
   --tensorboard-logdir $LOG_DIR $EVAL_BLEU $BLEU_DETOK $BLEU_REMOVE $BLEU_CHECKPOINT $BLEU_MAXIMIZE

   

