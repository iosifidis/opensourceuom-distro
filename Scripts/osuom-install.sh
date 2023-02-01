#!/bin/bash

# get the distribution name
distro=$(lsb_release -is)

if [ $distro == "Fedora" ] || [ $distro == "openSUSE" ]; then
  # check if flatpak is installed in Fedora or openSUSE
  if ! command -v flatpak > /dev/null 2>&1; then
    # ask the user if they want to install flatpak
    install_flatpak=$(zenity --title="Install Flatpak" --width=300 --height=100 \
      --question --text="Flatpak is not installed. Do you want to install it?")
    if [ $install_flatpak == "0" ]; then
      # install flatpak
      if [ $distro == "Fedora" ]; then
        sudo dnf install flatpak -y
      else
        sudo zypper install flatpak -y
      fi
    fi
  fi
else
  # check if flatpak is installed in Ubuntu
  if ! command -v flatpak > /dev/null 2>&1; then
    # ask the user if they want to install flatpak
    install_flatpak=$(zenity --title="Install Flatpak" --width=300 --height=100 \
      --question --text="Flatpak is not installed. Do you want to install it?")
    if [ $install_flatpak == "0" ]; then
      # install flatpak
      sudo apt-get install flatpak -y
    fi
  fi
fi

# Function to install packages from repositories
install_repo_package() {
  if [ "$distro" == "Fedora" ]; then
    sudo dnf install -y $1
  elif [ "$distro" == "openSUSE" ]; then
    sudo zypper install -y $1
  elif [ "$distro" == "Ubuntu" ]; then
    sudo apt-get update
    sudo apt-get install -y $1
  elif [ "$distro" == "EndeavourOS" ]; then
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

