#!/bin/bash

#==================================================================
# Script Name   : psh-python-installer
# Description	: Enables oh-my-zsh's python plugin
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

apply_antigen_bundle "python"
apply_antigen_bundle "virtualenv"
apply_antigen_bundle "pip"
