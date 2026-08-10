#!/bin/bash

# Controlla presenza pacchetto nala
if dpkg -s nala &>/dev/null; then
  pm=nala
else
  pm=apt
fi

sudo echo "Cleaning package cache..."
if [ $pm = 'nala' ]; then
  sudo $pm clean
else 
  sudo $pm autoclean
fi

echo -e "---\nChecking updates..."
sudo $pm update

# Installa gli aggiornamenti disponibili solo se ci sono nuovi aggiornamenti
(($($pm list --upgradeable 2>/dev/null | wc -l) > 1)) && {
  echo -e "---\nUpgrading packages..."
  $pm list --upgradeable
  sudo $pm upgrade -y
}
echo -e "---\nChecking obsolete packages..."
# Rimuove i pacchetti obsoleti solo se ci sono pacchetti obsoleti
if (($($pm list -- ?obsolete 2>/dev/null | wc -l) > 1)); then {
  echo "Removing obsolete packages..."
  $pm list -- ?obsolete
  sudo $pm autoremove -y
}; else echo "No obsolete packages found."; fi
exit 0
