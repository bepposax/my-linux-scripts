#!/bin/bash

DIR=$(dirname "$0")

# disabling MOTD...
HUSH=~/.hushlogin

if [ -f $HUSH ]; then
  echo "'$HUSH' exists. Skipping"
else {
  echo -n "Creating '$HUSH'..."
  touch $HUSH && echo " Done"
}; fi

# adding the update script...
DEST=~/scripts
SCRIPT=update.sh

# creates DEST if it doesn't exist
if [ -d $DEST ]; then
  echo "'$DEST' exists. Skipping"
else {
  echo -n "Creating '$DEST'..."
  mkdir $DEST && echo " Done"
}; fi

# copies SCRIPT file in DEST if it doesn't exist
if [ -f $DEST/$SCRIPT ]; then
  echo "'$DEST/$SCRIPT' exists. Skipping"
else {
  echo -n "Copying '$DIR/$SCRIPT' in '$DEST'..."
  cp "$DIR"/$SCRIPT $DEST && echo " Done"
}; fi

# setting alias to run the update script...
ALIASFILE=~/.bash_aliases

# creates ALIASFILE if it doesnìt exist
if [ -f $ALIASFILE ]; then
  echo "'$ALIASFILE' exists. Skipping"
else {
  echo -n "Creating '$ALIASFILE'..."
  touch $ALIASFILE && echo " Done"
}; fi

# adds the ALIAS line inside ALIASFILE if it doesn't exist
ALIAS=("alias update='bash $DEST/$SCRIPT'")

if grep "alias update" $ALIASFILE 1>/dev/null; then
  echo "\"${ALIAS[*]}\" already set. Skipping"
else {
  echo -n "Adding \"${ALIAS[*]}\" to '$ALIASFILE'..."
  echo "${ALIAS[@]}" >>$ALIASFILE && echo " Done"
}; fi

# adding command to ~/.bashrc...
BASHRC=~/.bashrc

# checking bash version...
((${BASH_VERSION:0:1} < 4)) && {
  echo "Upgrading bash version..."
  sudo apt-get autoclean
  sudo apt-get install --only-upgrade bash
}
((${BASH_VERSION:0:1} >= 4)) && {
  CMDDOC="# sets the number of trailing directories to retain in the PS1 prompt"
  CMD="PROMPT_DIRTRIM=2"

  # adds CMD to ~/.bashrc if it isn't set
  if grep $CMD $BASHRC 1>/dev/null; then
    echo "$CMD already set. Skipping"
  else {
    echo -n "Adding '$CMD' to '$BASHRC'..."
    echo -e "\n$CMDDOC\n$CMD" >>$BASHRC && echo " Done"
  }; fi
}

# changing mirrors in /etc/apt/sources.list to ".it" mirrors...
SRCLST="/etc/apt/sources.list"
NEW_MIRR="deb http://it.archive"

# sets ".it" mirrors only if they're not ".it" mirrors
if grep "$NEW_MIRR" $SRCLST 1>/dev/null; then
  echo "Mirrors in '$SRCLST' already set. Skipping"
else {
  # assigns to MIRR whichever mirror "head" is currently saved in SRCLST
  MIRR=$(grep -Eom 1 "^deb http://([a-z]{2}.)?archive" $SRCLST)
  echo -n "Changing mirrors in '$SRCLST'... "
  sudo sed -i "s+$MIRR+$NEW_MIRR+g" $SRCLST && echo "Done"
}; fi

# removing the folder containing this file...
if [[ $DIR == . ]]; then {
  echo -n "Removing '$PWD'..."
  rm -rf "$PWD" && echo " Done"
}; else {
  echo -n "Removing '$DIR'..."
  rm -rf "$DIR" && echo " Done"
}; fi

echo "Restart the terminal for changes to take effect." && exit 0
