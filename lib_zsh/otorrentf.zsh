export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH=$HOME/bin:/usr/local/bin:$PATH
# export PATH=/bin:/usr/bin:/usr/local/bin:${PATH} # Not working

# export PATH="$PATH:$HOME/.rvm/gems/ruby-2.0.0-p648/bin" # Add RVM to PATH for scripting
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export PATH="$PATH:$HOME/.node/bin"

############################################################################
#### Load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


############################################################################
#### Fix for Powerline fonts seems to have issues with locale:
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8


############################################################################
#### CONFIG for Jira ZSH plugin
JIRA_URL=https://jira.unic.com
JIRA_NAME=oriol.torrent
JIRA_PREFIX=KPTVPK-


############################################################################
DEFAULT_USER=otorrentf
EDITOR=code


############################################################################
# Avoid Node Error: EMFILE, too many open files
# default value: 256
ulimit -n 1024


############################################################################
# POWERLEVEL9K_MODE='awesome-patched'
POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"
POWERLEVEL9K_STATUS_VERBOSE=false
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status os_icon load context dir vcs)
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs)
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time node_version rbenv)
POWERLEVEL9K_PROMPT_ON_NEWLINE=true


############################################################################
# More npm alias
alias npmtop="npm list -g --depth=0"
alias ls='ls -FGahl'


############################################################################
# More git alias
# http://nakkaya.com/2009/09/24/git-delete-last-commit/
alias gdellastcommit="git reset --soft HEAD~1"
alias gdellastcommitandchanges="git reset --hard HEAD~1"
alias gdellastpushed="git revert HEAD"

alias gShowMergedLocalBranches="git branch --merged"
alias gShowNotMergedLocalBranches="gbnm"
alias gDelMergedLocalBranches="gbda"

alias gShowMergedRemoteBranches="git branch -r --merged origin/develop"
alias gShowNotMergedRemoteBranches="git branch -r --no-merged origin/develop"

gfindByMessage () {
	git log --decorate --all --grep="$@"
}


############################################################################
# Frontend @Unic
# alias g="gulp --dev --interactive=false"
alias g="node_modules/gulp/bin/gulp.js --dev --interactive=false --local --skipTests"
alias gni="node_modules/gulp/bin/gulp.js --dev --interactive=false --local --skipHtmlDependencyGraph --skipTests"
alias gb="node_modules/gulp/bin/gulp.js build"
alias gc="node_modules/gulp/bin/gulp.js clean"
alias npmclean="rm -rf node_modules && npm cache clean && nvm use && npm i"
alias getsetup="curl 'https://gist.githubusercontent.com/orioltf/c3b1a7821fcdf656737a/raw/55259181712220e1c0f4c3434530ff8ef9ec83d4/setup.sh' > setup.sh && chmod 754 setup.sh"
# alias m="bundle exec middleman"
# alias mb="bundle exec middleman build"
# alias mi="bundle install"


############################################################################
# Fix for SourceTree Commanline tools installation fail:
# https://jira.atlassian.com/browse/SRCTREE-3172
alias stree='/Applications/SourceTree.app/Contents/Resources/stree'

# Get readable list of network IPs
alias ips="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
alias flush="dscacheutil -flushcache" # Flush DNS cache

# alias gzip="gzip -9n" # set strongest compression level as ‘default’ for gzip
# alias ping="ping -c 5" # ping 5 times ‘by default’
alias ql="qlmanage -p 2>/dev/null" # preview a file using QuickLook

# Start server on directory
alias pserver="python -m SimpleHTTPServer 8000"
alias rserver="ruby -run -e httpd . -p 8000"

# Show hidden files
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
# Hide hidden files
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'

# Edit Bash Profile
alias edit_profile='$EDITOR ~/.zshrc'

# Reload Bash Profil after editing
# alias reload_profile='source ~/.zshrc'
# Changed because of https://github.com/robbyrussell/oh-my-zsh/issues/5243#issuecomment-256438747
alias reload_profile='exec zsh'

# Clean up LaunchServices to remove duplicates in the “Open With” menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"


############################################################################
# Highlight Code (that was copied to the clipboard before)
alias highlight_css='pbpaste | highlight --syntax=css -O rtf --font-size 18 --style solarized-dark -W -J 80 -j 3 | pbcopy'
alias highlight_css_ln='pbpaste | highlight --syntax=css -O rtf --line-numbers --font-size 18 --style solarized-dark -W -J 80 -j 3 | pbcopy'
alias highlight_html='pbpaste | highlight --syntax=html -O rtf --font-size 18 --style solarized-dark -W -J 80 -j 3 | pbcopy'
alias highlight_html_ln='pbpaste | highlight --syntax=html -O rtf --line-numbers --font-size 18 --style solarized-dark -W -J 80 -j 3 | pbcopy'
alias highlight_js='pbpaste | highlight --syntax=js -O rtf --font-size 18 --style solarized-dark -W -J 80 -j 3 | pbcopy'
alias highlight_js_ln='pbpaste | highlight --syntax=js -O rtf --line-numbers --font-size 18 --style solarized-dark -W -J 80 -j 3 | pbcopy'


############################################################################
# Open a man page in Preview:
pman () {
	man -t "${1}" | open -f -a /Applications/Preview.app
	# Use "man -t $@..." instead to specify manual sections
}

# Open a man page in Preview using ps2pdf:
pman2 () {
	man -t $* | ps2pdf - - | open -g -f -a /Applications/Preview.app
}

# Open a man page in Atom:
aman () {
	man "${1}" | col -b | atom
}

# Create a new directory and enter it:
mkcd() {
	mkdir -p "$@" && cd "$@";
}

# Convert a file to a base64 string and copy the string to clipboard
b64() {
	openssl base64 < "${1}" | tr -d '\n' | pbcopy
}

function gc() {
	giturl=$(git config --get remote.origin.url)
	if [ "$giturl" = "" ]; then
		echo "Not a git repository or no remote.origin.url set"
	elif [[ "$giturl" = *"git@bitbucket"* ]]; then
		giturl=${giturl/git\@bitbucket\.org\:/https://bitbucket.org/}
		url=$giturl/branches/compare/$2\%0D$1
		open $url
	elif [[ "$giturl" = *"git.unic.com"* ]]; then
		url=$(echo $giturl| cut -d'@' -f 2)
		url=$(echo $url| cut -d'/' -f 1)
		project=$(echo $giturl| cut -d'/' -f 5)
		repo=$(echo $giturl| cut -d'/' -f 6)
		repo=$(echo $repo| cut -d'.' -f 1)
		url='https://'$url/projects/$project/repos/$repo/pull-requests?create\&sourceBranch=refs/heads/$1\&targetBranch=refs/heads/$2
		open $url
 	else
		giturl=${giturl/git\@github\.com\:/https://github.com/}
		giturl=${giturl/\.git/\/compare/}
		# branch="$(git symbolic-ref HEAD 2>/dev/null)" ||
		# branch="(unnamed branch)" # detached HEAD
		# branch=${branch##refs/heads/}
		giturl=$giturl/$1...$2
		open $giturl
	fi
}

function gh() {
	giturl=$(git config --get remote.origin.url)

	if [ "$giturl" = "" ]; then
		echo "Not a git repository or no remote.origin.url set"
		exit
	elif [[ "$giturl" = *"git@github"* ]]; then
		echo "Seems it is Github"
		giturl=${giturl/git\@github\.com\:/https://github.com/}
		branch="$(git symbolic-ref HEAD 2>/dev/null)" ||
		branch="(unnamed branch)" # detached HEAD
		branch=${branch##refs/heads/}
		if [ $# -eq 1 ]; then
			giturl=$giturl/commit/$1
		else
			giturl=$giturl/tree/$branch
		fi
		# open $giturl
		# echo $giturl
	elif [[ "$giturl" = *"git@bitbucket"* ]]; then
		echo "Seems it is Bitbucket"
		giturl=${giturl/git\@bitbucket\.org\:/https://bitbucket.org/}
		branch="$(git symbolic-ref HEAD 2>/dev/null)" ||
		branch="(unnamed branch)" # detached HEAD
		branch=${branch##refs/heads/}
		if [ $# -eq 1 ]; then
			giturl=$giturl/commits/$1
		else
			giturl=$giturl/src/?at=$branch
		fi
		# open $giturl
	elif [[ "$giturl" = *"git.unic.com"* ]]; then
		echo "Seems it is Unic"
		url=$(echo $giturl| cut -d'@' -f 2)
		url=$(echo $url| cut -d'/' -f 1)
		project=$(echo $giturl| cut -d'/' -f 5)
		repo=$(echo $giturl| cut -d'/' -f 6)
		repo=$(echo $repo| cut -d'.' -f 1)
		branch="$(git symbolic-ref HEAD 2>/dev/null)" ||
		branch="(unnamed branch)" # detached HEAD
		branch=${branch##refs/heads/}
		if [ $# -eq 1 ]; then
			giturl='https://'$url/projects/$project/repos/$repo/commits/$1
		else
			giturl='https://'$url/projects/$project/repos/$repo/browse?at=refs/heads/$branch
		fi
		# open $url
	else
		echo "Can't identify source: open remote.origin.url"
		# open giturl
	fi

	open $giturl
}
