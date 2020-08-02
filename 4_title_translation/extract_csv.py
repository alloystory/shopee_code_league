import argparse
import pandas as pd
import opencc
import re
from pathlib import Path

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description = "Extract columns in CSV file")

    parser.add_argument("input_file", type = Path, help = "Input File")
    parser.add_argument("output_file", type = Path, help = "Output File")
    parser.add_argument("column", type = str, help = "Column")
    parser.add_argument("-s", "--simplify", action = "store_true", help = "Convert to simplified chinese")

    args = parser.parse_args()

    if not args.input_file.exists():
        print("Input File {} does not exist!".format(args.input_file))
        exit(1)
    
    if args.output_file.exists():
        print("Output File {} exists!".format(args.output_file))
        exit(1)
        
    print("Started converting '{}'...".format(args.input_file.stem))

    converter = opencc.OpenCC("t2s.json")
    emoji_pattern = re.compile("[(" +
            "\U0001F600-\U0001F92F|" + 
            "\U0001F300-\U0001F5FF|" +
            "\U0001F680-\U0001F6FF|" +
            "\U0001F190-\U0001F1FF|" +
            "\U00002702-\U000027B0|" +
            "\U0001F926-\U0001FA9F|" +
            "\u200d|" +
            "\u2640-\u2642|" +
            "\u2600-\u2B55|" +
            "\u23cf|" +
            "\u23e9|" +
            "\u231a|" +
            "\ufe0f" + 
            ")]+")

    df = pd.read_csv(args.input_file)
    with args.output_file.open("w") as f:
        for row in df[args.column]:
            row = str(row)
            row = emoji_pattern.sub("", row)
            if args.simplify:
                row = converter.convert(row)
            if not row:
                continue
            f.write(row + "\n")

    print("Finished converting")