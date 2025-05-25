import spacy
import re
from tqdm import tqdm
import string
import sys

py_nlp = spacy.load("en_core_web_md")
dictionary_path = sys.argv[1]
src_lang = sys.argv[2]
tgt_lang = sys.argv[3]
domain = sys.argv[4]
target_lang_name = sys.argv[5]
main_raw_data_path = sys.argv[6]

punctuations = string.punctuation + "–" + "." + '\"' + "\n" + "’" + "\’" + "\'"

## loading the dictionary first
    
dictionary = {}
with open(dictionary_path, "r") as dict:
    all_lines = dict.readlines()
    for line in all_lines:
        src, tgt = line.split("///", 1)
        if tgt.endswith("\n"):
            tgt = tgt[:-1]
        if len(src) > 0 and len(tgt) > 0:
            dictionary[src.lower()] = tgt.lower()
    

extra_tgt = []
extra_src = []

r = re.compile(r"^\d+[.,]?\d*$") ## to see if it's a number


read_path = "{path}/{dom}/{target_lang}/train/{sr}-{tg}-train-raw.{ex}".format(path=main_raw_data_path, dom=domain, target_lang = target_lang_name, sr = src_lang, tg = tgt_lang, ex = src_lang)
## maybe we could search for lemmatized version of words in the dictionary instead??
with open(read_path, "r") as mono:
    lines = mono.readlines()
    for line in tqdm(lines, total = len(lines)):
        # lowered = line.lower()
        lowered = line.lower()
        tokens = py_nlp(lowered)
        new_src = []
        new_tgt = []
        i = 0
        while(i < len(tokens)):
            if tokens[i].text.lower() in dictionary.keys():
                new_src.append(tokens[i].text.lower())
                new_tgt.append(dictionary[tokens[i].text.lower()])
            elif tokens[i].lemma_.lower() in dictionary.keys():
                new_src.append(tokens[i].lemma_.lower())
                new_tgt.append(dictionary[tokens[i].lemma_.lower()])
            else:
                # used to be just numbers and punctuations, but DALI simply copies if it can't find replacements. 
                new_src.append(tokens[i].text.lower())
                new_tgt.append(tokens[i].text.lower())
            i += 1
            
            
        src_str = " ".join(new_src)
        tgt_str = " ".join(new_tgt)

        if len(src_str) > 1 and len(tgt_str) > 1: ## more than just '.'
            extra_src.append(src_str)
            extra_tgt.append(tgt_str)

 

def write_to_file(file_name, list_):
    with open(file_name, 'w') as f1:
        for i, t in enumerate(list_):
            if i != (len(list_) - 1) and t[-1] != '\n':
                f1.write(t+"\n")
            else:
                f1.write(t)
    
    print(file_name)


write_to_file("{path}/{dom}/{target_lang}/train/{sr}-{tg}-train.{ex}".format(path=main_raw_data_path, dom=domain, target_lang = target_lang_name, sr = src_lang, tg = tgt_lang, ex = src_lang), extra_src)
write_to_file("{path}/{dom}/{target_lang}/train/{sr}-{tg}-train.{ex}".format(path=main_raw_data_path, dom=domain, target_lang = target_lang_name, sr = src_lang, tg = tgt_lang, ex = tgt_lang), extra_tgt)

        


