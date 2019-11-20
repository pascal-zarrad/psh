#!/bin/bash

#==================================================================
# Script Name   : psh-user-management
# Description	: Functions to work with Linux users (like getting
#                 their home directory)
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# Check if a specific user does exist on the system
#
# @param $1 The name of the user to check for
function check_user_exists() {
    local targetUser="$1"
    if getent passwd "$targetUser" >> /dev/null
        then
            return 0
        else
            return 1
    fi
}

# Get the home directory of a specific user.
# The functions uses getent to get the home directory.
#
# @param $1 The user from which the home dir will be grabbed
function get_user_home() {
    local targetUser="$1"
    local result
    result="$(getent passwd "$targetUser" | cut -d: -f6)"
    echo "$result"
}
