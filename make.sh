#!/bin/bash

DIR=$(dirname "$0")
RESTART=false
CHANGES=false
RELOG=false

# disabling MOTD...
read -rp "Disable MOTD? (y/n): " choice
[[ $choice = y* || $choice = Y* ]] && {
  HUSH="$HOME/.hushlogin"

  [ -f $HUSH ] || {
    echo -n "Creating '$HUSH'..."
    touch $HUSH && echo " Done"
    RESTART=true
  }
}

# adding the update script...
DEST="$HOME/scripts"
SCRIPT=update.sh
read -rp "Import 'update.sh'? (y/n): " choice
[[ $choice = y* || $choice = Y* ]] && {
  # creates DEST if it doesn't exist
  [ -d $DEST ] || {
    echo -n "Creating '$DEST'..."
    mkdir $DEST && echo " Done"
    CHANGES=true
  }

  # copies SCRIPT file in DEST if it doesn't exist
  [ -f $DEST/$SCRIPT ] || {
    echo -n "Copying '$DIR/$SCRIPT' in '$DEST'..."
    cp "$DIR"/$SCRIPT $DEST && echo " Done"
    CHANGES=true
  }
}

# setting aliases...
ALIASFILE="$HOME/.bash_aliases"
ALIASES=(
  "alias update='$DEST/$SCRIPT'"
  "ccat() { pygmentize -g -P style=lightbulb \"\$@\" | nl -b a -w 4; }"
)

# creates the alias file if it doesn't exist
[ -f "$ALIASFILE" ] || {
  echo -n "Creating "$ALIASFILE"..."
  touch "$ALIASFILE" && echo " Done"
  CHANGES=true
}

# adds aliases to ALIASFILE if they don't exist
SOURCE=false

for alias in "${ALIASES[@]}"; do
  read -rp "Create alias \"$alias\"? (y/n): " choice
  [[ $choice = y* || $choice = Y* ]] && {
    grep "$alias" "$ALIASFILE" 1>/dev/null || {
      echo -n "Adding "$alias" to "$ALIASFILE"..."
      echo "$alias" >>"$ALIASFILE" && echo " Done"
      SOURCE=true
    }
  }
done

# source ALIASFILE if changed
$SOURCE && {
  # if not in a subshell...
  [ $SHLVL == 1 ] && {
    echo -n "Sourcing "$ALIASFILE"..."
    . "$ALIASFILE" && echo " Done"
  } || RESTART=true
}

# adding command to ~/.bashrc...
read -rp "Trim prompt directories? (y/n): " choice
[[ $choice = y* || $choice = Y* ]] && {
  BASHRC="$HOME/.bashrc"

  # checking bash version...
  ((${BASH_VERSION:0:1} < 4)) && {
    echo "Upgrading bash version..."
    sudo apt-get autoclean
    sudo apt-get install --only-upgrade bash
    CHANGES=true
  }
  ((${BASH_VERSION:0:1} >= 4)) && {
    CMDDOC="# sets the number of trailing directories to retain in the PS1 prompt"
    CMD="PROMPT_DIRTRIM=2"

    # adds CMD to ~/.bashrc if it isn't set
    grep $CMD $BASHRC 1>/dev/null || {
      echo -n "Adding '$CMD' to '$BASHRC'..."
      echo -e "\n$CMDDOC\n$CMD" >>$BASHRC && echo " Done"
      RESTART=true
    }
  }
}

! $CHANGES && ! $RESTART && ! $RELOG echo "No changes."
$RESTART && ! $RELOG && echo "Restart the terminal for changes to take effect."
$RELOG && {
  echo "Restart the shell for changes to take effect."
  read -rp "Restart now? (y/n): " choice
}
[[ $choice = y* || $choice = Y* ]] && killall -SIGQUIT gnome-shell
[ $SHLVL != 1 ] && exit 0
