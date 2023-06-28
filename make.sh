#!/bin/bash

DIR=$(dirname "$0")
RESTART=false
CHANGES=false

# disabling MOTD...
HUSH=~/.hushlogin

[ -f $HUSH ] || {
  echo -n "Creating '$HUSH'..."
  touch $HUSH && echo " Done"
  RESTART=true
}

# adding the update script...
DEST=~/scripts
SCRIPT=update.sh

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

# setting alias to run the update script...
ALIASFILE=~/.bash_aliases

# creates ALIASFILE if it doesnìt exist
[ -f $ALIASFILE ] || {
  echo -n "Creating '$ALIASFILE'..."
  touch $ALIASFILE && echo " Done"
  CHANGES=true
}

# adds the ALIAS line inside ALIASFILE if it doesn't exist
ALIAS=("alias update='sudo bash $DEST/$SCRIPT'")

grep "alias update" $ALIASFILE 1>/dev/null || {
  echo -n "Adding \"${ALIAS[*]}\" to '$ALIASFILE'..."
  echo "${ALIAS[@]}" >>$ALIASFILE && echo " Done"
  RESTART=true
}

# adding command to ~/.bashrc...
BASHRC=~/.bashrc

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

# changing mirrors in /etc/apt/sources.list to ".it" mirrors...
SRCLST="/etc/apt/sources.list"
NEW_MIRR="deb http://it.archive"

# sets ".it" mirrors only if they're not ".it" mirrors
grep "$NEW_MIRR" $SRCLST 1>/dev/null || {
  # assigns to MIRR whichever mirror "head" is currently saved in SRCLST
  MIRR=$(grep -Eom 1 "^deb http://([a-z]{2}.)?archive" $SRCLST)
  echo -n "Changing mirrors in '$SRCLST'... "
  sudo sed -i "s+$MIRR+$NEW_MIRR+g" $SRCLST && echo "Done"
  RESTART=true
}

# changing dock's appearance if not on WSL...
[ ! "$(uname -r | sed -n 's/.*\( *Microsoft *\).*/\1/ip')" ] &&
  # checking if running on Ubuntu...
  lsb_release -d | grep Ubuntu 1>/dev/null &&
  {
    # turning on dock 'autohide' if not on...
    ! eval "$(gsettings get org.gnome.shell.extensions.dash-to-dock autohide)" && {
      echo -n "Turning on dock 'autohide'..."
      gsettings set org.gnome.shell.extensions.dash-to-dock autohide true && echo " Done"
      CHANGES=true
    }
    # turning off 'dock-fixed' if not off...
    eval "$(gsettings get org.gnome.shell.extensions.dash-to-dock dock-fixed)" && {
      echo -n "Turning off 'dock-fixed'..."
      gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false && echo " Done"
      CHANGES=true
    }
    # turning off extended dock if extended...
    eval "$(gsettings get org.gnome.shell.extensions.dash-to-dock extend-height)" && {
      echo -n "Turning off extended dock..."
      gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false && echo " Done"
      CHANGES=true
    }
    # shrinking the dock if not shrinked...
    ! eval "$(gsettings get org.gnome.shell.extensions.dash-to-dock custom-theme-shrink)" && {
      echo -n "Shrinking the dock..."
      gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true && echo " Done"
      CHANGES=true
    }
    # moving dock to bottom if not there already...
    ! gsettings get org.gnome.shell.extensions.dash-to-dock dock-position | grep 'BOTTOM' 1>/dev/null && {
      echo -n "Moving dock to bottom..."
      gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM' && echo " Done"
      CHANGES=true
    }
    # changing dock transparency to 80% if different...
    ! gsettings get org.gnome.shell.extensions.dash-to-dock background-opacity | grep 0.2 1>/dev/null && {
      echo -n "Changing dock transparency to 80%..."
      gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'DYNAMIC'
      gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.2 && echo " Done"
      CHANGES=true
    }
  }

! $CHANGES && ! $RESTART && echo "No changes."

# removing the folder containing this file...
if [[ $DIR == . ]]; then {
  echo -n "Removing '$PWD'..."
  rm -rf "$PWD" && echo " Done"
}; else {
  echo -n "Removing '$DIR'..."
  rm -rf "$DIR" && echo " Done"
}; fi

$RESTART && echo "Restart the terminal for changes to take effect."

exit 0
