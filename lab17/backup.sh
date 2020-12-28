#!/bin/sh
export BORG_REPO='borg@192.168.11.150:/var/backup/client'
export BORG_PASSPHRASE='otus'
export PATH=$PATH:/usr/local/bin
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2;  logger -t [BACKUP] "$*"; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM
info "Starting backup"
borg create --verbose --filter AME --list --stats --show-rc --compression lz4 --exclude-caches $BORG_REPO::'{hostname}-{now:%Y-%m-%d_%H:%M:%S}' /etc
backup_exit=$?
info "Pruning repository"
borg prune --list --prefix '{hostname}-' --show-rc --keep-daily 90 --keep-monthly 12
prune_exit=$?
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
if [ ${global_exit} -eq 0 ]; then
    info "Backup and Prune finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup and/or Prune finished with warnings"
else
    info "Backup and/or Prune finished with errors"
fi
exit ${global_exit}