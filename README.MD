# psh
psh - which stands for Pascal's Shell is a configuration for zsh that I use on a daily basis. It is a composition of the finest plugins and a nice looking theme (currently it is one bundled with oh-my-zsh) that help myself and hopefully also others to grow their productivity.

This installer enables the fast installation of zsh, antigen (with that oh-my-zsh) other stuff that is required for a great zsh experience.
The installer builds always a custom .zshrc which can be modified by adding own customizations to the plugins folder.

The targets of psh are:
 * Create a great zsh experience out of the box
 * Automate and simplify installation by using an installer
 * Be extendable for forks and own variations of the installer

## What is used
Some of the best known open source projects come together in psh.
Here is a list of every plugin used.

**Framework and package management:**
 * [Antigen](https://github.com/zsh-users/antigen)
 * [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)

**Plugins:**
 * [auto-suggestions](https://github.com/zsh-users/zsh-autosuggestions)
 * [syntax-highlight](https://github.com/zsh-users/zsh-syntax-highlighting)
 * alias-finder
 * ant
 * aws
 * bgnotify
 * catimg
 * common-aliases
 * composer
 * copydir
 * docker-compose, docker-machine, docker
 * encode64
 * extract
 * git
 * golang
 * gradle
 * gulp
 * jsontools
 * mvn
 * n98-magerun
 * ng
 * node, npm
 * pip
 * python
 * redis-cli
 * symfony
 * ubuntu
 * yarn

**Theme:**
 * Agnoster
 * Bira (Fallback for Windows Subsystem for Linux)

When a plugin or theme does not have a link, it is being shipped with oh-my-zsh.

## Compatibility
In theory all configuration done by psh should work on any system that is compatible with zsh and all dependencies that are used to enhance the zsh experience.
But as the installer uses ```apt```, you need any system that supports ```apt``` to use it.

Currently psh is only tested in the following environments:
 * Ubuntu 18.04 (Windows Subsystem for Linux 1) (Take a look at "Note on WSL 1")
 * Ubuntu 18.04
 * Debian 9

**Note on WSL 1:**
zsh and antigen work on WSL 1. But git clone has a permission problem and seems to clone all files with a permission set of 777. Some research resulted in the fact that the problem seems to be on WSL's site and not this script. Till I figure out a way to fix the problem, you will see a warning about insecure directories during the initialization of zsh. Just answer with yes and run the "fix-wsl.sh" shipped with this repo. It will update the permissions of ~/.antigen/bundles from 777 to 755.
Also the user would have to manually install powerline fonts on windows, so there is a fallback theme used on windows.

## Installation

psh is being installed using an install script that will guide you through the installation process of zsh and all required dependencies. Finally the installer will do all required configuration tasks to get a great experience out of zsh without manual configuration.

The installation process of psh is simple - you just need git to clone this repo - but the download as zip button can also do the job of getting all required files.
Note that the described process is for Ubuntu and users that use sudo. It is recommended that you open a shell and navigate to your home directory before executing the required commands.The described commands will install psh into a sub-directory in the directory you're currently in.

### Step by step
#### Ensure that git is installed
Use the following concatenated command to ensure that git is installed.
```
sudo apt update && sudo apt upgrade && sudo apt install git
```

#### Clone this repo
Now clone this repository to collect all required installation files.
```
git clone https://github.com/pascal-zarrad/psh.git
```

#### Go into folder & fix permissions
Now go into the cloned folder and make the install.sh executable.
```
cd psh && chmod +x install.sh
```

#### Finally, install
Now execute the install script.
```
./install.sh
```

### As one command
Execute the following command to install psh using only one console command.
```
sudo apt update && sudo apt upgrade && sudo apt install git && git clone https://github.com/pascal-zarrad/psh.git && cd psh && chmod +x install.sh && ./install.sh
```

## Updating
Updating psh is as simple as installing it- you just need to pull the newest version from GitHub.

**IMPORTANT:**
During the update process, your .zshrc will be rebuild. If you made any manual changes to it, those will be lost!

### Step by step
#### Find your psh installation
You have to ```cd``` into the directory where psh has been cloned to. If you followed the default installation procedure, it should be installed under ```~/psh/```.

#### Pull changes
Simply use git pull to get the newest changes from the remote repository.
```
git pull
```

#### Ensure that git did not mess up permissions
Sometimes git can mess up a files permissions when pulling the newest version of a file.
Use ```chmod``` to ensure that the installer is executable.
```
chmod +x install.sh
```

#### Re-run the installer
Now just re-run the installer to install the newest version and update.
```
./install.sh
```

### As one command
Execute the following command to update psh using only one console command.
It is assumed that you're already in psh's installation directory!
```
git pull && chmod +x install.sh && ./install.sh
```

## Code Quality
To ensure code quality, the scripts in the repository are being checked by [shellcheck](https://github.com/koalaman/shellcheck).
Please refer to the shellcheck repository's README on how to install shellcheck on your computer.

To check code quality run: ```shellcheck **/*.sh```

**NOTE:** When pushing to this repository, TravisCI will check your changes.There's no way around the check.

## Contributing

You are welcome to contribute to psh if you have improvements or bug fixes.
You are also welcome to suggest own plugins that should be added to the default
psh installation. As this is the configuration I use every day, not every plugin suggestion will be accepted,
but I try to be open regarding contributions.
