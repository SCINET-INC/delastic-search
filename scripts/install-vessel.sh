if [[ "$OSTYPE" == "darwin"* ]]; then
  BINDIR=/usr/local/bin
  OS_FILENAME=macos
else
  BINDIR=$HOME/bin
  OS_FILENAME=linux64
fi

mkdir -p $BINDIR
BIN=$BINDIR/vessel
VERSION=v0.6.3

wget --output-document $BIN https://github.com/dfinity/vessel/releases/download/$VERSION/vessel-$OS_FILENAME
chmod +x $BIN && $BIN help