#!/bin/bash
# Clone files to Github - https://github.com/talesCPV/PIC.git

cd ..

git init

git clone https://github.com/talesCPV/PIC.git

cd PIC/

cp -rf * ../

cd ..

rm -rf PIC/



