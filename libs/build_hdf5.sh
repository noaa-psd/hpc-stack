#!/bin/bash

set -eux

name="hdf5"
version=${1:-${STACK_hdf5_version}}

# Hyphenated version used for install prefix
compiler=$(echo $HPC_COMPILER | sed 's/\//-/g')
mpi=$(echo $HPC_MPI | sed 's/\//-/g')

[[ ${STACK_hdf5_enable_szip:-} =~ [yYtT] ]] && enable_szip=YES || enable_szip=NO
[[ ${STACK_hdf5_enable_zlib:-} =~ [yYtT] ]] && enable_zlib=YES || enable_zlib=NO
[[ ${STACK_hdf5_shared:-} =~ [yYtT] ]] && enable_shared=YES || enable_shared=NO

 module purge

 export PATH=.:$PATH
 export HPC_OPT=/contrib/Wei.Huang/opt

 export MODULEPATH=/apps/modules/modulefamilies/intel:/apps/modules/modulefiles
#export MODULEPATH=$HPC_OPT/modulefiles/core:$MODULEPATH
#export MODULEPATH=$HPC_OPT/modulefiles/mpi/intel/18.0.5.274/impi/2018.4.274:$MODULEPATH
#export MODULEPATH=$HPC_OPT/modulefiles/compiler/intel/2018.4.274:$MODULEPATH
 module use $HPC_OPT/modulefiles/core
 module use $HPC_OPT/modulefiles/compiler/intel/18.0.5.274
 module use $HPC_OPT/modulefiles/mpi/intel/18.0.5.274/impi/2018.4.274

#module use $HPC_OPT/modulefiles/compiler/intel/2020.2

#module load intel/2020.2 impi/2020.2 cmake/3.20.1 

 module load intel/18.0.5.274
 module load impi/2018.4.274
 module load cmake/3.20.1

#module load intel/18.0.5.274/hpc-impi/2018.4.274    intel/18.0.5.274/jpeg/9.1.0    intel/18.0.5.274/udunits/2.2.28 \
#            intel/18.0.5.274/jasper/2.0.22          intel/18.0.5.274/szip/2.1.1    intel/18.0.5.274/zlib/1.2.11

 module load jpeg/9.1.0    udunits/2.2.28 \
             jasper/2.0.22          szip/2.1.1    zlib/1.2.11
 module load hpc-impi/2018.4.274

 export FC=ifort
 export CC=icc
 export CXX=icpc

 export SERIAL_FC=ifort
 export SERIAL_CC=icc
 export SERIAL_CXX=icpc

 export MPI_FC=mpiifort
 export MPI_CC=mpiicc
 export MPI_CXX=mpiicpc

if $MODULES; then
  set +x
 #source $MODULESHOME/init/bash
 #module load hpc-$HPC_COMPILER
 #[[ -z $mpi ]] || module load hpc-$HPC_MPI

  [[ $enable_szip =~ [yYtT] ]] && module try-load szip
  [[ $enable_zlib =~ [yYtT] ]] && module try-load zlib
  module list
  set -x

  prefix="${PREFIX:-"/opt/modules"}/$compiler/$mpi/$name/$version"
  if [[ -d $prefix ]]; then
    [[ $OVERWRITE =~ [yYtT] ]] && ( echo "WARNING: $prefix EXISTS: OVERWRITING!";$SUDO rm -rf $prefix; $SUDO mkdir $prefix ) \
                               || ( echo "WARNING: $prefix EXISTS, SKIPPING"; exit 1 )
  fi

else
    prefix=${HDF5_ROOT:-"/usr/local"}
fi

if [[ ! -z $mpi ]]; then
  export FC=$MPI_FC
  export CC=$MPI_CC
  export CXX=$MPI_CXX
else
  export FC=$SERIAL_FC
  export CC=$SERIAL_CC
  export CXX=$SERIAL_CXX
fi

export F9X=$FC
export FFLAGS="${STACK_FFLAGS:-} ${STACK_hdf5_FFLAGS:-} -fPIC -w"
export CFLAGS="${STACK_CFLAGS:-} ${STACK_hdf5_CFLAGS:-} -fPIC -w"
export CXXFLAGS="${STACK_CXXFLAGS:-} ${STACK_hdf5_CXXFLAGS:-} -fPIC -w"
export FCFLAGS="$FFLAGS"

URL="https://github.com/HDFGroup/hdf5.git"

cd ${HPC_STACK_ROOT}/${PKGDIR:-"pkg"}

software=$name-$(echo $version | sed 's/\./_/g')
[[ -d $software ]] || ( git clone -b $software $URL $software )
[[ ${DOWNLOAD_ONLY} =~ [yYtT] ]] && exit 0
[[ -d $software ]] && cd $software || ( echo "$software does not exist, ABORT!"; exit 1 )
[[ -d build ]] && rm -rf build
mkdir -p build && cd build

[[ -z $mpi ]] || extra_conf="--enable-parallel --enable-unsupported"

[[ $enable_shared =~ [yYtT] ]] || shared_flags="--disable-shared --enable-static --enable-static-exec"
[[ $enable_szip =~ [yYtT] ]] && szip_flags="--with-szlib=$SZIP_ROOT"
[[ $enable_zlib =~ [yYtT] ]] && zlib_flags="--with-zlib=$ZLIB_ROOT"

../configure --prefix=$prefix \
             --enable-fortran --enable-cxx \
             ${szip_flags:-} ${zlib_flags:-} ${shared_flags:-} ${extra_conf:-}

VERBOSE=$MAKE_VERBOSE make -j${NTHREADS:-4}
[[ $MAKE_CHECK =~ [yYtT] ]] && make check
[[ $USE_SUDO =~ [yYtT] ]] && sudo -- bash -c "export PATH=$PATH; make install" \
                          || make install

# generate modulefile from template
[[ -z $mpi ]] && modpath=compiler || modpath=mpi
$MODULES && update_modules $modpath $name $version
echo $name $version $URL >> ${HPC_STACK_ROOT}/hpc-stack-contents.log
