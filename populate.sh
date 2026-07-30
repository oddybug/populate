#!/bin/bash

install_cpp_tools_fedora(){
    sudo dnf install cmake gcc-c++
}

install_zsh_fedora(){
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_nvim_fedora(){
    sudo dnf install nvim
    git clone https://github.com/oddybug/dot-nvim.git ~/.config/nvim

    echo "Nvim installed succesfuly."
}

install_zsh_fedora(){
    sudo dnf install zsh
}


install_sway_fedora(){
    sudo dnf install sway
    sudo dnf install waybar

    echo "sway installed succesfuly."
}

install_alacritty_fedora(){
    sudo dnf install alacritty -y
    mkdir -p ~/.config/alacritty
    echo -e "[window]\nopacity = 0.8" > ~/.config/alacritty/alacritty.toml

    echo "Alacritty installed succesfuly."
}

config_git_profile(){
    read -p "Enter your Git user name: " git_name
    read -p "Enter your Git email address: " git_email

    git config --global user.name "$git_name"
    git config --global user.email "$git_email"

    echo "Successfully updated ~/.gitconfig:"
    echo "Name:  $(git config --global user.name)"
    echo "Email: $(git config --global user.email)"
}

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

install_utils_fedora(){
    sudo dnf install btop j4-dmenu-desktop
}

install_wireguard_fedora(){
    sudo dnf install wireguard-tools
}

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Error: Cannot determine OS distribution."
    exit 1
fi

if [ "$ID" = "fedora" ]; then
    echo "Populating for Fedora Linux."
    install_alacritty_fedora
    install_nvim_fedora
    install_nerdfont_fedora
    config_git_profile
    install_zsh_fedora
    install_cpp_tools_fedora
    install_utils_fedora
    install_wireguard_fedora
else
    echo "Check failed: This system is $NAME, not Fedora."
    exit 1
fi

