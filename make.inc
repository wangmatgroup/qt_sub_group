LIBDIR = ${MKLROOT}/lib/intel64
LIBS   = -L$(LIBDIR) -lmkl_core -lmkl_intel_lp64 -lmkl_sequential -lpthread

PREFIX = 

#===================
# gfortran
#===================
F90 = gfortran

#Add next two lines for parallel postw90. Choose the correct name of the mpi f90 wrapper
COMMS  = mpi
MPIF90 = mpif90 #mpif90

FCOPTS = -O3
LDOPTS =

#Next two lines are good for debugging
#FCOPTS = -fstrict-aliasing  -fno-omit-frame-pointer -fno-realloc-lhs -fcheck=bounds,do,recursion,pointer -ffree-form -Wall -Waliasing -Wsurprising -Wline-truncation -Wno-tabs -Wno-uninitialized -Wno-unused-dummy-argument -Wno-unused -Wno-character-truncation -O1 -g -fbacktrace
#LDOPTS = -fstrict-aliasing  -fno-omit-frame-pointer -fno-realloc-lhs -fcheck=bounds,do,recursion,pointer -ffree-form -Wall -Waliasing -Wsurprising -Wline-truncation -Wno-tabs -Wno-uninitialized -Wno-unused-dummy-argument -Wno-unused -Wno-character-truncation -O1 -g -fbacktrace

