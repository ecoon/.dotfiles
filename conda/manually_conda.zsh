__conda_setup="$('/Users/Shared/ornldev/code/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/Shared/ornldev/code/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/Shared/ornldev/code/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/Shared/ornldev/code/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

conda activate default
