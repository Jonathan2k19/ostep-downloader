#! /bin/bash

################################################################################
# Script to get a PDF of the 'Operating Systems: Three Easy Pieces' book.
# Might break in future versions of the website (last tested: 16th April 2024).
################################################################################

OSTEP_WEBSITE=https://pages.cs.wisc.edu/~remzi/OSTEP/
TMP_DIR=/tmp/ostep_chapters
OUT_FILE=ostep.pdf

echo Download website to collect chapter names and their order ...
files=$(curl -# $OSTEP_WEBSITE \
    | grep -oE '<small>[0-9]+</small>.*\.pdf' \
    | sed -E 's/<small>//; s/<\/small>//; s/\s.*href=/_/' \
    | sort -n \
    | sed -E '/^1_/ i\preface.pdf\ntoc.pdf') # preface-/toc.pdf not numbered
echo Done.

echo Create temporary directory for storing single chapters ...
rm -rf $TMP_DIR && mkdir $TMP_DIR
echo Done.

echo Download all chapters ...
for f in $files; do
    if [ "$f" = "preface.pdf" ] || [ "$f" = "toc.pdf" ]; then
        fname=$f
    else
        fname=$(echo $f | awk -F '_' '{print $2}')
    fi
    echo $fname
    curl -# $OSTEP_WEBSITE$fname --output $TMP_DIR/$f
done
echo Done.

echo Merge all chapters into $OUT_FILE ...
OUT_DIR=$(pwd)
cd $TMP_DIR
pdfunite $(ls *.pdf | sort -n) $OUT_DIR/$OUT_FILE
echo Done.

echo Clean up.
rm -rf $TMP_DIR
echo Done.
