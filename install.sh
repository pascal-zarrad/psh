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

# Dependencies that need to be installed with root privileges
readonly DEPENDENCIES=(
    "zsh"
    "git"
    "curl"
    "imagemagick"
    "xclip"
)

# Load functions for console read/write
source "lib/console.sh"
# Load functions to manage user specific stuff
source "lib/user_management.sh"

# Function to print usage of install.sh
show_param_help() {
    print_message "Usage of install.sh:"
    print_message "install.sh [USER] [--arg]"
    print_message ""
    print_message "--help                - Prints this help page"
    print_message "--disable-templates   - Disables inclusion of templates"
    print_message "--disable-plugins     - Disable plugin execution"
    print_message "--unattended          - Run without user interaction (except password prompts)"
    print_message ""
    print_message "You can place the user parameter anywhere. The first parameter without"
    print_message "a dash is being used as the target user. All other arguments without"
    print_message "leading dashes are being ignored."
    print_message "Note that installing psh for another user requires root privileges!"
    exit
}

# Variables (flags) that are set by the start parameters
start_arg_disable_template_engine_parameter=0
start_arg_disable_plugin_system_parameter=0
start_arg_run_unattended_parameter=0
start_arg_install_for_user_parameter=$(whoami)
# Process arguments/start parameters
# and set values to use
while test $# != 0
do
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
        *)
            if [ "$start_arg_install_for_user_parameter" = "$(whoami)" ];
                then
                    if [ "$(id -u)" -eq "0" ]
                        then
                            start_arg_install_for_user_parameter="$1"
                        else
                            print_error "Run the install script as root to install psh for another user!"
                            exit 1
                    fi
            fi
            ;;
    esac
    shift
done

# Construct the target home directory of the user which will receive psh
if check_user_exists "$start_arg_install_for_user_parameter"
    then
        CUSTOM_USER_HOME_DIR="$(get_user_home "$start_arg_install_for_user_parameter")"
        readonly CUSTOM_USER_HOME_DIR
    else
        print_error "The targeted user does not exist!"
        exit 1
fi

# Print initial
print_message "This install script will install zsh and configure it automatically for the user ${start_arg_install_for_user_parameter}."
print_message "If you accept all steps of the installation, zsh will be pre-confiured to provide a great experience out of the box."
print_message "The installer will check the dependencies and will inform you about required actions."
print_message "If you have sudo installed, the installer will automatically try to install the dependencies, after your approval."

# Ask user if he wants to start installation
# Ask the user if he really wants to install the cron
print_message ""
yes_no_abort_dialog "Do you want to install psh for ${start_arg_install_for_user_parameter}? (y/n): " "${start_arg_run_unattended_parameter}"

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
else
    print_error "Could not detect a valid distribution!"
    exit 1
fi

# Import the right package manager depending on current distribution
if  [[ "$detected_os" = "Debian GNU/Linux" || "$detected_os" = "Ubuntu" || "$detected_os" = "Pop!_OS" ]]; then
    source "lib/distdep/deb_based/package_management.sh"
elif  [[ "$detected_os" = "Arch Linux" || "$detected_os" = "Manjaro Linux" ]]; then
    source "lib/distdep/arch_based/package_management.sh"
else
    print_error "Your current distribution '$detected_os' is not supported!"
    exit 1
fi

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
if [ "$(packages_installed "sudo")" = "sudo" ]
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
print_message "The basic installation of zsh is now done."
print_message "Now components required for customization will be installed."
print_message "zplug is used for plugin management."
print_message "To enable this plugin manager, it will now be installed..."
readonly ZPLUG_FOLDER_PATH="${CUSTOM_USER_HOME_DIR}/.zplug"
readonly ZPLUG_PATH="${ZPLUG_FOLDER_PATH}/init.zsh"
if [ -f "${ZPLUG_PATH}" ]
    then
        print_success "zplug is already installed."
    else
        if ! [ -d "${ZPLUG_FOLDER_PATH}" ]; then
            mkdir "${ZPLUG_FOLDER_PATH}"
        fi
        if git clone https://github.com/zplug/zplug  "${ZPLUG_FOLDER_PATH}"
            then
                print_success "Successfully installed zplug to ${ZPLUG_PATH}"
            else
                print_error "Failed to install zplug!"
                exit 1
        fi
fi
fix_user_permissions "${start_arg_install_for_user_parameter}" "${ZPLUG_FOLDER_PATH}"

# Load plugin API
source "lib/plugin_api.sh"

# Specifiy .zshrc and .zshrc_unmodified paths
readonly ZSHRC_PATH="${CUSTOM_USER_HOME_DIR}/.zshrc"
readonly ZSHRC_UNMODIFIED_PATH="${CUSTOM_USER_HOME_DIR}/.zshrc_unmodified"

# First of all backup .zshrc
print_message ""
print_message "Backing up ${ZSHRC_PATH} to ${ZSHRC_UNMODIFIED_PATH}..."
if [ -f "${ZSHRC_PATH}" ]
    then
        if cp "${ZSHRC_PATH}" "${ZSHRC_UNMODIFIED_PATH}"
            then
                fix_user_permissions "${start_arg_install_for_user_parameter}" "${ZSHRC_UNMODIFIED_PATH}"
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
} > "${ZSHRC_PATH}"

# Include templates the the start of the file after the header
include_templates "${TEMPLATE_START}" "${start_arg_disable_template_engine_parameter}" "${ZSHRC_PATH}"

# Enable zplug
{
    echo "# Enable zplug"
    echo "source ${ZPLUG_PATH}"
} >> "${ZSHRC_PATH}"

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
    } >> "${ZSHRC_PATH}"

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
} >> "${ZSHRC_PATH}"

# Include templates at the end of the .zshrc
include_templates "${TEMPLATE_END}" "${start_arg_disable_template_engine_parameter}" "${ZSHRC_PATH}"

# Print warnings for templates without the template directive
print_template_warnings "${start_arg_disable_template_engine_parameter}"

# Fix .zshrc permissions
fix_user_permissions "${start_arg_install_for_user_parameter}" "${ZSHRC_PATH}"

# Trigger shell chage (chsh) to zsh of a specific user
#
# @param $1 The user of which the shell will be changed
function change_shell_to_zsh() {
    local user="$1"
    local zsh_path;zsh_path=$(command -v zsh)
    if chsh  "${user}" -s "${zsh_path}"
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
if [ "${start_arg_run_unattended_parameter}" -eq 0 ]
    then
        read -r -p "Do you want to set zsh as your default shell? (y/n): " confirmDefaultShell
        if [ "${confirmDefaultShell}" = "y" ] || [ "${confirmDefaultShell}" = "yes" ];
            then
               change_shell_to_zsh "${start_arg_install_for_user_parameter}"
        fi
    else
        change_shell_to_zsh "${start_arg_install_for_user_parameter}"
fi

# The installation was successful
print_message ""
print_success "Installation completed successfully!"
print_success "Restart your terminal or re-login to activate zsh!"
