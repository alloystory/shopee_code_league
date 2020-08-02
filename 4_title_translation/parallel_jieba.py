import jieba
import re
import argparse
import time
import math
from pathlib import Path
from multiprocessing import Pool

def clean(word):
    if word == "\n":
        return word
    elif word.isspace():
        return None
    return re.sub('\s+', ' ', word).strip()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description = "Tokenize Chinese Document")
    parser.add_argument("input_file", type = Path, help = "Input File")
    parser.add_argument("output_file", type = Path, help = "Output File")
    args = parser.parse_args()

    jieba.enable_parallel()
    with args.input_file.open('rb') as f:
        with args.output_file.open('w') as g:
            print("Started tokenizing '{}'...".format(args.input_file.name))

            chunk_count = 0
            chunk_size = 100 * 1024 * 1024 # 100MB
            num_chunks = math.ceil(args.input_file.stat().st_size / chunk_size)
            start_time = time.time()

            print("Completed: {}/{} chunks".format(chunk_count, num_chunks), end = '\r')
            while True:
                chunk = f.read(chunk_size)
                if not chunk:
                    break
                
                seg_list = jieba.cut(chunk)
                # with Pool() as p:
                #     seg_list = p.map(clean, seg_list)
                # output = ' '.join(filter(None, seg_list))
                output = ' '.join(seg_list)
                g.write(output)

                chunk_count += 1
                elapsed_time = time.time() - start_time
                print("Completed: {}/{} chunks, {:.2f} MB/sec".format(
                        chunk_count, num_chunks, (chunk_count * chunk_size / (1024 * 1024)) / elapsed_time), end = '\r')

            print()
            print("Finished tokenizing")
