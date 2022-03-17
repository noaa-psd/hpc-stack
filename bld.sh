#!/bin/sh

#set -x

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

 export OVERWRITE=N

#setup_modules.sh -p ${HPC_OPT} \
#                 -c config/config_azure_centos7_ufsrnr_p7c.sh

 build_stack.sh -p ${HPC_OPT} \
 -c config/config_azure_centos7_ufsrnr_p7c.sh \
 -y stack/stack_ufsrnr_p7c.yaml \
 -m

#-y stack/stack_jedi.yaml \
