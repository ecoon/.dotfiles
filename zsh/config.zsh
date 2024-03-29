export LSCOLORS="exfxcxdxbxegedabagacad"
export CLICOLOR=true
export EDITOR='emacsclient -n'
export fignore=(.o \~)

fpath=($ZSH/functions $fpath)

autoload -U $ZSH/functions/*(:t)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt NO_BG_NICE # don't nice background tasks
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt HIST_VERIFY
setopt SHARE_HISTORY # share history between sessions ???
setopt EXTENDED_HISTORY # add timestamps to history
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF
unsetopt CORRECT_ALL # turn off obnoxious autocorrect
unsetopt CORRECT # turn off obnoxious autocorrect

setopt APPEND_HISTORY # adds history
unsetopt INC_APPEND_HISTORY  # adds history incrementally (rather than on close)
unsetopt SHARE_HISTORY # turn off history sharing across tabs
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_REDUCE_BLANKS

setopt RM_STAR_SILENT
setopt +o NOMATCH
unsetopt AUTOPUSHD

# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
setopt complete_aliases

bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[5D' beginning-of-line
bindkey '^[[5C' end-of-line
bindkey '^[[3~' delete-char

# ORNL pem files
# export REQUESTS_CA_BUNDLE=/Library/Application\ Support/Netskope/STAgent/data/nscacert.pem
# export SSL_CERT_DIR=/Library/Application\ Support/Netskope/STAgent/data/
# export SSL_CERT_FILE=/Library/Application\ Support/Netskope/STAgent/data/nscacert.pem
