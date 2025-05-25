import os
import math
import random
import numpy as np
from random import shuffle
from shutil import rmtree
import sys

src_lang = sys.argv[1]
tgt_lang = sys.argv[2]
domain = sys.argv[3]
target_lang_name = sys.argv[4]
init_bible_path = sys.argv[5]
seed = int(sys.argv[6])
main_raw_data_path = sys.argv[7]



random.seed(seed)


def read_file(path):

    lines = []
    with open(path, 'r') as file:
        lines = file.readlines()
        lines = [x.strip().lower() for x in lines]

    return lines

def write_file(path, list):

    with open(path, "w") as file:
        for i, line in enumerate(list):
            if i != len(list) - 1:
                file.write(line + "\n")
            else:
                file.write(line)
         

main_folder = "{path}/{dom}/{lang}/train/".format(path=main_raw_data_path,dom=domain, lang=target_lang_name)

all_source = read_file(main_folder+src_lang+"-"+tgt_lang+"-train."+src_lang)
all_target = read_file(main_folder+src_lang+"-"+tgt_lang+"-train."+tgt_lang)


bible_path = init_bible_path+target_lang_name+"/"

valid_source = read_file(bible_path+"bible-valid-{s}-{t}.".format(s=src_lang, t=tgt_lang)+src_lang)
valid_target = read_file(bible_path+"bible-valid-{s}-{t}.".format(s=src_lang, t=tgt_lang)+tgt_lang)


bible_source = read_file(bible_path+"bible-train-{s}-{t}.".format(s=src_lang, t=tgt_lang)+src_lang)
bible_target = read_file(bible_path+"bible-train-{s}-{t}.".format(s=src_lang, t=tgt_lang)+tgt_lang)


number_of_folds = math.ceil(len(all_source) / len(bible_source))




fold_size = len(all_source) // number_of_folds


all_indices = [i for i in range(len(all_source))]
shuffle(all_indices)


sublists = np.array_split(all_indices, number_of_folds)

## removing previous folders
for file in os.listdir(main_folder):
    full_path = os.path.join(main_folder, file)
    if os.path.isdir(full_path):
        rmtree(full_path)


for i in range(number_of_folds):

        source_of_fold = [all_source[j] for j in sublists[i]]
        target_of_fold = [all_target[j] for j in sublists[i]]

        source_of_fold.extend(bible_source)
        target_of_fold.extend(bible_target)

        all_indices_fold = [i for i in range(len(source_of_fold))]
        shuffle(all_indices_fold)

        source_of_fold_ = [source_of_fold[j] for j in all_indices_fold]
        target_of_fold_ = [target_of_fold[j] for j in all_indices_fold]

        if not os.path.exists(main_folder+"fold"+str(i)):
            os.makedirs(main_folder+"fold"+str(i))


        write_file(main_folder+"fold"+str(i)+"/train."+src_lang,  source_of_fold_)
        write_file(main_folder+"fold"+str(i)+"/train."+tgt_lang,  target_of_fold_)
        
        ## the same validation set for all folds (epochs)
        write_file(main_folder+"fold"+str(i)+"/valid."+src_lang,  valid_source)
        write_file(main_folder+"fold"+str(i)+"/valid."+tgt_lang,  valid_target)
        
        




