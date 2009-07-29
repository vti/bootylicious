#!/bin/sh

TITLE=$1
ARTICLES_DIR='articles'
DATE=`date +%Y%m%d`
FILENAME="$ARTICLES_DIR/$DATE-$TITLE.pod"
EDITOR='vim +3'

mkdir -p $ARTICLES_DIR

cat > $FILENAME << EOF
=head1 NAME

$TITLE
EOF

$EDITOR $FILENAME
