#!/usr/bin/env bash


###########################
# This script processes the remaining tasks after rebooting once the system is configured
# @author Oriol Torrent Florensa
###########################

# source nvm: https://unix.stackexchange.com/questions/184508/nvm-command-not-available-in-bash-script
# source $(brew --prefix nvm)/nvm.sh # if installed via Brew; you shouldn't
source ${HOME}/.nvm/nvm.sh

# include my library helpers for colorized echo and require_brew, etc
source ./lib_sh/echos.sh
source ./lib_sh/requirers.sh

# Set desired terminal theme name
# https://github.com/lysyi3m/macos-terminal-themes.git
TERMINAL_THEME="FrontEndDelight"


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


###############################################################################
# ZSH                                                                         #
###############################################################################

bot "finishing ZSH installation"

read -r -p "Do you want to install Powerline fonts? [Y|n] " response
if [[ $response =~ ^(y|yes|Y) ]];then
    running "installing PowerLine fonts"
    ./Sites/_Tools/powerline-fonts/install.sh
fi
ok

read -r -p "Do you want to activate zsh-completions? [Y|n] " response
if [[ $response =~ ^(y|yes|Y) ]];then
    running "activating zsh-completions"
    # make sure the path has the correct permissions to avoid insecrure directories warning:
    # https://stackoverflow.com/questions/13762280/zsh-compinit-insecure-directories
    sudo chmod -R 755 /usr/local/share
    rm -f ~/.zcompdump; compinit
fi
ok

running "making sure ZSH is up to date"
# the same than calling 'upgrade_oh_my_zsh' in a ZSH environment
env ZSH=$ZSH /bin/sh $ZSH/tools/upgrade.sh
ok


###############################################################################
# TERMINAL                                                                    #
###############################################################################

sleep 1
bot "To finish the Terminal customisation..."
sleep 2
running "Open Terminal > Prefernces (Cmd+,)"
sleep 2
running "Select the ${TERMINAL_THEME} theme"
sleep 2
running "Set a PowerLine font family (Ex: Meslo LG S DZ Regular Powerline)"
sleep 4
echo -e "\n"
read -r -p "Restart terminal? [Y|n] " response
if [[ $response =~ ^(y|yes|Y) ]];then
    action "killing terminal..."
    sleep 2
    killall "Terminal" &> /dev/null
else
    ok "terminal left open";
    info "Remember that changes will only take place once you restart the terminal or in new windows"
fi
