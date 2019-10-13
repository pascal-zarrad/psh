#!/bin/bash

#==================================================================
# Script Name   : psh-node-installer
# Description	: Enables oh-my-zsh's node and npm plugin
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

apply_antigen_bundle "node"
apply_antigen_bundle "npm"
apply_antigen_bundle "bower"
apply_antigen_bundle "grunt"
apply_antigen_bundle "bundler"
