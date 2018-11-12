#!/usr/bin/env bash


###########################
# This script installs the dotfiles and runs all other system configuration scripts
# @author Adam Eivy
# @author Oriol Torrent Florensa
###########################

#
# Reasonably sets OS X defaults. My sources:
#  - https://github.com/atomantic/dotfiles
#  - https://gist.github.com/garethrees/2470157
#  - https://github.com/pawelgrzybek/dotfiles/blob/master/setup-macos.sh
#  - https://github.com/nicksp/dotfiles/blob/master/osx/set-defaults.sh
#  - https://github.com/skwp/dotfiles/blob/master/bin/osx
#  - https://github.com/mathiasbynens/dotfiles/blob/master/.osx
# ~/dotfiles/osx/set-defaults.sh — http://mths.be/osx
#


###############################################################################
# PREPARATION
###############################################################################

# include my library helpers for colorized echo and require_brew, etc
source ./lib_sh/echos.sh
source ./lib_sh/requirers.sh

# Set computer name
COMPUTERNAME="OrTF_mb-air"
HOSTNAME='ortfair'
LOCALHOSTNAME='ortfair'

# Folders
bin_dir="/usr/local/bin"
work_dir="$HOME/Sites/"
tools_dir="$HOME/Sites/_Tools"
nvm_dir="$HOME/.nvm"
torrents_dir="$HOME/Documents/Torrents"

# Set desired terminal theme name
# https://github.com/lysyi3m/macos-terminal-themes.git
TERMINAL_THEME="FrontEndDelight"


bot "Hi! I'm going to install tooling and tweak your system settings. Here I go..."
bot "I may need you to enter your sudo password so I can install some things:"

# Ask for the administrator password upfront
if ! sudo grep -q "%wheel		ALL=(ALL) NOPASSWD: ALL #atomantic/dotfiles" "/etc/sudoers"; then

  # Ask for the administrator password upfront
  sudo -v

  # Keep-alive: update existing sudo time stamp until the script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

  # bot "Do you want me to setup this machine to allow you to run sudo without a password?\nPlease read here to see what I am doing:\nhttp://wiki.summercode.com/sudo_without_a_password_in_mac_os_x \n"

  # read -r -p "Make sudo passwordless? [y|N] " response

  # if [[ $response =~ (yes|y|Y) ]];then
  #     sudo cp /etc/sudoers /etc/sudoers.back
  #     echo '%wheel		ALL=(ALL) NOPASSWD: ALL #atomantic/dotfiles' | sudo tee -a /etc/sudoers > /dev/null
  #     sudo dscl . append /Groups/wheel GroupMembership $(whoami)
  #     bot "You can now run sudo commands without password!"
  # fi
fi


###############################################################################
# Creating directories                                                        #
###############################################################################

bot "Creating directories"

running "Creating $work_dir..."
if [[ ! -e "$work_dir" ]]; then
  mkdir $work_dir
  ok
else
  info "Already created"
fi

running "Creating $tools_dir..."
if [[ ! -e "$tools_dir" ]]; then
  mkdir $tools_dir
  ok
else
  info "Already created"
fi

running "Creating $nvm_dir..."
if [[ ! -e "$nvm_dir" ]]; then
  mkdir $nvm_dir
  ok
else
  info "Already created"
fi

running "Creating $torrents_dir..."
if [[ ! -e "$torrents_dir" ]]; then
  mkdir $torrents_dir
  ok
else
  info "Already created"
fi


###############################################################################
# HOSTS                                                                       #
###############################################################################

bot "setting up hosts"
read -r -p "Overwrite /etc/hosts with the ad-blocking hosts file from someonewhocares.org? (from ./configs/hosts file) [y|N] " response
if [[ $response =~ (yes|y|Y) ]];then
    action "cp /etc/hosts /etc/hosts.backup"
    sudo cp /etc/hosts /etc/hosts.backup
    ok
    action "cp ./configs/hosts /etc/hosts"
    sudo cp ./configs/hosts /etc/hosts
    ok
    bot "Your /etc/hosts file has been updated. Last version is saved in /etc/hosts.backup"
else
  info "hosts were left untouched"
fi


###############################################################################
# GITHUB                                                                      #
###############################################################################

bot "Let's setup your Github account"
grep 'user = GITHUBUSER' ./homedir/.gitconfig > /dev/null 2>&1
if [[ $? = 0 ]]; then
    read -r -p "What is your github.com username? " githubuser

  fullname=`osascript -e "long user name of (system info)"`

  if [[ -n "$fullname" ]];then
    lastname=$(echo $fullname | awk '{print $2}');
    firstname=$(echo $fullname | awk '{print $1}');
  fi

  if [[ -z $lastname ]]; then
    lastname=`dscl . -read /Users/$(whoami) | grep LastName | sed "s/LastName: //"`
  fi
  if [[ -z $firstname ]]; then
    firstname=`dscl . -read /Users/$(whoami) | grep FirstName | sed "s/FirstName: //"`
  fi
  email=`dscl . -read /Users/$(whoami)  | grep EMailAddress | sed "s/EMailAddress: //"`

  if [[ ! "$firstname" ]];then
    response='n'
  else
    echo -e "I see that your full name is $COL_YELLOW$firstname $lastname$COL_RESET"
    read -r -p "Is this correct? [Y|n] " response
  fi

  if [[ $response =~ ^(no|n|N) ]];then
    read -r -p "What is your first name? " firstname
    read -r -p "What is your last name? " lastname
  fi
  fullname="$firstname $lastname"

  bot "Great $fullname, "

  if [[ ! $email ]];then
    response='n'
  else
    echo -e "The best I can make out, your email address is $COL_YELLOW$email$COL_RESET"
    read -r -p "Is this correct? [Y|n] " response
  fi

  if [[ $response =~ ^(no|n|N) ]];then
    read -r -p "What is your email? " email
    if [[ ! $email ]];then
      error "you must provide an email to configure .gitconfig"
      exit 1
    fi
  fi


  running "replacing items in .gitconfig with your info ($COL_YELLOW$fullname, $email, $githubuser$COL_RESET)"

  # test if gnu-sed or MacOS sed

  sed -i "s/GITHUBFULLNAME/$firstname $lastname/" ./homedir/.gitconfig > /dev/null 2>&1 | true
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    echo
    running "looks like you are using MacOS sed rather than gnu-sed, accommodating"
    sed -i '' "s/GITHUBFULLNAME/$firstname $lastname/" ./homedir/.gitconfig;
    sed -i '' 's/GITHUBEMAIL/'$email'/' ./homedir/.gitconfig;
    sed -i '' 's/GITHUBUSER/'$githubuser'/' ./homedir/.gitconfig;
    ok
  else
    echo
    bot "looks like you are already using gnu-sed. woot!"
    sed -i 's/GITHUBEMAIL/'$email'/' ./homedir/.gitconfig;
    sed -i 's/GITHUBUSER/'$githubuser'/' ./homedir/.gitconfig;
  fi
fi


###############################################################################
# WALLPAPER                                                                   #
###############################################################################

# MD5_NEWWP=$(md5 img/wallpaper.jpg | awk '{print $4}')
# MD5_OLDWP=$(md5 /System/Library/CoreServices/DefaultDesktop.jpg | awk '{print $4}')
# if [[ "$MD5_NEWWP" != "$MD5_OLDWP" ]]; then
#   read -r -p "Do you want to use the project's custom desktop wallpaper? [Y|n] " response
#   if [[ $response =~ ^(no|n|N) ]];then
#     echo "skipping...";
#     ok
#   else
#     running "Set a custom wallpaper image"
#     # `DefaultDesktop.jpg` is already a symlink, and
#     # all wallpapers are in `/Library/Desktop Pictures/`. The default is `Wave.jpg`.
#     rm -rf ~/Library/Application Support/Dock/desktoppicture.db
#     sudo rm -f /System/Library/CoreServices/DefaultDesktop.jpg > /dev/null 2>&1
#     sudo rm -f /Library/Desktop\ Pictures/El\ Capitan.jpg > /dev/null 2>&1
#     sudo rm -f /Library/Desktop\ Pictures/Sierra.jpg > /dev/null 2>&1
#     sudo rm -f /Library/Desktop\ Pictures/Sierra\ 2.jpg > /dev/null 2>&1
#     sudo cp ./img/wallpaper.jpg /System/Library/CoreServices/DefaultDesktop.jpg;
#     sudo cp ./img/wallpaper.jpg /Library/Desktop\ Pictures/Sierra.jpg;
#     sudo cp ./img/wallpaper.jpg /Library/Desktop\ Pictures/Sierra\ 2.jpg;
#     sudo cp ./img/wallpaper.jpg /Library/Desktop\ Pictures/El\ Capitan.jpg;ok
#   fi
# fi


###############################################################################
# Homebrew                                                                    #
###############################################################################

running "checking homebrew install"
brew_bin=$(which brew) 2>&1 > /dev/null
if [[ $? != 0 ]]; then
  action "installing homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [[ $? != 0 ]]; then
      error "unable to install homebrew, script $0 abort!"
      exit 2
  fi
else
  ok
  # Make sure we’re using the latest Homebrew
  running "updating homebrew"
  brew update
  ok
  bot "before installing brew packages, we can upgrade any outdated packages."
  read -r -p "run brew upgrade? [y|N] " response
  if [[ $response =~ ^(y|yes|Y) ]];then
      # Upgrade any already-installed formulae
      action "upgrade brew packages..."
      brew upgrade
      ok "brews updated..."
  else
      ok "skipped brew package upgrades.";
  fi
fi


##############################################################################
# Homebrew bundle                                                            #
##############################################################################

running "installing homebrew bundle"
# output=$(brew tap | grep cask)
# if [[ $? != 0 ]]; then
#   action "installing brew-cask"
#   require_brew caskroom/cask/brew-cask
# fi
# brew tap caskroom/versions > /dev/null 2>&1

# https://github.com/Homebrew/homebrew-bundle
brew bundle install
ok

# skip those GUI clients, git command-line all the way
# require_brew git
# need fontconfig to install/build fonts
# require_brew fontconfig
# update zsh to latest
# require_brew zsh
# update ruby to latest
# use versions of packages installed with homebrew
# RUBY_CONFIGURE_OPTS="--with-openssl-dir=`brew --prefix openssl` --with-readline-dir=`brew --prefix readline` --with-libyaml-dir=`brew --prefix libyaml`"
# require_brew ruby


###############################################################################
# ZSH                                                                         #
###############################################################################

bot "setting zsh as the user login shell"
CURRENTSHELL=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
if [[ "$CURRENTSHELL" != "/usr/local/bin/zsh" ]]; then
  bot "setting newer homebrew zsh (/usr/local/bin/zsh) as your shell (password required)"
  # sudo bash -c 'echo "/usr/local/bin/zsh" >> /etc/shells'
  # chsh -s /usr/local/bin/zsh
  sudo dscl . -change /Users/$USER UserShell $SHELL /usr/local/bin/zsh > /dev/null 2>&1
  ok
fi

running "copying custom ZSH files"
action "cp lib_zsh/*.zsh oh-my-zsh/custom"
cp lib_zsh/*.zsh oh-my-zsh/custom
ok

running "installing powerLevel9k theme"
if [[ ! -d "./oh-my-zsh/custom/themes/powerlevel9k" ]]; then
  git clone https://github.com/bhilburn/powerlevel9k.git oh-my-zsh/custom/themes/powerlevel9k
fi
ok

running "getting PowerLine fonts"
if [[ ! -d "~/Sites/_Tools/powerline-fonts" ]]; then
  git clone https://github.com/powerline/fonts.git ~/Sites/_Tools/powerline-fonts
fi
ok

running "installing useful key bindings and fuzzy completion"
# https://github.com/junegunn/fzf#fuzzy-completion-for-bash-and-zsh
# https://sourabhbajaj.com/mac-setup/iTerm/fzf.html
$(brew --prefix)/opt/fzf/install
ok

running "installing fonts"
./fonts/install.sh
# brew tap caskroom/fonts
# require_cask font-fontawesome
# require_cask font-awesome-terminal-fonts
# require_cask font-hack
# require_cask font-inconsolata-dz-for-powerline
# require_cask font-inconsolata-g-for-powerline
# require_cask font-inconsolata-for-powerline
# require_cask font-roboto-mono
# require_cask font-roboto-mono-for-powerline
# require_cask font-source-code-pro
ok


###############################################################################
# DOTFILES                                                                    #
###############################################################################

bot "creating symlinks for project dotfiles..."
pushd homedir > /dev/null 2>&1
now=$(date +"%Y.%m.%d.%H.%M.%S")

for file in .*; do
  if [[ $file == "." || $file == ".." ]]; then
    continue
  fi
  running "~/$file"
  # if the file exists:
  if [[ -e ~/$file ]]; then
      mkdir -p ~/.dotfiles_backup/$now
      mv ~/$file ~/.dotfiles_backup/$now/$file
      echo "backup saved as ~/.dotfiles_backup/$now/$file"
  fi
  # symlink might still exist
  unlink ~/$file > /dev/null 2>&1
  # create the link
  ln -s ~/.dotfiles/homedir/$file ~/$file
  echo -en '\tlinked';ok
done

popd > /dev/null 2>&1


###############################################################################
# VIM                                                                         #
###############################################################################

bot "installing vim plugins"
# cmake is required to compile vim bundle YouCompleteMe
# require_brew cmake
vim +PluginInstall +qall > /dev/null 2>&1
ok


###############################################################################
# RUBY                                                                        #
###############################################################################

# if [[ -d "/Library/Ruby/Gems/2.0.0" ]]; then
#   running "Fixing Ruby Gems Directory Permissions"
#   sudo chown -R $(whoami) /Library/Ruby/Gems/2.0.0
#   ok
# fi


###############################################################################
# NVM                                                                         #
###############################################################################

bot "installing nvm"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
ok


#####################################
# Now we can switch to node.js mode
# for better maintainability and
# easier configuration via
# JSON files and inquirer prompts
#####################################

# bot "installing npm tools needed to run this project..."
# npm install
# ok

# bot "installing packages from config.js..."
# node index.js
# ok


bot "Let's adjust the system..."
sleep 1

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
running "closing any system preferences to prevent issues with automated changes"
osascript -e 'tell application "System Preferences" to quit'
ok

{
  ###############################################################################
  bot "General UI/UX"
  ###############################################################################

  running "Set computer name (as done via System Preferences → Sharing)"
  sudo scutil --set ComputerName $COMPUTERNAME
  sudo scutil --set HostName $HOSTNAME
  sudo scutil --set LocalHostName $LOCALHOSTNAME
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $LOCALHOSTNAME

  #running "Disable the sound effects on boot"
  #sudo nvram SystemAudioVolume=" "

  #running "Disable transparency in the menu bar and elsewhere on Yosemite"
  #defaults write com.apple.universalaccess reduceTransparency -bool true

  running "Set highlight color to green"
  defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"

  running "Set sidebar icon size to medium"
  defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

  #running "Always show scrollbars"
  #defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
  #Possible values: `WhenScrolling`, `Automatic` and `Always`

  #running "Disable the over-the-top focus ring animation"
  #defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

  #running "Disable smooth scrolling"
  #"(Uncomment if you’re on an older Mac that messes up the animation)"
  #defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false

  running "Increase window resize speed for Cocoa applications"
  defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

  running "Expand save panel by default"
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

  running "Expand print panel by default"
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  running "Save to disk (not to iCloud) by default"
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

  running "Automatically quit printer app once the print jobs complete"
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

  running "Disable the “Are you sure you want to open this application?” dialog"
  defaults write com.apple.LaunchServices LSQuarantine -bool false

  running "Remove duplicates in the “Open With” menu"
  # (also see `lscleanup` alias)
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

  running "Display ASCII control characters using caret notation in standard text views"
  # Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
  defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

  running "Disable Resume system-wide"
  defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

  running "Disable automatic termination of inactive apps"
  defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

  running "Disable the crash reporter"
  defaults write com.apple.CrashReporter DialogType -string "none"

  running "Set Help Viewer windows to non-floating mode"
  defaults write com.apple.helpviewer DevMode -bool true

  # "Fix for the ancient UTF-8 bug in QuickLook (https://mths.be/bbo)
  # "Commented out, as this is known to cause problems in various Adobe apps :(
  # "See https://github.com/mathiasbynens/dotfiles/issues/237
  #running "0x08000100:0" > ~/.CFUserTextEncoding

  running "Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window"
  sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

  running "Disable Notification Center and remove the menu bar icon"
  launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

  running "Disable automatic capitalization as it’s annoying when typing code"
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

  running "Disable smart dashes as they’re annoying when typing code"
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  running "Disable automatic period substitution as it’s annoying when typing code"
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

  running "Disable smart quotes as they’re annoying when typing code"
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

  #running "Disable auto-correct"
  #defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  running "Enable auto-correct"
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool true

  #running "Set a custom wallpaper image. `DefaultDesktop.jpg` is already a symlink, and"
  #running "all wallpapers are in `/Library/Desktop Pictures/`. The default is `Wave.jpg`"
  #rm -rf ~/Library/Application Support/Dock/desktoppicture.db
  #sudo rm -rf /System/Library/CoreServices/DefaultDesktop.jpg
  #sudo ln -s /path/to/your/image /System/Library/CoreServices/DefaultDesktop.jpg

  ##########
  running "Show remaining battery percentage"
  defaults write com.apple.menuextra.battery ShowPercent -string "YES"

  running "Hide remaining battery time"
  defaults write com.apple.menuextra.battery ShowTime -string "NO"

  running "Configure menu-extras in the menu bar"
  defaults write com.apple.systemuiserver menuExtras -array \
    "/System/Library/CoreServices/Menu Extras/TextInput.menu" \
    "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
    "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
    "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
    "/System/Library/CoreServices/Menu Extras/Battery.menu" \
    "/System/Library/CoreServices/Menu Extras/Volume.menu" \
    "/System/Library/CoreServices/Menu Extras/Clock.menu"


  ###############################################################################
  bot "SSD-specific tweaks"
  ###############################################################################

  ##########
  running "Disable the sudden motion sensor as it’s not useful for SSDs"
  sudo pmset -a sms 0


  ###############################################################################
  bot "Trackpad, mouse, keyboard, Bluetooth accessories, and input"
  ###############################################################################

  running "Trackpad: enable tap to click for this user and for the login screen"
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  running "Trackpad: map bottom right corner to right-click"
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

  running "Enable “natural” (Lion-style) scrolling"
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

  running "Increase sound quality for Bluetooth headphones/headsets"
  defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

  running "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  #running "Use scroll gesture with the Ctrl (^) modifier key to zoom"
  #defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
  #defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
  #running "Follow the keyboard focus while zoomed in"
  #defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

  running "Disable press-and-hold for keys in favor of key repeat"
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

  running "Set a blazingly fast keyboard repeat rate"
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 10

  # running "Set language and text formats"
  # Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
  # `Inches`, `en_GB` with `en_US`, and `true` with `false`.
  defaults write -g AppleLanguages -array "en-CH"
  defaults write -g AppleLocale -string "en_CHB@currency=CHF"
  defaults write -g AppleMeasurementUnits -string "Centimeters"
  defaults write -g AppleMetricUnits -bool true

  running "Show language menu in the top right corner of the boot screen"
  sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true

  running "Set the timezone"
  # see systemsetup -listtimezones for other values
  systemsetup -settimezone "Europe/Zurich" > /dev/null
  sudo systemsetup -setnetworktimeserver "time.euro.apple.com"
  sudo systemsetup -setusingnetworktime on

  #running Stop iTunes from responding to the keyboard media keys
  #launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

  ##########
  running "System Preferences > Accessibility > Mouse & Trackpad > Trackpad Options"
  # https://discussions.apple.com/thread/7387742
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

  defaults write com.apple.AppleMultitouchTrackpad Dragging -bool false
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool false

  running "Automatically illuminate built-in MacBook keyboard in low light"
  defaults write com.apple.BezelServices kDim -bool true

  running "Turn off keyboard illumination when computer is not used for 5 minutes"
  defaults write com.apple.BezelServices kDimTime -int 300

  running "System Preferences > General > Click in the scrollbar to: Jump to the spot that's clicked"
  defaults write -globalDomain "AppleScrollerPagingBehavior" -bool true


  ###############################################################################
  bot "Energy saving"
  ###############################################################################

  running "Turns on lid wakeup"
  sudo pmset -a lidwake 1

  running "Automatic restart on power loss"
  sudo pmset -a autorestart 1

  running "Restart automatically if the computer freezes"
  sudo systemsetup -setrestartfreeze on

  running "Sets displaysleep to 15 minutes"
  sudo pmset -a displaysleep 15

  running "Do not allow machine to sleep on charger"
  sudo pmset -c sleep 0

  running "Set machine sleep to 5 minutes on battery"
  sudo pmset -b sleep 5

  #running "Set standby delay to 24 hours (default is 1 hour)"
  #sudo pmset -a standbydelay 86400

  #running "Never go into computer sleep mode"
  #sudo systemsetup -setcomputersleep Off > /dev/null

  #running "Hibernation mode"
  # 0: Disable hibernation (speeds up entering sleep mode)
  # 3: Copy RAM to disk so the system state can still be restored in case of a
  #    power failure.
  #sudo pmset -a hibernatemode 0

  #running "Remove the sleep image file to save disk space"
  #sudo rm /private/var/vm/sleepimage
  #running "Create a zero-byte file instead…"
  #sudo touch /private/var/vm/sleepimage
  #running "…and make sure it can’t be rewritten"
  #sudo chflags uchg /private/var/vm/sleepimage


  ###############################################################################
  bot "Screen"
  ###############################################################################

  running "Require password immediately after sleep or screen saver"
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0

  running "Save screenshots to a folders "Screenshots" folder in desktop"
  defaults write com.apple.screencapture location -string "${HOME}/Desktop/Screenshots"

  running "Save screenshots in PNG format"
  #(other options: BMP, GIF, JPG, PDF, TIFF)
  defaults write com.apple.screencapture type -string "png"

  # running "Disable shadow in screenshots"
  #defaults write com.apple.screencapture disable-shadow -bool true

  running "Enable sub-pixel rendering on non-Apple LCDs"
  # Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
  # 1 light | 2 medium | 3 big
  defaults write NSGlobalDomain AppleFontSmoothing -int 1

  running Disable Font Smoothing Disabler in macOS Mojave
  # Reference: https://ahmadawais.com/fix-macos-mojave-font-rendering-issue/
  defaults write -g CGFontRenderingFontSmoothingDisabled -bool FALSE

  running "Enable HiDPI display modes (requires restart)"
  sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

  ##########
  running "Minimum font size for antialiasing"
  # default is 4
  defaults write NSGlobalDomain AppleAntiAliasingThreshold -int 2


  ###############################################################################
  bot "Finder"
  ###############################################################################

  #running "Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons"
  #defaults write com.apple.finder QuitMenuItem -bool true

  #running "Finder: disable window animations and Get Info animations"
  #defaults write com.apple.finder DisableAllAnimations -bool true

  running "Set Home as the default location for new Finder windows"
  # For other paths, use `PfLo` and `file:///full/path/here/`
  defaults write com.apple.finder NewWindowTarget -string "PfLo"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

  running "Set the Finder prefs for showing a few different volumes on the Desktop"
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

  running "Finder: show hidden files by default"
  defaults write com.apple.finder AppleShowAllFiles -bool true

  running "Finder: show all filename extensions"
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  running "Finder: show status bar"
  defaults write com.apple.finder ShowStatusBar -bool true

  running "Finder: show path bar"
  defaults write com.apple.finder ShowPathbar -bool true

  running "Display full POSIX path as Finder window title"
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

  running "Keep folders on top when sorting by name"
  defaults write com.apple.finder _FXSortFoldersFirst -bool true

  running "When performing a search, search the current folder by default"
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

  running "Disable the warning when changing a file extension"
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  running "Enable spring loading for directories"
  defaults write NSGlobalDomain com.apple.springing.enabled -bool true

  running "Remove the spring loading delay for directories"
  defaults write NSGlobalDomain com.apple.springing.delay -float 0

  running "Avoid creating .DS_Store files on network or USB volumes"
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  running "Disable disk image verification"
  defaults write com.apple.frameworks.diskimages skip-verify -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
  defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true
  running "Automatically open a new Finder window when a volume is mounted"
  defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
  defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
  defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

  running "Show item info near icons on the desktop and in other icon views"
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

  running "Show item info to the right of the icons on the desktop"
  /usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

  running "Enable snap-to-grid for icons on the desktop and in other icon views"
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

  running "Increase grid spacing for icons on the desktop and in other icon views"
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 70" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 70" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 70" ~/Library/Preferences/com.apple.finder.plist

  running "Increase the size of icons on the desktop and in other icon views"
  /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 56" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 56" ~/Library/Preferences/com.apple.finder.plist
  /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 56" ~/Library/Preferences/com.apple.finder.plist

  running "Use columns view in all Finder windows by default"
  # Four-letter codes for the other view modes: `icnv`, "Nlsv", `clmv`, `Flwv`
  defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

  running "Disable the warning before emptying the Trash"
  defaults write com.apple.finder WarnOnEmptyTrash -bool false

  running "Enable AirDrop over Ethernet and on unsupported Macs running Lion"
  defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

  running "Show the ~/Library folder"
  chflags nohidden ~/Library

  running "Show the /Volumes folder"
  sudo chflags nohidden /Volumes

  #running "Remove Dropbox’s green checkmark icons in Finder"
  #file=/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns
  #[ -e "${file}" ] && mv -f "${file}" "${file}.bak"

  running "Expand the following File Info panes:"
  running "“General”, “Open with”, and “Sharing & Permissions”"
  defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true

  ##########
  running "Finder > Preferences > Disable warning before removing from iCloud Drive"
  defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false

  running "Enable text selection in quicklook"
  defaults write com.apple.finder QLEnableTextSelection -bool true


  ###############################################################################
  bot "Dock"
  ###############################################################################

  running "Enable highlight hover effect for the grid view of a stack (Dock)"
  defaults write com.apple.dock mouse-over-hilite-stack -bool true

  running "Set the icon size of Dock items to 32 pixels"
  defaults write com.apple.dock tilesize -int 32

  running "Change minimize/maximize window effect"
  # "scale" or "genie"
  defaults write com.apple.dock mineffect -string "genie"

  running "Minimize windows into their application’s icon"
  defaults write com.apple.dock minimize-to-application -bool true

  running "Enable spring loading for all Dock items"
  defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

  running "Show indicator lights for open applications in the Dock"
  defaults write com.apple.dock show-process-indicators -bool true

  running "Wipe all (default) app icons from the Dock"
  # This is only really useful when setting up a new Mac, or if you don’t use
  # the Dock to launch apps.
  defaults write com.apple.dock persistent-apps -array
  #defaults delete com.apple.dock persistent-apps
  #defaults delete com.apple.dock persistent-others

  #running "Show only open applications in the Dock"
  #defaults write com.apple.dock static-only -bool true

  #running "Don’t animate opening applications from the Dock"
  #defaults write com.apple.dock launchanim -bool false

  running "Speed up Mission Control animations"
  defaults write com.apple.dock expose-animation-duration -float 0.1

  running "Don’t group windows by application in Mission Control"
  # (i.e. use the old Exposé behavior instead)
  defaults write com.apple.dock expose-group-by-app -bool false

  running "Disable Dashboard"
  defaults write com.apple.dashboard mcx-disabled -boolean true

  running "Don’t show Dashboard as a Space"
  defaults write com.apple.dock dashboard-in-overlay -bool true

  running "Don’t automatically rearrange Spaces based on most recent use"
  defaults write com.apple.dock mru-spaces -bool false

  #running "Remove the auto-hiding Dock delay"
  #defaults write com.apple.dock autohide-delay -float 0
  #running "Remove the animation when hiding/showing the Dock"
  #defaults write com.apple.dock autohide-time-modifier -float 0
  running "Set the animation when hiding/showing the Dock"
  defaults write com.apple.dock autohide-time-modifier -float 0.5

  running "Automatically hide and show the Dock"
  defaults write com.apple.dock autohide -bool true

  running "Make Dock icons of hidden applications translucent"
  defaults write com.apple.dock showhidden -bool true

  #running "Don’t show recent applications in Dock"
  #defaults write com.apple.dock show-recents -bool false

  #running "Disable the Launchpad gesture (pinch with thumb and three fingers)"
  #defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

  #running "Reset Launchpad, but keep the desktop wallpaper intact"
  #find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete

  #running "Add iOS & Watch Simulator to Launchpad"
  #sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
  #sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"

  # Add a spacer to the left side of the Dock (where the applications are)
  #defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
  # Add a spacer to the right side of the Dock (where the Trash is)
  #defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'

  # Hot corners
  # Possible values:
  #   0: no-op
  #   2: Mission Control
  #   3: Show application windows
  #   4: Desktop
  #   5: Start screen saver
  #   6: Disable screen saver
  #   7: Dashboard
  #  10: Put display to sleep
  #  11: Launchpad
  #  12: Notification Center
  # defaults write com.apple.dock wvous-bl-corner -int 5
  # defaults write com.apple.dock wvous-bl-modifier -int 0

  running "Configure hot corners:"
  running "Set bottom-left: Put display to sleep"
  defaults write com.apple.dock wvous-bl-corner -int 10
  defaults write com.apple.dock wvous-bl-modifier -int 0
  running "Set bottom-right: Show Desktop"
  defaults write com.apple.dock wvous-br-corner -int 4
  defaults write com.apple.dock wvous-br-modifier -int 0
  running "Set top-left: Mission Control"
  defaults write com.apple.dock wvous-tl-corner -int 2
  defaults write com.apple.dock wvous-tl-modifier -int 0
  running "Set top-right: Show application windows"
  defaults write com.apple.dock wvous-tr-corner -int 3
  defaults write com.apple.dock wvous-tr-modifier -int 0

  ##########
  running "System Preferences > Dock > Size (magnified)"
  defaults write com.apple.dock largesize -int 63

  running "System Preferences > Dock > Magnification"
  defaults write com.apple.dock magnification -bool true

  running "System Preferences > Dock > Orientation"
  defaults write com.apple.dock orientation -string left

  # running "Remove the delay for showing the Dock in full screen"
  # defaults write com.apple.dock autohide-fullscreen-delayed -bool false

  running "Create macOS Dock recent items stacks"
  defaults write com.apple.dock persistent-others -array-add '{"tile-data" = {"list-type" = 1;}; "tile-type" = "recents-tile";}'


  ###############################################################################
  bot "Safari & WebKit"
  ###############################################################################
 
  running "Privacy: don’t send search queries to Apple"
  defaults write com.apple.Safari UniversalSearchEnabled -bool false
  defaults write com.apple.Safari SuppressSearchSuggestions -bool true

  running "Press Tab to highlight each item on a web page"
  defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

  running "Show the full URL in the address bar (note: this still hides the scheme)"
  defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

  # running "Set Safari’s home page to `about:blank` for faster loading"
  # defaults write com.apple.Safari HomePage -string "about:blank"

  running "Prevent Safari from opening ‘safe’ files automatically after downloading"
  defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

  running "Allow hitting the Backspace key to go to the previous page in history"
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

  running "Hide Safari's bookmark bar"
  defaults write com.apple.Safari ShowFavoritesBar -bool false

  running "Hide Safari’s sidebar in Top Sites"
  defaults write com.apple.Safari ShowSidebarInTopSites -bool false

  running "Disable Safari’s thumbnail cache for History and Top Sites"
  defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

  running "Enable Safari’s debug menu"
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

  running "Make Safari’s search banners default to Contains instead of Starts With"
  defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

  running "Remove useless icons from Safari’s bookmarks bar"
  defaults write com.apple.Safari ProxiesInBookmarksBar "()"

  running "Enable the Develop menu and the Web Inspector in Safari"
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

  running "Add a context menu item for showing the Web Inspector in web views"
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

  running "Enable continuous spellchecking"
  defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true
  running "Disable auto-correct"
  defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

  running "Disable AutoFill"
  defaults write com.apple.Safari AutoFillFromAddressBook -bool false
  defaults write com.apple.Safari AutoFillPasswords -bool false
  defaults write com.apple.Safari AutoFillCreditCardData -bool false
  defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

  running "Warn about fraudulent websites"
  defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

  running "Disable plug-ins"
  defaults write com.apple.Safari WebKitPluginsEnabled -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false

  running "Disable Java"
  defaults write com.apple.Safari WebKitJavaEnabled -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles -bool false

  running "Block pop-up windows"
  defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

  running "Disable auto-playing video"
  #defaults write com.apple.Safari WebKitMediaPlaybackAllowsInline -bool false
  #defaults write com.apple.SafariTechnologyPreview WebKitMediaPlaybackAllowsInline -bool false
  #defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
  #defaults write com.apple.SafariTechnologyPreview com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false

  running "Enable “Do Not Track”"
  defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

  running "Update extensions automatically"
  defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true


  ###############################################################################
  bot "Mail"
  ###############################################################################
 
  #running "Disable send and reply animations in Mail.app"
  #defaults write com.apple.mail DisableReplyAnimations -bool true
  #defaults write com.apple.mail DisableSendAnimations -bool true

  running "Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app"
  defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

  running "Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app"
  defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

  running "Display emails in threaded mode, sorted by date (oldest at the top)"
  defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
  defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
  defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

  running "Disable inline attachments (just show the icons)"
  defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

  #running "Disable automatic spell checking"
  #defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"


  ###############################################################################
  bot "Spotlight"
  ###############################################################################

  #running "Hide Spotlight tray-icon (and subsequent helper)"
  #sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search

  #running "Disable Spotlight indexing for any volume that gets mounted and has not yet"
  #running "been indexed before."
  # Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing any volume.
  #sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"

  running "Change indexing order and disable some search results"
  # Yosemite-specific search results (remove them if you are using macOS 10.9 or older):
  # 	MENU_DEFINITION
  # 	MENU_CONVERSION
  # 	MENU_EXPRESSION
  # 	MENU_SPOTLIGHT_SUGGESTIONS (send search queries to Apple)
  # 	MENU_WEBSEARCH             (send search queries to Apple)
  # 	MENU_OTHER
  defaults write com.apple.spotlight orderedItems -array \
    '{"enabled" = 1;"name" = "APPLICATIONS";}' \
    '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
    '{"enabled" = 1;"name" = "DIRECTORIES";}' \
    '{"enabled" = 1;"name" = "PDF";}' \
    '{"enabled" = 1;"name" = "FONTS";}' \
    '{"enabled" = 1;"name" = "DOCUMENTS";}' \
    '{"enabled" = 1;"name" = "MESSAGES";}' \
    '{"enabled" = 1;"name" = "CONTACT";}' \
    '{"enabled" = 1;"name" = "EVENT_TODO";}' \
    '{"enabled" = 1;"name" = "IMAGES";}' \
    '{"enabled" = 1;"name" = "BOOKMARKS";}' \
    '{"enabled" = 1;"name" = "MUSIC";}' \
    '{"enabled" = 1;"name" = "MOVIES";}' \
    '{"enabled" = 1;"name" = "PRESENTATIONS";}' \
    '{"enabled" = 1;"name" = "SPREADSHEETS";}' \
    '{"enabled" = 1;"name" = "SOURCE";}' \
    '{"enabled" = 1;"name" = "MENU_DEFINITION";}' \
    '{"enabled" = 1;"name" = "MENU_OTHER";}' \
    '{"enabled" = 1;"name" = "MENU_CONVERSION";}' \
    '{"enabled" = 1;"name" = "MENU_EXPRESSION";}' \
    '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
    '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

  running "Load new settings before rebuilding the index"
  sudo killall mds > /dev/null 2>&1

  running "Make sure indexing is enabled for the main volume"
  sudo mdutil -i on / > /dev/null

  running "Rebuild the index from scratch"
  sudo mdutil -E / > /dev/null


  ###############################################################################
  bot "Terminal & iTerm 2"
  ###############################################################################

  running "Only use UTF-8 in Terminal.app"
  defaults write com.apple.terminal StringEncodings -array 4

  #running "Enable “focus follows mouse” for Terminal.app and all X11 apps"
  # i.e. hover over a window and start typing in it without clicking first
  #defaults write com.apple.terminal FocusFollowsMouse -bool true
  #defaults write org.x.X11 wm_ffm -bool true

  running "Enable Secure Keyboard Entry in Terminal.app"
  # See: https://security.stackexchange.com/a/47786/8918
  defaults write com.apple.terminal SecureKeyboardEntry -bool true

  running "Disable the annoying line marks"
  defaults write com.apple.Terminal ShowLineMarks -int 0

  #running "Install the Solarized Dark theme for iTerm"
  #open "${HOME}/init/Solarized Dark.itermcolors"

  #running "Don’t display the annoying prompt when quitting iTerm"
  #defaults write com.googlecode.iterm2 PromptOnQuit -bool false

  running "installing terminal themes"
  git clone https://github.com/lysyi3m/macos-terminal-themes.git ${tools_dir}/macos-terminal-themes

  action "open the theme, so that it is included in the Library"
  open ${tools_dir}/macos-terminal-themes/schemes/${TERMINAL_THEME}.terminal

  running "seting Terminal defaults"
  # https://redlinetech.wordpress.com/2015/03/18/scripting-the-default-terminal-theme-in-os-x/
  sudo -u $USER defaults write /Users/$USER/Library/Preferences/com.apple.Terminal.plist "Default Window Settings" "FrontEndDelight"
  sudo -u $USER defaults write /Users/$USER/Library/Preferences/com.apple.Terminal.plist "Startup Window Settings" "FrontEndDelight"

  #set window width to 180
  sudo /usr/libexec/PlistBuddy -c "Add :Window\ Settings:FrontEndDelight:columnCount integer 180" /Users/$USER/Library/Preferences/com.apple.Terminal.plist
  defaults write /Users/$USER/Library/Preferences/com.apple.Terminal.plist "NSWindow Frame TTWindow FrontEndDelight" "187 65 640 778 0 0 1440 877 "


  ###############################################################################
  bot "TimeMachine"
  ###############################################################################

  running "Prevent Time Machine from prompting to use new hard drives as backup volume"
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

  running "Disable local Time Machine backups"
  hash tmutil &> /dev/null && sudo tmutil disablelocal


  ###############################################################################
  bot "Activity Monitor"
  ###############################################################################

  running "Show the main window when launching Activity Monitor"
  defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

  running "Visualise CPU usage in the Activity Monitor Dock icon"
  defaults write com.apple.ActivityMonitor IconType -int 5

  running "Show all processes in Activity Monitor"
  defaults write com.apple.ActivityMonitor ShowCategory -int 0

  running "Sort Activity Monitor results by CPU usage"
  defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
  defaults write com.apple.ActivityMonitor SortDirection -int 0


  ###############################################################################
  bot "Address Book, Dashboard, iCal, TextEdit, and Disk Utility"
  ###############################################################################

  #running "Enable the debug menu in Address Book"
  #defaults write com.apple.addressbook ABShowDebugMenu -bool true

  #running "Enable Dashboard dev mode (allows keeping widgets on the desktop)"
  #defaults write com.apple.dashboard devmode -bool true

  #running "Enable the debug menu in iCal (pre-10.8)"
  #defaults write com.apple.iCal IncludeDebugMenu -bool true

  running "Use plain text mode for new TextEdit documents"
  defaults write com.apple.TextEdit RichText -int 0
  running "Open and save files as UTF-8 in TextEdit"
  defaults write com.apple.TextEdit PlainTextEncoding -int 4
  defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

  running "Enable the debug menu in Disk Utility"
  defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
  defaults write com.apple.DiskUtility advanced-image-options -bool true

  running "Auto-play videos when opened with QuickTime Player"
  defaults write com.apple.QuickTimePlayerX MGPlayMovieOnOpen -bool true


  ###############################################################################
  bot "Mac App Store"
  ###############################################################################

  running "Enable the WebKit Developer Tools in the Mac App Store"
  defaults write com.apple.appstore WebKitDeveloperExtras -bool true

  running "Enable Debug Menu in the Mac App Store"
  defaults write com.apple.appstore ShowDebugMenu -bool true

  running "Enable the automatic update check"
  defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

  running "Check for software updates daily, not just once per week"
  defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

  running "Download newly available updates in background"
  defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

  running "Install System data files & security updates"
  defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

  running "Automatically download apps purchased on other Macs"
  defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

  running "Turn on app auto-update"
  defaults write com.apple.commerce AutoUpdate -bool true

  running "Allow the App Store to reboot machine on macOS updates"
  defaults write com.apple.commerce AutoUpdateRestartRequired -bool true


  ###############################################################################
  bot "Photos"
  ###############################################################################

  running "Prevent Photos from opening automatically when devices are plugged in"
  defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true


  ###############################################################################
  bot "Messages"
  ###############################################################################

  #running "Disable automatic emoji substitution (i.e. use plain text smileys)"
  #defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

  running "Disable smart quotes as it’s annoying for messages that contain code"
  defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

  #running "Disable continuous spell checking"
  #defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false


  ###############################################################################
  bot "Google Chrome & Google Chrome Canary"
  ###############################################################################

  running "Disable the all too sensitive backswipe on trackpads"
  defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
  defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

  running "Disable the all too sensitive backswipe on Magic Mouse"
  defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
  defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

  running "Use the system-native print preview dialog"
  defaults write com.google.Chrome DisablePrintPreview -bool true
  defaults write com.google.Chrome.canary DisablePrintPreview -bool true

  running "Expand the print dialog by default"
  defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
  defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true


  ###############################################################################
  bot "GPGMail 2"
  ###############################################################################

  running "Disable signing emails by default"
  defaults write ~/Library/Preferences/org.gpgtools.gpgmail SignNewEmailsByDefault -bool false


  ###############################################################################
  bot "Opera & Opera Developer"
  ###############################################################################

  running "Expand the print dialog by default"
  defaults write com.operasoftware.Opera PMPrintingExpandedStateForPrint2 -boolean true
  defaults write com.operasoftware.OperaDeveloper PMPrintingExpandedStateForPrint2 -boolean true


  ###############################################################################
  #bot "SizeUp.app"
  ###############################################################################

  # running "Start SizeUp at login"
  # defaults write com.irradiatedsoftware.SizeUp StartAtLogin -bool true

  # running "Don’t show the preferences window on next start"
  # defaults write com.irradiatedsoftware.SizeUp ShowPrefsOnNextStart -bool false


  ###############################################################################
  #bot "Sublime Text"
  ###############################################################################

  #running "Install Sublime Text settings"
  #cp -r init/Preferences.sublime-settings ~/Library/Application\ Support/Sublime\ Text*/Packages/User/Preferences.sublime-settings 2> /dev/null


  ###############################################################################
  bot "Spectacle.app"
  ###############################################################################

  running "Set up my preferred keyboard shortcuts"
  cp -r configs/spectacle.json ~/Library/Application\ Support/Spectacle/Shortcuts.json 2> /dev/null


  ###############################################################################
  bot "Transmission.app"
  ###############################################################################

  running "Use `~/Documents/Torrents` to store incomplete downloads"
  defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
  defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Documents/Torrents"

  running "Use `~/Downloads` to store completed downloads"
  defaults write org.m0k.transmission DownloadLocationConstant -bool true

  running "Don’t prompt for confirmation before downloading"
  defaults write org.m0k.transmission DownloadAsk -bool false
  defaults write org.m0k.transmission MagnetOpenAsk -bool false

  running "Don’t prompt for confirmation before removing non-downloading active transfers"
  defaults write org.m0k.transmission CheckRemoveDownloading -bool true

  running "Trash original torrent files"
  defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

  running "Hide the donate message"
  defaults write org.m0k.transmission WarningDonate -bool false
  running "Hide the legal disclaimer"
  defaults write org.m0k.transmission WarningLegal -bool false

  running "IP block list."
  # Source: https://giuliomac.wordpress.com/2014/02/19/best-blocklist-for-transmission/
  defaults write org.m0k.transmission BlocklistNew -bool true
  defaults write org.m0k.transmission BlocklistURL -string "http://john.bitsurge.net/public/biglist.p2p.gz"
  defaults write org.m0k.transmission BlocklistAutoUpdate -bool true

  running "Randomize port on launch"
  defaults write org.m0k.transmission RandomPort -bool true


  ###############################################################################
  bot "Twitter.app"
  ###############################################################################

  running "Disable smart quotes as it’s annoying for code tweets"
  defaults write com.twitter.twitter-mac AutomaticQuoteSubstitutionEnabled -bool false

  running "Show the app window when clicking the menu bar icon"
  defaults write com.twitter.twitter-mac MenuItemBehavior -int 1

  running "Enable the hidden ‘Develop’ menu"
  defaults write com.twitter.twitter-mac ShowDevelopMenu -bool true

  running "Open links in the background"
  defaults write com.twitter.twitter-mac openLinksInBackground -bool true

  running "Allow closing the ‘new tweet’ window by pressing `Esc`"
  defaults write com.twitter.twitter-mac ESCClosesComposeWindow -bool true

  running "Show full names rather than Twitter handles"
  defaults write com.twitter.twitter-mac ShowFullNames -bool true

  running "Hide the app in the background if it’s not the front-most window"
  defaults write com.twitter.twitter-mac HideInBackground -bool true


  ###############################################################################
  bot "Tweetbot.app"
  ###############################################################################

  running "Bypass the annoyingly slow t.co URL shortener"
  defaults write com.tapbots.TweetbotMac OpenURLsDirectly -bool true


  ###############################################################################
  bot "iTunes"
  ###############################################################################

  running "Disable the Ping sidebar in iTunes"
  defaults write com.apple.iTunes disablePingSidebar -bool true

  running "Disable all the other Ping stuff in iTunes"
  defaults write com.apple.iTunes disablePing -bool true

  running "Make ⌘ + F focus the search input in iTunes"
  defaults write com.apple.iTunes NSUserKeyEquivalents -dict-add "Target Search Field" "@F"
}
ok "System adjustments applied! ☺️"


###############################################################################
# Kill affected applications                                                  #
###############################################################################

bot "OK. Note that some of these changes require a logout/restart to take effect. Killing affected applications (so they can reboot)...."

for app in "Activity Monitor" \
	"Address Book" \
	"Calendar" \
	"cfprefsd" \
	"Contacts" \
	"Dock" \
	"Finder" \
	"Google Chrome Canary" \
	"Google Chrome" \
	"Mail" \
	"Messages" \
	"Opera" \
	"Photos" \
	"Safari" \
	"SizeUp" \
	"Spectacle" \
	"SystemUIServer" \
	"Transmission" \
	"Tweetbot" \
	"Twitter" \
	"iCal"; do
	killall "${app}" &> /dev/null
done

# Wait a bit before moving on...
sleep 1

ok

# ...and then.
bot "Woot! All done. Kill this terminal and launch iTerm"


###############################################################################
bot "Reboot"
###############################################################################

# See if the user wants to reboot.
function reboot() {
  read -p "Do you want to reboot your computer now? (y/N)" choice
  case "$choice" in
    y | Yes | yes ) echo "Yes"; exit;; # If y | yes, reboot
    n | N | No | no) echo "No"; exit;; # If n | no, exit
    * ) echo "Invalid answer. Enter \"y/yes\" or \"N/no\"" && return;;
  esac
}

# Call on the function
if [[ "Yes" == $(reboot) ]]
then
  echo "Rebooting."
  sudo reboot
  exit 0
else
  exit 1
fi
