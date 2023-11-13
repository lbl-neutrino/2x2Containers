#!/usr/bin/env bash

set -o errexit

source /build/core.env.sh
cat /build/core.env.sh >> /etc/profile.d/sh.local

## Need to get a new cmake version for ROOT6
# ln -s /usr/bin/cmake3 /usr/bin/cmake

export NCORES=${NCORES:-32}
echo "Using $NCORES cores"

## Create working directory
mkdir -p "$GEN_DIR"

# cd $GEN_DIR
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

# source it so that it picks up any aliases
# source ./makePythia6.linuxx8664
./makePythia6.linuxx8664
# unalias gcc

mkdir -p "$PYTHIA6"
mv libPythia6.so "$PYTHIA6"

# mkdir ${GEN_DIR}/root/lib
# cp ${GEN_DIR}/pythia6/libPythia6.so ${GEN_DIR}/root/lib/.

cd /build

## Get a copy of ROOT
git clone -b "$ROOT_VERSION" --depth 1 --single-branch https://github.com/root-project/root.git root

## Now build root
export VERBOSE=1
cd root
mkdir builddir "$GEN_DIR"/root
cd builddir
cmake \
  -DCMAKE_INSTALL_PREFIX="$GEN_DIR"/root \
  -DPYTHIA6_LIBRARY="$PYTHIA6"/libPythia6.so \
  -DCMAKE_CXX_STANDARD=20 \
  -Dcxx20=ON \
  -Dpythia6=ON \
  -Dminuit2=ON \
  -Dmathmore=ON \
  -Ddavix=OFF \
  -Dfitsio=OFF \
  -Dgfal=OFF \
  -Dcastor=OFF \
  -Dclad=OFF \
  -Dhttp=OFF \
  -Droot7=ON \
  -Dwebgui=OFF \
  -Dxrootd=OFF \
  -Dmlp=OFF \
  -Dmysql=OFF \
  -Doracle=OFF \
  -Dpgsql=OFF \
  -Droofit=OFF \
  -Dspectrum=OFF \
  -Dsqlite=OFF \
  -Ddataframe=OFF \
  -Dimt=OFF \
  -Dtmva=OFF \
  -Dtmva-cpu=OFF \
  -Dtmva-pymva=OFF \
  -Dssl=OFF \
  -Dcudnn=OFF \
  -Dexceptions=OFF \
  -Dgdml=ON \
  -Dbuiltin_clang=ON \
  -DPYTHON_EXECUTABLE=/usr/bin/python3 \
  -Dpython3=ON \
  ../
make -j "$NCORES" install

source "$GEN_DIR"/root/install/bin/thisroot.sh

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

cd /build

## Get the GENIE code
git clone -b "$GENIE_VERSION" https://github.com/GENIE-MC/Generator.git
cd Generator
sed -i 's/g77/gfortran/g' src/make/Make.include

## Need to copy a file from GENIE into LHAPDF... pretty mad!
cp data/evgen/pdfs/GRV98lo_patched.LHgrid "$LHAPATH"

## Configure GENIE
./configure \
  --prefix="$GENIE" \
  --enable-fnal \
  --with-pythia6-lib="$PYTHIA6" \
  --with-lhapdf-inc="$LHAPDF_INC" \
  --with-lhapdf-lib="$LHAPDF_LIB" \
  --with-libxml2-inc="$LIBXML2_INC" \
  --with-libxml2-lib="$LIBXML2_LIB"

make -j "$NCORES" install

## Shut GENIE up when it runs
cp "$GENIE"/config/Messenger_whisper.xml "$GENIE"/config/Messenger.xml

## Have to mess around with the file to actually shut it up though...
sed -i '$ d' "$GENIE"/config/Messenger.xml # delete last line
echo '  <priority msgstream="ResonanceDecay">      FATAL </priority>' >> "$GENIE"/config/Messenger.xml
echo '  <priority msgstream="Pythia6Decay">        FATAL </priority>' >> "$GENIE"/config/Messenger.xml
echo '  <priority msgstream="INukeNucleonCorr">    FATAL </priority>' >> "$GENIE"/config/Messenger.xml
echo '  <priority msgstream="gevgen_fnal">         FATAL </priority>' >> "$GENIE"/config/Messenger.xml
echo '</messenger_config>' >> "$GENIE"/config/Messenger.xml

## Get DK2NU sorted
cd /build
git clone https://github.com/NuSoftHEP/dk2nu.git
cd dk2nu
cmake \
  -DCMAKE_INSTALL_PREFIX="$DK2NU" \
  -DCMAKE_CXX_STANDARD=20 \
  -DWITH_TBB=OFF \
  ../
make -j "$NCORES" install

cd /build
git clone -b "$GEANT4_VERSION" https://github.com/Geant4/geant4.git geant4
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

echo 'source "$GEN_DIR"/root/bin/thisroot.sh' >> /etc/profile.d/sh.local
echo 'source "$GEN_DIR"/geant4/bin/geant4.sh' >> /etc/profile.d/sh.local
