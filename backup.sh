#!/bin/bash
#################
# Konfiguration #
#################

# Verzeichnis, das gesichert werden soll
source_dir="/docker"
# Verzeichnis, in dem die Backups gespeichert werden sollen
backup_dir="/backup"
# Aktuelles Datum und Uhrzeit
current_datetime=$(date +"%Y-%m-%d_%H-%M-%S")
# Initialer Name für das Backup-Archiv
backup_filename="${current_datetime}.tar"
# Füge den Dateinamen zusammen
backup_fullpath="${backup_dir}/${backup_filename}"
# Hostname
hostname=$(hostname)
# Upload Ziel
dest="docker_to_onedrive:/backup/$hostname"
# Behalte Backups x-Tage
keepdays="10"
# Array von Ordnern im $source_dir die gesichert werden sollen
declare -a containers=("ha" "mqtt" "netcup" "npm" "sponsorblock")


#########################
# Kopiere Verzeichnisse #
#########################

echo "> Erstelle Arbeitsverzeichnis ${backup_dir}/working"
mkdir -p "${backup_dir}/working"
# -p Create any missing intermediate pathname components

# Iteriere Array
for i in "${containers[@]}"
do
   echo "> Sichere ${backup_dir}/$i ..."
   cd /${source_dir}/"$i" || exit
   docker-compose down
   # Archiv, Rekursiv, Überschreibe neuere Dateien, Kopiere keine log Dateien, Quelle, Ziel
   rsync -avh --recursive --update --delete-after --exclude=*.log* /docker/"$i" /backup/working/"$i"
   docker-compose up -d
done


###################
# Erstelle Backup #
###################
echo "> Erstelle das Backup-Archiv ${backup_fullpath}"
tar -cpf "${backup_fullpath}" "/backup/working"

echo "> Komprimiere das Backup-Archiv"
gzip "${backup_fullpath}"
backup_fullpath="${backup_fullpath}.gz"


####################
# Lade Backup hoch #
####################

echo "Lösche alte Backups nach $keepdays Tagen"
find /backup -maxdepth 1 -mtime +$keepdays -type f -name '*.tar*' -exec rm -f {} \;

echo "> Rclone zu Onedrive"
/usr/bin/rclone sync --progress --update --contimeout 60s --timeout 300s --retries 3 --delete-after "${backup_fullpath}" "$dest"


############
# Optional #
############

# Entferne Ordner
# echo "Entferne working Ordner"
# rm -rf /backup/working


##########
# Fertig #
##########
echo "> Backup wurde erstellt: ${backup_fullpath}"