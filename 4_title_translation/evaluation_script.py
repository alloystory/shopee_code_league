# product_title_translation_eval_script.py
"""Sample evaluation script for product title translation."""

import re
from typing import List

import regex
from sacrebleu import corpus_bleu

OTHERS_PATTERN: re.Pattern = regex.compile(r'\p{So}')


def eval(preds: List[str], refs: List[str]) -> float:
    """BLEU score computation.

    Strips all characters belonging to the unicode category "So".
    Tokenize with standard WMT "13a" tokenizer.
    Compute 4-BLEU.

    Args:
        preds (List[str]): List of translated texts.
        refs (List[str]): List of target reference texts.
    """
    preds = [OTHERS_PATTERN.sub(' ', text) for text in preds]
    refs = [OTHERS_PATTERN.sub(' ', text) for text in refs]
    return corpus_bleu(
        preds, [refs],
        lowercase=True,
        tokenize='13a',
        use_effective_order= False
    ).score
