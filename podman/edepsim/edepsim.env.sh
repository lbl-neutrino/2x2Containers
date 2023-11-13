#!/usr/bin/env bash

export EDEPSIM="$GEN_DIR"/edep-sim/install
export PATH="$EDEPSIM"/bin:${PATH}
export LD_LIBRARY_PATH="$EDEPSIM"/lib:"$LD_LIBRARY_PATH"

# This points to a MakeProject-generated library for the edep-sim output format
# See comments in 2x2_sim's run_spill_build.sh
# Also useful for 2x2_sim's admin/dump_metadata.py
export LIBTG4EVENT_DIR="$GEN_DIR"/libTG4Event
