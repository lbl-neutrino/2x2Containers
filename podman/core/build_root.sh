#!/usr/bin/env bash

source common.inc.sh

cd /build

git clone -b "$ROOT_VERSION" --depth 1 --single-branch https://github.com/root-project/root.git root

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

echo 'source "$GEN_DIR"/root/bin/thisroot.sh' >> /opt/environment

# cleanup before snapshot
cd /build
rm -rf root
