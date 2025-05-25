DO_PRETRAIN=false
DO_TRAIN=true
DO_TEST=true
DO_PSEUDO=false
DOMAIN=bible_data ## 'bible_data' if you want to preprocess bible data only for training
TARGET_LANG_NAME=Polish
TGT_CODE=pl
TGT_MBART_CODE=pl_XX
SETTING=just_bible ## could be just_bible, or mixed_training (mixed with pseudo data), or just pretraining.


DICTIONARY_PATH=PATH_TO_DICT
MAKE_BIBLE=true

PRETRAIN_NUM=200000
TEST_SIZE=1500

SEED=42
SRC_CODE=en
SRC_MBART_CODE=en_XX
MAIN_DATA_PREPROCESS_PATH=PATH_TO_RAW_DATA_FOLDER
SCRIPT_PATH=$pwd/scripts
BIBLE_DATA_PATH=$MAIN_DATA_PREPROCESS_PATH/bible_data/
BIBLE_SCRIPT_PATH=$SCRIPT_PATH/split_train-valid.py
PREPROCESS_SCRIPTS_PATH=$SCRIPT_PATH
VALID_PORTION=0.08