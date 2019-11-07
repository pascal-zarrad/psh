#!/bin/bash

#==================================================================
# Script Name   : psh-console
# Description	: Functions to interact with the console
#                 (logging, prompts, ...)
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# Print a message
# This function is allows something in the future like a clean log file
# with only relevant log messages from the script to be created.
print_message() {
    echo -e "$1"
}

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
yes_no_abort_dialog() {
    # start_arg_run_unattended is set in ../install.sh
    # shellcheck disable=SC2154
    if [ "$start_arg_run_unattended" -eq 0 ]; then
        local display_message="$1"
        read -r -p "$display_message" confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "yes" ];
            then
                print_error "Installation aborted..."
                exit 1
        fi
    fi
}
