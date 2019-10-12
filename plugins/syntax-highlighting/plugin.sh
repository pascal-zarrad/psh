#!/bin/bash

#==================================================================
# Script Name   : psh-syntax-highlighting-installer
# Description	: Plugin that handles installation of
#                 zsh-syntax-hightlighting.
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# Append zsh-users/zsh-syntax-highlighting bundle loading to .zshrc,
# if not already applied
apply_antigen_bundle "zsh-users/zsh-syntax-highlighting"
