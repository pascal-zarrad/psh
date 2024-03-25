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
# Script Name   : fix-wsl
# Description	: Script to fix permission problems on WSL
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

if [ -d "${HOME}/.antigen/bundles" ]
    then
        echo "Fixing permissions of ${HOME}/.antigen/bundles..."
        chmod -R 755 "${HOME}/.antigen/bundles"
        chmod_result="$?"
        if [ "$chmod_result" -eq 0 ]
            then
                echo "Succesfully fixed permissions of ${HOME}/.antigen/bundles"
            else
                echo "Failed to fix permissions of ${HOME}/.antigen/bundles"
        fi
    else
        echo "${HOME}/.antigen/bundles does not exist, you first have to launch the fully configured"
        echo "zsh at least once after running this fixer."
fi
