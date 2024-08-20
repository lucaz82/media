## Rclone Setup and Config

`sudo -v ; curl https://rclone.org/install.sh | sudo bash`

```
rclone config

n

name> docker_to_onedrive

Storage> 33

region> 1 Microsoft Cloud Global

Edit advanced config?
y) Yes
n) No (default)
y/n> n

Use web browser to automatically authenticate rclone with remote?
 * Say Y if the machine running rclone has a web browser you can use
 * Say N if running rclone on a (remote) machine without web browser access
If not sure try Y. If Y failed, try N.

y) Yes (default)
n) No
y/n> n

Option config_token.
For this to work, you will need rclone available on a machine that has
a web browser available.
For more help and alternate methods see: https://rclone.org/remote_setup/
Execute the following on the machine with the web browser (same rclone
version recommended):
        rclone authorize "onedrive"
Then paste the result.
Enter a value.
config_token> { xxx }

Option config_type.
Type of connection
Choose a number from below, or type in an existing value of type string.
Press Enter for the default (onedrive).
 1 / OneDrive Personal or Business
config_type> 1

Option config_driveid.
Select drive you want to use
Choose a number from below, or type in your own value of type string.
Press Enter for the default (b!TkGKJU0VKEG-NbexVFnj-iFo7o78Q5NMmA3ZQmA1zGh4Eu8SeRVNQ4AUQbcy8iG6).
 1 / Dokumente (business)
   \ (b!TkGKJU0VKEG-NbexVFnj-iFo7o78Q5NMmA3ZQmA1zGh4Eu8SeRVNQ4AUQbcy8iG6)
config_driveid> 1

Drive OK?

Found drive "root" of type "business"
URL: https://yellowfox-my.sharepoint.com/personal/lucas_graf_yellowfox_onmicrosoft_com/Documents

y) Yes (default)
n) No
y/n> y
```

## Backup Bash Script
#! TODO: Use check to only stop containers if changes detected

```
#!/bin/bash
#################
# Konfiguration #
#################

# Verzeichnis, das gesichert werden soll
source_dir="/docker"
# Verzeichnis, in dem die Backups gespeichert werden sollen
backup_dir="/backup"
# Aktuelles Datum und Uhrzeit
current_datetime=$(date +"%Y%m%d-%H%M%S")
# Initialer Name für das Backup-Archiv
backup_filename="${current_datetime}_nb001.tar"
# Füge den Dateinamen zusammen
backup_fullpath="${backup_dir}/${backup_filename}"
# Upload Ziel
dest="docker_to_onedrive:/backup"
# Behalte Backups x-Tage
keepdays="7"

# Array von Ordnern im $source_dir die gesichert werden sollen
declare -a containers=("ghost" "netcup" "npm" "sponsorblock")


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
   cd /docker/$i
   docker-compose down
   # Archiv, Rekursiv, Überschreibe neuere Dateien, Kopiere keine log Dateien, Quelle, Ziel
   rsync --archive --recursive --update --exclude=*.log* /docker/$i /backup/working/$i
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
find /backup -maxdepth 1 -mtime +$keepdays -type f -name '*.tar*' -exec rm -f {} \

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
```

<br/>
<br/>

[Jump to parent file](README.md)