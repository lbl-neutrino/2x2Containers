#!/usr/bin/env bash

set -o errexit

export NCORES=${NCORES:-16}
echo "Using $NCORES cores"

## build standalone libTG4Event first
cd /build
edepfile=MiniRun3_1E19_RHC.spill.00123.EDEPSIM_SPILLS.root
wget -q https://portal.nersc.gov/project/dune/data/2x2/simulation/productions/MiniRun3_1E19_RHC/MiniRun3_1E19_RHC.spill/EDEPSIM_SPILLS/$edepfile
root -l -b -q "$edepfile" -e "_file0->MakeProject(\"$GEN_DIR/libTG4Event\", \"*\", \"RECREATE++\")"
rm $edepfile

## build edep-sim
cd /build
git clone https://github.com/lbl-neutrino/edep-sim.git
cd edep-sim
# git checkout c7dfcbbffa21933651c82c7c50cb418292f60fb3
git checkout 5fc8fd17be46a64e36e18c535d82c382d2f19c75
cd build
cmake -DCMAKE_INSTALL_PREFIX="$EDEPSIM" ../
make -j "$NCORES" install
