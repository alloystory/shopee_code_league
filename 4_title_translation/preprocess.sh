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
# Download Additional Data
cd $DOWNLOAD_DIR
if [ ! -f zhwiki-latest-pages-articles.xml.bz2 ]; then
    wget -c https://dumps.wikimedia.org/zhwiki/latest/zhwiki-latest-pages-articles.xml.bz2
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Downloaded ZH Wiki data"

if [ ! -f enwiki-latest-pages-articles.xml.bz2 ]; then
    wget -c https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-pages-articles.xml.bz2
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Downloaded EN Wiki data"

if [ ! -f en-zh.txt.zip ]; then
    wget -c https://object.pouta.csc.fi/OPUS-MultiUN/v1/moses/en-zh.txt.zip
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Downloaded Parallel MultiUN data"

# -----------------------------------------------------------------------
# Extract Downloaded Data
cd $DOWNLOAD_DIR
if [ ! -f wiki.10m.zh ]; then
    python $TOOLS_DIR/wikiextractor/WikiExtractor.py zhwiki-latest-pages-articles.xml.bz2 --processes 6 -q -o - \
        | sed "/^\s*\$/d" \
        | grep -v "^<doc id=" \
        | grep -v "</doc>\$" \
        | head -10000000 \
        | python $WORKING_DIR/convert_to_simplified_chinese.py > wiki.10m.zh
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Extracted 10M ZH Wiki Data"

if [ ! -f wiki.10m.en ]; then
    python $TOOLS_DIR/wikiextractor/WikiExtractor.py enwiki-latest-pages-articles.xml.bz2 --processes 6 -q -o - \
        | sed "/^\s*\$/d" \
        | grep -v "^<doc id=" \
        | grep -v "</doc>\$" \
        | head -10000000 > wiki.10m.en
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Extracted 10M ZH Wiki Data"

if [[ ! -f MultiUN.en-zh.en || ! -f MultiUN.en-zh.zh ]]; then
    unzip en-zh.txt.zip
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Extracted Parallel MultiUN Data"

# -----------------------------------------------------------------------
# Merge Additional Data
cd $MONO_DATA_DIR
if [ ! -f train.lm.zh ]; then
    shuf -r -n 4000000 $DOWNLOAD_DIR/wiki.10m.zh >> train.lm.zh
    shuf -r -n 1000000 $EXTRACTED_RAW_DATA_DIR/train.zh >> train.lm.zh
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Created 5M ZH XLM Training Data"

if [ ! -f train.lm.en ]; then
    shuf -r -n 4000000 $DOWNLOAD_DIR/wiki.10m.en >> train.lm.en
    shuf -r -n 1000000 $EXTRACTED_RAW_DATA_DIR/train.en >> train.lm.en
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Created 5M EN XLM Training Data"

# -----------------------------------------------------------------------
# Preprocess Training Data (XLM)
cd $WORKING_DIR
if [[ ! -f $MONO_DATA_DIR/train.lm.tok.en || ! -f $MONO_DATA_DIR/train.lm.tok.zh ]]; then
    $ZH_TOKENIZER < $MONO_DATA_DIR/train.lm.zh > $MONO_DATA_DIR/train.lm.tok.zh
    $EN_TOKENIZER < $MONO_DATA_DIR/train.lm.en > $MONO_DATA_DIR/train.lm.tok.en
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Tokenized XLM Training Data"

if [ ! -f $LM_DATA_DIR/codes ]; then
    $FASTBPE learnbpe 80000 $MONO_DATA_DIR/train.lm.tok.en $MONO_DATA_DIR/train.lm.tok.zh > $LM_DATA_DIR/codes
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Created XLM BPE Codes"

if [[ ! -f $MONO_DATA_DIR/train.lm.bpe.en || ! -f $MONO_DATA_DIR/train.lm.bpe.zh ]]; then
    $FASTBPE applybpe $MONO_DATA_DIR/train.lm.bpe.zh $MONO_DATA_DIR/train.lm.tok.zh $LM_DATA_DIR/codes
    $FASTBPE applybpe $MONO_DATA_DIR/train.lm.bpe.en $MONO_DATA_DIR/train.lm.tok.en $LM_DATA_DIR/codes
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Created BPE for XLM Training Data"

if [[ ! -f $MONO_DATA_DIR/train.lm.vocab.en || ! -f $MONO_DATA_DIR/train.lm.vocab.zh ]]; then
    $FASTBPE getvocab $MONO_DATA_DIR/train.lm.bpe.zh > $MONO_DATA_DIR/train.lm.vocab.zh
    $FASTBPE getvocab $MONO_DATA_DIR/train.lm.bpe.en > $MONO_DATA_DIR/train.lm.vocab.en
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Extracted XLM Training Data Vocabulary"

if [ ! -f $LM_DATA_DIR/vocab ]; then
    $FASTBPE getvocab $MONO_DATA_DIR/train.lm.bpe.en $MONO_DATA_DIR/train.lm.bpe.zh > $LM_DATA_DIR/vocab
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Extracted XLM Full Vocabulary"

if [[ ! -f $MONO_DATA_DIR/train.lm.bpe.en.pth || ! -f $MONO_DATA_DIR/train.lm.bpe.zh.pth ]]; then
    python $XLM_DIR/preprocess.py $LM_DATA_DIR/vocab $MONO_DATA_DIR/train.lm.bpe.zh
    python $XLM_DIR/preprocess.py $LM_DATA_DIR/vocab $MONO_DATA_DIR/train.lm.bpe.en
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Binarized XLM Training Data"

# -----------------------------------------------------------------------
# Preprocess XLM Validation Data
cd $WORKING_DIR
if [[ ! -f $PARA_DATA_DIR/valid.lm.en-zh.tok.en || ! -f $PARA_DATA_DIR/valid.lm.en-zh.tok.zh ]]; then
    head -10000 $DOWNLOAD_DIR/MultiUN.en-zh.zh | $ZH_TOKENIZER > $PARA_DATA_DIR/valid.lm.en-zh.tok.zh
    head -10000 $DOWNLOAD_DIR/MultiUN.en-zh.en | $EN_TOKENIZER > $PARA_DATA_DIR/valid.lm.en-zh.tok.en
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Tokenized XLM Validation Data"

if [[ ! -f $PARA_DATA_DIR/valid.lm.en-zh.bpe.en || ! -f $PARA_DATA_DIR/valid.lm.en-zh.bpe.zh ]]; then
    $FASTBPE applybpe $PARA_DATA_DIR/valid.lm.en-zh.bpe.zh $PARA_DATA_DIR/valid.lm.en-zh.tok.zh $LM_DATA_DIR/codes $MONO_DATA_DIR/train.lm.vocab.zh
    $FASTBPE applybpe $PARA_DATA_DIR/valid.lm.en-zh.bpe.en $PARA_DATA_DIR/valid.lm.en-zh.tok.en $LM_DATA_DIR/codes $MONO_DATA_DIR/train.lm.vocab.en
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Created BPE for XLM Validation Data"

if [[ ! -f $PARA_DATA_DIR/valid.lm.en-zh.bpe.en.pth || ! -f $PARA_DATA_DIR/valid.lm.en-zh.bpe.zh.pth ]]; then
    python $XLM_DIR/preprocess.py $LM_DATA_DIR/vocab $PARA_DATA_DIR/valid.lm.en-zh.bpe.zh
    python $XLM_DIR/preprocess.py $LM_DATA_DIR/vocab $PARA_DATA_DIR/valid.lm.en-zh.bpe.en
fi
echo "`date +'%d-%m-%y %H:%M:%S'` - Binarized XLM Validation Data"

# -----------------------------------------------------------------------
# Link Final Data
ln -sf $MONO_DATA_DIR/train.lm.bpe.zh.pth $LM_DATA_DIR/train.zh.pth
ln -sf $MONO_DATA_DIR/train.lm.bpe.en.pth $LM_DATA_DIR/train.en.pth

ln -sf $PARA_DATA_DIR/valid.lm.en-zh.bpe.en.pth $LM_DATA_DIR/valid.en-zh.en.pth
ln -sf $PARA_DATA_DIR/valid.lm.en-zh.bpe.zh.pth $LM_DATA_DIR/valid.en-zh.zh.pth
ln -sf $PARA_DATA_DIR/valid.lm.en-zh.bpe.en.pth $LM_DATA_DIR/valid.en.pth
ln -sf $PARA_DATA_DIR/valid.lm.en-zh.bpe.zh.pth $LM_DATA_DIR/valid.zh.pth

ln -sf $PARA_DATA_DIR/valid.lm.en-zh.bpe.en.pth $LM_DATA_DIR/test.en-zh.en.pth
ln -sf $PARA_DATA_DIR/valid.lm.en-zh.bpe.zh.pth $LM_DATA_DIR/test.en-zh.zh.pth
ln -sf $PARA_DATA_DIR/valid.lm.en-zh.bpe.en.pth $LM_DATA_DIR/test.en.pth
ln -sf $PARA_DATA_DIR/valid.lm.en-zh.bpe.zh.pth $LM_DATA_DIR/test.zh.pth

echo "`date +'%d-%m-%y %H:%M:%S'` - Finished Preprocessing XLM Data"