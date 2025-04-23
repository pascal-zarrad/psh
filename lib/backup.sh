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
# Script Name   : psh-backup
# Description	: Backup utilities for psh
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# Function that copies the source file to the backup file.
# During backup process, info is logged to the console.
#
# @param $1 The path to the file to backup
# @param $2 The path to the backup file
function psh_backup_file() {
    source="$1"
    backup="$2"

    print_message ""
    print_message "Backing up ${source} to ${backup}..."
    if [ -f "${ANTIDOTE_PLUGINS_LIST_PATH}" ]; then
        if cp "${ANTIDOTE_PLUGINS_LIST_PATH}" "${backup}"; then
            print_success "Backed up ${ANTIDOTE_PLUGINS_LIST_PATH}"
        else
            print_error "Failed to backup ${ANTIDOTE_PLUGINS_LIST_PATH}"
        fi
    else
        print_warning "No .zshrc exists, nothing has been backed up!"
    fi
    print_message ""
}
