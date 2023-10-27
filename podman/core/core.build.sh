#!/usr/bin/env bash

## Need to get a new cmake version for ROOT6
# ln -s /usr/bin/cmake3 /usr/bin/cmake

set -o errexit

export NCORES=${NCORES:-16}
echo "Using $NCORES cores"

## Create working directory
mkdir -p $GEN_DIR
cd $GEN_DIR

## Get a copy of ROOT
# git clone -b v6-14-06 --depth 1 --single-branch https://github.com/root-project/root.git root
git clone -b v6-28-06 --depth 1 --single-branch https://github.com/root-project/root.git root

## Get PYTHIA6 (with specific placement for NuWro)
wget --no-check-certificate http://root.cern.ch/download/pythia6.tar.gz
tar -xzvf pythia6.tar.gz
rm -f pythia6.tar.gz
wget --no-check-certificate https://pythia.org/download/pythia6/pythia6428.f
mv pythia6428.f pythia6/pythia6428.f
rm pythia6/pythia6416.f

## Build PYTHIA6 and copy to where NuWro expects it
cd pythia6

## Newer gcc has -fno-common as default, which would require adding the 'extern'
## keyword everywhere in pythia_common_address.c.
# alias gcc='gcc -fcommon'

# NOTE: Above doesn't seem to work for newer gcc, so instead we "extern"
# everything except pyuppr
sed -i '51,72s/^/extern /' pythia6_common_address.c
sed -i 's/extern int pyuppr/int pyuppr/' pythia6_common_address.c

# source it so that it picks up any aliases
source ./makePythia6.linuxx8664
# unalias gcc

mkdir ${GEN_DIR}/root/lib
cp ${GEN_DIR}/pythia6/libPythia6.so ${GEN_DIR}/root/lib/.

export VERBOSE=1

## Now build root
mkdir ${GEN_DIR}/root/install
cd ${GEN_DIR}/root/install
cmake -DPYTHIA6_LIBRARY=${GEN_DIR}/root/lib/libPythia6.so \
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
make -j ${NCORES}

source ${GEN_DIR}/root/install/bin/thisroot.sh

mkdir ${GEN_DIR}/LHAPDF
cd ${GEN_DIR}/LHAPDF
# what happened to hepforge?
# wget https://lhapdf.hepforge.org/downloads/old/lhapdf-5.9.1.tar.gz
wget https://src.fedoraproject.org/repo/pkgs/lhapdf/lhapdf-5.9.1.tar.gz/5260c1979355243f6584c16a5f19bfd1/lhapdf-5.9.1.tar.gz
tar xzf lhapdf-5.9.1.tar.gz
rm lhapdf-5.9.1.tar.gz
mkdir lhapdf-5.9.1_build
cd lhapdf-5.9.1
# replace/patch configure.ac and m4/python.m4 (or not; python bindings seem hopelessly borked for py3)
# ./configure --prefix=${PWD}/../lhapdf-5.9.1_build
./configure --disable-pyext --prefix=${PWD}/../lhapdf-5.9.1_build
make -j ${NCORES} FFLAGS=-std=legacy && make install

## Get the GENIE code
mkdir -p ${GEN_DIR}/GENIE
git clone -b ${GENIE_VERSION} https://github.com/GENIE-MC/Generator.git ${GEN_DIR}/GENIE/${GENIE_VERSION}
export GENIE=${GEN_DIR}/GENIE/${GENIE_VERSION}
cd ${GENIE}
sed -i 's/g77/gfortran/g' src/make/Make.include

## Need to copy a file from GENIE into LHAPDF... pretty mad!
cp ${GENIE}/data/evgen/pdfs/GRV98lo_patched.LHgrid ${LHAPATH}/.

## Configure GENIE
./configure --enable-fnal \
    --with-pythia6-lib=${PYTHIA6} \
    --with-lhapdf-inc=$LHAPDF_INC \
    --with-lhapdf-lib=$LHAPDF_LIB \
    --with-libxml2-inc=$LIBXML2_INC \
    --with-libxml2-lib=$LIBXML2_LIB

make -j ${NCORES}
make install

## Shut GENIE up when it runs
cp ${GENIE}/config/Messenger_whisper.xml ${GENIE}/config/Messenger.xml

## Have to mess around with the file to actually shut it up though...
sed -i '$ d' ${GENIE}/config/Messenger.xml
echo '  <priority msgstream="ResonanceDecay">      FATAL </priority>' >> ${GENIE}/config/Messenger.xml
echo '  <priority msgstream="Pythia6Decay">        FATAL </priority>' >> ${GENIE}/config/Messenger.xml
echo '  <priority msgstream="INukeNucleonCorr">    FATAL </priority>' >> ${GENIE}/config/Messenger.xml
echo '  <priority msgstream="gevgen_fnal">         FATAL </priority>' >> ${GENIE}/config/Messenger.xml
echo '</messenger_config>' >> ${GENIE}/config/Messenger.xml

## Get DK2NU sorted
cd ${GEN_DIR}
git clone https://github.com/NuSoftHEP/dk2nu.git
cd ${DK2NU}
# Either set the std to c++20 (same as when we compiled root), or remove
# -pedantic-errors from CXXFLAGS. Otherwise, we get a #warning about different
# C++ standards from the ROOT headers, which becomes a pedantic error.
echo CXXFLAGS+=-std=c++20 >> make.include
make all

cd ${GEN_DIR}
git clone -b v10.7.4 https://github.com/Geant4/geant4.git geant4
# otherwise we get an error re std::uint32_t
sed -i '38i#include <cstdint>\r' geant4/source/externals/clhep/include/CLHEP/Random/MixMaxRng.h
mkdir geant4/install geant4/build
cd geant4/build
# cmake -DCMAKE_INSTALL_PREFIX=../install \
#   -DGEANT4_BUILD_CXXSTD=20 \
#   -DGEANT4_INSTALL_DATA=ON \
#   -DGEANT4_USE_GDML=ON ../
cmake -DCMAKE_INSTALL_PREFIX=../install \
  -DGEANT4_INSTALL_DATA=ON \
  -DGEANT4_USE_GDML=ON ../
# include cstdint
make -j${NCORES} && make install

echo "source $GEN_DIR/root/install/bin/thisroot.sh" >> ~/.bashrc
