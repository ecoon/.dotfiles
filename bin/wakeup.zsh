#!/bin/zsh

echo "running (keyboard_remap.zsh) in wakeup.zsh at:" >> ~/sleepwatcher.log
date >> ~/sleepwatcher.log

. ~/.dotfiles/zsh/system/keyboard_remap.zsh
echo "complete" >> ~/sleepwatcher.log

