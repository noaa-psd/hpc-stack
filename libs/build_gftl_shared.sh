#!/bin/bash

set -eux

name="gftl-shared"
repo="Goddard-Fortran-Ecosystem"
version=${2:-${STACK_gftl_shared_version:-"main"}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
id=${version//\//-}

if $MODULES; then
  set +x
 #source $MODULESHOME/init/bash
 #module load hpc-$HPC_COMPILER
 #module try-load cmake
 #module list

  module purge

  export HPC_OPT=/contrib/Wei.Huang/opt

  export MODULEPATH=/apps/modules/modulefamilies/intel:/apps/modules/modulefiles
  module use $HPC_OPT/modulefiles/core
  module use $HPC_OPT/modulefiles/compiler/intel/18.0.5.274
  module use $HPC_OPT/modulefiles/mpi/intel/18.0.5.274/impi/2018.4.274

  module load intel/18.0.5.274
  module load impi/2018.4.274
  module load cmake/3.20.1

 #module load jpeg/9.1.0    udunits/2.2.28 \
 #            jasper/2.0.22          szip/2.1.1    zlib/1.2.11
 #module load eckit/ecmwf-1.16.0    fckit/ecmwf-0.9.2
 #module load atlas/ecmwf-0.24.1
 #module load hpc-impi/2018.4.274

  export FC=ifort
  export CC=icc
  export CXX=icpc

 #export SERIAL_FC=ifort
 #export SERIAL_CC=icc
 #export SERIAL_CXX=icpc

 #export MPI_FC=mpiifort
 #export MPI_CC=mpiicc
 #export MPI_CXX=mpiicpc

  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$id"
  if [[ -d $prefix ]]; then
      if [[ $OVERWRITE =~ [yYtT] ]]; then
          echo "WARNING: $prefix EXISTS: OVERWRITING!"
          $SUDO rm -rf $prefix
          $SUDO mkdir $prefix
      else
          echo "WARNING: $prefix EXISTS, SKIPPING"
          exit 0
      fi
  fi
else
  prefix=${GFTL_SHARED_ROOT:-"/usr/local"}
fi

software=$name-$id
cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}
URL="https://github.com/$repo/$name.git"
[[ -d $software ]] || git clone $URL $software
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

git checkout $version
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0

[[ -d build ]] && $SUDO rm -rf build
mkdir -p build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$prefix ..
VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4} install

# generate modulefile from template
$MODULES && update_modules compiler $name $id
echo $name $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
