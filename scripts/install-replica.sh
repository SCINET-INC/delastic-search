#!/bin/sh

if [[ "$OSTYPE" == "darwin"* ]]; then
  BINDIR=/usr/local/bin
  OS_FILENAME=macos
else
  BINDIR=$HOME/bin
  OS_FILENAME=linux64
fi

mkdir -p $BINDIR
BIN=$BINDIR/ic-repl
VERSION=0.1.1

wget --output-document $BIN https://github.com/chenyan2002/ic-repl/releases/download/$VERSION/ic-repl-$OS_FILENAME
chmod +x $BIN && $BIN --help