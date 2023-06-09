#!/bin/bash

ls ~/scripts 2>/dev/null || mkdir ~/scripts;
ls ~/scripts | grep update.sh || mv update.sh ~/scripts;

ls ~ | grep ~/.bash_aliases 1>/dev/null || touch ~/.bash_aliases;
if ! grep "alias update" ~/.bash_aliases; then
  echo "alias update='bash ~/scripts/update.sh'" 1>/dev/null >> ~/.bash_aliases
fi;

cd .. ; rm -rf ./my_linux_scripts