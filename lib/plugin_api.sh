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

# Function that checks if zplug plugin is loaded or not
# and then adds the plugin to the .zshrc
#
# @param $1 The plugin to add to the .zshrc
function apply_plugin() {
    zplug_plugin="$1"
    if ! grep -q "zplug \"${zplug_plugin}\"" "${ZSHRC_PATH}" ; then
        write_zshrc "zplug \"${zplug_plugin}\""
    fi
}

# Function that checks if zplug plugin is loaded or not
# and then adds the plugin with a specific version to the .zshrc
#
# @param $1 The plugin to add to the .zshrc
function apply_plugin_version() {
    zplug_plugin="$1"
    zplug_plugin_version="$2"
    if ! grep -q "zplug \"${zplug_plugin}\"" "${ZSHRC_PATH}" ; then
        write_zshrc "zplug \"${zplug_plugin}\", at:${zplug_plugin_version}"
    fi
}

# Function that checks if zplug oh-my-zsh lib is loaded or not
# and then adds the lib to the .zshrc
#
# @param $1 The lib to add to the .zshrc
function apply_ohmyzsh_lib() {
    zplug_lib="$1"
    if ! grep -q "zplug \"lib/${zplug_lib}\", from:oh-my-zsh" "${ZSHRC_PATH}" ; then
        write_zshrc "zplug \"lib/${zplug_lib}\", from:oh-my-zsh"
    fi
}

# Function that checks if zplug oh-my-zsh plugin is loaded or not
# and then adds the plugin to the .zshrc
#
# @param $1 The plugin to add to the .zshrc
function apply_ohmyzsh_plugin() {
    zplug_plugin="$1"
    if ! grep -q "zplug \"plugins/${zplug_plugin}\", from:oh-my-zsh" "${ZSHRC_PATH}" ; then
        write_zshrc "zplug \"plugins/${zplug_plugin}\", from:oh-my-zsh"
    fi
}

# Function that checks if zplug theme is loaded or not
# and then adds the theme to the .zshrc
#
# @param $1 The name if the theme that should be added to the zshrc
function apply_ohmyzsh_theme() {
    zplug_theme="$1"
    if ! grep -q "zplug \"themes/${zplug_theme}\", from:oh-my-zsh, as:theme" "${ZSHRC_PATH}" ; then
        write_zshrc "zplug \"themes/$zplug_theme\", from:oh-my-zsh, as:theme"
    fi
}
