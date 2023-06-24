#!/bin/bash

# disable MOTD
touch ~/.hushlogin

# adding the update script...
DIR=$(dirname $0)
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
CMDFILE=~/.bashrc

if ((${BASH_VERSION:0:1} >= 4)); then
  CMD="PROMPT_DIRTRIM=1"

  # adds CMD to ~/.bashrc if it isn't set
  grep $CMD $CMDFILE 1>/dev/null && echo "$CMD already set. Skipping..." || {
    echo -n "Adding $CMD to $CMDFILE..."
    echo -e "\n# sets the number of trailing directories to retain in PS1\n$CMD" >>$CMDFILE && echo " Done"
  }
fi

# removing the folder containing this file
[[ $DIR == . ]] && {
  echo -n "Removing $PWD..."
  rm -rf $PWD && echo " Done"
} || {
  echo -n "Removing $DIR..."
  rm -rf $DIR && echo " Done"
}

echo "Restart the terminal for changes to take effect."
