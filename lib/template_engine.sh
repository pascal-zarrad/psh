#!/bin/bash

#==================================================================
# Script Name   : psh-template-engine
# Description	: Template engine of psh.
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# Store the paths of our different template types in the arrays
# to reduce I/O operations in comparison to v1 of the engine.
templates_start=()
templates_between_antigen_and_oh_my_zsh=()
templates_between_oh_my_zsh_and_plugins=()
templates_after_plugins_before_antigen_apply=()
templates_end=()
# Load our templates
echo "Searching for templates..."
templateFiles=()
while IFS='' read -r line; do templateFiles+=("$line"); done < <(ls -1 templates)
for templateFile in "${templateFiles[@]}"
do
    if [ -s "templates/$templateFile" ]; then
        if read -r templateHeader < "templates/$templateFile"
            then
                case $templateHeader in
                    "${TEMPLATE_DIRECTIVE}$TEMPLATE_START")
                        templates_start=("${templates_start[@]}" "$templateFile")
                        ;;
                    "${TEMPLATE_DIRECTIVE}$TEMPLATE_BETWEEN_ANTIGEN_AND_OH_MY_ZSH")
                        templates_between_antigen_and_oh_my_zsh=("${templates_between_antigen_and_oh_my_zsh[@]}" "$templateFile")
                        ;;
                    "${TEMPLATE_DIRECTIVE}$TEMPLATE_BETWEEN_OH_MY_ZSH_AND_PLUGINS")
                        templates_between_oh_my_zsh_and_plugins=("${templates_between_oh_my_zsh_and_plugins[@]}" "$templateFile")
                        ;;
                    "${TEMPLATE_DIRECTIVE}$TEMPLATE_AFTER_PLUGINS_BEFORE_ANTIGEN_APPLY")
                        templates_after_plugins_before_antigen_apply=("${templates_after_plugins_before_antigen_apply[@]}" "$templateFile")
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
include_templates() {
    local templateType="$1"
    echo "# User defined templates: $templateType" >> "${HOME}/.zshrc"
    local currentTemplateFiles=()
    case $templateType in
            "$TEMPLATE_START")
                currentTemplateFiles=("${templates_start[@]}")
                ;;
            "$TEMPLATE_BETWEEN_ANTIGEN_AND_OH_MY_ZSH")
                currentTemplateFiles=("${templates_between_antigen_and_oh_my_zsh[@]}")
                ;;
            "$TEMPLATE_BETWEEN_OH_MY_ZSH_AND_PLUGINS")
                currentTemplateFiles=("${templates_between_oh_my_zsh_and_plugins[@]}")
                ;;
            "$TEMPLATE_AFTER_PLUGINS_BEFORE_ANTIGEN_APPLY")
                currentTemplateFiles=("${templates_after_plugins_before_antigen_apply[@]}")
                ;;
            "$TEMPLATE_END")
                currentTemplateFiles=("${templates_end[@]}")
                ;;
        esac
    for templateFile in "${currentTemplateFiles[@]}"
    do
        local currentTemplateFile="templates/${templateFile}"
        echo "Applying template file ${templateFile}"
        if tail -n +2 "$currentTemplateFile" >> "${HOME}/.zshrc"
            then
                print_success "Applied template file ${currentTemplateFile}!"
            else
                print_error "Failed to apply template file ${currentTemplateFile}!"
                exit 1
        fi
    done
}

# Print warnings about template files that do not contain the #TEMPLATE=[TYPE]] header
print_template_warnings() {
    if [ "${#templates_invalid[@]}" -ge 1 ]
        then
            for templateFile in "${templates_invalid[@]}"
            do
                print_warning "Not applied template due to missing template directive: templates/${templateFile}!"
            done
    fi
}
