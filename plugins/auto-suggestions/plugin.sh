#!/bin/bash

#==================================================================
# Script Name   : psh-auto-suggestions-installer
# Description	: Plugin that handles installation of
#                 zsh-autosuggestions.
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# Append zsh-autosuggestions bundle loading to .zshrc,
# if not already applied
apply_antigen_bundle "zsh-users/zsh-autosuggestions"
