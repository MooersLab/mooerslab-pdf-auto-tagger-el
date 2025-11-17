![Version](https://img.shields.io/static/v1?label=mooerslab-pdf-auto-tagger-el&message=0.1&color=brightcolor)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)


# Elisp package that uses NLP to generate and add tages to PDF file

## Objective

Automate the generation and addition of tags to PDF files in a selected region in a buffer inside of Emacs.

## Main Functions:

- *mooerslab-tag-pdfs-in-region*: Tag all PDFs listed in a region.
- *mooerslab-show-pdf-tags*: Display tags for a specific PDF.
- *mooerslab-remove-pdf-tags*: Remove tags from a PDF.

## Features

### Two tag extraction methods:

- Simple keyword extraction (no dependencies).
- NLP-based extraction using spaCy (optional, more accurate).

### Customization options:

- *mooerslab-pdf-tagger-use-nlp*: Toggle between simple and NLP extraction.
- *mooerslab-pdf-tagger-max-tags*: Set maximum number of tags.
- *mooerslab-pdf-tagger-python-command*: Specify Python command.

### Smart tag generation:

- Extracts meaningful keywords from titles.
- Recognizes domain-specific terms (programming languages, scientific fields).
- Filters out common stop words.
- Uses lemmatization with spaCy for better results.

## Usage

```elisp
;; Basic usage with simple extraction
(setq mooerslab-pdf-tagger-use-nlp nil)
M-x mooerslab-tag-pdfs-in-region

;; With NLP (requires spaCy: pip install spacy && python -m spacy download en_core_web_sm)
(setq mooerslab-pdf-tagger-use-nlp t)
M-x mooerslab-tag-pdfs-in-region

;; Check tags on a file
M-x mooerslab-show-pdf-tags

;; Remove tags
M-x mooerslab-remove-pdf-tags   
```


## Update history

|Version      | Changes                                                                                                                                                                         | Date                 |
|:-----------|:------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------|
| Version 0.1 |   Added badges, funding, and update table.  Initial commit.                                                                                        | 11/16/2025  |

## Sources of funding

- NIH: R01 CA242845
- NIH: R01 AI088011
- NIH: P30 CA225520 (PI: R. Mannel)
- NIH: P20 GM103640 and P30 GM145423 (PI: A. West)
