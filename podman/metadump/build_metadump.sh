#!/usr/bin/env bash

cd /opt

apt install -y python3-h5py

edepfile=MiniRun3_1E19_RHC.spill.00123.EDEPSIM_SPILLS.root
wget -q https://portal.nersc.gov/project/dune/data/2x2/simulation/productions/MiniRun3_1E19_RHC/MiniRun3_1E19_RHC.spill/EDEPSIM_SPILLS/$edepfile

root -l -b -q $edepfile -e '_file0->MakeProject("libTG4Event", "*", "RECREATE++")'

rm $edepfile
