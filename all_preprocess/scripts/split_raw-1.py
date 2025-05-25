from sklearn.model_selection import train_test_split
import pathlib
from pathlib import Path
import sys

def get_bool(string):
    if string.lower() == "false":
        return False 
    return True

def read_file(path):

    lines = []
    with open(path, 'r') as file:
        lines = file.readlines()
        lines = [x.strip().lower() for x in lines]

    return lines

def write_file(path, list):

    with open(path, "w") as file:
        for i, line in enumerate(list):
            if i != len(list) - 1 and line[-1] != "\n":
                file.write(line + "\n")
            else:
                file.write(line)

domain = sys.argv[1]
target_lang_name = sys.argv[2]
src_code = sys.argv[3]
tgt_code = sys.argv[4]
setting= sys.argv[5]
do_pretrain = get_bool(sys.argv[6])
do_train = get_bool(sys.argv[7])
do_test = get_bool(sys.argv[8])
pretrain_num = int(sys.argv[9])
test_num = int(sys.argv[10])
seed = int(sys.argv[11])
base_path=sys.argv[12]


source_lines = read_file(base_path + domain + "/" + target_lang_name + "/raw/" + "all." + src_code)
target_lines = read_file(base_path + domain + "/" + target_lang_name + "/raw/" + "all." + tgt_code)


if do_test:
    test_dir = base_path + domain + "/" + target_lang_name + "/test/"
    pathlib.Path(test_dir).mkdir(parents=True, exist_ok=True)

    X_rest, X_test, y_rest, y_test = train_test_split(
            source_lines, target_lines, test_size = test_num , random_state=seed) 

    test_dir_local = "../../data_raw/" + target_lang_name + "/" + domain + "/"
    pathlib.Path(test_dir_local).mkdir(parents=True, exist_ok=True)


    write_file((test_dir + "{src}-{tgt}-test-in.{ext}").format(src=src_code, tgt=tgt_code, ext=src_code), X_test)
    write_file((test_dir + "{src}-{tgt}-test-in.{ext}").format(src=src_code, tgt=tgt_code, ext=tgt_code), y_test)

    write_file((test_dir_local + "test.{ext}").format(ext=src_code), X_test)
    write_file((test_dir_local + "test.{ext}").format(ext=tgt_code), y_test)

else:

    X_rest = source_lines
    y_rest = target_lines





if do_pretrain:

    if len(X_rest) <= pretrain_num:
        X_pretrain = X_rest
        y_pretrain = y_rest 
    else:    
        X_pretrain, _ , y_pretrain, _ = train_test_split(
            X_rest, y_rest, train_size = pretrain_num, random_state=seed)

    X_pretrain_final, X_valid, y_pretrain_final, y_valid = train_test_split(
        X_pretrain, y_pretrain, train_size = 0.99, random_state=seed)
    

    pretrain_dir = base_path + domain + "/" + target_lang_name + "/pretrain/fold0/"
    pathlib.Path(pretrain_dir).mkdir(parents=True, exist_ok=True) 

    write_file((pretrain_dir + "train.{ext}").format(ext=src_code), X_pretrain_final)
    write_file((pretrain_dir + "train.{ext}").format(ext=tgt_code), X_pretrain_final) ## for denoising, they need to predict the actual input

    write_file((pretrain_dir + "valid.{ext}").format(ext=src_code), X_valid)
    write_file((pretrain_dir + "valid.{ext}").format(ext=tgt_code), X_valid)

    X_rest = X_pretrain
    y_rest = y_pretrain



if do_train:

    assert do_pretrain == True ## to make sure we are not going over 200K examples!

    X_train = X_rest
    y_train = y_rest

    train_dir = base_path + domain + "/" + target_lang_name + "/train/"
    pathlib.Path(train_dir).mkdir(parents=True, exist_ok=True)

    write_file((train_dir + "{src}-{tgt}-train-raw.{ext}").format(src=src_code, tgt=tgt_code, ext=src_code), X_train)
    write_file((train_dir + "{src}-{tgt}-train-raw.{ext}").format(src=src_code, tgt=tgt_code, ext=tgt_code), y_train)





