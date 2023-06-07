#!/bin/bash

sudo apt update

# Installa gli aggiornamenti disponibili solo se ci sono nuovi aggiornamenti
if [ "$(sudo apt list --upgradable 2>/dev/null | wc -l)" -gt "1" ]; then
  sudo apt list --upgradable
  sudo apt upgrade -y
fi

# Rimuove i pacchetti obsoleti solo se ci sono pacchetti obsoleti
if [ "$(sudo apt list ?obsolete 2>/dev/null | wc -l)" -gt "1" ]; then
  sudo apt autoremove -y
fi
