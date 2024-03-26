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
# Script Name   : psh-template-engine
# Description	: Template engine of psh.
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# Template directive constant
export readonly TEMPLATE_DIRECTIVE="#PSH_TEMPLATE="
# Different template insertion points
export readonly TEMPLATE_START="START"
export readonly TEMPLATE_BETWEEN_ZPLUG_AND_OH_MY_ZSH="BETWEEN_ZPLUG_AND_OH_MY_ZSH"
export readonly TEMPLATE_BETWEEN_OH_MY_ZSH_AND_PLUGINS="BETWEEN_OH_MY_ZSH_AND_PLUGINS"
export readonly TEMPLATE_AFTER_PLUGINS_BEFORE_ZPLUG_APPLY="AFTER_PLUGINS_BEFORE_ZPLUG_APPLY"
export readonly TEMPLATE_END="END"

# Store the paths of our different template types in the arrays
# to reduce I/O operations in comparison to v1 of the engine.
templates_start=()
templates_between_zplug_and_oh_my_zsh=()
templates_between_oh_my_zsh_and_plugins=()
templates_after_plugins_before_zplug_apply=()
templates_end=()
# Load our templates
echo "Searching for templates..."
templateFiles=()
while IFS='' read -r line; do templateFiles+=("$line"); done < <(ls -1 templates)
for templateFile in "${templateFiles[@]}"
do
    if [[ "$templateFile" =~ \.template.zshrc$ ]] && [ -s "templates/$templateFile" ]; then
        if read -r templateHeader < "templates/$templateFile"
            then
                case $templateHeader in
                    "${TEMPLATE_DIRECTIVE}$TEMPLATE_START")
                        templates_start=("${templates_start[@]}" "$templateFile")
                        ;;
                    "${TEMPLATE_DIRECTIVE}$TEMPLATE_BETWEEN_ZPLUG_AND_OH_MY_ZSH")
                        templates_between_zplug_and_oh_my_zsh=("${templates_between_zplug_and_oh_my_zsh[@]}" "$templateFile")
                        ;;
                    "${TEMPLATE_DIRECTIVE}$TEMPLATE_BETWEEN_OH_MY_ZSH_AND_PLUGINS")
                        templates_between_oh_my_zsh_and_plugins=("${templates_between_oh_my_zsh_and_plugins[@]}" "$templateFile")
                        ;;
                    "${TEMPLATE_DIRECTIVE}$TEMPLATE_AFTER_PLUGINS_BEFORE_ZPLUG_APPLY")
                        templates_after_plugins_before_zplug_apply=("${templates_after_plugins_before_zplug_apply[@]}" "$templateFile")
                        ;;
                    "${TEMPLATE_DIRECTIVE}$TEMPLATE_END")
                        templates_end=("${templates_end[@]}" "$templateFile")
                        ;;
                    *)
                        templates_invalid=("${templates_invalid[@]}" "$templateFile")
                        ;;
                esac
            else
                    print_error "Failed to read teamplate file ${templateFile}!"
        fi
    fi
done
print_success "Completed template search!"

# Include templates into the new .zshrc
#
# @param $1 The type of the templates to include
# @param $2 Status if the template engine has been disabled
# @param $3 The location of the home directory of the specified user
function include_templates() {
    local template_type="$1"
    local start_arg_disable_template_engine="$2"
    local zshrc_path="$3"
    # $start_arg_disable_template_engine is set on install.sh
    # shellcheck disable=SC2154
    if [ "$start_arg_disable_template_engine" -eq 1 ]; then
        return
    fi
    echo "# User defined templates: $template_type" >> "${zshrc_path}"
    local currentTemplateFiles=()
    case $template_type in
            "$TEMPLATE_START")
                currentTemplateFiles=("${templates_start[@]}")
                ;;
            "$TEMPLATE_BETWEEN_ZPLUG_AND_OH_MY_ZSH")
                currentTemplateFiles=("${templates_between_zplug_and_oh_my_zsh[@]}")
                ;;
            "$TEMPLATE_BETWEEN_OH_MY_ZSH_AND_PLUGINS")
                currentTemplateFiles=("${templates_between_oh_my_zsh_and_plugins[@]}")
                ;;
            "$TEMPLATE_AFTER_PLUGINS_BEFORE_ZPLUG_APPLY")
                currentTemplateFiles=("${templates_after_plugins_before_zplug_apply[@]}")
                ;;
            "$TEMPLATE_END")
                currentTemplateFiles=("${templates_end[@]}")
                ;;
        esac
    for templateFile in "${currentTemplateFiles[@]}"
    do
        local currentTemplateFile="templates/${templateFile}"
        echo "Applying template file ${templateFile}"
        if tail -n +2 "$currentTemplateFile" >> "${zshrc_path}"
            then
                print_success "Applied template file ${currentTemplateFile}!"
            else
                print_error "Failed to apply template file ${currentTemplateFile}!"
                exit 1
        fi
    done
}

# Print warnings about template files that do not contain the #TEMPLATE=[TYPE]] header
#
# @param $1 Status if the template engine has been disabled
function print_template_warnings() {
    local start_arg_disable_template_engine="$1"
    if [ "$start_arg_disable_template_engine" -eq 1 ]; then
        return
    fi
    if [ "${#templates_invalid[@]}" -ge 1 ]
        then
            for templateFile in "${templates_invalid[@]}"
            do
                print_warning "Not applied template due to missing template directive: templates/${templateFile}!"
            done
    fi
}
