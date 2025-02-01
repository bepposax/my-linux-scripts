#!/bin/bash

DIR=$(dirname "$0")
RESTART=false
CHANGES=false
RELOG=false

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

# setting aliases...
ALIASFILE=~/.bash_aliases

# creates ALIASFILE if it doesn't exist
[ -f $ALIASFILE ] || {
  echo -n "Creating '$ALIASFILE'..."
  touch $ALIASFILE && echo " Done"
  CHANGES=true
}

# adds update alias if it doesn't exist
ALIAS="alias update='$DEST/$SCRIPT'"
grep "alias update" $ALIASFILE 1>/dev/null || {
  echo -n "Adding \"$ALIAS\" to '$ALIASFILE'..."
  echo "$ALIAS" >>$ALIASFILE && echo " Done"
  RESTART=true
}

# adds ccat alias if it doesn't exist
ALIAS="alias ccat='pygmentize -g -P style=material'"
grep "alias ccat" $ALIASFILE 1>/dev/null || {
  echo -n "Adding \"$ALIAS\" to '$ALIASFILE'..."
  echo "$ALIAS" >>$ALIASFILE && echo " Done"
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

# changing mirrors in /etc/apt/sources.list.d/ubuntu.sources to ".it" mirrors...
SRCLST="/etc/apt/sources.list.d/ubuntu.sources"
NEW_MIRR="http://it.archive"

# sets ".it" mirrors only if they're not ".it" mirrors
grep "$NEW_MIRR" $SRCLST 1>/dev/null || {
  # assigns to MIRR whichever mirror "head" is currently saved in SRCLST
  MIRR=$(grep -Eom 1 "http://([a-z]{2}.)?archive" $SRCLST)
  echo -n "Changing mirrors in '$SRCLST'... "
  sudo sed -i "s+$MIRR+$NEW_MIRR+g" $SRCLST && echo "Done"
  RESTART=true
}

# if not on WSL...
[ ! "$(uname -r | sed -n 's/.*\( *Microsoft *\).*/\1/ip')" ] &&
  # and running on Ubuntu...
  lsb_release -d | grep Ubuntu 1>/dev/null &&
  {
    # installing gnome-shell-extensions if not installed...
    (($(apt list --installed gnome-shell-extensions 2>/dev/null | wc -l) > 1)) || {
      echo "Installing 'gnome-shell-extensions'..."
      sudo apt-get -qq install gnome-shell-extensions && echo "Done"
      RELOG=true
    }
    # installing gnome-shell-extension-installer if not installed...
    [ -f /usr/bin/gnome-shell-extension-installer ] || {
      echo -n "Installing 'gnome-shell-extension-installer'..."
      wget -q gnome-shell-extension-installer "https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer"
      chmod +x gnome-shell-extension-installer
      sudo mv gnome-shell-extension-installer /usr/bin/ && echo " Done"
      CHANGES=true
    }
    EXTPATH="$HOME/.local/share/gnome-shell/extensions"
    # installing 'dash-to-dock' gnome extension if not installed...
    [ -d "$EXTPATH/dash-to-dock@micxgx.gmail.com" ] || {
      echo -n "Installing 'Dash To Dock' gnome extension..."
      gnome-shell-extension-installer 307 --yes &>/dev/null && echo " Done"
      RELOG=true
    }
    # turning on dock 'autohide' if not on...
    eval "$(gsettings get org.gnome.shell.extensions.dash-to-dock autohide)" || {
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
    eval "$(gsettings get org.gnome.shell.extensions.dash-to-dock custom-theme-shrink)" || {
      echo -n "Shrinking the dock..."
      gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true && echo " Done"
      CHANGES=true
    }
    # moving dock to bottom if not there already...
    gsettings get org.gnome.shell.extensions.dash-to-dock dock-position | grep 'BOTTOM' 1>/dev/null || {
      echo -n "Moving dock to bottom..."
      gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM' && echo " Done"
      CHANGES=true
    }
    # setting dock transparency mode to dynamic if not different...
    gsettings get org.gnome.shell.extensions.dash-to-dock transparency-mode | grep 'DYNAMIC' 1>/dev/null || {
      echo -n "Changing dock transparency mode to 'DYNAMIC'..."
      gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'DYNAMIC' && echo " Done"
      CHANGES=true
    }
    # changing dock transparency to 80% if different...
    gsettings get org.gnome.shell.extensions.dash-to-dock background-opacity | grep 0.2 1>/dev/null || {
      echo -n "Changing dock transparency to 80%..."
      gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.2 && echo " Done"
      CHANGES=true
    }
    # installing 'hidetopbar' gnome extension if not installed...
    [ -d "$EXTPATH/hidetopbar@mathieu.bidon.ca" ] || {
      echo -n "Installing 'Hide Top Bar' gnome extension..."
      gnome-shell-extension-installer 545 --yes &>/dev/null && echo " Done"
      RELOG=true
    }
    # installing desktop-icons-ng if not installed...
    (($(apt list --installed gnome-shell-extension-desktop-icons-ng 2>/dev/null | wc -l) > 1)) || {
      echo "Installing 'Desktop Icons NG (DING)'..."
      sudo apt-get -qq install gnome-shell-extension-desktop-icons-ng && echo "Done"
      RELOG=true
    }
    # setting desktop icons default position to bottom left if not already set
    gsettings get org.gnome.shell.extensions.ding start-corner | grep 'bottom-left' 1>/dev/null || {
      echo -n "Changing desktop icons default position to 'bottom-left'..."
      gsettings set org.gnome.shell.extensions.ding start-corner 'bottom-left' && echo " Done"
      CHANGES=true
    }
  }

! $CHANGES && ! $RESTART && ! $RELOG echo "No changes."

$RESTART && ! $RELOG && echo "Restart the terminal for changes to take effect."

$RELOG && {
  echo "Restart the shell for changes to take effect."
  read -rp "Restart now? (y/n): " choice
}
[[ $choice = y* || $choice = Y* ]] && killall -SIGQUIT gnome-shell

exit 0
