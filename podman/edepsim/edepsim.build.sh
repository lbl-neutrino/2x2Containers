#!/usr/bin/env bash

set -o errexit

export NCORES=${NCORES:-16}
echo "Using $NCORES cores"

# ???
# source ~/.bashrc

# FIXME: this is done in core; delete me after full rebuild
source $GEN_DIR/root/install/bin/thisroot.sh
source $GEN_DIR/geant4/install/bin/geant4.sh
evilfile=$GEN_DIR/geant4/install/lib64/Geant4-${GEANT4_VERSION}/Geant4PackageCache.cmake
sed -i 's/EXPAT_LIBRARY ""  ""/EXPAT_LIBRARY "" STRING ""/' $evilfile

### build standalone libTG4Event
### do this before building edep-sim, in case the latter interferes?

cd $GEN_DIR

edepfile=MiniRun3_1E19_RHC.spill.00123.EDEPSIM_SPILLS.root
wget -q https://portal.nersc.gov/project/dune/data/2x2/simulation/productions/MiniRun3_1E19_RHC/MiniRun3_1E19_RHC.spill/EDEPSIM_SPILLS/$edepfile
root -l -b -q $edepfile -e '_file0->MakeProject("libTG4Event", "*", "RECREATE++")'
rm $edepfile

### build edep-sim

cd $GEN_DIR

git clone https://github.com/lbl-neutrino/edep-sim.git
cd edep-sim
# git checkout c7dfcbbffa21933651c82c7c50cb418292f60fb3
git checkout 5fc8fd17be46a64e36e18c535d82c382d2f19c75
cd build
mkdir -p $EDEPSIM
cmake -DCMAKE_INSTALL_PREFIX=$EDEPSIM ../
make -j${NCORES} VERBOSE=1 && make install

