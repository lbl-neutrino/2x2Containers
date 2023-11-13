#!/usr/bin/env bash

dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora37/x86_64/cuda-fedora37.repo
dnf clean all
dnf -y install cuda-runtime-12-3
pip install cupy-cuda12x
