import argparse
import pandas as pd

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description = "Process Test Result")
    parser.add_argument("--input_file", type = argparse.FileType('r'), help = "Input File", required = True)
    parser.add_argument("--output_file", type = argparse.FileType('w'), help = "Output File", required = True)
    args = parser.parse_args()

    output = []
    for line in args.input_file:
        line = line.replace("@@ ", "")
        line = line.replace("\n", "")
        output.append([line])

    df = pd.DataFrame(output, columns = ["translation_output"])
    df.to_csv(args.output_file, index = False)