rsync -a -e 'ssh -p 22' --exclude-from=~/.dotfiles/backup/exclude.txt ~/comms ~/admin ~/research ~/.dotfiles ~/code ecoon@BC-backup.local::ORNL_Mac/
