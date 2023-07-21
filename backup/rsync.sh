rsync -avhrm --progress -e 'ssh -p 22'  --filter="merge /Users/uec/.dotfiles/backup/filter1.txt" ~/ ecoon@BC-backup.local::ORNL_Mac/ &> rsync1-`date "+%F-%T"`.log
rsync -avhrm --progress -e 'ssh -p 22' --filter="merge /Users/uec/.dotfiles/backup/filter2.txt" /Users/Shared/ornldev/code/ ecoon@BC-backup.local::ORNL_Mac_code/ &> rsync2-`date "+%F-%T"`.log
