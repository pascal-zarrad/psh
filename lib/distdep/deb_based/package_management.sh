#!/bin/bash

#
# Copyright 2022 Pascal Zarrad
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
# Script Name   : psh-package-management
# Description	: Sript that contains functions to work with
#                 packages on debian based systems.
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# Check which dependencies are installed and which not
#
# @param $@ All dependencies that should be checked
function packages_installed() {
    local dependencies=("$@")
    local not_installed=()
    for dependency in "${dependencies[@]}"
    do
        dpgk_install_check_result=$(dpkg-query -W -f='${Status}' "$dependency" 2>/dev/null | grep -c "ok installed")
        if [ "$dpgk_install_check_result" -eq 0 ]; then
                not_installed=("${not_installed[@]}" "${dependency}")
        fi
    done
    echo "${not_installed[@]}"
}

# Install dependencies. Use sudo if available.
#
# @param $1 Defines whether to prefix the commands with sudo or not
# @param $2 Defines if the unattended mode is being used
# @param $3 The pace separated packages that need to be installed
function install_apt_packages() {
    local use_sudo="${1}"
    local start_arg_run_unattended="${2}"
    local package_install_command="${3}"
    IFS=' ' read -r -a package_install_arguments <<< "$package_install_command"
    print_message "The installer has to install the following packages through apt (using sudo if available): "
    print_message "During package installation, an apt update is done automatically!"
    print_message "${COLOR_CYAN}${package_install_command}${COLOR_RESET}"
    yes_no_abort_dialog "Do you want to continue? (y/n): " "${start_arg_run_unattended}"
    if [ "$use_sudo" -eq 1 ]
        then
            sudo apt-get update && sudo apt-get install -y "${package_install_arguments[@]}"
        else
            apt-get update && apt-get install -y "${package_install_arguments[@]}"
    fi
    install_result="$?"
    if [ "$install_result" -ne 0 ]; then
        print_error "An error occured during installation of dependencies."
        print_error "Please take a look at the problem and revolve the problem manually!"
        exit 1
    fi
}
