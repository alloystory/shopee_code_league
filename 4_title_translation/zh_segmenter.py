import jieba
import re
import argparse
import time
import math
import sys
from pathlib import Path

def clean(word):
    if word == "\n":
        return word
    elif word.isspace():
        return None
    return re.sub('\s+', ' ', word).strip()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description = "Tokenize Chinese Document")
    parser.add_argument("input_file", type = argparse.FileType('r'), nargs="?", help = "Input File", default = sys.stdin)
    parser.add_argument("output_file", type = argparse.FileType('w'), nargs="?", help = "Output File", default = sys.stdout)
    args = parser.parse_args()

    if args.output_file != sys.stdout:
        print("Started tokenizing '{}'...".format(args.input_file.name))

    for line in args.input_file:
        seg_list = jieba.cut(line)
        seg_list = map(clean, seg_list)
        seg_list = filter(None, seg_list)
        output = ' '.join(seg_list)
        args.output_file.write(output)

    if args.output_file != sys.stdout:
        print("Finished tokenizing")
