#!/usr/bin/env bash
set -e

# Get the directory of this script so that the rest of the script can be run from any working directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

echo "Setting Up everything For you boss"

sleep 0.5

Install_app(){
    # Define a list of packages to install
    local packages="vscode git gh zsh btop ghostty curl wget"

    # Detect the package manager and install packages
    if command -v pacman >/dev/null 2>&1;then
        echo "Installing packages for Arch Linux"
        sudo pacman -S --noconfirm --needed $packages
    elif command -v apt >/dev/null 2>&1; then
        echo "Installing packages for Debian/Ubuntu"
        sudo apt update
        sudo apt install -y $packages
    elif command -v dnf >/dev/null 2>&1; then
        echo "Installing packages for Fedora"
        sudo dnf install -y $packages
    elif command -v zypper >/dev/null 2>&1; then
        echo "Installing packages for OpenSUSE"
        sudo zypper install -y $packages
    else
        echo "No supported package manager found. Please install the packages manually."
        echo "Packages: $packages"
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
    rm -rf $HOME/.zshrc

    echo "Reinstalling zsh and zsh conf"
    [[ -f "$HOME/.zshrc" ]] && rm -rf "$HOME/.zshrc"
    cp "$SCRIPT_DIR/zsh-config/.zshrc" "$HOME/.zshrc"
    echo "the current shell is zsh now"
}

starship_config(){
    echo "Setting up StarShip"
    mkdir -p "$HOME/.config"
    cp "$SCRIPT_DIR/starship-config/starship.toml" "$HOME/.config/starship.toml"
    echo "Starship setup complete"
    sleep 0.5
}
power_config(){
    if ! command -v pacman >/dev/null 2>&1; then
        echo "Skipping power configuration. Not an Arch-based system."
        return
    fi
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
    sudo cp "$SCRIPT_DIR/reboot2menu/reboot2bios.sh" "/usr/local/bin/reboot2menu.sh"
    sudo chmod +x "/usr/local/bin/reboot2menu.sh"
    echo "Install completed"
    sleep 0.5
}
vscode(){
    if ! command -v code >/dev/null 2>&1; then
        echo "VSCode not found. Skipping configuration."
        return
    fi

    echo "Configuring vscode"
    code --version
    xargs -n 1 code --install-extension < "$SCRIPT_DIR/vscode/vscodeext.txt"

    local vscode_config_dir
    if [ -d "$HOME/.config/Code/User" ]; then
        vscode_config_dir="$HOME/.config/Code/User"
    elif [ -d "$HOME/.config/Code - OSS/User" ]; then
        vscode_config_dir="$HOME/.config/Code - OSS/User"
    else
        echo "VSCode user settings directory not found. Skipping settings configuration."
        return
    fi

    cp "$SCRIPT_DIR/vscode/settings.json" "$vscode_config_dir/settings.json"
    echo "Config Done"
    sleep 0.5
}

show_menu() {
    echo "-------------------------------------"
    echo "          Linux Setup Menu"
    echo "-------------------------------------"
    echo "1. Install Applications"
    echo "2. Install/Configure Zsh"
    echo "3. Setup Starship"
    echo "4. Configure Power (Arch Only)"
    echo "5. Install Reboot to BIOS menu"
    echo "6. Configure VSCode"
    echo "-------------------------------------"
    echo "a. Run All"
    echo "e. Exit"
    echo "-------------------------------------"
}

main_menu() {
    local choice
    local zsh_changed=false
    while true; do
        show_menu
        read -p "Enter your choice: " choice
        echo
        case $choice in
            1) Install_app ;;
            2) Zsh_install; zsh_changed=true ;;
            3) starship_config ;;
            4) power_config ;;
            5) rebootmenu ;;
            6) vscode ;;
            a)
                Install_app
                Zsh_install
                zsh_changed=true
                starship_config
                power_config
                rebootmenu
                vscode
                ;;
            e)
                echo "Exiting."
                break
                ;;
            *)
                echo "Invalid choice. Please try again."
                ;;
        esac

        if [[ "$choice" != "e" ]]; then
            read -p "Press Enter to continue..."
            clear
        fi
    done

    if [ "$zsh_changed" = true ]; then
        echo
        read -p "Zsh was configured. It's recommended to restart your shell. Restart now? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            exec zsh
        fi
    fi
}

main_menu
