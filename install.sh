#!/bin/bash

#==================================================================
# Script Name   : psh-installer
# Description	: Installer script that installs psh (zsh installer
#                 with default configuration)
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# ---- START: Constants used by PSH
# All constants that not belong to plugins should be listed below and not
# in sourced scripts, to have a central overview of them.

# Dependencies that need to be installed with root privileges trhough apt-get
readonly DEPENDENCIES=(
    "zsh"
    "fonts-powerline"
    "git"
    "curl"
    "imagemagick"
    "xclip"
)

# Template directive constant
readonly TEMPLATE_DIRECTIVE="#PSH_TEMPLATE="
# Different template insertion points
readonly TEMPLATE_START="START"
readonly TEMPLATE_BETWEEN_ANTIGEN_AND_OH_MY_ZSH="BETWEEN_ANTIGEN_AND_OH_MY_ZSH"
readonly TEMPLATE_BETWEEN_OH_MY_ZSH_AND_PLUGINS="BETWEEN_OH_MY_ZSH_AND_PLUGINS"
readonly TEMPLATE_AFTER_PLUGINS_BEFORE_ANTIGEN_APPLY="AFTER_PLUGINS_BEFORE_ANTIGEN_APPLY"
readonly TEMPLATE_END="END"

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
# ---- END: Constants used by PSH

# Function to print usage of install.sh
cmd_help() {
    echo "Usage of install.sh:"
    echo "install.sh [--disable-templates] [--help]"
    echo ""
    echo "--help                - Prints this help page"
    echo "--disable-templates   - Disables inclusion of templates"
    echo "--disable-plugins     - Disable plugin execution"
    echo ""
    exit
}

# Variables (flags) that are set by the start parameters
start_arg_disable_template_engine=0
start_arg_disable_plugin_system=0
# Process arguments/start parameters
# and set values to use
while test $# != 0
do
    case "$1" in
        --disable-templates)
            start_arg_disable_template_engine=1
            ;;
        --disable-plugins)
            start_arg_disable_plugin_system=1
            ;;
        --help)
            cmd_help
            ;;
        *)
            cmd_help
            ;;
    esac
    shift
done

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
    read -r -p "$display_message" confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "yes" ];
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
    dpgk_install_check_result=$(dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -c "ok installed")
    if [ "$dpgk_install_check_result" -eq 0 ]
        then
            echo -e "$package: ${COLOR_RED}NOT INSTALLED${COLOR_RESET}"
            not_installed=("${not_installed[@]}" "${package}")
        else
            echo -e "$package: ${COLOR_GREEN}INSTALLED${COLOR_RESET}"
    fi
}

# Install dependencies. Use sudo if available.
install_apt_packages() {
    local use_sudo="$1"
    local package_install_command="$2"
    IFS=' ' read -r -a package_install_arguments <<< "$package_install_command"
    echo "The installer has to install the following packages through apt (using sudo if available): "
    echo "During package installation, an apt update & upgrade are done automatically!"
    echo -e "${COLOR_CYAN}${package_install_command}${COLOR_RESET}"
    yes_no_dialog "Do you want to continue? (y/n): "
    echo "${package_install_arguments[@]}"
    if [ "$use_sudo" -eq 1 ]
        then
            sudo apt-get update && sudo apt-get upgrade && sudo apt-get install -y "${package_install_arguments[@]}"
        else
            apt-get update && apt-get upgrade && apt-get install -y "${package_install_arguments[@]}"
    fi
    install_result="$?"
    if [ "$install_result" -ne 0 ]; then
        print_error "An error occured during installation of dependencies."
        print_error "Please take a look at the problem and revolve the problem manually!"
        exit 1
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
dpgk_sudo_check_result=$(dpkg-query -W -f='${Status}' sudo 2>/dev/null | grep -c "ok installed")
if [ "$dpgk_sudo_check_result" -eq 0 ]
    then
        sudo_installed="0"
        echo -e "sudo is ${COLOR_RED}NOT INSTALLED${COLOR_RESET}"
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
                if [ "$(id -u)" -eq "0" ]
                    then
                        install_apt_packages $sudo_installed "$package_install_command"
                    else
                        echo ""
                        echo ""
                        print_error "Sudo is not installed and you're not root."
                        print_error "All missing dependencies have to be installed manually using apt."
                        print_error "We generated the required apt command for you:"
                        print_error "${COLOR_CYAN}apt install $package_install_command"
                        exit 1
                fi
            else
                install_apt_packages $sudo_installed "$package_install_command"
        fi
fi

print_success "Installed all apt dependencies for psh!"
echo ""

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
        if curl -L git.io/antigen > "${HOME}/.antigen/antigen.zsh"
            then
                print_success "Successfully installed antigen to ${HOME}/.antigen/antigen.zsh"
            else
                print_error "Failed to install antigen!"
                exit 1
        fi
fi

# Load plugin API
source "lib/plugin_api.sh"

# First of all backup .zshrc
echo ""
echo "Backing up ${HOME}/.zshrc to ${HOME}/.zshrc_unmodified..."
if [ -f "${HOME}/.zshrc" ]
    then
        if cp "${HOME}/.zshrc" "${HOME}/.zshrc_unmodified"
            then
                print_success "Backed up ${HOME}/.zshrc"
            else
                print_error "Failed to backup ${HOME}/.zshrc"
        fi
    else
        print_warning "No .zshrc exists, nothing has been backed up!"
fi
echo ""

echo "Preparing ${HOME}/.zshrc..."

# Load template engine
echo ""
source "lib/template_engine.sh"
echo ""

# Now reset ~/.zshrc, as we build our own only using antigen
# to load things
{
    echo "# This .zshrc has been generated by psh."
    echo "# https://github.com/pascal-zarrad/psh"
    echo "# ======================================"
} > "${HOME}/.zshrc"

# Include templates the the start of the file after the header
include_templates $TEMPLATE_START

# Enable antigen
{
    echo "# Enable antigen"
    echo "source ${HOME}/.antigen/antigen.zsh"
} >> "${HOME}/.zshrc"

# Include templates after antigen has been loaded but before oh-my-zsh is being loaded
include_templates "$TEMPLATE_BETWEEN_ANTIGEN_AND_OH_MY_ZSH"

# Load oh-my-zsh library
{
    echo "# Load oh-my-zsh library"
    echo "antigen use oh-my-zsh"
} >> "${HOME}/.zshrc"

# Include templates between oh-my-zsh and the plugin execution
include_templates "$TEMPLATE_BETWEEN_OH_MY_ZSH_AND_PLUGINS"

print_success "Prepared ${HOME}/.zshrc"

if [ "$start_arg_disable_plugin_system" -ne 1 ]; then

    # Add comment which tells the user that here all automatically loaded
    # plugins are loaded
    {
        echo "# Load plugins and themes (generated by psh plugins during installation)"
    } >> "${HOME}/.zshrc"

    # Applay all customizations
    # For a better overview, the customizations are done using
    # automatically loaded plugin files.
    # This keeps this script short.
    echo ""
    echo "Applying all customizations for zsh using plugins..."
    plugins=()
    while IFS='' read -r line; do plugins+=("$line"); done < <(ls -1 plugins)
    for plugin in "${plugins[@]}"
    do
        pluginFile="plugins/${plugin}/plugin.sh"
        if [ -f "$pluginFile" ]
            then
                echo ""
                echo "Running plugin: ${plugin}"
                # shellcheck source=/dev/null
                if source "$pluginFile"
                    then
                        print_success "Successfully executed plugin ${plugin}"
                    else
                    print_warning "Failed to execute plugin ${plugin}!"
                fi
            else
                print_warning "Plugin ${plugin} has no plugin.sh, skipping!"
        fi
    done
    echo ""
    print_success "Plugin execution done."
    echo ""
fi

# Include templates after plugins being loaded but before antigen settings are applied
include_templates "$TEMPLATE_AFTER_PLUGINS_BEFORE_ANTIGEN_APPLY"

{
    # Now finish by telling antigen to apply the bundles and themes
    # Now load oh-my-zsh library
    echo "# Apply everything"
    echo "antigen apply"
} >> "${HOME}/.zshrc"

# Include templates at the end of the .zshrc
include_templates "$TEMPLATE_END"

# Print warnings for templates without the template directive
print_template_warnings

# Ask user if he wants to set zsh as default shell
echo ""
echo ""
echo "zsh has been installed and is configured!"
echo "It is currently not configured as your default shell."
echo -e "${COLOR_CYAN}NOTE${COLOR_RESET} Only set for your current user account!"
read -r -p "Do you want to set zsh as your default shell? (y/n): " confirmDefaultShell
if [ "$confirmDefaultShell" = "y" ] || [ "$confirmDefaultShell" = "yes" ];
    then
        zsh_path=$(command -v zsh)
        if chsh -s "${zsh_path}"
            then
                print_success "zsh has been set as your default login shell!"
                print_success "From now zsh will be loaded after login."
            else
                print_error "Failed to change login shell using chsh."
                exit 1
        fi
fi

# The installation was successful
echo ""
print_success "Installation completed successfully!"
print_success "Restart your terminal or re-login to activate zsh!"
