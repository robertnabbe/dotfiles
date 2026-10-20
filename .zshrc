# ==============================
# Antigen
# ==============================

# Load Antigen
# You can find the installation location with `brew ls antigen`
# If silicon chip:
source /opt/homebrew/Cellar/antigen/2.2.3/share/antigen/antigen.zsh

# Bootstrap
antigen use oh-my-zsh

# Plugins
antigen bundle osx
antigen bundle brew
antigen bundle git
antigen bundle zsh-users/zsh-syntax-highlighting
# antigen bundle mafredri/zsh-async

# Load the theme
antigen theme robbyrussell

# Start
antigen apply

# ==============================
# Exports
# ==============================

# PATH
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/opt/coreutils/libexec/gnubin:$PATH

# MANPATH
# If silicon chip:
export MANPATH="/opt/homebrew/Cellar/coreutils/libexec/gnuman:$MANPATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
export MANPATH="/opt/homebrew/Cellar/coreutils/libexec/gnuman:$MANPATH"

# NVM PATH
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Default editor
export EDITOR=nvim

# Homebrew
# If silicon chip:
export PATH=/opt/homebrew/bin:$PATH
export PATH=/usr/local/sbin:$PATH

# Composer
# export PATH=$PATH:$HOME/.composer/vendor/bin

# Previous MySQL version
# If silicon chip: export PATH="/opt/homebrew/Cellar/mysql@5.7/bin:$PATH"
# export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
# export PATH="/opt/homebrew/Cellar/mysql@5.7/bin:$PATH"

# export PATH="/opt/homebrew/opt/php@7.4/bin:$PATH"
# export PATH="/opt/homebrew/opt/php@7.4/sbin:$PATH"
# export PATH="/opt/homebrew/sbin:$PATH"

# ==============================
# Aliases
# ==============================

# git
alias gcln='git clean -fd'
alias gbsc='git branch --show-current | pbcopy'

# Show/hide hidden files in Finder
alias show='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hide='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'

# File operations
alias mv='mv -v'
alias rm='rm -i -v'
alias cp='cp -v'

# Lists
alias l="ls -laF -G"
alias ls="gls -AFh --color --group-directories-first"

# Always enable colored `grep` output
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Clear log files
alias clearlog='sudo rm -rf /var/log/asl/*.asl'

# Update antigen
alias antup='antigen update; antigen cleanup'

# Update fast-moving brew casks
alias brewup='brew upgrade claude-code@latest gh nvim'

# Clear antigen cache
alias antreset='rm ~/.antigen/init.zsh'

# Recursively delete `.DS_Store` files
alias cleanup_dsstore="find . -name '*.DS_Store' -type f -ls -delete"

# AWS nonsense
export AWS_SDK_LOG_LEVEL=warn
export PATH="$HOME/.local/bin:$PATH"

# itermocil/window configs 
source ~/.zsh_chiroup

# source functions file
source ~/.zshfuncs

