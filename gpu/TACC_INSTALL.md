# COMPILE ABINIT ON LONESTAR6

## 1. NVIDIA
module load python cuda/12.8 gcc/11.2.0
wget https://developer.download.nvidia.com/hpc-sdk/25.3/nvhpc_2025_253_Linux_x86_64_cuda_12.8.tar.gz
tar xpzf nvhpc_2025_253_Linux_x86_64_cuda_12.8.tar.gz
nvhpc_2025_253_Linux_x86_64_cuda_12.8/install

### 1.1 ADD THE FOLLOWING TO ~/.bashrc:
alias load_nvidia='module purge; unset PATH; unset LD_LIBRARY_PATH; export NVIDIA_DIR=**path/to/nvidia/Linux_x86_64/25.3**; export FC=${NVIDIA_DIR}/comm_libs/12.8/openmpi4/openmpi-4.1.5/bin/mpif90; export CC=${NVIDIA_DIR}/comm_libs/12.8/openmpi4/openmpi-4.1.5/bin/mpicc; export CXX=${NVIDIA_DIR}/comm_libs/12.8/openmpi4/openmpi-4.1.5/bin/mpic++; export NVIDIA_MATH_LIB=${NVIDIA_DIR}/math_libs/lib64; export NVIDIA_MATH_INC=${NVIDIA_DIR}/math_libs/include; export PATH=${NVIDIA_DIR}/comm_libs/12.8/openmpi4/openmpi-4.1.5/bin:${NVIDIA_DIR}/comm_libs/12.8/nvshmem/bin:${NVIDIA_DIR}/cuda/12.8/bin:${NVIDIA_DIR}/compilers/extras/qd/bin:${NVIDIA_DIR}/compilers/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin; export MODULEPATH=${MODULEPATH}:${NVIDIA_DIR}/modulefiles; export LD_LIBRARY_PATH=${NVIDIA_DIR}/comm_libs/12.8/openmpi4/openmpi-4.1.5/lib:${NVIDIA_DIR}/math_libs/12.8/lib64:${NVIDIA_DIR}/comm_libs/12.8/nvshmem/lib:${NVIDIA_DIR}/comm_libs/12.8/nccl/lib:${NVIDIA_DIR}/cuda/12.8/extras/CUPTI/lib64:${NVIDIA_DIR}/cuda/12.8/lib64:${NVIDIA_DIR}/compilers/lib:${NVIDIA_DIR}/compilers/extras/qd/lib; export NVIDIA_LIB=${NVIDIA_DIR}/compilers/lib; export NVIDIA_INC=${NVIDIA_DIR}/compilers/include'

## 2. LIBXC
load_nvidia
autoreconf -i
./configure --prefix=**path/to/install/libxc** --enable-kxc
make (check)
make install

## 3. ZLIB
load_nvidia
Download zlib/1.3.2
cmake -S . -B build -D CMAKE_BUILD_TYPE=Release --install-prefix=**path/to/install/zlib**
cd build
make (check)
make install

## 4. HDF5
load_nvidia
Download hdf5/1.14.6 
cd ./hdf5-1.14.6
./configure --enable-parallel --with-zlib=**path/to/zlib(with include and lib)** --prefix=**path/to/install/hdf5**
make (check)
make install

## 5. WANNIER
load_nvidia

### 5.1. EDIT "make.inc":
export PREFIX=**path/to/install/wannier**
#===================
### nvhpc
#===================
F90 = ${FC}
COMMS=mpi
MPIF90=${FC}
FCOPTS = -O2
LDOPTS = -O2
#=======================
### Blas and LAPACK
#=======================
LIBDIR = ${NVIDIA_LIB}
LIBS = -L$(LIBDIR)  -llapack -lblas

make
make install
make lib

## 6. NETCDF-C
load_nvidia
export HDF5_DIR=**path/you/installed/hdf5** 
export ZLIB_DIR=**path/you/installed/zlib** 
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HDF5_DIR}/lib
export CFLAGS="-I${HDF5_DIR}/include"
export LDFLAGS="-L${HDF5_DIR}/lib -L${ZLIB_DIR}/lib"
./configure --prefix=$HDF5_DIR 
make
make install

## 7. NETCDF-fortran
load_nvidia
export HDF5_DIR=**path/you/installed/hdf5**
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HDF5_DIR}/lib
export HDF5_PLUGIN_PATH=${HDF5_DIR}/hdf5/lib/plugin
CPPFLAGS="-I${HDF5_DIR}/include -fPIC" LDFLAGS=-L${HDF5_DIR}/lib ./configure --prefix=${HDF5_DIR}
make
make install

## 8. FFTW3
load_nvidia
./configure --enable-threads --enable-mpi --enable-shared --enable-float --prefix=**path/to/install/fftw3**
make
make install

### 8.1. ADD THE FOLLOWING TO ~/.bashrc:
alias load_fftw3='export FFTW3_DIR=**path/you/installed/fftw3**; export FFTW3_LIB=**path/you/installed/fftw3**/lib; export FFTW3_INC=**path/you/installed/fftw3**/include; export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${FFTW3_LIB}'

## 9. ABINIT 10.6.5
load_nvidia
load_fftw3
module load cuda/12.8 gcc/11.2.0 python3/3.9.7 autotools/1.4
export HDF5_DIR=**path/you/installed/hdf5**
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HDF5_DIR}/lib
unset FC CC CXX
./configure --with-config-file='config.ac9'
make (check) -j4
make install
cd **path/you/installed/abinit-gpu**/bin
for f in *; do mv -- "$f" "${f}-gpu"; done

### 9.1. ADD THE FOLLOWING TO ~/.bashrc:
alias pre_gpu_abinit='load_nvidia; load_fftw3; module load cuda/12.8 gcc/11.2.0 python3/3.9.7; export HDF5_DIR=**path/you/installed/hdf5**; export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${HDF5_DIR}/hdf5/lib/plugin:${HDF5_DIR}/lib:**path/you/installed/libxc**/lib:**path/you/installed/zlib**/lib; export PATH=$PATH:**path/you/installed/abinit-gpu**/bin'