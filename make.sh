#!/bin/bash

DIR=$(dirname $0)

# disable MOTD
touch ~/.hushlogin

# adding the update script...
DEST=~/scripts
SCRIPT=update.sh

# creates DEST if it doesn't exist
[ -d $DEST ] && echo "$DEST exists. Skipping..." || {
  echo -n "Creating $DEST..."
  mkdir $DEST && echo " Done"
}
# copies SCRIPT file in DEST if it doesn't exist
[ -f $DEST/$SCRIPT ] && echo "$DEST/$SCRIPT exists. Skipping..." || {
  echo -n "Copying $DIR/$SCRIPT in $DEST..."
  cp $DIR/$SCRIPT $DEST && echo " Done"
}

# setting alias to run the update script...
ALIASFILE=~/.bash_aliases
ALIAS="alias update='bash $DEST/$SCRIPT'"

# creates ALIASFILE if it doesnìt exist
[ -f $ALIASFILE ] && echo "$ALIASFILE exists. Skipping..." || {
  echo -n "Creating $ALIASFILE..."
  touch $ALIASFILE && echo " Done"
}
# adds the ALIAS line inside ALIASFILE if it doesn't exist
grep "alias update" $ALIASFILE 1>/dev/null && echo "alias already set. Skipping..." || {
  echo -n "Adding alias to $ALIASFILE..."
  echo $ALIAS >>$ALIASFILE && echo " Done"
}

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
  grep $CMD $BASHRC 1>/dev/null && echo "$CMD already set. Skipping..." || {
    echo -n "Adding $CMD to $BASHRC..."
    echo -e "\n$CMDDOC\n$CMD" >>$BASHRC && echo " Done"
  }
}

# removing the folder containing this file...
[[ $DIR == . ]] && {
  echo -n "Removing $PWD..."
  rm -rf $PWD && echo " Done"
} || {
  echo -n "Removing $DIR..."
  rm -rf $DIR && echo " Done"
}

echo "Restart the terminal for changes to take effect."
