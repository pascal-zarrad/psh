#!/bin/bash

#
# Copyright 2025 Pascal Zarrad
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
# Script Name   : psh-gnupg-wsl-config
# Description	: Configure GnuPG TTY for WSL
#                 This is configured using a plugin instead of a
#                 template, to ensure it's only applied when
#                 running in WSL.
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

if grep -q "Microsoft" "/proc/version" || grep -q ".*microsoft-standard*." "/proc/version"
    then
        # Configure GPG_TTY for WSL explicitly.
        # Without this, GPG pinentry may not work in WSL.
        write_zshrc "export GPG_TTY=\$(tty)"
fi
