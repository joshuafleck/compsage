#!/bin/bash

#ensure we received the proper number of arguments
if [ ! $# == 3 ]; then
  echo "Usage: $0 <environment: production|staging> <backup level: 0|1|2> <primary partition: sda1|xvda>"
  exit 1
fi

#don't run the backup if we are running out of disk
USAGE_PERCENT=`df -h | grep $3 | awk '{ print $5 }' | cut -d'%' -f1`
if [ $USAGE_PERCENT -ge 90 ]; then 
  echo "Disk usage exceeding 90% on partition: $3, backup failed" >&2
  exit 1
else
  echo "Disk usage is $USAGE_PERCENT% on partition: $3"
fi

#backup commands and constants
TAR="tar -czPf"
RSYNC="rsync -avz"
TIMESTAMP=`date +"%m%d%H%M%S"`
GEM_LIST="gem list"
PACKAGE_LIST="dpkg --get-selections"
ENVIRONMENT=$1
PRODUCTION="production"
BACKUP_LEVEL=$2
PRODUCTION_SERVER=compsage.com
STAGING_SERVER=dev.huminsight.com
COMPSAGE_MYSQL_USERNAME=`cat /var/www/compsage/shared/config-files/database.yml | awk '/username/ {print $2}'`
COMPSAGE_MYSQL_PASSWORD=`cat /var/www/compsage/shared/config-files/database.yml | awk '/password/ {print $2}'`
COMPSAGE_MYSQL_EXPORT="mysqldump -u$COMPSAGE_MYSQL_USERNAME -p$COMPSAGE_MYSQL_PASSWORD compsage_$ENVIRONMENT"
REDMINE_MYSQL_EXPORT="mysqldump -uroot redmine"

#backed-up directories
APACHE_DIR=/etc/apache2
POSTFIX_DIR=/etc/postfix
LOGOS_DIR=/var/www/compsage/shared/logos
CONFIG_DIR=/var/www/compsage/shared/config-files
REDMINE_ATTACHMENTS_DIR=/var/www/redmine/files
INTEGRITY_DIR=/var/www/integrity

#backup store locations and filenames
BACKUP_BASE=/home/deploy/backups/compsage
BACKUP_STORE=$BACKUP_BASE/$ENVIRONMENT
LOGOS_FILE=$BACKUP_STORE/logos_$TIMESTAMP.tgz
APACHE_FILE=$BACKUP_STORE/apache_$TIMESTAMP.tgz
POSTFIX_FILE=$BACKUP_STORE/postfix_$TIMESTAMP.tgz
LOGOS_FILE=$BACKUP_STORE/logos_$TIMESTAMP.tgz
GEM_LIST_FILE=$BACKUP_STORE/gem-list_$TIMESTAMP.gz
PACKAGE_LIST_FILE=$BACKUP_STORE/package-list_$TIMESTAMP.gz
CONFIG_FILE=$BACKUP_STORE/config_$TIMESTAMP.tgz
COMPSAGE_DB_FILE=$BACKUP_STORE/compsage-$ENVIRONMENT-db_$TIMESTAMP.gz
REDMINE_DB_FILE=$BACKUP_STORE/redmine-db_$TIMESTAMP.gz
REDMINE_ATTACHMENTS_FILE=$BACKUP_STORE/redmine-attachments_$TIMESTAMP.tgz
INTEGRITY_FILE=$BACKUP_STORE/integrity_$TIMESTAMP.tgz

#Remove any archives older than X days
echo "Removing archives older than 30 days"
find $BACKUP_BASE -type f -mtime +30 -exec rm {} \;

#Perform local backup
if [ $BACKUP_LEVEL == 0 ]; then

  if [ $ENVIRONMENT == $PRODUCTION ]; then

    echo "Backing up compsage production mysql database"
    $COMPSAGE_MYSQL_EXPORT | gzip > $COMPSAGE_DB_FILE

  else

    echo "Nothing to backup for staging environment"

  fi

elif [ $BACKUP_LEVEL == 1 ]; then

  if [ $ENVIRONMENT == $PRODUCTION ]; then

    echo "Backing up production logos"
    $TAR $LOGOS_FILE $LOGOS_DIR

  else

    echo "Backing up redmine files and database in staging environment"
    $REDMINE_MYSQL_EXPORT | gzip > $REDMINE_DB_FILE
    $TAR $REDMINE_ATTACHMENTS_FILE $REDMINE_ATTACHMENTS_DIR

  fi

elif [ $BACKUP_LEVEL == 2 ]; then

  echo "Backing up configuration files in staging or production environment"
  $TAR $APACHE_FILE $APACHE_DIR
  $TAR $POSTFIX_FILE $POSTFIX_DIR
  $TAR $CONFIG_FILE $CONFIG_DIR
  $GEM_LIST | gzip > $GEM_LIST_FILE
  $PACKAGE_LIST | gzip > $PACKAGE_LIST_FILE

  if [ $ENVIRONMENT == $PRODUCTION ]; then

    echo "Nothing production-specific to back up"

  else

    echo "Backing up integrity files in staging environment"
    $TAR $INTEGRITY_FILE $INTEGRITY_DIR --exclude $INTEGRITY_DIR/builds

  fi

else

  echo "Error, unknown backup level: $BACKUP_LEVEL" >&2
  exit 1

fi

#Copy backup to remote server
if [ $ENVIRONMENT == $PRODUCTION ]; then

  echo "Moving production backups to remote server"
  $RSYNC $BACKUP_STORE/ $STAGING_SERVER:$BACKUP_STORE/

else

  echo "Moving staging backups to remote server"
  $RSYNC $BACKUP_STORE/ $PRODUCTION_SERVER:$BACKUP_STORE/

fi
