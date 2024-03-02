# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/uec/code/mambaforge/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/uec/code/mambaforge/etc/profile.d/conda.sh" ]; then
        . "/Users/uec/code/mambaforge/etc/profile.d/conda.sh"
    else
        export PATH="/Users/uec/code/mambaforge/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "/Users/uec/code/mambaforge/etc/profile.d/mamba.sh" ]; then
    . "/Users/uec/code/mambaforge/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

export REQUESTS_CA_BUNDLE=/etc/ssl/cert.pem
