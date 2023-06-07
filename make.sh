#!/bin/bash

mkdir ~/scripts & cp update.sh ~/scripts
touch ~/.bash_aliases & echo "alias update='bash ~/scripts/update.sh'" >> ~/.bash_aliases"
rm "update.sh" "make.sh"
