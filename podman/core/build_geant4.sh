#!/usr/bin/env bash

source common.inc.sh

cd /build

git clone -b "v$GEANT4_VERSION" https://github.com/Geant4/geant4.git geant4
cd geant4
# otherwise we get an error re std::uint32_t
sed -i '38i#include <cstdint>\r' source/externals/clhep/include/CLHEP/Random/MixMaxRng.h
mkdir builddir "$GEN_DIR"/geant4
cd builddir

# add -DGEANT4_BUILD_CXXSTD=20 ?
cmake \
  -DCMAKE_INSTALL_PREFIX="$GEN_DIR"/geant4 \
  -DGEANT4_INSTALL_DATA=ON \
  -DGEANT4_USE_GDML=ON \
  ../

make -j"$NCORES" install

# Fix a broken cmake file. Otherwise we can't build edep-sim.
# https://geant4-forum.web.cern.ch/t/cmake-error-with-example/2057/2
evilfile=$GEN_DIR/geant4/lib64/Geant4-${GEANT4_VERSION}/Geant4PackageCache.cmake
sed -i 's/EXPAT_LIBRARY ""  ""/EXPAT_LIBRARY "" STRING ""/' "$evilfile"

echo 'source "$GEN_DIR"/geant4/bin/geant4.sh' >> /environment
