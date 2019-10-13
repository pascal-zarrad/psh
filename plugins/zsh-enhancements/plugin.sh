#!/bin/bash

#==================================================================
# Script Names  : psh-zsh-enhancements
# Description	: Plugins that enhance the zsh experience.
# Args          : -
# Author(s)     : Pascal Zarrad, Nico Just
# Email         : P.Zarrad@outlook.de, nicojust@users.noreply.github.com
#==================================================================

# Append zsh-users/zsh-syntax-highlighting bundle loading to .zshrc,
# if not already applied
apply_antigen_bundle "zsh-users/zsh-syntax-highlighting"

# Additional completion definitions for Zsh.
apply_antigen_bundle "zsh-users/zsh-completions"

# It suggests commands as you type based on history and completions.
apply_antigen_bundle "zsh-users/zsh-autosuggestions"

# This is a clean-room implementation of the Fish shell's history
# search feature, where you can type in any part of any command
# from history and then press chosen keys, such as the UP and
# DOWN arrows, to cycle through matches.
apply_antigen_bundle "zsh-users/zsh-history-substring-search"
