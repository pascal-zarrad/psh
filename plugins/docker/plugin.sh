#!/bin/bash

#==================================================================
# Script Name   : psh-docker-installer
# Description	: Enables oh-my-zsh's docker, docker-compose
#                 docker-machine plugin
# Args          : -
# Author       	: Pascal Zarrad
# Email         : P.Zarrad@outlook.de
#==================================================================

apply_antigen_bundle "docker"
apply_antigen_bundle "docker-compose"
apply_antigen_bundle "docker-machine"
