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
# Script Name   : psh-ssh-agent-installer
# Description	: Enables oh-my-zsh's ssh-agent plugin
#                 to automatically load the ssh-agent.
#                 Only enabled on WSL2.
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

if grep -q "Microsoft" "/proc/version" || grep -q ".*microsoft-standard*." "/proc/version"
    then
        apply_ohmyzsh_plugin "ssh-agent"

        # Configure ssh agent to not instantly load keys on zsh start
        write_zshrc "zstyle :omz:plugins:ssh-agent lazy yes"
fi
