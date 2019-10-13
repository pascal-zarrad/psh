#!/bin/bash

#==================================================================
# Script Name   : psh-php-installer
# Description	: Enables oh-my-zsh's voronkovich/phpcs.plugin.zsh plugin
# Args          : -
# Author       	: Nico Just
# Email         : nicojust@users.noreply.github.com
#==================================================================

apply_antigen_bundle "voronkovich/phpcs.plugin.zsh"
apply_antigen_bundle "voronkovich/phpunit.plugin.zsh"
