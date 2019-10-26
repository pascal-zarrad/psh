#!/bin/bash

#==================================================================
# Script Name   : psh-theme-loader-installer
# Description	: Plugin that handles the activation of
#                 default theme for psh.
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# As WSL can install powerline fonts, they need also be installed on windows itself.
# So we just check if we're running on WSL and use another good font.
if grep -q "Microsoft" "/proc/version" || grep -q ".*microsoft-standard*." "/proc/version"
    then
        echo "Running on Windows Subsystem for Linux, falling back to bira theme!"
        apply_antigen_theme "bira"
    else
        apply_antigen_theme "agnoster"
fi
