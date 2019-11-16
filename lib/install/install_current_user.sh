#!/bin/bash

#==================================================================
# Script Name   : psh-install-current-user
# Description	: Script used to install psh for the current user
#                 (The user that has execueted the script)
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

# Run the psh installation for the another user
# and use sudo if possible (else expect to run as root
# or throw an error)
run_psh_installation() {

}

# TODO:
# - Abstract installation into functions and allow installation on other users
# - Remove "Magic". Pass constants and variables to functions of sourced scripts
#   as childs functions should not be dependent on their parent.
