#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

cd src

if [ -e subkillergame ] 
then
echo "Running CMake subkiller"
  ./subkillergame
else
echo "Running CodeBlocks subkiller"
bin/Debug/SubKiller
fi

cd "$DIR"
exit 0
