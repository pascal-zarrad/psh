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

# IMPORTANT: This script's functions requires a ZSHRC_PATH and ANTIDOTE_PLUGINS_LIST_PATH
# variable to be set to work. Automatically set by the ../install.sh script.

# Function that writes everything from the first parameter
# to the .zshrc that is being generated
#
# @param $1 The line of content to write to the .zshrc
function write_zshrc() {
    content="$1"
    echo "$content" >> "${ZSHRC_PATH}"
}

# Function that writes everything from the first parameter
# to the antidote plugins file that is being generated
#
# @param $1 The line of content to write to the plugins list
function write_antidote_plugins_list() {
    content="$1"
    echo "$content" >> "${ANTIDOTE_PLUGINS_LIST_PATH}"
}

# Function that writes OMZ initialization with antidote to
# to the antidote plugins list that is being generated
function apply_ohmyzsh_initialization() {
    write_antidote_plugins_list "getantidote/use-omz"
    write_antidote_plugins_list "ohmyzsh/ohmyzsh path:lib"
}

# Function that checks if antidote plugin is loaded or not
# and then adds the plugin to the antidote plugins list
#
# @param $1 The plugin to add to the plugins list
function apply_plugin() {
    antidote_plugin="$1"
    if ! grep -q "${antidote_plugin}" "${ANTIDOTE_PLUGINS_LIST_PATH}" ; then
        write_antidote_plugins_list "${antidote_plugin}"
    fi
}

# Function that checks if antidote plugin is loaded or not
# and then adds the plugin with a specific version to the antidote plugins list
#
# @param $1 The plugin to add to the plugins list
function apply_plugin_version() {
    antidote_plugin="$1"
    antidote_plugin_version="$2"
    if ! grep -q "${antidote_plugin}" "${ANTIDOTE_PLUGINS_LIST_PATH}" ; then
        write_antidote_plugins_list "${antidote_plugin} branch:${antidote_plugin_version}"
    fi
}

# Function that checks if antidote oh-my-zsh plugin is loaded or not
# and then adds the plugin to the antidote plugins list
#
# @param $1 The plugin to add to the plugins list
function apply_ohmyzsh_plugin() {
    antidote_plugin="$1"
    if ! grep -q "ohmyzsh/ohmyzsh path:plugins/${antidote_plugin}" "${ANTIDOTE_PLUGINS_LIST_PATH}" ; then
        write_antidote_plugins_list "ohmyzsh/ohmyzsh path:plugins/${antidote_plugin}"
    fi
}

# Function that checks if antidote theme is loaded or not
# and then adds the theme to the antidote plugins list
#
# @param $1 The name if the theme that should be added to the plugins list
function apply_ohmyzsh_theme() {
    antidote_theme="$1"
    if ! grep -q "ohmyzsh/ohmyzsh path:themes/${antidote_theme}.zsh-theme" "${ANTIDOTE_PLUGINS_LIST_PATH}" ; then
        write_antidote_plugins_list "ohmyzsh/ohmyzsh path:themes/${antidote_theme}.zsh-theme"
    fi
}
