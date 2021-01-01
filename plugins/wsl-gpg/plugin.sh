#!/bin/bash

#
# Copyright 2021 Pascal Zarrad
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
