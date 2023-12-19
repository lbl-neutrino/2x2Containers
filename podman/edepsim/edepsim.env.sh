#!/usr/bin/env bash

export EDEPSIM="$GEN_DIR"/edep-sim/install
export PATH="$EDEPSIM"/bin:${PATH}
export LD_LIBRARY_PATH="$EDEPSIM"/lib:"$LD_LIBRARY_PATH"
# After going from ROOT 6.14.06 to 6.28.06, apparently we need to point CPATH to
# the edepsim-io headers. Otherwise convert2h5 fails.
export CPATH=$EDEPSIM/include/EDepSim:$CPATH

# This points to a MakeProject-generated library for the edep-sim output format
# See comments in 2x2_sim's run_spill_build.sh
# Also useful for 2x2_sim's admin/dump_metadata.py
export LIBTG4EVENT_DIR="$GEN_DIR"/libTG4Event
