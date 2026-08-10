#!/bin/bash

sudo echo "Cleaning package cache..."
sudo nala clean

echo -e "---\nChecking updates..."
sudo nala update

# Installa gli aggiornamenti disponibili solo se ci sono nuovi aggiornamenti
(($(nala list --upgradeable 2>/dev/null | wc -l) > 1)) && {
  echo -e "---\nUpgrading packages..."
  nala list --upgradeable
  sudo nala upgrade -y
}
echo -e "---\nChecking obsolete packages..."
# Rimuove i pacchetti obsoleti solo se ci sono pacchetti obsoleti
if (($(nala list -- ?obsolete 2>/dev/null | wc -l) > 1)); then {
  echo "Removing obsolete packages..."
  nala list -- ?obsolete
  sudo nala autoremove -y
}; else echo "No obsolete packages found."; fi
exit 0
