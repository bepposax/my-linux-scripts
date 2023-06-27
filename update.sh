#!/bin/bash

sudo apt-get autoclean
sudo apt update

# Installa gli aggiornamenti disponibili solo se ci sono nuovi aggiornamenti
(($(apt list --upgradable 2>/dev/null | wc -l) > 1)) && {
  apt list --upgradable
  sudo apt upgrade -y
}

# Rimuove i pacchetti obsoleti solo se ci sono pacchetti obsoleti
(($(apt list -- ?obsolete 2>/dev/null | wc -l) > 1)) && {
  apt list -- ?obsolete
  sudo apt autoremove -y
}
exit 0
