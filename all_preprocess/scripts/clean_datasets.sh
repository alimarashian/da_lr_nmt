#!/bin/bash
source $1 ## just to get the config set. We won't need all the vars obviously



SCRIPTS=../mosesdecoder/scripts
TOKENIZER=$SCRIPTS/tokenizer/tokenizer.perl
CLEAN=$SCRIPTS/training/clean-corpus-n.perl
NORM_PUNC=$SCRIPTS/tokenizer/normalize-punctuation.perl
REM_NON_PRINT_CHAR=$SCRIPTS/tokenizer/remove-non-printing-char.perl
REPLACE_UNICODE_PUNCT=$SCRIPTS/tokenizer/replace-unicode-punctuation.perl

## run this first -> then in data_polished, run filter_empty.py -> encode-spm_.sh -> preprocess.sh


SRC=$SRC_MBART_CODE
TGT=$TGT_MBART_CODE
src=$SRC_CODE
tgt=$TGT_CODE

if [ $DO_PRETRAIN == true ] && [ $DO_TRAIN == false ]; then
orig=/scratch/alpine/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/pretrain
other=/scratch/alpine/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/pretraining_processing/cleaned
else
orig=/scratch/alpine/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/train
other=/scratch/alpine/sema4648/project_data/$DOMAIN/$TARGET_LANG_NAME/processing/cleaned
fi

tr=train
val=valid
echo "pre-processing train data..."

## making sure to empty the destination first
rm -rfv $other
mkdir $other
    
for dir in $orig/*/; do
    x=$(basename $dir)
    mkdir -p $other/$x
    rm -rf $other/$x/*
    
    for l in $src $tgt; do
        if [ $l == $src ]; then
            extension=$SRC
        else
            extension=$TGT
        fi
        for f in $tr $val; do
            if [ "$TARGET_LANG_NAME" != "Tamil" ]; then
                cat $dir$f.$l | \
                sed 's/\&amp;/\&/g' |   # escape escape
                sed 's/\&#124;/\|/g'|  # factor separator
                sed 's/\&lt;/\</g' |   # xml
                sed 's/\&gt;/\>/g' |   # xml
                sed "s/\s\&apos;/\'/g" | # xml
                sed 's/\&quot;/\"/g' | # xml
                sed 's/\&#91;/\[/g'  | # syntax non-terminal
                sed 's/\&#93;/\]/g'  |
                sed -e 's/.*/\L&/g'  | 
                perl $REPLACE_UNICODE_PUNCT | \
                perl $NORM_PUNC $l | \
                perl $REM_NON_PRINT_CHAR |
                perl $TOKENIZER -threads 8 -no-escape 1 -l $l > $other/$x/$f.$extension
            else
                if [ $l == "tm" ]; then
                echo $other/$x/$f.$extension
                fi
                cat $dir$f.$l > $other/$x/$f.$extension ## for Tamil we just copy, something happens and adds an extra character and i don't know why yet. 
            fi
        done
    done
done


        
    



            



            