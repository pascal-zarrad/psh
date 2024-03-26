#!/bin/bash

#
# Copyright 2024 Pascal Zarrad
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#==================================================================
# Script Name   : psh-installer
# Description	: Installer script that installs psh (zsh installer
#                 with default configuration)
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# Semantic versioning version constant
readonly PSH_VERSION="2.0.0"
echo "PSH - VERSION: ${PSH_VERSION}"

if [ -f /etc/os-release ]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    detected_os=$NAME
elif type lsb_release >/dev/null 2>&1; then
    # shellcheck source=/dev/null
    detected_os=$(lsb_release -si)
elif [ -f /etc/lsb-release ]; then
    # shellcheck source=/dev/null
    source /etc/lsb-release
    detected_os=$DISTRIB_ID
elif [ -f /etc/debian_version ]; then
    detected_os=Debian
elif [[ $(uname) = "Darwin" ]]; then
    detected_os=Darwin
else
    print_error "Could not detect a valid distribution!"
    exit 1
fi

# Dependencies that need to be installed
# On macOS we do not need the clipboard dependencies
if [[ "$detected_os" = "Darwin" ]]; then
    # zsh is default on mac, we can skip installation!
    # Also tool used for clipboard is already included.
    readonly DEPENDENCIES=(
        "git"
        "curl"
        "imagemagick"
    )
else
    readonly DEPENDENCIES=(
        "zsh"
        "git"
        "curl"
        "imagemagick"
        "xclip"
        "wl-clipboard"
    )
fi

# Load functions for console read/write
source "lib/console.sh"

# Function to print usage of install.sh
show_param_help() {
    print_message "Usage of install.sh:"
    print_message "install.sh [--arg]"
    print_message ""
    print_message "--help                - Prints this help page"
    print_message "--disable-templates   - Disables inclusion of templates"
    print_message "--disable-plugins     - Disable plugin execution"
    print_message "--unattended          - Run without user interaction (except password prompts)"
    exit
}

# Variables (flags) that are set by the start parameters
start_arg_disable_template_engine_parameter=0
start_arg_disable_plugin_system_parameter=0
start_arg_run_unattended_parameter=0
# Process arguments/start parameters
# and set values to use
while test $# != 0; do
    case "$1" in
    --disable-templates)
        start_arg_disable_template_engine_parameter=1
        ;;
    --disable-plugins)
        start_arg_disable_plugin_system_parameter=1
        ;;
    --unattended)
        start_arg_run_unattended_parameter=1
        ;;
    --help)
        show_param_help
        ;;
    -*)
        show_param_help
        ;;
    esac
    shift
done

# Construct the target home directory of the user which will receive psh
INSTALLATION_USERNAME=$(whoami)
readonly INSTALLATION_USERNAME
readonly CUSTOM_USER_HOME_DIR="$HOME"

# Print initial
print_message "This install script will install zsh and configure it automatically."
print_message "If you accept all steps of the installation, zsh will be pre-confiured to provide a great experience out of the box."
print_message "The installer will check the dependencies and will inform you about required actions."
print_message "If you have sudo installed, the installer will automatically try to install the dependencies, after your approval."
print_message "On macOS brew without sudo is used to install dependencies!"

# Ask user if he wants to start installation
# Ask the user if he really wants to install the cron
print_message ""
yes_no_abort_dialog "Do you want to install psh? (y/n): " "${start_arg_run_unattended_parameter}"

# Import the right package manager depending on current distribution
if [[ "$detected_os" = "Debian GNU/Linux" || "$detected_os" = "Ubuntu" || "$detected_os" = "Pop!_OS" ]]; then
    source "lib/distdep/deb_based/package_management.sh"
elif [[ "$detected_os" = "Arch Linux" || "$detected_os" = "Manjaro Linux" ]]; then
    source "lib/distdep/arch_based/package_management.sh"
elif [[ "$detected_os" = "Darwin" ]]; then
    source "lib/distdep/darwin_based/package_management.sh"
else
    print_error "Your current distribution '$detected_os' is not supported!"
    exit 1
fi

# Analyse which dependencies are already installed
print_message ""
print_message "Checking dependencies..."
not_installed=("$(packages_installed "${DEPENDENCIES[@]}")")
if [[ "$detected_os" = "Darwin" ]]; then
    print_message "You are running psh on macOS. psh assumes that zsh and clipboard utilities (pbcopy, pbpaste) are already installed."
fi
for dependency in "${DEPENDENCIES[@]}"; do
    if [[ " ${not_installed[*]} " == *" ${dependency} "* ]]; then
        print_message "$dependency: ${COLOR_RED}NOT INSTALLED${COLOR_RESET}"
    else
        print_message "$dependency: ${COLOR_GREEN}INSTALLED${COLOR_RESET}"
    fi
done

sudo_installed="1"
# Check if sudo is installed
print_message ""
if [[ "$detected_os" = "Darwin" ]]; then
    # macOS case is handled in "sudo not installed" branch below
    sudo_installed="0"
    print_message "Running on macOS, ignoring sudo install status!"
else
    if [ "$(packages_installed "sudo")" = "sudo" ]; then
        sudo_installed="0"
        print_message "sudo is ${COLOR_RED}NOT INSTALLED${COLOR_RESET}"
    else
        print_message "sudo is ${COLOR_GREEN}AVAILABLE${COLOR_RESET}"
    fi
    print_message ""
fi

# built string containing all package that need to be installed.
package_install_command=""
for package in "${not_installed[@]}"; do
    package_install_command+="${package} "
done

# Handle package installation based on environment
if [ "$(id -u)" -eq "0" ] && [[ "$detected_os" = "Darwin" ]]; then
    print_error "You must not run psh install script as root or using sudo on macOS!"
    exit 1
fi

if [ -n "${package_install_command// /}" ]; then
    if [ "${sudo_installed}" = "0" ]; then
        if [ "$(id -u)" -eq "0" ] || [[ "$detected_os" = "Darwin" ]]; then
            install_apt_packages $sudo_installed $start_arg_run_unattended_parameter "$package_install_command"
        else
            print_message ""
            print_error "Sudo is not installed and you're not root."
            print_error "All missing dependencies have to be installed manually."
            print_error "We generated the package list for you:"
            print_error "${COLOR_CYAN}$package_install_command"
            exit 1
        fi
    else
        install_apt_packages $sudo_installed $start_arg_run_unattended_parameter "$package_install_command"
    fi
fi

print_success "Installed all system dependencies for psh!"
print_message ""

# Install zplug to ~/.zplug
print_message ""
print_message "The basic installation of zsh and its dependencies is now done."
print_message "Now components required for customization will be installed."
print_message "zplug is used for plugin management."
print_message "To enable this plugin manager, it will now be installed..."
readonly ZPLUG_FOLDER_PATH="${CUSTOM_USER_HOME_DIR}/.zplug"
readonly ZPLUG_PATH="${ZPLUG_FOLDER_PATH}/init.zsh"
if [ -f "${ZPLUG_PATH}" ]; then
    print_success "zplug is already installed."
else
    if ! [ -d "${ZPLUG_FOLDER_PATH}" ]; then
        mkdir "${ZPLUG_FOLDER_PATH}"
    fi
    if git clone https://github.com/zplug/zplug "${ZPLUG_FOLDER_PATH}"; then
        print_success "Successfully installed zplug to ${ZPLUG_PATH}"
    else
        print_error "Failed to install zplug!"
        exit 1
    fi
fi

# Load plugin API
source "lib/plugin_api.sh"

# Specifiy .zshrc and .zshrc_unmodified paths
readonly ZSHRC_PATH="${CUSTOM_USER_HOME_DIR}/.zshrc"
readonly ZSHRC_UNMODIFIED_PATH="${CUSTOM_USER_HOME_DIR}/.zshrc_unmodified"

# First of all backup .zshrc
print_message ""
print_message "Backing up ${ZSHRC_PATH} to ${ZSHRC_UNMODIFIED_PATH}..."
if [ -f "${ZSHRC_PATH}" ]; then
    if cp "${ZSHRC_PATH}" "${ZSHRC_UNMODIFIED_PATH}"; then
        print_success "Backed up ${ZSHRC_PATH}"
    else
        print_error "Failed to backup ${ZSHRC_PATH}"
    fi
else
    print_warning "No .zshrc exists, nothing has been backed up!"
fi
print_message ""

print_message "Preparing ${ZSHRC_PATH}"

# Load template engine
print_message ""
source "lib/template_engine.sh"
print_message ""

# Now reset ~/.zshrc, as we build our own only using zplug
# to load things
{
    echo "# This .zshrc has been generated by psh."
    echo "# https://github.com/pascal-zarrad/psh"
    echo "# ======================================"
} >"${ZSHRC_PATH}"

# Include templates the the start of the file after the header
include_templates "${TEMPLATE_START}" "${start_arg_disable_template_engine_parameter}" "${ZSHRC_PATH}"

# Enable zplug
{
    echo "# Enable zplug"
    echo "source ${ZPLUG_PATH}"
} >>"${ZSHRC_PATH}"

# Include templates after zplug has been loaded but before oh-my-zsh is being loaded
include_templates "${TEMPLATE_BETWEEN_ZPLUG_AND_OH_MY_ZSH}" "${start_arg_disable_template_engine_parameter}" "${ZSHRC_PATH}"

# Include templates between oh-my-zsh and the plugin execution
include_templates "${TEMPLATE_BETWEEN_OH_MY_ZSH_AND_PLUGINS}" "${start_arg_disable_template_engine_parameter}" "${ZSHRC_PATH}"

print_success "Prepared ${ZSHRC_PATH}"

if [ "${start_arg_disable_plugin_system_parameter}" -ne 1 ]; then

    # Add comment which tells the user that here all automatically loaded
    # plugins are loaded
    {
        echo "# Load plugins and themes (generated by psh plugins during installation)"
    } >>"${ZSHRC_PATH}"

    # Applay all customizations
    # For a better overview, the customizations are done using
    # automatically loaded plugin files.
    # This keeps this script short.
    print_message ""
    print_message "Applying all customizations for zsh using plugins..."
    plugins=()
    while IFS='' read -r line; do plugins+=("$line"); done < <(ls -1 plugins)
    for plugin in "${plugins[@]}"; do
        pluginFile="plugins/${plugin}/plugin.sh"
        if [ -f "$pluginFile" ]; then
            print_message ""
            print_message "Running plugin: ${plugin}"
            # shellcheck source=/dev/null
            if source "$pluginFile"; then
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

# Include templates after plugins being loaded but before zplug settings are applied
include_templates "${TEMPLATE_AFTER_PLUGINS_BEFORE_ZPLUG_APPLY}" "${start_arg_disable_template_engine_parameter}" "${ZSHRC_PATH}"

{
    # Now finish by telling zplug to inhstall and load the bundles and themes
    # Now load oh-my-zsh library
    echo "# Install plugins"
    echo "if ! zplug check --verbose; then"
    echo "    printf \"Install? [y/N]: \""
    echo "    if read -q; then;"
    echo "        echo; zplug install"
    echo "    fi"
    echo "fi"
    echo "# Load plugins"
    echo "zplug load"
} >>"${ZSHRC_PATH}"

# Include templates at the end of the .zshrc
include_templates "${TEMPLATE_END}" "${start_arg_disable_template_engine_parameter}" "${ZSHRC_PATH}"

# Print warnings for templates without the template directive
print_template_warnings "${start_arg_disable_template_engine_parameter}"

# Trigger shell chage (chsh) to zsh of a specific user
#
# @param $1 The user of which the shell will be changed
function change_shell_to_zsh() {
    local user="$1"
    local zsh_path
    zsh_path=$(command -v zsh)
    if chsh "${user}" -s "${zsh_path}"; then
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

if [[ "$detected_os" = "Darwin" ]]; then
    print_message ""
    print_message "${COLOR_CYAN}NOTE${COLOR_RESET} You are running macOS and should already have zsh as your default shell!"
    print_message ""
    print_success "Installation completed successfully!"
    print_success "Restart your terminal or re-login to activate zsh!"

    exit 0
fi

if [ "${start_arg_run_unattended_parameter}" -eq 0 ]; then
    read -r -p "Do you want to set zsh as your default shell? (y/n): " confirmDefaultShell
    if [ "${confirmDefaultShell}" = "y" ] || [ "${confirmDefaultShell}" = "yes" ]; then
        change_shell_to_zsh "${INSTALLATION_USERNAME}"
    fi
else
    change_shell_to_zsh "${INSTALLATION_USERNAME}"
fi

# The installation was successful
print_message ""
print_success "Installation completed successfully!"
print_success "Restart your terminal or re-login to activate zsh!"
