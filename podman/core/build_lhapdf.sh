#!/usr/bin/env bash

source common.inc.sh

cd /build

# what happened to hepforge? nvm
wget https://lhapdf.hepforge.org/downloads/old/lhapdf-5.9.1.tar.gz
# wget https://src.fedoraproject.org/repo/pkgs/lhapdf/lhapdf-5.9.1.tar.gz/5260c1979355243f6584c16a5f19bfd1/lhapdf-5.9.1.tar.gz
tar xzf lhapdf-5.9.1.tar.gz
rm lhapdf-5.9.1.tar.gz
mkdir lhapdf-5.9.1_build
cd lhapdf-5.9.1
# replace/patch configure.ac and m4/python.m4 (or not; python bindings seem hopelessly borked for py3)
# ./configure --prefix=${PWD}/../lhapdf-5.9.1_build
./configure --disable-pyext --prefix="$LHAPDF"
make -j "$NCORES" FFLAGS=-std=legacy && make install
