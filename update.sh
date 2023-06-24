#!/bin/bash

sudo apt-get autoclean
sudo apt update

# Installa gli aggiornamenti disponibili solo se ci sono nuovi aggiornamenti
if [ "$(apt list --upgradable 2>/dev/null | wc -l)" -gt "1" ]; then
  apt list --upgradable
  sudo apt upgrade -y
fi

# Rimuove i pacchetti obsoleti solo se ci sono pacchetti obsoleti
if [ "$(apt list ?obsolete 2>/dev/null | wc -l)" -gt "1" ]; then
  sudo apt autoremove -y
fi
