#!/usr/bin/env bash

# For libyaml-cpp (needed by MPV/MPR)
export LD_LIBRARY_PATH=$EDEPSIM/lib64:$LD_LIBRARY_PATH

# MPV/MPR "particle bomb" generator for SPINE training samples
export DLPGENERATOR_INCDIR=$GEN_DIR/DLPGenerator/build/include
export DLPGENERATOR_LIBDIR=$GEN_DIR/DLPGenerator/build/lib
export LD_LIBRARY_PATH=$DLPGENERATOR_LIBDIR:$LD_LIBRARY_PATH
