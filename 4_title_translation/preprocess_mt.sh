#!/bin/bash
# USE_PRETRAINED=false

# Directory
WORKING_DIR=$PWD
DATA_DIR=$WORKING_DIR/data
DOWNLOAD_DIR=$DATA_DIR/downloaded
PROCESSED_DATA_DIR=$DATA_DIR/processed
RAW_DATA_DIR=$DATA_DIR/raw
EXTRACTED_RAW_DATA_DIR=$RAW_DATA_DIR/extracted
LM_DATA_DIR=$PROCESSED_DATA_DIR/lm
UMT_DATA_DIR=$PROCESSED_DATA_DIR/umt
MONO_DATA_DIR=$PROCESSED_DATA_DIR/mono
PARA_DATA_DIR=$PROCESSED_DATA_DIR/para
XLM_DIR=$WORKING_DIR/XLM
TOOLS_DIR=$XLM_DIR/tools

mkdir -p $DOWNLOAD_DIR
mkdir -p $PROCESSED_DATA_DIR
mkdir -p $RAW_DATA_DIR
mkdir -p $EXTRACTED_RAW_DATA_DIR
mkdir -p $LM_DATA_DIR
mkdir -p $UMT_DATA_DIR
mkdir -p $MONO_DATA_DIR
mkdir -p $PARA_DATA_DIR

ZH_TOKENIZER="python $WORKING_DIR/zh_segmenter.py"
EN_TOKENIZER="$TOOLS_DIR/mosesdecoder/scripts/tokenizer/tokenizer.perl -l en -threads 6"
FASTBPE=$TOOLS_DIR/fastBPE/fast

# -----------------------------------------------------------------------
# Download all dependencies
if [ ! -d $XLM_DIR ]; then
    git clone https://github.com/facebookresearch/XLM.git
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Cloned XLM Repository"

cd $XLM_DIR
if [ ! -d $TOOLS_DIR/mosesdecoder ]; then
    bash install-tools.sh
fi

echo "`date +'%d-%m-%y %H:%M:%S'` - Installed Tools"

# -----------------------------------------------------------------------
# Extract Training Data
cd $WORKING_DIR
if [ ! -f $EXTRACTED_RAW_DATA_DIR/train.zh ]; then
    python extract_csv.py $RAW_DATA_DIR/train_tcn.csv $EXTRACTED_RAW_DATA_DIR/train.zh product_title --simplify
fi

if [ ! -f $EXTRACTED_RAW_DATA_DIR/train.en ]; then
    python extract_csv.py $RAW_DATA_DIR/train_en.csv $EXTRACTED_RAW_DATA_DIR/train.en product_title
fi

if [ ! -f $EXTRACTED_RAW_DATA_DIR/dev.zh ]; then
    python extract_csv.py $RAW_DATA_DIR/dev_tcn.csv $EXTRACTED_RAW_DATA_DIR/dev.zh text --simplify
fi

if [ ! -f $EXTRACTED_RAW_DATA_DIR/dev.en ]; then
    python extract_csv.py $RAW_DATA_DIR/dev_en.csv $EXTRACTED_RAW_DATA_DIR/dev.en translation_output
fi

if [ ! -f $EXTRACTED_RAW_DATA_DIR/test.zh ]; then
    python extract_csv.py $RAW_DATA_DIR/test_tcn.csv $EXTRACTED_RAW_DATA_DIR/test.zh text --simplify
fi

echo "`date +'%d-%m-%y %H:%M:%S'` - Extracted Training Data"

# -----------------------------------------------------------------------
# Preprocess Training Data (MT)
cd $WORKING_DIR
if [[ ! -f $MONO_DATA_DIR/train.mt.tok.en || ! -f $MONO_DATA_DIR/train.mt.tok.zh ]]; then
    $ZH_TOKENIZER < $EXTRACTED_RAW_DATA_DIR/train.zh > $MONO_DATA_DIR/train.mt.tok.zh
    $EN_TOKENIZER < $EXTRACTED_RAW_DATA_DIR/train.en > $MONO_DATA_DIR/train.mt.tok.en
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Tokenized MT Training Data"

if [[ ! -f $MONO_DATA_DIR/train.mt.bpe.en || ! -f $MONO_DATA_DIR/train.mt.bpe.zh ]]; then
    $FASTBPE applybpe $MONO_DATA_DIR/train.mt.bpe.zh $MONO_DATA_DIR/train.mt.tok.zh $LM_DATA_DIR/codes
    $FASTBPE applybpe $MONO_DATA_DIR/train.mt.bpe.en $MONO_DATA_DIR/train.mt.tok.en $LM_DATA_DIR/codes
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Created BPE for MT Training Data"

if [[ ! -f $MONO_DATA_DIR/train.mt.vocab.en || ! -f $MONO_DATA_DIR/train.mt.vocab.zh ]]; then
    $FASTBPE getvocab $MONO_DATA_DIR/train.mt.bpe.zh > $MONO_DATA_DIR/train.mt.vocab.zh
    $FASTBPE getvocab $MONO_DATA_DIR/train.mt.bpe.en > $MONO_DATA_DIR/train.mt.vocab.en
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Extracted MT Training Data Vocabulary"

if [[ ! -f $MONO_DATA_DIR/train.mt.bpe.en.pth || ! -f $MONO_DATA_DIR/train.mt.bpe.zh.pth ]]; then
    python $XLM_DIR/preprocess.py $LM_DATA_DIR/vocab $MONO_DATA_DIR/train.mt.bpe.zh
    python $XLM_DIR/preprocess.py $LM_DATA_DIR/vocab $MONO_DATA_DIR/train.mt.bpe.en
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Binarized MT Training Data"

# -----------------------------------------------------------------------
# Preprocess MT Validation Data
cd $WORKING_DIR
if [[ ! -f $PARA_DATA_DIR/valid.mt.en-zh.tok.en || ! -f $PARA_DATA_DIR/valid.mt.en-zh.tok.zh ]]; then
    $ZH_TOKENIZER < $EXTRACTED_RAW_DATA_DIR/dev.zh > $PARA_DATA_DIR/valid.mt.en-zh.tok.zh
    $EN_TOKENIZER < $EXTRACTED_RAW_DATA_DIR/dev.en > $PARA_DATA_DIR/valid.mt.en-zh.tok.en
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Tokenized MT Validation Data"

if [[ ! -f $PARA_DATA_DIR/valid.mt.en-zh.bpe.en || ! -f $PARA_DATA_DIR/valid.mt.en-zh.bpe.zh ]]; then
    $FASTBPE applybpe $PARA_DATA_DIR/valid.mt.en-zh.bpe.zh $PARA_DATA_DIR/valid.mt.en-zh.tok.zh $LM_DATA_DIR/codes $MONO_DATA_DIR/train.mt.vocab.zh
    $FASTBPE applybpe $PARA_DATA_DIR/valid.mt.en-zh.bpe.en $PARA_DATA_DIR/valid.mt.en-zh.tok.en $LM_DATA_DIR/codes $MONO_DATA_DIR/train.mt.vocab.en
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Created BPE for MT Validation Data"

if [[ ! -f $PARA_DATA_DIR/valid.mt.en-zh.bpe.en.pth || ! -f $PARA_DATA_DIR/valid.mt.en-zh.bpe.zh.pth ]]; then
    python $XLM_DIR/preprocess.py $LM_DATA_DIR/vocab $PARA_DATA_DIR/valid.mt.en-zh.bpe.zh
    python $XLM_DIR/preprocess.py $LM_DATA_DIR/vocab $PARA_DATA_DIR/valid.mt.en-zh.bpe.en
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Binarized MT Validation Data"

# -----------------------------------------------------------------------
# Link Final Data
ln -sf $MONO_DATA_DIR/train.mt.bpe.zh.pth $UMT_DATA_DIR/train.zh.pth
ln -sf $MONO_DATA_DIR/train.mt.bpe.en.pth $UMT_DATA_DIR/train.en.pth

ln -sf $PARA_DATA_DIR/valid.mt.en-zh.bpe.en.pth $UMT_DATA_DIR/valid.en-zh.en.pth
ln -sf $PARA_DATA_DIR/valid.mt.en-zh.bpe.zh.pth $UMT_DATA_DIR/valid.en-zh.zh.pth
ln -sf $PARA_DATA_DIR/valid.mt.en-zh.bpe.en.pth $UMT_DATA_DIR/valid.en.pth
ln -sf $PARA_DATA_DIR/valid.mt.en-zh.bpe.zh.pth $UMT_DATA_DIR/valid.zh.pth

ln -sf $PARA_DATA_DIR/valid.mt.en-zh.bpe.en.pth $UMT_DATA_DIR/test.en-zh.en.pth
ln -sf $PARA_DATA_DIR/valid.mt.en-zh.bpe.zh.pth $UMT_DATA_DIR/test.en-zh.zh.pth
ln -sf $PARA_DATA_DIR/valid.mt.en-zh.bpe.en.pth $UMT_DATA_DIR/test.en.pth
ln -sf $PARA_DATA_DIR/valid.mt.en-zh.bpe.zh.pth $UMT_DATA_DIR/test.zh.pth

echo "`date +'%d-%m-%y %H:%M:%S'` - Finished Preprocessing MT Data"