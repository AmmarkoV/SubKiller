#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"
cd ..

scp -r testgodot/ ammar@192.168.1.47:/home/ammar/Documents/Programming

exit 0
