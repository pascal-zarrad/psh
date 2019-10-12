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
    "fonts-powerline"
    "git"
    "curl"
)

# Colors used during script execution
readonly COLOR_RESET="\e[0m"
readonly COLOR_RED="\e[31m"
readonly COLOR_GREEN="\e[32m"
readonly COLOR_CYAN="\e[36m"
readonly COLOR_YELLOW="\e[33m"

# Prefixes
readonly ERROR_PREFIX="${COLOR_RED}ERROR${COLOR_RESET}"
readonly SUCCESS_PREFIX="${COLOR_GREEN}SUCCESS${COLOR_RESET}"
readonly WARNING_PREFIX="${COLOR_YELLOW}WARNING${COLOR_RESET}"

# Print an error message
print_error() {
    echo -e "${ERROR_PREFIX} $1"
}

# Print a warning message
print_warning() {
    echo -e "${WARNING_PREFIX} $1"
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

# Install antigen to ~/.antigen/antigen.sh
echo ""
echo "The basic installation of zsh is now done."
echo "Now components required for customization will be installed."
echo "Antigen is used for plugin management."
echo "To enable this plugin manager, it will now be installed..."
if [ -f "${HOME}/.antigen/antigen.zsh" ]
    then
        print_success "Antigen is already installed."
    else
        if ! [ -d "${HOME}/.antigen" ]; then
            mkdir "${HOME}/.antigen"
        fi
        curl -L git.io/antigen > "${HOME}/.antigen/antigen.zsh"
        if [ "$?" -eq 0 ]
            then
                print_success "Successfully installed antigen to ${HOME}/.antigen/antigen.zsh"
            else
                print_error "Failed to install antigen!"
                exit
        fi
fi

# Function that checks if antigen bundle is loaded or not
# and then adds the bundle to the .zshrc
apply_antigen_bundle() {
    antigen_bundle="$1"
    if ! grep -q "$antigen_bundle" "${HOME}/.zshrc" ; then
        echo "antigen bundle ${antigen_bundle}" >> "${HOME}/.zshrc"
    fi
}

# Function that checks if antigen theme is loaded or not
# and then adds the theme to the .zshrc
apply_antigen_theme() {
    antigen_bundle="$1"
    if ! grep -q "antigen theme ${antigen_bundle}" "${HOME}/.zshrc" ; then
        echo "antigen theme ${antigen_bundle}" >> "${HOME}/.zshrc"
    fi
}

# First of all backup .zshrc
echo ""
echo "Backing up ${HOME}/.zshrc to ${HOME}/.zshrc_unmodified..."
cp "${HOME}/.zshrc" "${HOME}/.zshrc_unmodified"
if [ "$?" -eq 0 ]
    then
        print_success "Backed up ${HOME}/.zshrc"
    else
        print_error "Failed to backup ${HOME}/.zshrc"
fi
echo ""

echo "Preparing ${HOME}/.zshrc..."

# Now reset ~/.zshrc, as we build our own only using antigen
# to load things
echo "# This .zshrc has been generated by psh." > "${HOME}/.zshrc"
echo "# https://github.com/pascal-zarrad/psh" >>"${HOME}/.zshrc"
echo "# ======================================" >> "${HOME}/.zshrc"
echo "" >> "${HOME}/.zshrc"

# Enable antigen
echo "# Enable antigen" >> "${HOME}/.zshrc"

echo "source ${HOME}/.antigen/antigen.zsh" >> "${HOME}/.zshrc"

# Load oh-my-zsh library
echo "# Load oh-my-zsh library" >> "${HOME}/.zshrc"
echo "antigen use oh-my-zsh" >> "${HOME}/.zshrc"

# Add comment which tells the user that here all automatically loaded
# plugins are loaded
echo "# Load plugins and themes (generated by psh plugins during installation)" >> "${HOME}/.zshrc"

print_success "Prepared ${HOME}/.zshrc"

# Applay all customizations
# For a better overview, the customizations are done using
# automatically loaded plugin files.
# This keeps this script short.
echo ""
echo "Applying all customizations for zsh using plugins..."
plugins=($(ls plugins))
for plugin in "${plugins[@]}"
do
    pluginFile="plugins/${plugin}/plugin.sh"
    if [ -f "$pluginFile" ]
        then
            echo ""
            echo "Running plugin: ${plugin}"
            source "$pluginFile"
            if [ "$?" -eq 0 ]
                then
                    print_success "Run plugin ${plugin}"
                else
                    print_warning "Failed to run plugin ${plugin}!"
            fi
        else
            print_warning "Plugin ${plugin} has no plugin.sh, skipping!"
    fi
done
echo ""
echo "Plugin execution done."

# Now finish by telling antigen to apply the bundles and themes
# Now load oh-my-zsh library
echo "# Apply everything" >> "${HOME}/.zshrc"
echo "antigen apply" >> "${HOME}/.zshrc"

# The installation was successful
echo ""
print_success "Installation completed successfully!"
print_success "Restart your terminal or re-login to activate zsh!"
