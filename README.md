
Extract address, charity name and number as well as annual income and spending from reports of British charities.
=====================================================================================

The goal of this task is to retrieve charity address (but not other
addresses), charity number, charity name and its annual income and
spending in GBP (British Pounds) in PDF files published by British
charities.

Note that this an information extraction task, you are given keys
(labels, attribute names) and you are expected to guess their
respective values. It is not a NER task, we are not interested in
where the information or entity is to be found, just the information
itself.

The metric used is F1 score calculated on upper-cased values. As an
auxiliary metric, also F1 on true-cased values is calculated.

It should not be assumed that for each key, a corresponding value is
to be extracted from a document. There might be some “decoy” keys, for
which no value should be given.

You are allowed to give more than one value, even if one is expected
(e.g. if you have two options, but you are not sure which is right),
though, of course, the metric will be lower than just guessing the
right value.

Evaluation
----------

You can carry out evaluation using the [GEval](https://gitlab.com/filipg/geval),
when you generate `out.tsv` files (in the same format as `expected.tsv` files):

```
wget https://gonito.net/get/bin/geval
chmod u+x geval
./geval -t dev-0
```

Textual and graphical features
------------------------------

1D (textual) and/or 2D (graphical) features can be considered, as both
the PDF documents and the extracted text is available. We provide 4 different text outputs based on:
* pdf2djvu/djvu2hocr tools, ver. `0.9.8`,
* tesseract tool, ver. `4.1.1-rc1-7-gb36c`, ran with `--oem 2 -l eng --dpi 300` flags
(meaning both new and old OCR engines were used simultaneously, and language and pixel
density were forced for better results),
* textract tool, ver. `March 1, 2020`,
* combination of pdf2djvu/djvu2hocr and tesseract tools. Documents are processed with both tools, by
default we take the text from pdf2djvu/djvu2hocr, unless the text returned by tesseract is 1000
characters longer.

It should not be assumed that the OCR-ed text layer is perfect.
You are free to use alternative OCR software.

The texts are neither tokenized nor pre-processed in any manner.

Git-annex
---------

The data is not treated as sensitive, but the PDF files are stored
with [git-annex](https://git-annex.branchable.com/) due to their total
large size (12GB).

You need to get the actual documents from storage using git-annex:

    ./annex-get-all-from-s3.sh

Use this **only** if you need documents for training. If you only need
documents for generating output for tests, use the following script:

    ./annex-get-test-documents-from-s3.sh

This will download only documents for dev-0 and test-A test sets (2.23GB).

Note that if you operate only on texts, you do *not* need either
script, do not run them if it is not really necessary!

Directory structure
-------------------

* `README.md` — this file
* `config.txt` — GEval configuration file
* `in-header.tsv` — one-line TSV file with column names for input data (features),
* `train/` — directory with training data
* `train/in.tsv.xz` — input data for the train set
* `train/expected.tsv` — expected (reference) data for the train set
* `dev-0/` — directory with dev (test) data from the same sources as the train set
* `dev-0/in.tsv.xz` — input data for the dev set
* `dev-0/expected.tsv` — expected (reference) data for the dev set
* `test-A` — directory with test data
* `test-A/in.tsv.xz` — input data for the test set
* `test-A/expected.tsv` — expected (reference) data for the test set (hidden) ⦃make sure this file is not committed to `master`, only to `dont-peek`⦄
* `documents/` — all documents (for train, dev-0 and test-A), they are references in TSV files

Note that we mean TSV, *not* CSV files. In particular, double quotes
are not considered special characters here! In particular, set
`quoting` to `QUOTE_NONE` in the Python `csv` module:

    import csv
    with open('file.tsv', 'r') as tsvfile:
        reader = csv.reader(tsvfile, delimiter='\t', quoting=csv.QUOTE_NONE)
        for item in reader:
            ...

The files are sorted by MD5 sum hashes.

Structure of data sets
----------------------

The original dataset was split into train, dev-0 and test-A subsets in
a stable pseudorandom manner using the hashes (fingerprints) of the
document contents ⦃hashes might be calculated on other things, e.g. on
company names, in order to avoid two documents from the same company
being in two different splits (one in the train set, one in a test
set).⦄

* the train set contains 1729 items,
* the dev-0 set contains 440 items,
* the test-A set contains 609 items.


Format of the test sets
-----------------------

The input file (`in.tsv.xz`) consists of 3 TAB-separated columns:

The input file (`in.tsv.xz`) consists of 6 TAB-separated columns:

* the file name of the document (MD5 sum for binary contents with the
  right extension), to be taken from the `documents/' subdirectory,
* list of keys in alphabetical order to be considered during
  prediction, keys are given in English with underscores in place of
  spaces and are separated with spaces,
* the plain text extracted by pdf2djvu/djvu2hocr tools from the document with the end-of-lines
  TABs and non-printable characters replaced with spaces (so that they
  would not be confused with TSV special characters),
* the plain text extracted by tesseract tool from the document with the end-of-lines
  TABs and non-printable characters replaced with spaces (so that they
  would not be confused with TSV special characters),
* the plain text extracted by textract tool from the document with the end-of-lines
  TABs and non-printable characters replaced with spaces (so that they
  would not be confused with TSV special characters),
* the plain text extracted by combination of pdf2djvu/djvu2hocr and tesseract tools
  from the document with the end-of-lines TABs and non-printable characters replaced
  with spaces (so that they would not be confused with TSV special characters).

The `expected.tsv` file is just a list of key-value pairs sorted
alphabetically (by keys). Pairs are separated with spaces, value is
separated from a key with the equals sign (`=`). The spaces and colons in values are
replaced with underscores.

Escaping special characters
---------------------------

The following escape sequences are used for the OCR-ed text:

* `\f` — page break (`^L`)
* `\n` — end of line,
* `\t` — tabulation
* `\\` — literal backslash

Information to be extracted
---------------------------

The data of interest are:

* `address__post_town` — post town of the address of the charitable organization (**in upper-case letters**),
* `address__postcode` — postcode of the address of the charitable organization (**in upper-case letters**),
* `address__street_line` — street line of the address of the charitable organization,
* `charity_name` — the name of the charitable organization (**in upper-case letters**),
* `charity_number` — the registered number of the charitable organization,
* `income_annually_in_british_pounds` — the annual income in British Pounds of the charitable organization,
* `report_date` — the reporting date of the annual document of the charitable organization,
* `spending_annually_in_british_pounds` — the annual spending in British Pounds of the charitable organization.

You can find detailed description of the address part on [this](https://alliescomputing.com/knowledge-base/how-to-address-uk-mail-correctly) website.

Normalization
-------------

The expected pieces of information were normalized to some degree:

### Dates

* the attribute name contains word `date`,
* the attribute values should are in the `YYYY-MM-DD` (ISO8601) format
  (be careful when converting from other formats, be sure whether you are
  converting from `DD-MM-YYYY` or from the American `MM-DD-YYYY` format).

### Monetary values

As for attribute names:

* monetary attributes end with currency name (British Pounds in this dataset).

As for attribute values:

* the value is given as a real number with two digits after decimal separator
  (dot in this case, e.g. `1000000.00`, `1590.50`, `230.03`).

Format of the output files for test sets
----------------------------------------

The format of the output is the same as the format of
`expected.tsv` files. The order of key-value pairs does not matter.

Sources
-------

The data were downloaded from https://www.gov.uk/government/organisations/charity-commission.

Data was filtered only to english language.
