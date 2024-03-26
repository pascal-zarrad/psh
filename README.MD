# psh ![CI](https://github.com/pascal-zarrad/psh/workflows/CI/badge.svg?branch=master)
psh - which stands for Pascal's Shell is a configuration tool for zsh.
It is a composition of the finest plugins and a nice looking theme (currently it is one bundled with oh-my-zsh)
that helps myself and hopefully also others to grow their productivity by customizing their shell experience.

This installer enables the fast installation of zsh, zplug and other stuff that is required for a great zsh experience on the shell.
The installer generates always a custom .zshrc which can be modified by adding own customizations to the plugins folder.
To make customizations even easier, psh has a template system that allows the import of personalized .zshrc snippets that are composed together
and inserted into the generated configuration!

It was never that easy and therefore fast to install a customized shell than with psh - and with some knowledge about shell scripting with bash,
you will be able to implement everything you could imagine in a configuration for zsh.

> Why psh if I could just use zplug?
>
> First of all, psh is pre-configured in a way that is already quite powerful.
> Secondly, psh takes care of dependencies. You setup your new os, clone this repository
> and run the `install.sh` script. If your system is supported, psh installs literally
> everything necessary - from zsh to git or curl - you can just start working without
> any further manual stuff to do for your shell setup.

![PSH Installer](https://github.com/pascal-zarrad/psh/raw/master/.github/MEDIA/psh.gif)

The targets of psh are:
 * Create a great zsh experience out of the box
 * Automate and simplify installation by using an installer
 * Be extendable for forks and own variations of the installer

## What is used
You can find a list of used frameworks and plugins in the wiki under [Technologies](https://github.com/pascal-zarrad/psh/wiki/Technologies).

## Compatibility
In theory all configuration done by psh should work on any system that is compatible with zsh and all dependencies that are used to enhance the zsh experience.
But as the installer uses ```apt```, you need any system that supports ```apt``` to use it.

Currently psh is only tested in the following environments:
 * Arch Linux
 * Manjaro Linux
 + Windows Subsystem for Linux 2 (WSL2)
 * Ubuntu
 * Debian
 + PopOs!

Always assume that the newest operating system version relativ to the newest release has been used.

You can find further information in the wiki under [Compatibility](https://github.com/pascal-zarrad/psh/wiki/Compatibility).

## Installation

The installation is documented in the wiki under [Installation](https://github.com/pascal-zarrad/psh/wiki/Installation).

## Updating
Updating psh is as simple as installing it- you just need to pull the newest version from GitHub.
You find information on how to update psh in the wiki under [Updating](https://github.com/pascal-zarrad/psh/wiki/Updating).

## Creating templates
A guide on templates is also available on the wiki under [Templates](https://github.com/pascal-zarrad/psh/wiki/Templates).

## Code Quality
To ensure code quality, the scripts in the repository are being checked by [shellcheck](https://github.com/koalaman/shellcheck).
Please refer to the shellcheck repository's README on how to install shellcheck on your computer.

To check code quality run: ```shellcheck **/*.sh```

**NOTE:** When pushing to this repository, TravisCI will check your changes.There's no way around the check.

## Contributing

You are welcome to contribute to psh if you have improvements or bug fixes.
You are also welcome to suggest own plugins that should be added to the default
psh installation. Refer to [Contributing](https://github.com/pascal-zarrad/psh/blob/master/CONTRIBUTING.md)
if you want to be a contributor or simply create an issue.
