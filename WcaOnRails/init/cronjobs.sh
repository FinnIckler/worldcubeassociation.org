#!/bin/bash

# Define variables
SECRETS_FOLDER=${REPO_ROOT}/secrets
DB_DUMP_FOLDER=${SECRETS_FOLDER}/wca_db

# Define commands
DUMP_DB_COMMAND=${REPO_ROOT}/scripts/db.sh dump "${DB_DUMP_FOLDER}"
DUMP_GH_COMMAND="github-backup --incremental --fork --private --all -t <GITHUB_BACKUP_ACCESS_TOKEN> --organization thewca -o ${SECRETS_FOLDER}/github-thewca"
BACKUP_COMMAND="${DUMP_DB_COMMAND} && ${DUMP_GH_COMMAND}"
if [ "$NODE_ENV" = "production" ]; then
  BACKUP_COMMAND+=" && ${REPO_ROOT}/scripts/backup.sh"
fi
BACKUP_COMMAND="( ${BACKUP_COMMAND} ) >/tmp/cron-backup.log 2>&1 || (echo 'FAILURE of the backup script, see below for the error log:'; cat /tmp/cron-backup.log)"

# Define cron jobs
(crontab -l ; echo "0 0 * * 1 ${BACKUP_COMMAND}") | crontab -
(crontab -l ; echo "0 * * * * cd ${REPO_ROOT}/WcaOnRails && RACK_ENV=production bin/rake work:schedule") | crontab -
(crontab -l ; echo "0 4 * * * ${REPO_ROOT}/scripts/cronned_results_scripts.sh") | crontab -
(crontab -l ; echo "0 5 * * 1,3,6 cd ${REPO_ROOT}/WcaOnRails && RACK_ENV=production bin/rake tmp:cache:clear") | crontab -
(crontab -l ; echo "0 8 23 * * cd ${REPO_ROOT}/WcaOnRails && RACK_ENV=production bin/rake chores:generate") | crontab -
