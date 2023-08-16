export VISUAL='vim'
export EDITOR='vim'

# Base config
setopt long_list_jobs       # list jobs in the long format by default
setopt auto_resume          # Attempt to resume existing job before creating a new process.
setopt notify               # Report status of background jobs immediately.
unsetopt bg_nice            # Don't run all background jobs at a lower priority.
unsetopt hup                # Don't kill jobs on shell exit.
setopt nolistbeep           # don't beep on ambiguous completion \o/
setopt no_beep              # don't beep on error
setopt interactive_comments # Allow comments even in interactive shells
setopt multios              # Perform implicit tees or cats when multiple redirections are attempted, see http://zsh.sourceforge.net/Doc/Release/Options.html#index-MULTIOS
setopt extended_glob        # Treat the ‘#’, ‘~’ and ‘^’ characters as part of patterns for filename generation, etc. (An initial unquoted ‘~’ always produces named directory expansion.)
setopt auto_pushd           # Make cd push the old directory onto the directory stack.
setopt pushd_ignore_dups    # don't push multiple copies of the same directory onto the directory stack
setopt pushdminus           # Reverts the +/- operators (for cd +<TAB> and cd -<TAB>)
setopt auto_cd              # If you type foo, and it isn't a command, and it is a directory in your cdpath, go there
setopt cdable_vars          # cd to named dirs without ~ at beginning

# Installs
mkdir -p "$HOME/.zsh"
mkdir -p "$HOME/.zsh/zsh-plugins"

if [[ ! -d "$HOME/.zsh/spaceship" ]]; then
    git clone --depth=1 https://github.com/spaceship-prompt/spaceship-prompt.git "$HOME/.zsh/spaceship"
fi
source "$HOME/.zsh/spaceship/spaceship.zsh"

if [[ ! -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.zsh/zsh-autosuggestions"
fi
source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"

if [[ ! -f "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh/zsh-syntax-highlighting"
fi
source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

if [[ ! -d "$HOME/.vim" ]]; then
    git clone https://github.com/morhetz/gruvbox.git "$HOME/.vim/pack/default/start/gruvbox"
fi

if [[ ! -x /usr/local/bin/exa ]]; then
    wget https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip -O ~/exa.zip; unzip -d ~/exa ~/exa.zip; rm ~/exa.zip;
    sudo mv ~/exa/bin/exa /usr/local/bin;
    sudo chown codespace:codespace /usr/local/bin/exa;
    rm -rf ~/exa;
fi

# History
if [ -z "$HISTFILE" ]; then
    HISTFILE=$HOME/.zsh/zsh-history
fi

HISTSIZE=10000
SAVEHIST=10000

# Show history
case $HIST_STAMPS in
  "mm/dd/yyyy") alias history='fc -fl 1' ;;
  "dd.mm.yyyy") alias history='fc -El 1' ;;
  "yyyy-mm-dd") alias history='fc -il 1' ;;
  *) alias history='fc -l 1' ;;
esac

setopt append_history         # append to history file, rather than replace it on new session
setopt extended_history       # save each command’s beginning timestamp (in seconds since the epoch) and the duration (in seconds) to the history file.
setopt hist_expire_dups_first # if the internal history needs to be trimmed to add the current command line, setting this option will cause the oldest history event that has a duplicate to be lost before losing a unique event from the list.
setopt hist_ignore_dups       # ignore duplication command history list
setopt hist_ignore_space      # remove command lines from the history list when the first character on the line is a space,
setopt hist_verify            # whenever the user enters a line with history expansion, don’t execute the line directly; instead, perform history expansion and reload the line into the editing buffer.
setopt inc_append_history     # new history lines are added to the $HISTFILE incrementally as soon as they are entered
setopt share_history          # share command history data

# Completions
ZSH_COMPDUMP="$HOME/.zsh/cache/zsh-completion-dump"

if [[ -d ~/.zsh/cache/zsh-completions ]]; then
    fpath=(~/.zsh/cache/zsh-completions $fpath)
fi

autoload -U compinit colors
compinit -i -d "${ZSH_COMPDUMP}"
colors

unsetopt flowcontrol     # output flow control via start/stop characters (usually assigned to ^S/^Q) is disabled in the shell’s editor
setopt menu_complete     # autoselect the first completion entry
setopt auto_menu         # show completion menu on succesive tab press
setopt complete_in_word  # allow completion in word
setopt always_to_end     # if a completion is performed with the cursor within a word, and a full completion is inserted, the cursor is moved to the end of the word

WORDCHARS='*?_[]~=&;!#$%^(){}<>'

zmodload -i zsh/complist

# SSH/SCP/RSYNC
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-order hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'
zstyle ':completion:*:(ssh|scp|rsync):*:users' ignored-patterns '*' # Don't complete users on SSH/SCP/RSYNC

# Case-sensitive (all), partial-word, and then substring completion.
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
setopt CASE_GLOB

# Group matches and describe.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Fuzzy match mistyped completions.
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Increase the number of errors based on the length of the typed word.
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'

# Don't complete unavailable commands.
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

# Array completion element sorting.
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# https://misc.flogisoft.com/bash/tip_colors_and_formatting
zstyle ':completion:*'                 list-colors 'di=94' 'ln=35' 'so=32' 'ex=92' 'bd=46;34' 'cd=43;34'
zstyle ':completion:*:commands'        list-colors '=*=32'
zstyle ':completion:*:builtins'        list-colors '=*=34'
zstyle ':completion:*:functions'       list-colors '=*=31'
zstyle ':completion:*:aliases'         list-colors '=*=32'
zstyle ':completion:*:parameters'      list-colors '=*=33'
zstyle ':completion:*:reserved-words'  list-colors '=*=31'
zstyle ':completion:*:manuals*'        list-colors '=*=36'
zstyle ':completion:*:options'         list-colors '=^(-- *)=1;34'

zstyle ':completion:*:*:kill:*'                    list-colors '=(#b) #([0-9]#)*( *[a-z])*=34=31=33'
zstyle ':completion:*:*:killall:*:processes-names' list-colors '=(#b) #([0-9]#)*=0=01;31'

zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*' squeeze-slashes true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Environmental Variables
zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}

# Populate hostname completion.
zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${=${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
  ${=${(f)"$(cat /etc/hosts(|)grep -v ".dev\|.test\|^#"(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# Don't complete parameters...
zstyle ':completion:*:*:*:parameters' ignored-patterns '*'

# Don't complete uninteresting commands...
zstyle ':completion:*:complete:-command-::commands' ignored-patterns gpu-manager ngettext serialver servertool

# Don't complete uninteresting users...
zstyle ':completion:*:*:*:users' ignored-patterns \
  adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
  dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
  hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
  mailman mailnull mldonkey mysql nagios \
  named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
  operator pcap postfix postgres privoxy pulse pvm quagga radvd \
  rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

# Ignore multiple entries.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Files types completions
zstyle ':completion:*:*:php:*'    file-patterns '*.(#i)php:php(-.) *(-/):directories' '*:all-files'
zstyle ':completion:*:*:perl:*'   file-patterns '*.(#i)pl:perl(-.) *(-/):directories' '*:all-files'
zstyle ':completion:*:*:python:*' file-patterns '*.(#i)py:python(-.) *(-/):directories' '*:all-files'
zstyle ':completion:*:*:ruby:*'   file-patterns '*.(#i)rb:ruby(-.) *(-/):directories' '*:all-files'
zstyle ':completion:*:*:mpv:*'    file-patterns '*.(#i)(avi|mkv|mp4|flac|m4a):medias(-.) *(-/):directories' '*:all-files'
zstyle ':completion:*:*:pinta:*'  file-patterns '*.(#i)(jpg|png|gif):images(-.) *(-/):directories' '*:all-files'
zstyle ':completion:*:*:wine:*'   file-patterns '*.(#i)exe:exe(-.) *(-/):directories' '*:all-files'

# Ignored patterns
zstyle ':completion:*:*:(subl|vim|nvim|vi|emacs|nano|e|v|s):*:*files' ignored-patterns '*.(#i)(wav|mp3|flac|ogg|mp4|avi|mkv|webm|iso|dmg|so|o|a|bin|exe|dll|pcap|7z|zip|tar|gz|bz2|rar|deb|pkg|gzip|pdf|mobi|epub|png|jpeg|jpg|gif)'

# Docker
alias dc='docker-compose'
alias dce='docker-compose exec'
alias dcb='docker-compose build'
alias dcu='docker-compose up'
alias dcd='docker-compose down'
alias dcud='docker-compose up -d'
alias dps='docker ps'

# Git
alias gs='git status'
alias gpr='git pull --rebase'
alias gprp='git pull --rebase && git push'
alias glo='git log --oneline --graph --decorate'
alias gd='git diff'
alias gpp='git pull && git push'
alias gc='git commit'
alias ga='git add'
alias gA='git add -A'
alias gcm='git commit -m'
alias gco='git checkout'
alias gb="git branch --sort=-committerdate"
alias gm="git merge"

alias ll='exa -al --group-directories-first --git'
alias lt='exa -lTlL=2 --group-directories-first --git'
alias lsa='exa -a'
alias ls='exa'
alias rmf='rm -rf'
alias nr='npm run'
alias nrw='npm run watch'

SPACESHIP_DOCKER_SHOW=false
SPACESHIP_NODE_SHOW=false
SPACESHIP_ASYNC_SHOW=false
SPACESHIP_PHP_SHOW=false
SPACESHIP_PACKAGE_SHOW=false
SPACESHIP_DIR_PREFIX=''
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=false
SPACESHIP_CHAR_SYMBOL='⇨  '
SPACESHIP_TIME_FORMAT='%T'
SPACESHIP_TIME_COLOR='208'
SPACESHIP_TIME_SHOW=false
SPACESHIP_EXEC_TIME_SHOW=false
SPACESHIP_DOCKER_SHOW=false
SPACESHIP_DOCKER_COMPOSE_SHOW=false
