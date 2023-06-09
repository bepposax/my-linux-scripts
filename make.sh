#!/bin/bash

DEST=~/scripts
SCRIPT=update.sh

[ -d $DEST ] && echo "$DEST exists." || {
  echo -n "Creating $DEST..."
  mkdir $DEST && echo " Done"
}
[ -f $DEST/$SCRIPT ] && echo "$DEST/$SCRIPT exists." || {
  echo -n "Copying $SCRIPT in $DEST..."
  cp $SCRIPT $DEST && echo " Done"
}

ALIASFILE=~/.bash_aliases
ALIAS="alias update='bash $DEST/$SCRIPT'"

[ -f $ALIASFILE ] && echo "$ALIASFILE exists." || {
  echo -n "Creating $ALIASFILE..."
  touch $ALIASFILE && echo " Done"
}
grep "alias update" $ALIASFILE 1>/dev/null && echo "alias already set." || {
  echo -n "Adding alias to $ALIASFILE..."
  echo $ALIAS >>$ALIASFILE && echo " Done"
}
echo -n "Removing $PWD..."
rm -rf ../my_linux_script && echo " Done"
