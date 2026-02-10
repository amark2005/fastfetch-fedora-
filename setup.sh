#!/usr/bin/env bash

echo "Setting Up everything For you boss"

sleep 0.5

Install_app(){
    #if command -v zypper >/dev/null 2>&1;then
        #echo "Installing package in Opensuse"
        #sudo zypper install firefox vscode git trash-cli zsh btop ghostty github-cli
    if command -v pacman >/dev/null 2>&1;then
        echo "Installing package in Arch"
        sudo pacman -S --noconfirm --needed vscode git gh-cli \
            trash-cli zsh btop ghostty curl wget btop 
    fi
}

Zsh_install(){
    Shell=$(echo "$SHELL")
    if [[ $Shell == "/usr/bin/zsh" ]]; then
        echo "the current shell is zsh"
    else
        echo "not zsh"
        chsh -s $(which zsh)
        echo "Defaulting zsh"
    fi
    trash $HOME/.zshrc

    echo "Reinstalling zsh and zsh conf"
    [[ -f "$HOME/.zshrc" ]] && trash "$HOME/.zshrc"
    cp "$PWD/zsh-config/.zshrc" "$HOME/.zshrc"
    echo "the current shell is zsh now"
}

starship_config(){
    echo "Setting up StarShip"
    cp starship-config/starship.toml $HOME/.config/starship.toml
    echo "Starship setup complete"
    sleep 0.5
}
power_config(){
    echo "Configuring power"
    sleep 0.6
    sudo pacman -S --noconfirm --needed tlp tlp-rdw

    sudo systemctl stop power-profiles-daemon.service
    sudo systemctl disable power-profiles-daemon.service
    sudo pacman -Rns --noconfirm power-profiles-daemon
    sudo systemctl enable tlp.service
    sudo systemctl start tlp.service
    sudo systemctl enable tlp-sleep.service
    sudo systemctl mask systemd-rfkill.service
    sudo systemctl mask systemd-rfkill.socket
    sudo tlp-stat -s
    sudo tlp start
    echo
    echo "Power Setup Completed"
    sleep 0.5
}
rebootmenu(){
    echo "installing reboot2menu"
    sudo cp reboot2menu/reboot2bios.sh /usr/local/bin/reboot2menu.sh
    sudo chmod +x /usr/local/bin/reboot2menu.sh
    echo "Install completed"
    sleep 0.5
}

Main(){
    #Install_app
    #Zsh_install
    #starship_config
    #power_config
    rebootmenu
    echo "Setup Completed"
    echo "Restarting ZSH"
    sleep 1.0
    exec zsh

}

Main
