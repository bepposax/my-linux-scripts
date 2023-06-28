#!/bin/bash

echo "Cleaning package cache..."
sudo apt-get autoclean

echo -e "---\nChecking updates..."
sudo apt update

# Installa gli aggiornamenti disponibili solo se ci sono nuovi aggiornamenti
(($(apt list --upgradeable 2>/dev/null | wc -l) > 1)) && {
  echo -e "---\nUpgrading packages..."
  apt list --upgradeable
  sudo apt upgrade -y
}
# Rimuove i pacchetti obsoleti solo se ci sono pacchetti obsoleti
if (($(apt list -- ?obsolete 2>/dev/null | wc -l) > 1)); then {
  echo -e "---\nRemoving obsolete packages..."
  apt list -- ?obsolete
  sudo apt autoremove -y
}; else echo -e "---\nNo obsolete packages found."; fi
exit 0
