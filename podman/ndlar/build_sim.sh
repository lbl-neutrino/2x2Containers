#!/usr/bin/env bash

pip install cupy-cuda12x

cd "$GEN_DIR"
git clone -b develop https://github.com/DUNE/larnd-sim
cd larnd-sim
SKIP_CUPY_INSTALL=1 pip install -e .
