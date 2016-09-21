#!/bin/bash

CNT=0
VERSIONS=$(find versions -name "*.patch" | sed -e "s:^versions/::" | sed -e "s/.patch$//")

for v in $VERSIONS; do 
    echo "Extracting TOSHIBA.TZ10xx_DFP.${v}.pack"
    if [ -e "${INSTALL_FILES}TOSHIBA.TZ10xx_DFP.${v}.pack" ]; then
        unzip -o -q -d "${TZ1_BASE}sdk/TOSHIBA.TZ10xx_DFP.${v}" "${INSTALL_FILES}TOSHIBA.TZ10xx_DFP.${v}.pack"
        cp versions/${v}.patch "${TZ1_BASE}sdk"
        CNT=$((CNT + 1))
    fi
done
echo "$CNT packs install succeed."

echo "Converting DOS files into Unix format..."
find ${TZ1_BASE}sdk -type f -exec dos2unix -q {} \;

echo "Applying for patchs."
for f in $(find ${INSTALL_FILES} -name "TOSHIBA.TZ10xx_DFP*.patch"); do
    if [ -e ${TZ1_BASE}sdk/$( basename ${f} | sed -e "s/.patch$//") ]; then
        echo ${f}
        cat ${f} | sed -e '/---/ s:\\:\/:g' | sed -e '/+++/ s:\\:\/:g' >${f}.tmp
        patch -p0 -d ${TZ1_BASE}sdk < ${f}.tmp
        rm ${f}.tmp
    fi
done

echo $CNT>CNTFILE
