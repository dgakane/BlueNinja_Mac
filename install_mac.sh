#!/bin/bash

export TZ1_BASE=$HOME/Cerevo/CDP-TZ01B/
export INSTALL_FILES=install_files/

GCC_ARM_NONE_EABI_URL=https://launchpad.net/gcc-arm-embedded/4.9/4.9-2015-q3-update/+download/gcc-arm-none-eabi-4_9-2015q3-20150921-mac.tar.bz2
GCC_ARM_NONE_EABI=$(basename ${GCC_ARM_NONE_EABI_URL})

echo "Create directories."
if [ ! -e ${TZ1_BASE} ]; then
    mkdir -p ${TZ1_BASE}
fi

echo "Setup SDKs"
if [ ! -e ${TZ1_BASE}sdk ]; then
    mkdir ${TZ1_BASE}sdk
fi

echo "Extract TZ10xx_DFP"
./append_pack.sh
CNT=$(cat CNTFILE)
rm -f CNTFILE

cd $INSTALL_FILES

if [ ! -e ${TZ1_BASE}sdk/TOSHIBA.TZ10xx_DFP ]; then
    mkdir ${TZ1_BASE}sdk/TOSHIBA.TZ10xx_DFP
fi

if [ -e "TOSHIBA.TZ10xxDFP.1.31.1.pack" ]; then
    unzip -o -q -d ${TZ1_BASE}sdk/TOSHIBA.TZ10xx_DFP TOSHIBA.TZ10xx_DFP.1.31.1.pack
    CNT=$(($CNT + 1))
fi

if [ "$CNT" == "0" ]; then
    echo "Error: TOSHIBA.TZ10xx_DFP.*.pack not installed."
    exit
fi

echo "Extract CMSIS"
if [ ! -e ${TZ1_BASE}sdk/ARM.CMSIS ]; then
    mkdir ${TZ1_BASE}sdk/ARM.CMSIS
fi

if [ -e "ARM.CMSIS.3.20.4.pack" ]; then
    unzip -o -q -d ${TZ1_BASE}sdk/ARM.CMSIS ARM.CMSIS.3.20.4.pack
elif [ -e "ARM.CMSIS.3.20.4.zip" ]; then
    unzip -o -q -d ${TZ1_BASE}sdk/ARM.CMSIS ARM.CMSIS.3.20.4.zip
else
    echo "ARM.CMSIS.3.20.4 is not found."
    exit
fi

echo "Setup tool chain."
if [ ! -e ${TZ1_BASE}tools ]; then
    mkdir ${TZ1_BASE}tools
fi

if [ ! -e ${GCC_ARM_NONE_EABI} ]; then
    echo "Download gcc-arm-none-eabi"
    wget ${GCC_ARM_NONE_EABI_URL}
fi
tar -jxf ${GCC_ARM_NONE_EABI} -C ${TZ1_BASE}tools --strip=1

echo "GNU tool TZ10xx Support"
cp tz10xx.specs ${TZ1_BASE}tools/arm-none-eabi/lib
${TZ1_BASE}tools/bin/arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -mthumb-interwork -march=armv7e-m -mfloat-abi=soft -std=c99 -g -O0 -c tz10xx-crt0.c -o ${TZ1_BASE}tools/arm-none-eabi/lib/tz10xx-crt0.o

cd ..
cp -rf _TZ1/* ${TZ1_BASE}

echo "Done..."
