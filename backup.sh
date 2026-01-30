#!/bin/bash

set -eu

source util.sh

TIMESTAMP=$(date +%Y-%m-%d-%H%M)
GHOST_DIR="/var/www/ghost/"
GHOST_MYSQL_BACKUP_FILENAME="backup-from-mysql-$TIMESTAMP.sql.gz"
GHOST_CONTENT_BACKUP_FILENAME="content-$TIMESTAMP.tar.gz"
REMOTE_BACKUP_LOCATION="cmcg-backup/"
BACKUP_TAR_FILENAME="backup-$TIMESTAMP.tar"

# MySQL connection variables in global scope
mysql_host=""
mysql_user=""
mysql_password=""
mysql_database=""

# run checks
pre_backup_checks() {
    if [ ! -d "$GHOST_DIR" ]; then
        log "Ghost directory does not exist"
        exit 1
    fi

    log "Running pre-backup checks"
    cd $GHOST_DIR

    cli=("expect" "gzip" "mysql" "mysqldump" "ghost" "rclone" "tar")
    for c in "${cli[@]}"; do
        check_command_installation "$c"
    done
    # check_ghost_status
}

# backup Ghost content folder
backup_ghost_content() {
    log "Running content backup..."
    cd $GHOST_DIR

    # expect wraith.exp
    tar -czf $GHOST_CONTENT_BACKUP_FILENAME content
}

# check MySQL connection
check_mysql_connection() {
    log "Checking MySQL connection..."
    if ! mysql -h"$mysql_host" -u"$mysql_user" -p"$mysql_password" -e ";" &>/dev/null; then
        log "Could not connect to MySQL"
        exit 1
    fi
    log "MySQL connection OK"
}

# backup MySQL database
backup_mysql() {
    log "Backing up MySQL database..."
    cd $GHOST_DIR

    mysql_host=$(ghost config get database.connection.host | tail -n1)
    mysql_user=$(ghost config get database.connection.user | tail -n1)
    mysql_password=$(ghost config get database.connection.password | tail -n1)
    mysql_database=$(ghost config get database.connection.database | tail -n1)

    check_mysql_connection

    log "Dumping MySQL database..."
    mysqldump -h"$mysql_host" -u"$mysql_user" -p"$mysql_password" "$mysql_database" --no-tablespaces | gzip >"$GHOST_MYSQL_BACKUP_FILENAME"
}

# `rclone` backup
# assumes that `rclone config` is configured
rclone_to_cloud_storage() {
    log "Rclone backup..."
    cd $GHOST_DIR

    rclone_remote_name="remote" # TODO: parse from config or prompt

    tar -cf $BACKUP_TAR_FILENAME $GHOST_CONTENT_BACKUP_FILENAME $GHOST_MYSQL_BACKUP_FILENAME

    # rclone copy backup-from-*-on-*.zip "$rclone_remote_name:$REMOTE_BACKUP_LOCATION"
    # rclone copy "$GHOST_MYSQL_BACKUP_FILENAME" "$rclone_remote_name:$REMOTE_BACKUP_LOCATION"
    rclone copy $BACKUP_TAR_FILENAME "$rclone_remote_name:$REMOTE_BACKUP_LOCATION"
}

# clean up old backups
clean_up() {
    log "Cleaning up backups..."
    cd $GHOST_DIR

    rm -rf backup/
    rm -f "$GHOST_CONTENT_BACKUP_FILENAME"
    rm -f "$GHOST_MYSQL_BACKUP_FILENAME"
    rm -f "$BACKUP_TAR_FILENAME"
}

# main entrypoint of the script
main() {
    log "Welcome to wraith"

    # Ensure cleanup runs on exit, error, or interrupt
    trap clean_up EXIT

    pre_backup_checks
    clean_up
    backup_ghost_content
    backup_mysql
    rclone_to_cloud_storage
    clean_up
    log "Completed backup to $REMOTE_BACKUP_LOCATION"
}

main
