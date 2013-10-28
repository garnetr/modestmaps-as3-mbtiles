#!/bin/bash

FLEX_HOME=/Applications/Adobe\ Flash\ Builder\ 4.7/sdks/4.6.0/
AIR_PATH="${FLEX_HOME}frameworks/libs/air/"
PROJ_PATH="$( dirname "${BASH_SOURCE[0]}" )"

if [ ! -d "${FLEX_HOME}" ]; then
    echo "Could not find SDK at ${FLEX_HOME}"
    exit 2
fi

"${FLEX_HOME}"/bin/asdoc -doc-sources $PROJ_PATH/lib -library-path+="${AIR_PATH}" -output docs
