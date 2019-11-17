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

# Function to print usage of install.sh
cmd_help() {
    print_message "Usage of install.sh:"
    print_message "install.sh [--disable-templates] [--help]"
    print_message ""
    print_message "--help                - Prints this help page"
    print_message "--disable-templates   - Disables inclusion of templates"
    print_message "--disable-plugins     - Disable plugin execution"
    print_message "--unattended          - Run without user interaction (except password prompts)"
    print_message ""
    exit
}

# Variables (flags) that are set by the start parameters
start_arg_disable_template_engine=0
start_arg_disable_plugin_system=0
start_arg_run_unattended_parameter=0
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
        --unattended)
            start_arg_run_unattended_parameter=1
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

# Load functions for console read/write
source "lib/console.sh"

# Print initial
print_message "This install script will install zsh and configure it automatically for you."
print_message "If you accept all steps of the installation, zsh will be pre-confiured to provide a great experience out of the box."
print_message "The installer will check the dependencies and will inform you about required actions.
If you have sudo installed, the installer will automatically try to install the dependencies. after your approval."

# Ask user if he wants to start installation
# Ask the user if he really wants to install the cron
print_message ""
yes_no_abort_dialog "Do you want to install psh? (y/n): " "${start_arg_run_unattended_parameter}"

# We currently only support debian based systems, so just source package management functions
# using apt.
source "lib/distdep/deb_based/package_management.sh"

# Analyse which dependencies are already installed
print_message ""
print_message "Checking dependencies..."
not_installed=("$(packages_installed "${DEPENDENCIES[@]}")")
for dependency in "${DEPENDENCIES[@]}"
do
    if [[ " ${not_installed[*]} " == *" ${dependency} "* ]]
        then
            print_message "$dependency: ${COLOR_RED}NOT INSTALLED${COLOR_RESET}"
        else
            print_message "$dependency: ${COLOR_GREEN}INSTALLED${COLOR_RESET}"
    fi
done

sudo_installed="1"
# Check if sudo is installed
print_message ""
dpgk_sudo_check_result=$(dpkg-query -W -f='${Status}' sudo 2>/dev/null | grep -c "ok installed")
if [ "$dpgk_sudo_check_result" -eq 0 ]
    then
        sudo_installed="0"
        print_message "sudo is ${COLOR_RED}NOT INSTALLED${COLOR_RESET}"
    else
        print_message "sudo is ${COLOR_GREEN}AVAILABLE${COLOR_RESET}"
fi
print_message ""

# built string containing all package that need to be installed.
package_install_command=""
for package in "${not_installed[@]}"
do
    echo "$package"
    package_install_command+="${package} "
done

# Handle package installation based on environment
if [ -n "${package_install_command// }" ]
    then
        if [ "${sudo_installed}" = "0" ];
            then
                if [ "$(id -u)" -eq "0" ]
                    then
                        install_apt_packages $sudo_installed  $start_arg_run_unattended_parameter "$package_install_command"
                    else
                        print_message ""
                        print_message ""
                        print_error "Sudo is not installed and you're not root."
                        print_error "All missing dependencies have to be installed manually using apt."
                        print_error "We generated the required apt command for you:"
                        print_error "${COLOR_CYAN}apt install $package_install_command"
                        exit 1
                fi
            else
                install_apt_packages $sudo_installed $start_arg_run_unattended_parameter "$package_install_command"
        fi
fi

print_success "Installed all apt dependencies for psh!"
print_message ""

# Install antigen to ~/.antigen/antigen.sh
print_message ""
print_message "The basic installation of zsh is now done."
print_message "Now components required for customization will be installed."
print_message "Antigen is used for plugin management."
print_message "To enable this plugin manager, it will now be installed..."
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
print_message ""
print_message "Backing up ${HOME}/.zshrc to ${HOME}/.zshrc_unmodified..."
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
print_message ""

print_message "Preparing ${HOME}/.zshrc..."

# Load template engine
print_message ""
source "lib/template_engine.sh"
print_message ""

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
    print_message ""
    print_message "Applying all customizations for zsh using plugins..."
    plugins=()
    while IFS='' read -r line; do plugins+=("$line"); done < <(ls -1 plugins)
    for plugin in "${plugins[@]}"
    do
        pluginFile="plugins/${plugin}/plugin.sh"
        if [ -f "$pluginFile" ]
            then
                print_message ""
                print_message "Running plugin: ${plugin}"
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
    print_message ""
    print_success "Plugin execution done."
    print_message ""
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

function change_shell_to_zsh() {
    zsh_path=$(command -v zsh)
    if chsh -s "${zsh_path}"
        then
            print_success "zsh has been set as your default login shell!"
            print_success "From now zsh will be loaded after login."
        else
            print_error "Failed to change login shell using chsh."
            exit 1
fi
}

# Ask user if he wants to set zsh as default shell
print_message ""
print_message ""
print_message "zsh has been installed and is configured!"
print_message "It is currently not configured as your default shell."
print_message "${COLOR_CYAN}NOTE${COLOR_RESET} Only set for your current user account!"
if [ "$start_arg_run_unattended_parameter" -eq 0 ]
    then
        read -r -p "Do you want to set zsh as your default shell? (y/n): " confirmDefaultShell
        if [ "$confirmDefaultShell" = "y" ] || [ "$confirmDefaultShell" = "yes" ];
            then
               change_shell_to_zsh
        fi
    else
        change_shell_to_zsh
fi

# The installation was successful
print_message ""
print_success "Installation completed successfully!"
print_success "Restart your terminal or re-login to activate zsh!"
