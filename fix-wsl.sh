#!/bin/bash

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
