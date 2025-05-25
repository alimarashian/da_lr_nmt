## after you download the data and put it in "/rc_scratch/sema4648/project_data/$domain/$target_lang_name/raw/"
## with names all.$src_code and all.$tgt_code
## we will make all the pretraining data, training and test data. 
## for validation, we use the bible data. We mix bible and train data for final train data. 

## outputs:
## 1. basic bible training data (no folds, or just one fold), 
## 2. and mixed bible + pseudo data, 
## 3. and also just the pretraining data. 

source $1

## if the setting is 'just_bible' do this

if [ $SETTING == "just_bible" ]; then ## DOMAIN should be bible_data

    if [ $MAKE_BIBLE == true ]; then
        python $BIBLE_SCRIPT_PATH $SRC_CODE $TGT_CODE $BIBLE_DATA_PATH $TARGET_LANG_NAME $VALID_PORTION $SEED
    fi


    mkdir -p  $MAIN_DATA_PREPROCESS_PATH/bible_data/$TARGET_LANG_NAME/train/fold0

    base_bible_path=$MAIN_DATA_PREPROCESS_PATH/bible_data/$TARGET_LANG_NAME


    if [ -f $base_bible_path/bible-train-$SRC_CODE-$TGT_CODE.$SRC_CODE  ]; then ## copy to train/fold0 subfolder
        cp $base_bible_path/bible-train-$SRC_CODE-$TGT_CODE.$SRC_CODE $base_bible_path/train/fold0/train.$SRC_CODE
        cp $base_bible_path/bible-train-$SRC_CODE-$TGT_CODE.$TGT_CODE $base_bible_path/train/fold0/train.$TGT_CODE
        cp $base_bible_path/bible-valid-$SRC_CODE-$TGT_CODE.$SRC_CODE $base_bible_path/train/fold0/valid.$SRC_CODE
        cp $base_bible_path/bible-valid-$SRC_CODE-$TGT_CODE.$TGT_CODE $base_bible_path/train/fold0/valid.$TGT_CODE
    fi
    

    rm -rfv $MAIN_DATA_PREPROCESS_PATH/bible_data/$TARGET_LANG_NAME/processing/
    mkdir -p $MAIN_DATA_PREPROCESS_PATH/bible_data/$TARGET_LANG_NAME/processing/

    mkdir -p $MAIN_DATA_PREPROCESS_PATH/bible_data/$TARGET_LANG_NAME/processing/cleaned
    mkdir -p $MAIN_DATA_PREPROCESS_PATH/bible_data/$TARGET_LANG_NAME/processing/encoded
    mkdir -p $MAIN_DATA_PREPROCESS_PATH/bible_data/$TARGET_LANG_NAME/processing/processed

    sh $PREPROCESS_SCRIPTS_PATH/clean_datasets.sh $1 ## the initial preprocessing -> for the bible, put the stuff in fold0 for some reason for the code to run smoothly. (matching the format of folded training)
    sh $PREPROCESS_SCRIPTS_PATH/encode_spm_.sh $1 ## the encoding
    sh $PREPROCESS_SCRIPTS_PATH/preprocess.sh $1 

    exit

fi

## else:


# splitting for pretraining, training and testing (if applicable)
# python $SCRIPT_PATH/split_raw-1.py $DOMAIN $TARGET_LANG_NAME $SRC_CODE $TGT_CODE $SETTING $DO_PRETRAIN $DO_TRAIN $DO_TEST $PRETRAIN_NUM $TEST_SIZE $SEED

if [ $DO_PRETRAIN == true ] && [ $DO_TRAIN == false ]; then
## let's preprocess just the pretraining data and end the execution here
rm -rfv $MAIN_DATA_PREPROCESS_PATH/$DOMAIN/$TARGET_LANG_NAME/pretraining_processing/
mkdir -p $MAIN_DATA_PREPROCESS_PATH/$DOMAIN/$TARGET_LANG_NAME/pretraining_processing/

mkdir -p $MAIN_DATA_PREPROCESS_PATH/$DOMAIN/$TARGET_LANG_NAME/pretraining_processing/cleaned
mkdir -p $MAIN_DATA_PREPROCESS_PATH/$DOMAIN/$TARGET_LANG_NAME/pretraining_processing/encoded
mkdir -p $MAIN_DATA_PREPROCESS_PATH/$DOMAIN/$TARGET_LANG_NAME/pretraining_processing/processed

sh $PREPROCESS_SCRIPTS_PATH/clean_datasets.sh $1 ## the initial preprocessing
sh $PREPROCESS_SCRIPTS_PATH/encode_spm_.sh $1 ## the encoding
sh $PREPROCESS_SCRIPTS_PATH/preprocess.sh $1 ## the encoding
exit

fi

## if bible data (the parts for training and validation) is not ready, make those splits too. 
# the english and target language bible data should be in the folder 'rc_scratch/sema4648/project_data/bible_data/$TARGET_LANG_NAME' as files bible.en and bible.TGT_CODE
if [ $MAKE_BIBLE == true ]; then
    python $BIBLE_SCRIPT_PATH $SRC_CODE $TGT_CODE $BIBLE_DATA_PATH $TARGET_LANG_NAME $VALID_PORTION $SEED
fi


if [ $DO_PSEUDO == true ]; then
    python  $SCRIPT_PATH/make_pseudo-2.py $DICTIONARY_PATH $SRC_CODE $TGT_CODE $DOMAIN $TARGET_LANG_NAME
fi


## making the folds. This is not for pertraining though. 

if [ $SETTING == 'mixed_training' ]; then ## we're mixing the data for training, and we're going to make some folds :) 
python $SCRIPT_PATH/split_train-3.py $SRC_CODE $TGT_CODE $DOMAIN $TARGET_LANG_NAME $BIBLE_DATA_PATH $SEED

rm -rfv $MAIN_DATA_PREPROCESS_PATH/$DOMAIN/$TARGET_LANG_NAME/processing/
mkdir -p $MAIN_DATA_PREPROCESS_PATH/$DOMAIN/$TARGET_LANG_NAME/processing/

mkdir -p $MAIN_DATA_PREPROCESS_PATH/$DOMAIN/$TARGET_LANG_NAME/processing/cleaned
mkdir -p $MAIN_DATA_PREPROCESS_PATH/$DOMAIN/$TARGET_LANG_NAME/processing/encoded
mkdir -p $MAIN_DATA_PREPROCESS_PATH/$DOMAIN/$TARGET_LANG_NAME/processing/processed


sh $PREPROCESS_SCRIPTS_PATH/clean_datasets.sh $1 ## the initial preprocessing. For Tamil, it gives an extra character which we don't want, so we skip this stage.
sh $PREPROCESS_SCRIPTS_PATH/encode_spm_.sh $1 ## the encoding
sh $PREPROCESS_SCRIPTS_PATH/preprocess.sh $1 ## the encoding
fi

















