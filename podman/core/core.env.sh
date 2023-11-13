export GENIE_VERSION=R-3_04_00
export GEANT4_VERSION=10.7.4
export ROOT_VERSION=v6-28-06

export GEN_DIR=/opt/generators

export GENIE="$GEN_DIR"/genie

export LHAPDF="$GEN_DIR"/lhapdf
export LHAPDF_INC="$LHAPDF"/include
export LHAPDF_LIB="$LHAPDF"/lib
export LHAPATH="$GEN_DIR"/lhapdf/include/LHAPDF

export PYTHIA6="$GEN_DIR"/pythia6

export GSL_LIB=/usr/lib64
export GSL_INC=/usr/include

export LIBXML2INC=/usr/include/libxml2
export LIBXML2_INC=/usr/include/libxml2
export LIBXML2_LIB=/usr/lib64

export DK2NU="$GEN_DIR"/dk2nu

export PATH="$GENIESYS"/bin:"$PATH"
export LD_LIBRARY_PATH="$DK2NU"/lib:"$LIBXML2_LIB":"$LHAPDF_LIB":"$PYTHIA6":"$GENIE"/lib:"$LD_LIBRARY_PATH"
export CMAKE_PREFIX_PATH="$GEN_DIR"/geant4/lib64/Geant4-"$GEANT4_VERSION":"$CMAKE_PREFIX_PATH"
