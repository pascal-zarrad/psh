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
