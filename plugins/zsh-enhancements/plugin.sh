#!/bin/bash

#
# Copyright 2022 Pascal Zarrad
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
# Script Names  : psh-zsh-enhancements-installer
# Description	: Plugins that enhance the zsh experience.
# Args          : -
# Author(s)     : Pascal Zarrad, Nico Just
# Email         : P.Zarrad@outlook.de, nicojust@users.noreply.github.com
#==================================================================

# Append zsh-users/zsh-syntax-highlighting bundle loading to .zshrc,
# if not already applied
apply_antigen_bundle "zsh-users/zsh-syntax-highlighting"

# Additional completion definitions for Zsh.
apply_antigen_bundle "zsh-users/zsh-completions"

# It suggests commands as you type based on history and completions.
apply_antigen_bundle "zsh-users/zsh-autosuggestions"

# This is a clean-room implementation of the Fish shell's history
# search feature, where you can type in any part of any command
# from history and then press chosen keys, such as the UP and
# DOWN arrows, to cycle through matches.
apply_antigen_bundle "zsh-users/zsh-history-substring-search"
