#!/bin/bash

install_nerdfont_fedora(){
local FONT_NAME="AdwaitaMono Nerd Font"
    local URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/AdwaitaMono.zip"
    local FONT_DIR="$HOME/.local/share/fonts/$FONT_NAME"

    if [ ! -d "$FONT_DIR" ]; then
        echo "Installing $FONT_NAME Nerd Font..."
        mkdir -p "$FONT_DIR"

        curl -fLo "/tmp/${FONT_NAME}.zip" "$URL"
        unzip "/tmp/${FONT_NAME}.zip" -d "$FONT_DIR"
        rm "/tmp/${FONT_NAME}.zip"

        fc-cache -fv
        echo "Installation complete. Font installed to $FONT_DIR"
    else
        echo "$FONT_NAME is already installed in $FONT_DIR"
    fi
}

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Error: Cannot determine OS distribution."
    exit 1
fi

if [ "$ID" = "fedora" ]; then
    echo "Populating for Fedora Linux."
    install_nerdfont_fedora
else
    echo "Check failed: This system is $NAME, not Fedora."
    exit 1
fi

