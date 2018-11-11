############################################################################
#### Homebrew Caveats

## ==> ncurses (zsh)

# ncurses is keg-only, which means it was not symlinked into /usr/local,
# because macOS already provides this software and installing another version in
# parallel can cause all kinds of trouble.

# If you need to have ncurses first in your PATH run:
#   echo 'export PATH="/usr/local/opt/ncurses/bin:$PATH"' >> ~/.zshrc

# For compilers to find ncurses you may need to set:
#   export LDFLAGS="-L/usr/local/opt/ncurses/lib"
#   export CPPFLAGS="-I/usr/local/opt/ncurses/include"


# ==> fzf
# To install useful keybindings and fuzzy completion:
#   /usr/local/opt/fzf/install

# To use fzf in Vim, add the following line to your .vimrc:
#  set rtp+=/usr/local/opt/fzf


## ==> zsh-completions
# To activate these completions, add the following to your .zshrc:
fpath=(/usr/local/share/zsh-completions $fpath)

# You may also need to force rebuild `zcompdump`:
#   rm -f ~/.zcompdump; compinit

# Additionally, if you receive "zsh compinit: insecure directories" warnings when attempting
# to load these completions, you may need to run this:
#   chmod go-w '/usr/local/share'


## ==> zsh-syntax-highlighting
# To activate the syntax highlighting, add the following at the end of your .zshrc:
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# If you receive "highlighters directory not found" error message,
# you may need to add the following to your .zshenv:
#   export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters


# ==> gettext (git)
# gettext is keg-only, which means it was not symlinked into /usr/local,
# because macOS provides the BSD gettext library & some software gets confused if both are in the library path.

# If you need to have gettext first in your PATH run:
#   echo 'export PATH="/usr/local/opt/gettext/bin:$PATH"' >> ~/.zshrc

# For compilers to find gettext you may need to set:
#   export LDFLAGS="-L/usr/local/opt/gettext/lib"
#   export CPPFLAGS="-I/usr/local/opt/gettext/include"


# ==> git
# Bash completion has been installed to:
#   /usr/local/etc/bash_completion.d

# zsh completions and functions have been installed to:
#   /usr/local/share/zsh/site-functions

# Emacs Lisp files have been installed to:
#   /usr/local/share/emacs/site-lisp/git


# ==> gnu-getopt (git-flow-avh)
# gnu-getopt is keg-only, which means it was not symlinked into /usr/local,
# because macOS already provides this software and installing another version in
# parallel can cause all kinds of trouble.

# If you need to have gnu-getopt first in your PATH run:
#   echo 'export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"' >> ~/.zshrc


# ==> git-flow-avh
# Bash completion has been installed to:
#   /usr/local/etc/bash_completion.d

# zsh functions have been installed to:
#   /usr/local/share/zsh/site-functions


# ==> libtool (graphicsmagick)
# In order to prevent conflicts with Apple's own libtool we have prepended a "g"
# so, you have instead: glibtool and glibtoolize.


# ==> mas
# Bash completion has been installed to:
#   /usr/local/etc/bash_completion.d
