#!/bin/bash

#==================================================================
# Script Name   : psh-installer
# Description	: Installer script that installs psh (zsh installer
#                 with default configuration)
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# Dependencies that need to be installed with root privileges trhough apt-get
readonly DEPENDENCIES=(
    "zsh"
    "git"
    "curl"
)

# Colors used during script execution
readonly COLOR_RESET="\e[0m"
readonly COLOR_RED="\e[31m"
readonly COLOR_GREEN="\e[32m"
readonly COLOR_CYAN="\e[36m"

# Prefixes
readonly ERROR_PREFIX="${COLOR_RED}ERROR${COLOR_RESET}"
readonly SUCCESS_PREFIX="${COLOR_GREEN}SUCCESS${COLOR_RESET}"

# Print an error message
print_error() {
    echo -e "${ERROR_PREFIX} $1"
}

# Print a success message
print_success() {
    echo -e "${SUCCESS_PREFIX} $1"
}

# A yes/no dialog that can be used for user approvements during installation
yes_no_dialog() {
    local display_message="$1"
    read -p "Do you want to continue? (y/n): " confirm
    if [ $confirm != "y" ] && [ $confirm != "yes" ];
        then
            print_error "Installation aborted..."
            exit 1
    fi
}

# Print initial
echo "This install script will install zsh and configure it automatically for you."
echo "If you accept all steps of the installation, zsh will be pre-confiured to provide a great experience out of the box."
echo "The installer will check the dependencies and will inform you about required actions.
If you have sudo installed, the installer will automatically try to install the dependencies. after your approval."

# Ask user if he wants to start installation
# Ask the user if he really wants to install the cron
echo ""
yes_no_dialog "Do you want to install psh? (y/n): "

# Check which dependencies are installed and which not
not_installed=()
packages_installed() {
    local package="$1"
    if [ $(dpkg-query -W -f='${Status}' $package 2>/dev/null | grep -c "ok installed") -eq 0 ]
        then
            echo -e "$package: ${COLOR_RED}NOT INSTALLED${COLOR_RESET}"
            not_installed=(${not_installed[@]} ${package})
        else
            echo -e "$package: ${COLOR_GREEN}INSTALLED${COLOR_RESET}"
    fi
}

# Install dependencies. Use sudo if available.
install_apt_packages() {
    local use_sudo="$1"
    local package_install_command="$2"
    echo "The installer has to install the following packages through apt (using sudo if available): "
    echo -e "${COLOR_CYAN}${package_install_command}${COLOR_RESET}"
    yes_no_dialog "Do you want to continue? (y/n): "
    if [ "$use_sudo" -eq 1 ]
        then
            sudo apt-get install -y ${package_install_command}
        else
            apt-get install -y ${package_install_command}
    fi
    install_result="$?"
    if [ "$install_result" -ne 0 ]; then
        print_error "An error occured during installation of dependencies."
        print_error "Please take a look at the problem and revolve the problem manually!"
        exit
    fi
}

# Analyse which dependencies are already installed
echo ""
echo "Checking dependencies..."
for dependency in "${DEPENDENCIES[@]}"
do
    packages_installed "$dependency"
done

sudo_installed="1"
# Check if sudo is installed
echo ""
if [ $(dpkg-query -W -f='${Status}' sudo 2>/dev/null | grep -c "ok installed") -eq 0 ]
    then
        sudo_installed="0"
        echo -e "sudo is ${$COLOR_RED}NOT INSTALLED${COLOR_RESET}"
    else
        echo -e "sudo is ${COLOR_GREEN}AVAILABLE${COLOR_RESET}"
fi
echo ""

# built string containing all package that need to be installed.
package_install_command=""
for package in "${not_installed[@]}"
do
    package_install_command+="${package} "
done

# Handle package installation based on environment
if [ "${#not_installed[@]}" -ne 0 ]
    then
        if [ "${sudo_installed}" = "0" ];
            then
                if [ $(id -u) -eq "0" ]
                    then
                        install_apt_packages $sudo_installed "$package_install_command"
                    else
                        echo ""
                        echo ""
                        print_error "Sudo is not installed and you're not root."
                        print_error "All missing dependencies have to be installed manually using apt."
                        print_error "We generated the required apt command for you:"
                        print_error "${COLOR_CYAN}apt install $package_install_command"
                        exit
                fi
            else
                install_apt_packages $sudo_installed "$package_install_command"
        fi
fi

print_success "Installed all apt dependencies for psh!"
echo ""

# Ask user if he wants to set zsh as default shell
echo "zsh has been installed and is now usable."
echo "But it is currently not configured as your default shell."
echo -e "${COLOR_CYAN}NOTE${COLOR_RESET} Only set for your current user account!"
read -p "Do you want to set zsh as your default shell? (y/n): " confirmDefaultShell
if [ $confirmDefaultShell = "y" ] || [ $confirmDefaultShell = "yes" ];
    then
        chsh -s $(which zsh)
        if [ "$?" -ne 0 ]
            then
                print_error "Failed to change login shell using chsh."
                exit
            else
                print_success "zsh has been set as your default login shell!"
                print_success "From now zsh will be loaded after login."
        fi
fi

print_success "Installation completed successfully!"
