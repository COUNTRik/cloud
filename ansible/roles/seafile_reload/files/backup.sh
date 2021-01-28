#!/bin/bash

#####
# Uncomment the following line if you rather want to run the script manually.
# Display usage if the script is not run as root user
#        if [[ $USER != "root" ]]; then
#                echo "This script must be run as root user!"
#                exit 1
#        fi
#
# echo "Super User detected!!"
# read -p "Press [ENTER] to start the procedure, this will stop the seafile server!!"
#####

DBUSER="seafile"
DBPASSWORD="seafile"
DBHOST="localhost"
DBPORT="3306"
DBPROT="tcp"
DBBACKUPDIR="/mnt/backup/"
# DBARCHDIR="/backup/"
DBCCNET="ccnet_db"
DBSEAFILE="seafile_db"
DBSEAHUB="seahub_db"
DATABACKUPDIR="/mnt/backup/"
DATADIR="/opt/seafile/seafile-data"

log(){
   message="$(date +"%y-%m-%d %T") $@"
   echo $message
}

log "------------------------------------------"
log "Mount NFS backup"

# mount NFS
ls /mnt/backup

# stop the server
log "------------------------------------------"
log "Starting maintenance procedure for seafile"
log "Stopping the seafile-server"
systemctl stop seafile.service
systemctl stop seahub.service

log "Giving the server some time to shut down properly"
sleep 20

# run the cleanup
log "Seafile cleanup started"
/opt/seafile/seafile-server-latest/seaf-gc.sh -r
/opt/seafile/seafile-server-latest/seaf-gc.sh
log "Seafile cleanup done!"
log "Giving the server some time"
sleep 10

# backup databases
log "Starting databases backup"
# rm ${DBARCHDIR}*.bz2
# mv ${DBBACKUPDIR}*.bz2 ${DBARCHDIR}

DBDATE=`date +"%Y-%m-%d"`
mysqldump -h ${DBHOST} -u${DBUSER} -p${DBPASSWORD} --protocol=${DBPROT} --port=${DBPORT} --opt ${DBCCNET} > ${DBBACKUPDIR}${DBDATE}.${DBCCNET}.sql
# bzip2 ${DBBACKUPDIR}${DBCCNET}.sql.${DBDATE}

DBDATE=`date +"%Y-%m-%d"`
mysqldump -h ${DBHOST} -u${DBUSER} -p${DBPASSWORD} --protocol=${DBPROT} --port=${DBPORT} --opt ${DBSEAFILE} > ${DBBACKUPDIR}${DBDATE}.${DBSEAFILE}.sql
# bzip2 ${DBBACKUPDIR}${DBSEAFILE}.sql.${DBDATE}

DBDATE=`date +"%Y-%m-%d"`
mysqldump -h ${DBHOST} -u${DBUSER} -p${DBPASSWORD} --protocol=${DBPROT} --port=${DBPORT} --opt ${DBSEAHUB} > ${DBBACKUPDIR}${DBDATE}.${DBSEAHUB}.sql
# bzip2 ${DBBACKUPDIR}${DBSEAHUB}.sql.${DBDATE}

# backup data
log "Starting data backup"
FILEDATE=`date +"%Y-%m-%d"`
mkdir ${DATABACKUPDIR}${FILEDATE}
cp -R ${DATADIR} ${DATABACKUPDIR}${FILEDATE}

# start the server again
log "Starting the Seafile-Server"
systemctl start seafile.service
systemctl start seahub.service

log "Seafile maintenance procedure complete!"