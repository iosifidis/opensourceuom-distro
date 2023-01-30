#!/bin/bash

# Detect the Linux distribution
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$NAME
else
  OS=$(uname -s)
fi

# Function to install packages from repositories
install_repo_package() {
  if [ "$OS" == "Fedora" ]; then
    sudo dnf install -y $1
  elif [ "$OS" == "openSUSE" ]; then
    sudo zypper install -y $1
  elif [ "$OS" == "Ubuntu" ]; then
    sudo apt-get update
    sudo apt-get install -y $1
  elif [ "$OS" == "Arch Linux" ]; then
    sudo pacman -S $1 --noconfirm
  fi
}

# Function to install packages from flatpak
install_flatpak_package() {
  if ! command -v flatpak > /dev/null 2>&1; then
    echo "Error: flatpak is not installed."
    exit 1
  fi

  flatpak install -y flathub $1
}

# GUI for user selection using zenity
SELECTION=$(zenity --list --checklist \
  --title "Open Source UoM Package Installer" \
  --text "Επιλέξτε πακέτα | Select packages to install:" \
  --width=400 --height=300 \
  --column "Select" --column "Package" \
  FALSE "dia" \
  FALSE "git" \
  FALSE "vscode" \
  FALSE "gitkraken" \
  FALSE "codeblocks" \
  FALSE "eclipse")

# Check if user clicked "Cancel"
if [ $? -ne 0 ]; then
  exit 1
fi

# Install selected packages
for package in $SELECTION; do
  case $package in
    dia)
      install_repo_package "dia"
      ;;
    git)
      install_repo_package "git"
      ;;
    vscode)
      install_flatpak_package "com.visualstudio.code"
      ;;
    gitkraken)
      install_flatpak_package "com.axosoft.GitKraken"
      ;;
    codeblocks)
      install_flatpak_package "org.codeblocks.codeblocks"
      ;;
    eclipse)
      install_flatpak_package "org.eclipse.Java"
      ;;
  esac
done

zenity --info --title "Linux Package Installer" --text "Installation complete."

