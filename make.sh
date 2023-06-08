#!/bin/bash

mkdir ~/scripts
cp update.sh ~/scripts

touch ~/.bash_aliases
if ! grep "alias update" ~/.bash_aliases; then
    echo "alias update='bash ~/scripts/update.sh'" >> ~/.bash_aliases
fi

rm -rf ../my_linux_scripts
cd ..