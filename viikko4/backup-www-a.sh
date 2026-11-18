#!/bin/bash
set -u
# Varmuuskopioi A:n /var/www/html B:lle aikaleimattuun kansioon

#--- Asetukset ---
SRC="ubuntu@192.168.1.170:/var/www/html/"
BACKUP_DIR="/var/backups/www-a"
KEY="/root/.ssh/sync_ed25519"
LOG="$BACKUP_DIR/backup.log"
KEEP=24

# --- Tämän ajon kohde ---
TS=$(date +%F_%H%M)
DEST="$BACKUP_DIR/$TS"

echo "Lähde: $SRC"
echo "Kohde: $DEST"

# --- Kopiointi ---
rsync -a -e "ssh -i $KEY" "$SRC" "$DEST/" 2>> "$LOG" 
RC=$?

# --- Kirjaus lokiin ---
if [ "$RC" -eq 0 ]; then
    echo "$(date '+%F %T') OK  $DEST" >> "$LOG"
else
    echo "$(date '+%F %T') FAIL rsync exit code $RC" >> "$LOG"
    rm -rf -- "$DEST"
    exit 1
fi

# --- Vanhojen varmuuskopioiden poisto ---
ls -1d "$BACKUP_DIR"/20??-??-??_???? | head -n -"$KEEP" | xargs -r rm -rf --