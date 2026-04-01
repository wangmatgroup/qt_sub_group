# COMPILE ABINIT ON LONESTAR6

## 1. LIBXC (https://libxc.gitlab.io/download/)  
tar -vxf libxc-7.0.0.tar.bz2  
module load gcc/13.2 impi/21.12  
cd ./libxc-7.0.0  
autoreconf -i  
./configure --prefix=**path/to/install/libxc** --enable-kxc  
make check  
make install  

### 1.1 ADD THE FOLLOWING TO ~/.bashrc:
export LD_LIBRARY_PATH=**path/you/installed/libxc**/lib:$LD_LIBRARY_PATH  

## 2. HDF5 (https://www.hdfgroup.org/download-hdf5/source-code/)
tar -xzvf hdf5-1.14.6.tar.gz  
module load gcc/13.2 impi/21.12 zlib  
cd ./hdf5-1.14.6  
CC=$MPI_ROOT/bin/mpicc ./configure --enable-parallel --with-zlib=$TACC_ZLIB_DIR --prefix=**path/to/install/not/hdf5-1.14.6/itself**  
make check  
make install  

### 2.1. ADD THE FOLLOWING TO ~/.bashrc:
export LD_LIBRARY_PATH=**path/you/installed/hdf5**/lib:$LD_LIBRARY_PATH  

## 3. NETCDF-C (https://downloads.unidata.ucar.edu/netcdf/)
tar -xzvf netcdf-c-4.9.3.tar.gz  
module load gcc/13.2 impi/21.12 zlib  
cd ./netcdf-c-4.9.3  
CC=$MPI_ROOT/bin/mpicc ./configure --prefix=**/path/you/installed/hdf5** LDFLAGS='-L**/path/you/installed/hdf5**/lib -L${TACC_ZLIB_LIB}' CPPFLAGS='-I**/path/you/installed/hdf5**/include -I${TACC_ZLIB_INC}'
make check

## 4. NETCDF-Fortran (https://downloads.unidata.ucar.edu/netcdf-fortran/)
tar -xzvf netcdf-fortran-4.6.2.tar.gz  
module load gcc/13.2 impi/21.12 zlib  
export HDF_PLUGIN_PATH=**/path/you/installed/hdf5**/hdf5/lib/plugin  
cd ./netcdf-fortran-4.6.2  
CC=$MPI_ROOT/bin/mpicc CPPFLAGS=-I**/path/you/installed/hdf5**/include LDFLAGS=-L**/path/you/installed/hdf5**/lib ./configure --prefix=**/path/you/installed/hdf5**  
make check  
make install

## 5. WANNIER
module load gcc/13.2 impi/21.12 mkl/24.1

### 5.1. EDIT "make.inc":
> export PREFIX=**path/to/install/wannier**  

make  
make install  
make lib  

## 6. ABINIT 10.4.3
git clone --branch 10.4.3 https://github.com/abinit/abinit.git   

### 6.1. EDIT "config.ac9":
> prefix=/path/to/install/abinit  
> with_libxc=path/you/installed/libxc  
> with_hdf5=/path/you/installed/hdf5  
> with_netcdf=/path/you/installed/hdf5  
> with_netcdf_fortran=/path/you/installed/hdf5  
> 
> enable_wannier="yes"  
> WANNIER90_LIBS=path/you/installed/wannier90/libwannier.a  

module load gcc/13.2 impi/21.12 mkl/24.1 zlib  
export LD_LIBRARY_PATH=**/path/you/installed/hdf5**/hdf5/lib/plugin:$LD_LIBRARY_PATH  
./configure --with-config-file='config.ac9'  
make (check) -j4  
make install  

### 6.2. ADD THE FOLLOWING TO ~/.bashrc:  
export PATH=**path/you/installed/abinit**/lib:$PATH   
