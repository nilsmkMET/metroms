#!/bin/bash
set -x
#export CICEVERSION=cice5.0
export CICEVERSION=cice5.1.2

NPX=1; NPY=1
if [ "${METROMS_MYHOST}" == "metlocal" ] || [ "${METROMS_MYHOST}" == "met_ppi" ]; then
    NPX=1  
    NPY=2
elif [ "${METROMS_MYHOST}" == "vilje" ] || [ "${METROMS_MYHOST}" == "fram" ]; then
    NPX=1  
    NPY=2
fi

if [ $# -lt 1 ]
  then
  echo "Usage: $0 modelname <xcpu> <ycpu>"
  echo "<xcpu> <ycpu> are optional arguments"
  exit
fi
export ROMS_APPLICATION=$1

if [ $# -ge 3 ]; then
    NPX=$2
    NPY=$3
fi

echo "NPX = $NPX, NPY = $NPY"

#if [ $# -ne 2 ]
#then
#    echo "Usage: $0 NPX NPY"
#    exit 1
#fi 

if [ ! -d ${METROMS_TMPDIR} ] ; then
    echo "METROMS_TMPDIR not defined, set environment variable METROMS_TMPDIR"
    exit 
fi
if [ ! -d ${METROMS_BASEDIR} ] ; then
    echo "METROMS_BASEDIR not defined, set environment variable METROMS_TMPDIR"
    exit 
fi

# Build CICE
export CICE_DIR=${METROMS_TMPDIR}/$ROMS_APPLICATION/cice
mkdir -p $CICE_DIR/rundir
cd ${METROMS_TMPDIR}/$ROMS_APPLICATION
# Unpack standard source files
echo $PWD
tar -xvf ${METROMS_BASEDIR}/static_libs/$CICEVERSION.tar.gz
cd $CICE_DIR

export MCT_INCDIR=${METROMS_TMPDIR}/MCT/include
export MCT_LIBDIR=${METROMS_TMPDIR}/MCT/lib


# Copy modified source files
#mkdir -p ${tup}/tmproms/cice
mkdir -p $CICE_DIR/input_templates/$ROMS_APPLICATION/
cp -a ${METROMS_BASEDIR}/build/modified_src/$CICEVERSION/* $CICE_DIR
cp -av ${METROMS_APPDIR}/$ROMS_APPLICATION/cice_input_grid/* $CICE_DIR/input_templates/$ROMS_APPLICATION/
# Remove old binaries
rm -f $CICE_DIR/rundir/cice

echo $PWD
./comp_ice $ROMS_APPLICATION $NPX $NPY

# Test if compilation and linking was successfull

if [ ! -f $CICE_DIR/rundir/cice ]; then
    echo "$CICE_DIR/rundir/cice not found"
    echo "Error with compilation "
    exit -1
fi

# Build a library (for use in the ROMS build)
cd $CICE_DIR/rundir/compile
ar rcv libcice.a *.o

rm -f $CICE_DIR/rundir/cice

#cd $CICE_DIR


set +x
