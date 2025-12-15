#!/usr/bin/env bash

gwtoolbox_uri="https://github.com/gwdevhub/GWToolboxpp/releases/download/8.3_Release/gwtoolbox.exe"
gmod_uri="https://api.github.com/repos/gwdevhub/gMod/releases/latest"
cartography_uri="https://raw.githubusercontent.com/juniordiscart/GuildWarsReforged_SteamDeck_ModInstallationGuide/main/resources/Cartography%20and%20IGMM.tpf"
steam_arbitrary_command_uri="https://raw.githubusercontent.com/ChthonVII/guildwarslinuxinstallguide/refs/heads/main/extras/steamarbitrarycommand.sh"

steam_install_dir="$HOME/.local/share/Steam/steamapps/common/Guild Wars"
runtime_dir="$HOME/.local/share/Steam/steamapps/compatdata/29720/pfx/drive_c/Program Files (x86)"
gwtoolbox_download_path="$HOME/Downloads/GWToolbox.exe"
gmod_download_path="$HOME/Downloads/gMod.dll"
cartography_download_path="$HOME/Downloads/Cartography.tpf"
steam_arbitrary_command_path="$HOME/steamarbitrarycommand.sh"

install_gwtoolbox(){
    if ! [ -f "${gwtoolbox_download_path}" ]; then
        echo -n "Downloading GWToolbox++... "
        wget -q -O "${gwtoolbox_download_path}" "${gwtoolbox_uri}"
        echo "Done!"
    else
        echo "GWToolbox already downloaded..."
    fi

    echo -n "Installing GWToolbox++... "
    if ! [ -d "${runtime_dir}/GWToolbox" ]; then
        mkdir "${runtime_dir}/GWToolbox"
    fi

    mv -f "${gwtoolbox_download_path}" "${runtime_dir}/GWToolbox/GWToolbox.exe"
    echo "Done!"
}

install_gmod(){
    if ! [ -f "${gmod_download_path}" ]; then
        echo -n "Downloading gMod... "
        gmod_dll_url=$(curl -s "${gmod_uri}" | jq -r '.assets[] | select(.name == "gMod.dll") | .browser_download_url')
        wget -q -O "${gmod_download_path}" "${gmod_dll_url}"
        echo "Done!"
    fi

    if ! [ -f "${cartography_download_path}" ]; then
        echo -n "Downloading cartography maps..."
        wget -q -O "${cartography_download_path}" "${cartography_uri}"
        echo "Done!"
    fi

    echo -n "Installing gMod... "
    mv -f "${gmod_download_path}" "${steam_install_dir}/d3d9.dll"
    mv -f "${cartography_download_path}" "${steam_install_dir}/Cartography.tpf"
    echo "C:\Program Files (x86)\Guild Wars\Cartography.tpf" > "${steam_install_dir}/modlist.txt"
    echo "Done!"
}

create_scripts(){
    echo -n "Creating scripts..."

    cat > "${steam_install_dir}/steamlauncher.bat" <<'endmsg'
echo off

cd /D "C:\Program Files (x86)\Guild Wars"
start Gw.exe

ping -n 15 127.0.0.1 > nul
cd /D "C:\Program Files (x86)\GWToolbox"
start GWToolbox.exe
endmsg

    curl -sL "${steam_arbitrary_command_uri}" > "${steam_arbitrary_command_path}"
    chmod +x "${steam_arbitrary_command_path}"

    echo "Done!"
}

if ! [ -d "${steam_install_dir}" ]; then
    echo "Guild Wars Reforged is not installed in Steam."
    exit 1
fi  

if ! [ -d "${runtime_dir}" ]; then
    echo "The Proton runtime folder for Guild Wars Reforged could not be found."
    exit 1
fi 

if ! [[ -L "${runtime_dir}/Guild Wars" && -d "${runtime_dir}/Guild Wars" ]]; then
    ln -s "${steam_install_dir}" "${runtime_dir}/Guild Wars"
    echo "Created symlink between the Guild Wars Reforged install directory and Proton runtime directory."
fi

install_gwtoolbox
install_gmod
create_scripts

echo "GWToolbox and gMod with Cartography Made Easy have been successfully installed!"

echo "==="
echo "IMPORTANT! Adjust the launch options for Guild Wars Reforged to the following:"
echo "${steam_arbitrary_command_path} %command% --run steamlauncher.bat"
echo "==="

echo "Credits to Harry (Target SC), God Of Fissures, Ruine Eternelle, Farlo for their work on the Cartography Made Easy maps that are used."
echo "Credits to ChthonVII and his contributors for their extensive guide on getting Guild Wars to run on Linux."
echo "Credits to the gwdevhub team for their GWToolbox and gMod add-ons."

exit 0
