#!/usr/bin/env bash

source common.inc.sh

cd /build

git clone -b "$GENIE_VERSION" https://github.com/GENIE-MC/Generator.git
cd Generator
sed -i 's/g77/gfortran/g' src/make/Make.include

## Need to copy a file from GENIE into LHAPDF... pretty mad!
cp data/evgen/pdfs/GRV98lo_patched.LHgrid "$LHAPATH"

# The configure script expects GENIE to point to the _source_
# But our convention is that it points to the install
genieInstall=$GENIE
export GENIE=$PWD

./configure \
  --prefix="$genieInstall" \
  --enable-fnal \
  --with-pythia6-lib="$PYTHIA6" \
  --with-lhapdf-inc="$LHAPDF_INC" \
  --with-lhapdf-lib="$LHAPDF_LIB" \
  --with-libxml2-inc="$LIBXML2_INC" \
  --with-libxml2-lib="$LIBXML2_LIB"

make -j "$NCORES" && make install

export GENIE=$genieInstall

# y no get install
mv config data VERSION $GENIE

## Shut GENIE up when it runs
cp "$GENIE"/config/Messenger_whisper.xml "$GENIE"/config/Messenger.xml

## Have to mess around with the file to actually shut it up though...
sed -i '$ d' "$GENIE"/config/Messenger.xml # delete last line
echo '  <priority msgstream="ResonanceDecay">      FATAL </priority>' >> "$GENIE"/config/Messenger.xml
echo '  <priority msgstream="Pythia6Decay">        FATAL </priority>' >> "$GENIE"/config/Messenger.xml
echo '  <priority msgstream="INukeNucleonCorr">    FATAL </priority>' >> "$GENIE"/config/Messenger.xml
echo '  <priority msgstream="gevgen_fnal">         FATAL </priority>' >> "$GENIE"/config/Messenger.xml
echo '</messenger_config>' >> "$GENIE"/config/Messenger.xml
