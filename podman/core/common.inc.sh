#!/usr/bin/env bash

# source /etc/profile.d/sh.local

set -o errexit

export NCORES=${NCORES:-32}
echo "Using $NCORES cores"
