#!/usr/bin/env bash

cd "$GEN_DIR"
git clone -b main https://github.com/larpix/h5flow.git
cd h5flow
pip install -e .

cd "$GEN_DIR"
git clone -b develop https://github.com/larpix/ndlar_flow.git
cd ndlar_flow
pip install -e .
cp /build/flow_inputs/* data/proto_nd_flow
