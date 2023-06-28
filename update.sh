#!/bin/bash

echo "Cleaning package cache..."
sudo apt-get autoclean
echo "---"
echo "Checking updates..."
sudo apt update
echo "---"
# Installa gli aggiornamenti disponibili solo se ci sono nuovi aggiornamenti
(($(apt list --upgradeable 2>/dev/null | wc -l) > 1)) && {
  echo "Upgrading packages..."
  apt list --upgradeable
  sudo apt upgrade -y
  echo "---"
}
# Rimuove i pacchetti obsoleti solo se ci sono pacchetti obsoleti
if (($(apt list -- ?obsolete 2>/dev/null | wc -l) > 1)); then {
  echo "Removing obsolete packages..."
  apt list -- ?obsolete
  sudo apt autoremove -y
}; else echo "No obsolete packages found."; fi
exit 0
