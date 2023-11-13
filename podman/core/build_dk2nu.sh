#!/usr/bin/env bash

source common.inc.sh

cd /build
git clone https://github.com/NuSoftHEP/dk2nu.git
cd dk2nu
mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX="$DK2NU" \
  -DCMAKE_CXX_STANDARD=20 \
  -DWITH_TBB=OFF \
  ../

# good times
ln -s $GENIE/include/GENIE $GENIE/src

make -j "$NCORES" install
