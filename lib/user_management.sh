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

# Set the owner of a specified file/folder to the specified user.
# The fucntion does not check if the user running this script has permissions
# to change a file's owner. This should be done before calling this function.
#
# @param $1 The user that will later on own the specified file
# @param $2 The file to fix
function fix_user_permissions() {
    local user="$1"
    local file="$2"
    # Only fix permission if user isn't already owner of file
    if [ "$(stat --format '%U' "$file")" != "$user" ]; then
        chown -R "$user":"$(id -gn "$user")" "$file"
    fi
}
