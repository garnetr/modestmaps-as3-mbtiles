#!/bin/bash

FLEX_HOME=/Applications/Adobe\ Flash\ Builder\ 4.7/sdks/4.6.0/
ACOMPC="${FLEX_HOME}/bin/acompc"
LIB_PATH="$( dirname "${BASH_SOURCE[0]}" )/../lib"
SWC_PATH="$( dirname "${BASH_SOURCE[0]}" )/bin/ModestMapsSWC.swc"

if [ ! -d "${FLEX_HOME}" ]; then
    echo "Could not find SDK at ${FLEX_HOME}"
    exit 2
fi

#generate list of all classes in package format
CLASS_LIST=""
for i in `find ../lib -name "*.as"`; do
    curClass="$( echo $i |sed 's/\.\.\/lib\///'|sed 's/\//\./g' )"
    if [ -z "$CLASS_LIST" ]; then
        CLASS_LIST="${curClass%.*}"
    else
        CLASS_LIST="$CLASS_LIST ${curClass%.*}"
    fi
done;

#build swc using ACOMPC
"${ACOMPC}" -source-path "${LIB_PATH}" -include-classes ${CLASS_LIST} -output "${SWC_PATH}"
