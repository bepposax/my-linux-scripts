#!/bin/bash

ls ~/scripts &>/dev/null || mkdir ~/scripts
ls ~/scripts | grep update.sh &>/dev/null || mv update.sh ~/scripts

ls ~ | grep ~/.bash_aliases  || touch ~/.bash_aliases
if ! grep "alias update" ~/.bash_aliases &>/dev/null; then
  echo "alias update='bash ~/scripts/update.sh'"  >> ~/.bash_aliases
fi

rm -rf ../my_linux_scripts