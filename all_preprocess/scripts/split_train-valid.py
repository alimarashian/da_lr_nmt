from sklearn.model_selection import train_test_split
import sys

def read_file(path):

    lines = []
    with open(path, 'r') as file:
        lines = file.readlines()
        lines = [x.strip().lower() for x in lines]

    return lines


def write_file(list_, path):

    with open(path, "w") as file:
        for i, line in enumerate(list_):
            if i != len(list_) - 1:
                file.write(line + "\n")
            else:
                file.write(line)


source_lang = sys.argv[1]
target_lang = sys.argv[2]
path_ = sys.argv[3]
target_lang_name = sys.argv[4]
valid_size = float(sys.argv[5])
seed = int(sys.argv[6])


path_ = path_ + target_lang_name +"/"
src_doc = read_file(path_ + "bible." + source_lang)
tgt_doc = read_file(path_ + "bible." + target_lang)

X_train, X_test, y_train, y_test = train_test_split(
    src_doc, tgt_doc, test_size=valid_size, random_state=seed)

write_file(X_train, path_ + "bible-train-"+source_lang + "-" +target_lang+ "."+source_lang)
write_file(X_test,  path_ + "bible-valid-"+source_lang + "-" +target_lang+ "."+source_lang)
write_file(y_train, path_ + "bible-train-"+source_lang + "-" +target_lang+ "."+target_lang)
write_file(y_test,  path_ + "bible-valid-"+source_lang + "-" +target_lang+ "."+target_lang)

