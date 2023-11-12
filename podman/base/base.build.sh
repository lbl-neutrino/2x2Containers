#!/usr/bin/env bash

set -o errexit

dnf -y upgrade

dnf -y install file
dnf -y install tar
dnf -y install bzip2

BUILD_SW="gcc gcc-c++ gcc-gfortran cmake3 make imake autoconf automake pkgconfig libtool"
RETRIEVAL_SW="git wget subversion openssh-clients openssl-devel"

# X11_UTILS="xorg-x11-utils"
X11_UTILS=""
X11_LIBS="libXt-devel libXpm-devel libXft-devel libXext-devel"

GRAPHICS_LIBS="mesa-libGLU-devel mesa-libGLw glew-devel motif-devel libpng-devel libjpeg-turbo-devel ftgl-devel"

DEVEL_LIBS="libxml2-devel gmp-devel gsl-devel log4cpp-devel bzip2-devel pcre-devel \
xz-devel zlib-devel freetype-devel fftw-devel blas-devel lapack-devel libnsl2-devel"

# MISC_SW="vim nano gdb csh tcsh ed quota python-devel patch emacs"
MISC_SW="vim nano gdb csh tcsh ed quota patch"

dnf -y install \
   ${BUILD_SW}\
   ${RETRIEVAL_SW}\
   ${X11_UTILS}\
   ${X11_LIBS}\
   ${GRAPHICS_LIBS}\
   ${DEVEL_LIBS}\
   ${MISC_SW}

## Required by the packages used downstream (some gotchas here)
dnf -y install man
dnf -y install which
dnf -y install ed
dnf -y install automake
dnf -y install perl
dnf -y install libXt-devel
dnf -y install openmotif-devel
dnf -y install csh


## To avoid ROOT builtins:
dnf -y install gl2ps-devel
dnf -y install xxhash-devel
dnf -y install lz4-devel

## Needed to install with python3
dnf -y install python3-devel

## Needed for G4:
dnf -y install xerces-c xerces-c-devel expat-devel

ln -s /usr/bin/python3 /usr/bin/python

# profiling tools

# dnf -y install dbus-x11 graphviz kcachegrind

# disable the default "-i" aliases which require confirmation

echo "unalias rm cp mv" >> ~/.bashrc
