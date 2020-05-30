#!/bin/bash

#==================================================================
# Script Name   : psh-console
# Description	: Functions to interact with the console
#                 (logging, prompts, ...)
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# Colors used during script execution
export readonly COLOR_RESET="\e[0m"
export readonly COLOR_RED="\e[31m"
export readonly COLOR_GREEN="\e[32m"
export readonly COLOR_CYAN="\e[36m"
export  readonly COLOR_YELLOW="\e[33m"

# Prefixes
export readonly ERROR_PREFIX="${COLOR_RED}ERROR${COLOR_RESET}"
export readonly SUCCESS_PREFIX="${COLOR_GREEN}SUCCESS${COLOR_RESET}"
export readonly WARNING_PREFIX="${COLOR_YELLOW}WARNING${COLOR_RESET}"

# Print a message to the console
#
# @param $1 The message to print
function print_message() {
    local message="${1}"
    echo -e "${message}"
}

# Print a error message to the console
#
# @param $1 The message to print
function print_error() {
    local message="${1}"
    print_message "${ERROR_PREFIX} ${1}"
}

# Print a warning message to the console
#
# @param $1 The message to print
function print_warning() {
    local message="${1}"
    print_message "${WARNING_PREFIX} ${1}"
}

# Print a success message to the console
#
# @param $1 The message to print
function print_success() {
    local message="${1}"
    print_message "${SUCCESS_PREFIX} ${1}"
}

# A yes/no dialog that can be used for user approvements during installation
#
# @param $1 The message that is displayed on prompt
# @param $2 The state if the prompt is required or not (--unattended) start parameter
function yes_no_abort_dialog() {
    local display_message="${1}"
    local start_arg_run_unattended="${2}"
    if [ "$start_arg_run_unattended" -eq 0 ]; then
        read -r -p "$display_message" confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "yes" ];
            then
                print_error "Installation aborted..."
                exit 1
        fi
    fi
}
