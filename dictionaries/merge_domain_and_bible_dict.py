
def read_dictionary(path):

    dic = {}
    
    with open(path, "r") as file:
        all_lines = file.readlines()
        lines = [x.strip() for x in all_lines]
        print(len(lines))
        for line in lines:
            if len(line.split("///")) < 2:
                print("nooo")
                breakpoint()

            src, tgt = line.split("///")
            if len(src) > 0 and len(tgt) > 0:
                dic[src] = tgt

    
    return dic



domain_dict = read_dictionary("PATH_TO_DOMAIN_DICT")
bible_dict = read_dictionary("PATH_TO_DICT_ELICITED_FROM_BIBLE")

bible_keys = bible_dict.keys()


print(len(domain_dict.keys()))
print(len(bible_dict.keys()))

for key in bible_keys:
    if key not in domain_dict.keys():
        domain_dict[key] = bible_dict[key]

eng_side = list(domain_dict.keys())

with open("Maltese/news/en-ml-news-merged.txt", 'w') as merged:
    for eng_ in eng_side:
        merged.write("{}///{}\n".format(eng_.rstrip().lower(), domain_dict[eng_].rstrip().lower()))


