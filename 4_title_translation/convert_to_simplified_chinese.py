import argparse
import opencc
import re
import time
import math
import sys

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description = "Convert Plain Text to Simplified Chinese")
    parser.add_argument("input_file", type = argparse.FileType('r'), nargs="?", help = "Input File", default = sys.stdin)
    parser.add_argument("output_file", type = argparse.FileType('w'), nargs="?", help = "Output File", default = sys.stdout)
    args = parser.parse_args()
    
    if args.output_file != sys.stdout:
        print("Started converting '{}' to simplified chinese...".format(args.input_file.name))

    converter = opencc.OpenCC("t2s.json")
    count = 0
    start_time = time.time()

    for line in args.input_file:
        line = converter.convert(line)
        args.output_file.write(line)

        count += 1
        elapsed_time = time.time() - start_time

        if args.output_file != sys.stdout:
            print("Completed: {} lines, {:.2f} lines/sec".format(count, count / elapsed_time), end = '\r')

    if args.output_file != sys.stdout:
        print()
        print("Finished converting")