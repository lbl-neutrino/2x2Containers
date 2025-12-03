#!/usr/bin/env bash

set -o errexit

export NCORES=${NCORES:-16}
echo "Using $NCORES cores"

## build standalone libTG4Event first
cd /build
prod=MiniRun5_1E19_RHC
edepfile=$prod.spill.00123.EDEPSIM_SPILLS.root
baseUrl=https://portal.nersc.gov/project/dune/data/2x2/simulation/productions
wget -q $baseUrl/$prod/$prod.spill/EDEPSIM_SPILLS/$edepfile
code="_file0->MakeProject(\"$GEN_DIR/libTG4Event\", \"*\", \"RECREATE++\")"
root -l -b -q "$edepfile" -e "$code"
rm $edepfile

## build yaml-cpp (needed by MPV/MPR generator)
cd /build
git clone https://github.com/jbeder/yaml-cpp.git
cd yaml-cpp
git checkout 0.8.0
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX="$EDEPSIM" ../
make -j "$NCORES" install

## build the MPV/MPR generator itself (in-place)
cd $GEN_DIR
git clone https://github.com/DeepLearnPhysics/DLPGenerator
cd DLPGenerator
git checkout 1af8cbfa13db5478542a3da9e9b61c57fa617d38
source setup.sh
make -j "$NCORES"

## build edep-sim
cd /build
git clone https://github.com/DUNE/edep-sim.git
cd edep-sim
git checkout f3a96fc7dd84440f837959c106984733507281e5
cd build
cmake -DCMAKE_INSTALL_PREFIX="$EDEPSIM" ../
make -j "$NCORES" install
