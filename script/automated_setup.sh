#!/bin/bash

steam_install_dir="/home/$USER/.local/share/Steam/steamapps/common/Guild Wars"
runtime_dir="/home/$USER/.local/share/Steam/steamapps/compatdata/29720/pfx/drive_c/Program Files (x86)"

if ! [ -d "${steam_install_dir}" ]; then
    echo "Guild Wars is not installed by Steam."
    exit 1
fi  

if ! [ -d "${runtime_dir}" ]; then
    echo "The Proton runtime folder for Guild Wars could not be found."
    exit 1
fi 

if ! [[ -L "${runtime_dir}/Guild Wars" && -d "${runtime_dir}/Guild Wars" ]]; then
  ln -s "${steam_install_dir}" "${runtime_dir}/Guild Wars"
  echo "Created symlink between the Steam install directory and Proton runtime directory."
fi

echo -n "Downloading GWToolbox++... "
wget -P "$HOME/Downloads" -O "GWToolbox.exe" https://github.com/gwdevhub/GWToolboxpp/releases/download/8.3_Release/gwtoolbox.exe
echo "Done!"

echo -n "Installing GWToolbox++... "
if ! [ -d "${runtime_dir}/GWToolbox" ]; then
    mkdir "${runtime_dir}/GWToolbox"
fi

mv -f "$HOME/Downloads/GWToolbox.exe" "${runtime_dir}/GWToolbox/GWToolbox.exe"
echo "Done!"

echo -n "Downloading gMod... "
gmod_dll_url=$(curl -s https://api.github.com/repos/gwdevhub/gMod/releases/latest | jq '.assets[] | select(.name == "gMod.dll") | .browser_download_url')
wget -P "$HOME/Downloads" -O "d3d9.dll" "${gmod_dll_url}"
echo "Done!"

echo -n "Downloading cartography maps..."
