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
