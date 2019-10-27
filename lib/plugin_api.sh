#!/bin/bash

#==================================================================
# Script Name   : psh-plugin-api
# Description	: Plugin API of psh. Provides usefull functions
#                 for plugin development.
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# Function that writes everything from the first parameter
# to the .zshrc that is being generated
write_zshrc() {
    content="$1"
    echo "$content" >> "${HOME}/.zshrc"
}

# Function that checks if antigen bundle is loaded or not
# and then adds the bundle to the .zshrc
apply_antigen_bundle() {
    antigen_bundle="$1"
    if ! grep -q "$antigen_bundle" "${HOME}/.zshrc" ; then
        write_zshrc "antigen bundle ${antigen_bundle}"
    fi
}

# Function that checks if antigen theme is loaded or not
# and then adds the theme to the .zshrc
apply_antigen_theme() {
    antigen_bundle="$1"
    if ! grep -q "antigen theme ${antigen_bundle}" "${HOME}/.zshrc" ; then
        write_zshrc "antigen theme ${antigen_bundle}"
    fi
}
