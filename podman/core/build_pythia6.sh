#!/usr/bin/env bash

source common.inc.sh

cd /build

## Get PYTHIA6 (with specific placement for NuWro)
## NOTE: We no longer put libPythia6.so in the ROOT source directory
## since we delete that in order to keep the container lightweight.
## This *shouldn't* break NuWro(?)
wget --no-check-certificate http://root.cern.ch/download/pythia6.tar.gz
tar -xzvf pythia6.tar.gz
rm -f pythia6.tar.gz
wget --no-check-certificate https://pythia.org/download/pythia6/pythia6428.f
mv pythia6428.f pythia6/pythia6428.f
rm pythia6/pythia6416.f

cd pythia6

## Newer gcc has -fno-common as default, which would require adding the 'extern'
## keyword everywhere in pythia_common_address.c.
# alias gcc='gcc -fcommon'

# NOTE: Above doesn't seem to work for newer gcc, so instead we "extern"
# everything except pyuppr
sed -i '51,72s/^/extern /' pythia6_common_address.c
sed -i 's/extern int pyuppr/int pyuppr/' pythia6_common_address.c

## source it so that it picks up any aliases
# source ./makePythia6.linuxx8664
./makePythia6.linuxx8664
# unalias gcc

mkdir -p "$PYTHIA6"
mv libPythia6.so "$PYTHIA6"

## old placement:
# mkdir ${GEN_DIR}/root/lib
# cp ${GEN_DIR}/pythia6/libPythia6.so ${GEN_DIR}/root/lib/.
