#!/bin/bash

#==================================================================
# Script Name   : psh-plugin-api
# Description	: Plugin API of psh. Provides usefull functions
#                 for plugin development.
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# IMPORTANT: This script's functions requires a ZSHRC_PATH variable
# to be set to work. Automatically set by the ../install.sh script.

# Function that writes everything from the first parameter
# to the .zshrc that is being generated
#
# @param $1 The line of content to write to the .zshrc
function write_zshrc() {
    content="$1"
    echo "$content" >> "${ZSHRC_PATH}"
}

# Function that checks if antigen bundle is loaded or not
# and then adds the bundle to the .zshrc
#
# @param $1 The bundle to add to the .zshrc
function apply_antigen_bundle() {
    antigen_bundle="$1"
    if ! grep -q "$antigen_bundle" "${ZSHRC_PATH}" ; then
        write_zshrc "antigen bundle ${antigen_bundle}"
    fi
}

# Function that checks if antigen theme is loaded or not
# and then adds the theme to the .zshrc
#
# @param $1 The name if the theme that should be added to the zshrc
function apply_antigen_theme() {
    antigen_theme="$1"
    if ! grep -q "antigen theme" "${ZSHRC_PATH}" ; then
        write_zshrc "antigen theme ${antigen_theme}"
    fi
}
