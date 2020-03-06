#!/bin/bash

#==================================================================
# Script Name   : wsl-gpg
# Description	: Plugin that puts a export into the .zshrc to use
#                 the terminal for the gpg password prompt on wsl.
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# This fix is only for WSL where gpg is unable to find a spot to prompt for
# the password, so we add a environment variable to fix that.
if grep -q "Microsoft" "/proc/version" || grep -q ".*microsoft-standard*." "/proc/version"
    then
        write_zshrc "export GPG_TTY=\$(tty)"
        echo "Applied wsl-gpg fix to support gpg on wsl!"
fi
