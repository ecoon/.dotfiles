alias reload!='. ~/.zshrc'

alias rm='rm -i'
alias et='exit'
alias rmold='rm -f ./*~'
alias directory_hog='find $1 -type d | xargs du -sm | sort -g'

alias hpg='history | grep $1'

# ssh external from ORNL
alias sshout='ssh -o "ProxyCommand=corkscrew snowman.ornl.gov 3128 %h %p"'
alias scpout='scp -o "ProxyCommand=corkscrew snowman.ornl.gov 3128 %h %p"'
alias rsyncout='rsync -e "sshout"'

alias e='emacsclient -n'
alias mkd='take'

function findsrc() {
    find $1 -name \*.hh -print -o -name \*.cc -print
}

# custom cd
function cd() {
    new_directory="$*";
    if [ $# -eq 0 ]; then 
        new_directory=${HOME};
    fi;
    builtin cd "${new_directory}" && ls
}
compdef _gnu_generic cd



# useful functions for parsing ATS output
function showc() {
  grep "Cycle = ${1}" ${2} | head -n1
}
function lastc() {
  grep "Cycle = " ${1} | tail -n1
}

# timediff file1 file2 shows difference, in seconds, of file2 - file1
function timediff() {
  echo $((`gstat --format=%Y $2` - `gstat --format=%Y $1`))
}



