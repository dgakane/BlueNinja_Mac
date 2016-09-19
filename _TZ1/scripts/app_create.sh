#!/bin/bash

if [ $# -eq 0 ]; then
    echo "usage: $0 APPNAME"
    exit
fi
if [ -e $1 ]; then
    echo "$1 is already exists."
    exit
fi

DFP_VER=$2
if [ "${DFP_VER}" == "" ]; then
    for file in $(find ${TZ1_BASE}sdk -name "*.patch"); do
        DFP_VER=$(basename ${file} | sed -e "s/.patch$//")
    done
else
    for file in $(find ${TZ1_BASE}sdk -name "*.patch"); do
        if [ "${DFP_VER}" == "$(basename ${file} | sed -e "s/.patch$//")" ]; then
            break
        fi
    done
    echo "TOSHIBA.TZ10xx_DFP.$2 is invalid version."
    echo "Please choice from the list:"
    for file in $(find ${TZ1_BASE}sdk -name "*.patch"); do
        echo "* $(basename ${file} | sed -e "s/.patch$//")"
    done
    exit 1
fi

echo "${DFP_VER}"

echo "Create application directory: $1"
mkdir $1

echo "Copy skeleton files."
rsync -a --exclude "*.doxyfile" ${TZ1_BASE}skel/ $1

echo "Copy RTE files."
mkdir -p $1/RTE/Device/TZ1001MBG
mkdir -p $1/RTE/Middleware/TZ1001MBG
cp -r ${SDK_DIR}TOSHIBA.TZ10xx_DFP.${DFP_VER}/RTE_Driver/Config/* $1/RTE/Device/TZ1001MBG/
cp -r ${SDK_DIR}TOSHIBA.TZ10xx_DFP.${DFP_VER}/Middleware/blelib/Config/* $1/RTE/Middleware/TZ1001MBG/
cp -r ${SDK_DIR}TOSHIBA.TZ10xx_DFP.${DFP_VER}/Middleware/TWiC/Config/ $1/RTE/Middleware/TZ1001MBG/
cp  ${SDK_DIR}TOSHIBA.TZ10xx_DFP.${DFP_VER}/Boards/TOSHIBA/RBTZ1000/Template/RTE/RTE_Components.h $1/RTE/

echo "Converting DOS files into Unix format..."
find $1 -type f -exec dos2unix -q {} \; # CRLFでpatchがエラーになる対策
cd $1
cat ${TZ1_BASE}sdk/${DFP_VER}.patch | LANG=C sed -e 's:\\:\/:g' >${TZ1_BASE}sdk/${DFP_VER}.patch.tmp
patch -p0 < ${TZ1_BASE}sdk/${DFP_VER}.patch.tmp

cat Makefile | sed -e "s/^TARGET.*$/TARGET=$1/" | sed -e "s/^DFP_VER.*$/DFP_VER=${DFP_VER}/" > Makefile.new
mv Makefile.new Makefile

