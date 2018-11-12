#!/usr/bin/env bash


###########################
# This script processes the remaining tasks after rebooting once the system is configured
# @author Oriol Torrent Florensa
###########################

# include my library helpers for colorized echo and require_brew, etc
source ./lib_sh/echos.sh
source ./lib_sh/requirers.sh

###############################################################################
# ZSH                                                                         #
###############################################################################

bot "finishing ZSH installation"

running "installing PowerLine fonts"
./Sites/_Tools/powerline-fonts/install.sh
ok

running "activating zsh-completions"
# make sure the path has the correct permissions to avoid insecrure directories warning:
# https://stackoverflow.com/questions/13762280/zsh-compinit-insecure-directories
sudo chmod -R 755 /usr/local/share
rm -f ~/.zcompdump; compinit
ok

running "making sure ZSH is up to date"
upgrade_oh_my_zsh
ok


###############################################################################
# NPM                                                                         #
###############################################################################

bot "installing latest lts node version"

nvm install --lts
ok

# always pin versions (no surprises, consistent dev/build machines)
running "always pin versions (save-exact) for 'npm i'"
npm config set save-exact true
ok


