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