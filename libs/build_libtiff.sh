#!/bin/bash

set -eux

name="libtiff"
version=${1:-${STACK_libtiff_version}}

[[ ${STACK_libtiff_shared:-} =~ [yYtT] ]] && enable_shared=YES || enable_shared=NO

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')

# manage package dependencies here
if $MODULES; then
    set +x
   #source $MODULESHOME/init/bash
   #module load hpc-$HPC_COMPILER
   #module try-load cmake
   #module load zlib
   #module list

 module purge

 export PATH=.:$PATH
 export MODULEPATH=/apps/modules/modulefamilies/intel:/apps/modules/modulefiles
 export HPC_OPT=/contrib/Wei.Huang/opt

 module use $HPC_OPT/modulefiles/core
 module use $HPC_OPT/modulefiles/compiler/intel/18.0.5.274
 module use $HPC_OPT/modulefiles/mpi/intel/18.0.5.274/impi/2018.4.274

 module load intel/18.0.5.274
 module load impi/2018.4.274
 module load cmake/3.20.1

 module load jpeg/9.1.0    udunits/2.2.28 \
             jasper/2.0.22          szip/2.1.1    zlib/1.2.11

#module load hpc-intel/18.0.5.274
#module load hpc-impi/2018.4.274

 export FC=ifort
 export CC=icc
 export CXX=icpc

 export SERIAL_FC=ifort
 export SERIAL_CC=icc
 export SERIAL_CXX=icpc

 export MPI_FC=mpiifort
 export MPI_CC=mpiicc
 export MPI_CXX=mpiicpc

    set -x

    prefix="${PREFIX:-"/opt/modules"}/$compiler/$name/$version"
    if [[ -d $prefix ]]; then
      if [[ $OVERWRITE =~ [yYtT] ]]; then
          echo "WARNING: $prefix EXISTS: OVERWRITING!"
          $SUDO rm -rf $prefix
      else
          echo "WARNING: $prefix EXISTS, SKIPPING"
          exit 0
      fi
    fi

else
    prefix=${LIBTIFF_ROOT:-"/usr/local"}
fi

export CC=$SERIAL_CC
export CFLAGS="${STACK_CFLAGS:-} ${STACK_libtiff_CFLAGS:-} -fPIC"

module list

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$version
URL="https://gitlab.com/${name}/${name}.git"
[[ -d $software ]] || ( git clone $URL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )

sourceDir=$PWD
cd build
cmake $sourceDir \
  -DCMAKE_INSTALL_PREFIX=$prefix \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DZLIB_ROOT=${ZLIB_ROOT} 
#
make -j${NTHREADS:-4}
$SUDO make install

# generate modulefile from template
$MODULES && update_modules compiler $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
