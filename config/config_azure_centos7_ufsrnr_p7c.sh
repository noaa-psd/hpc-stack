#!/bin/bash

# Compiler/MPI combination
export HPC_COMPILER="intel/18.0.5.274"
export HPC_MPI="impi/2018.4.274"
export HPC_PYTHON="intelpython/3.6.8"

# Build options
export USE_SUDO=N
export PKGDIR=pkg
export LOGDIR=log
export OVERWRITE=Y
export NTHREADS=8
export   MAKE_CHECK=N
export MAKE_VERBOSE=N
export   MAKE_CLEAN=N
export DOWNLOAD_ONLY=N
export STACK_EXIT_ON_FAIL=Y
export WGET="wget -nv"
# export VENVTYPE="condaenv"

# Load these basic modules for Hera
module load cmake/3.20.1
module load intelpython/3.6.8
module load intel/18.0.5.274
module load impi/2018.4.274

# Build FMS with AVX2 flags
export STACK_fms_CFLAGS="-march=core-avx2"
export STACK_fms_FFLAGS="-march=core-avx2"

# Miniconda3 URL on Hera
#export STACK_miniconda3_URL="http://anaconda.rdhpcs.noaa.gov"
export INTEL_LICENSE_FILE=27009@noaa-license.parallel.works

